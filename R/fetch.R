# Fetch upstream files listed in config/upstream.yml and record checksums.
#
# Usage (from repo root):
#   Rscript R/fetch.R            # download anything missing, verify against lock
#   Rscript R/fetch.R --force    # re-download everything, still verify against lock
#   Rscript R/fetch.R --refresh-lock # explicitly accept current files / new entries
#   Rscript R/fetch.R --force --refresh-lock # download and accept a new baseline
#   Rscript R/fetch.R --check    # re-download to temp, compare md5 to lock, exit 1 on drift
#
# Also sourced by _targets.R; the functions below are the API.

suppressPackageStartupMessages({
  library(yaml)
  library(digest)
})

options(timeout = max(1800, getOption("timeout")))  # gannet can be slow on 25 MB files

manifest_path <- "config/upstream.yml"
lock_path     <- "config/upstream.lock.yml"

read_manifest <- function(path = manifest_path) yaml::read_yaml(path)

read_lock <- function(path = lock_path) {
  if (!file.exists(path)) return(list())
  l <- yaml::read_yaml(path)
  if (is.null(l$files)) list() else setNames(l$files, vapply(l$files, `[[`, "", "id"))
}

md5_file <- function(path) digest::digest(path, algo = "md5", file = TRUE)

download_one <- function(url, dest, quiet = TRUE) {
  dir.create(dirname(dest), recursive = TRUE, showWarnings = FALSE)
  tmp <- paste0(dest, ".part")
  on.exit(if (file.exists(tmp)) unlink(tmp), add = TRUE)
  ok <- tryCatch({
    utils::download.file(url, tmp, mode = "wb", quiet = quiet, method = "libcurl")
    TRUE
  }, error = function(e) { message("  download failed: ", conditionMessage(e)); FALSE })
  if (!ok || !file.exists(tmp) || file.info(tmp)$size == 0) return(FALSE)
  file.rename(tmp, dest)
  TRUE
}

# Download every manifest entry (if missing or force), return a data.frame of
# id, dest, md5, bytes, fetched_on. Normal runs never modify the lock.
# Updating or creating a baseline requires refresh_lock = TRUE.
fetch_all <- function(force = FALSE, manifest = read_manifest(), write_lock = TRUE,
                      refresh_lock = FALSE) {
  lock <- read_lock()
  if (!refresh_lock) {
    missing <- vapply(manifest$files, function(f) is.null(lock[[f$id]]$md5), logical(1))
    if (any(missing)) stop("Files missing from checksum lock: ",
                           paste(vapply(manifest$files[missing], `[[`, "", "id"), collapse = ", "),
                           ". Review inputs, then run `Rscript R/fetch.R --refresh-lock`.")
  }
  rows <- lapply(manifest$files, function(f) {
    need <- force || !file.exists(f$dest)
    if (need) {
      message("fetching ", f$id, " <- ", f$url)
      if (!download_one(f$url, f$dest)) stop("Could not fetch ", f$id)
    }
    md5 <- md5_file(f$dest)
    prev <- lock[[f$id]]
    fetched_on <- if (!need && !is.null(prev$fetched_on)) prev$fetched_on else as.character(Sys.Date())
    if (!is.null(prev$md5) && prev$md5 != md5) {
      if (!refresh_lock) stop("Checksum mismatch for ", f$id, " (expected ", prev$md5,
                              ", got ", md5, "). Lock unchanged. Review the change before running ",
                              "`Rscript R/fetch.R --refresh-lock`.")
      message("  Refreshing: ", f$id, " md5 changed (", prev$md5, " -> ", md5, ")")
    }
    data.frame(id = f$id, layer = f$layer, species = f$species, dest = f$dest,
               md5 = md5, bytes = file.info(f$dest)$size,
               fetched_on = fetched_on, stringsAsFactors = FALSE)
  })
  out <- do.call(rbind, rows)
  if (write_lock && refresh_lock) write_lock_file(out, manifest)
  out
}

write_lock_file <- function(df, manifest = read_manifest(), path = lock_path) {
  files <- lapply(seq_len(nrow(df)), function(i) as.list(df[i, c("id", "md5", "bytes", "fetched_on")]))
  yaml::write_yaml(list(
    mosaic_commit = manifest$mosaic$commit,
    lock_updated  = as.character(Sys.Date()),
    files = files
  ), path)
  invisible(path)
}

# Re-download every file to a temp dir and compare against the lock.
# Returns a data.frame with one row per drifted/missing file (0 rows = clean).
check_drift <- function(manifest = read_manifest()) {
  lock <- read_lock()
  if (!length(lock)) stop("No lock file; review inputs and run `Rscript R/fetch.R --refresh-lock` first.")
  tmpdir <- tempfile("upstream-check-")
  dir.create(tmpdir)
  on.exit(unlink(tmpdir, recursive = TRUE), add = TRUE)
  rows <- lapply(manifest$files, function(f) {
    dest <- file.path(tmpdir, basename(f$dest))
    ok <- download_one(f$url, dest)
    new_md5 <- if (ok) md5_file(dest) else NA_character_
    old_md5 <- lock[[f$id]]$md5
    status <- if (!ok) "unreachable" else if (is.null(old_md5)) "not-in-lock" else if (identical(old_md5, new_md5)) "ok" else "changed"
    data.frame(id = f$id, url = f$url, status = status,
               lock_md5 = if (is.null(old_md5)) NA_character_ else old_md5,
               remote_md5 = new_md5, stringsAsFactors = FALSE)
  })
  res <- do.call(rbind, rows)
  res[res$status != "ok", , drop = FALSE]
}

if (sys.nframe() == 0L) {
  args <- commandArgs(trailingOnly = TRUE)
  if ("--check" %in% args) {
    drift <- check_drift()
    if (nrow(drift)) {
      cat("UPSTREAM DRIFT DETECTED\n")
      print(drift, row.names = FALSE)
      utils::write.csv(drift, "upstream-drift.csv", row.names = FALSE)
      quit(status = 1)
    }
    cat("Upstream clean: all", length(read_manifest()$files), "files match the lock.\n")
  } else {
    res <- fetch_all(force = "--force" %in% args, refresh_lock = "--refresh-lock" %in% args)
    print(res[, c("id", "bytes", "md5", "fetched_on")], row.names = FALSE)
  }
}
