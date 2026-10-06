# Shared expression preprocessing. H01 defines the filter; H02, H04, H08 and
# H09 pre-register "filtered as in H01", so it lives here rather than in a qmd.

# Keep features with >= min_count counts in >= min_frac of samples.
filter_expressed <- function(m, min_count = 10, min_frac = 0.25) {
  keep <- rowMeans(m >= min_count) >= min_frac
  m[keep, , drop = FALSE]
}

# Count tibble -> filtered, variance-stabilized matrix for samples with
# `has_genes`. Returns list(vst = matrix, info = design rows, n_raw = features in).
prep_vst <- function(counts, design = load_design(), min_count = 10, min_frac = 0.25) {
  m <- as_count_matrix(counts)
  info <- design_for(m, design)
  keep <- info$has_genes %in% TRUE
  m <- round(m[, keep, drop = FALSE])
  info <- info[keep, ]
  n_raw <- nrow(m)
  m <- filter_expressed(m, min_count, min_frac)
  dds <- DESeq2::DESeqDataSetFromMatrix(m, colData = as.data.frame(info), design = ~ 1)
  v <- SummarizedExperiment::assay(DESeq2::vst(dds, blind = TRUE))
  list(vst = v, info = info, n_raw = n_raw)
}
