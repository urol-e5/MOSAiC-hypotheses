# Variance partitioning shared by H01 and H04.

# Per-feature variance fractions. `m` is features x samples, `info` the matching
# design rows. Returns a tibble with feature_id and one column per component.
# Features are fitted in blocks of `chunk` rows with gc() between blocks: forked
# workers otherwise each grow to hold a copy of a large matrix (H04 Ptuh, 1.8 M
# CpGs, swapped a 16 GB machine with 7 workers). Each feature's fit is
# independent, so chunking does not change results.
fit_varpart <- function(m, info, form = ~ (1 | colony) + (1 | timepoint) + (1 | site),
                        BPPARAM = BiocParallel::SerialParam(), chunk = 1e5) {
  info <- as.data.frame(info) |> dplyr::mutate(dplyr::across(c(colony, timepoint, site), factor))
  rownames(info) <- colnames(m)
  blocks <- split(seq_len(nrow(m)), ceiling(seq_len(nrow(m)) / chunk))
  dplyr::bind_rows(lapply(seq_along(blocks), function(b) {
    if (length(blocks) > 1) message("fit_varpart: block ", b, "/", length(blocks), " ", format(Sys.time()))
    vp <- variancePartition::fitExtractVarPartModel(m[blocks[[b]], , drop = FALSE], form, info, BPPARAM = BPPARAM)
    out <- tibble::as_tibble(as.data.frame(vp), rownames = "feature_id")
    rm(vp); gc(verbose = FALSE)
    out
  }))
}

# Bootstrap (over features) 95% CIs on the median of each component, per
# `group` column value. Returns group, component, median, lo, hi.
boot_median_ci <- function(vp, components = c("colony", "timepoint"), B = 1000, group = "species") {
  dplyr::bind_rows(lapply(split(vp, vp[[group]]), function(d) {
    n <- nrow(d)
    est <- sapply(components, function(k) median(d[[k]]))
    bs <- replicate(B, { i <- sample.int(n, n, replace = TRUE); sapply(components, function(k) median(d[[k]][i])) })
    bs <- matrix(bs, nrow = length(components), dimnames = list(components, NULL))
    out <- tibble::tibble(g = d[[group]][1], component = components, median = est,
                          lo = apply(bs, 1, quantile, 0.025), hi = apply(bs, 1, quantile, 0.975))
    names(out)[1] <- group
    out
  }))
}
