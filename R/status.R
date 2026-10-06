# Build the hypothesis status board from the YAML front matter of every
# hypotheses/Hxx*/hypothesis.md.

suppressPackageStartupMessages({ library(yaml); library(tibble); library(dplyr) })

read_front_matter <- function(path) {
  lines <- readLines(path, warn = FALSE)
  fence <- which(trimws(lines) == "---")
  if (length(fence) < 2) return(NULL)
  yaml::yaml.load(paste(lines[(fence[1] + 1):(fence[2] - 1)], collapse = "\n"))
}

hypothesis_board <- function(dir = "hypotheses") {
  files <- list.files(dir, pattern = "^hypothesis\\.md$", recursive = TRUE, full.names = TRUE)
  files <- files[!grepl("_template", files)]
  rows <- lapply(files, function(f) {
    fm <- read_front_matter(f)
    if (is.null(fm)) return(NULL)
    tibble(id = fm$id %||% basename(dirname(f)),
           tier = as.integer(fm$tier %||% NA),
           title = fm$title %||% "",
           status = fm$status %||% "planned",
           layers = list(unlist(fm$layers)),
           species = list(unlist(fm$species)),
           depends_on = list(unlist(fm$depends_on)),
           dir = basename(dirname(f)))
  })
  bind_rows(rows) |> arrange(tier, id)
}

`%||%` <- function(a, b) if (is.null(a)) b else a
