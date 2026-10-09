# Shared expression preprocessing. H01 defines the filter; H02, H04, H08 and
# H09 pre-register "filtered as in H01", so it lives here rather than in a qmd.

# Keep features with >= min_count counts in >= min_frac of samples.
filter_expressed <- function(m, min_count = 10, min_frac = 0.25) {
  keep <- rowMeans(m >= min_count) >= min_frac
  m[keep, , drop = FALSE]
}

# Count tibble -> filtered integer count matrix for samples with `has_genes`.
# Returns list(counts = matrix, info = design rows, n_raw = features in).
prep_counts <- function(counts, design = load_design(), min_count = 10, min_frac = 0.25) {
  m <- if (is.matrix(counts)) counts else as_count_matrix(counts)
  info <- design_for(m, design)
  keep <- info$has_genes %in% TRUE
  m <- round(m[, keep, drop = FALSE])
  info <- info[keep, ]
  n_raw <- nrow(m)
  list(counts = filter_expressed(m, min_count, min_frac), info = info, n_raw = n_raw)
}

# As prep_counts(), plus a blind DESeq2 vst. Returns list(vst, info, n_raw).
prep_vst <- function(counts, design = load_design(), min_count = 10, min_frac = 0.25) {
  p <- prep_counts(counts, design, min_count, min_frac)
  dds <- DESeq2::DESeqDataSetFromMatrix(p$counts, colData = as.data.frame(p$info), design = ~ 1)
  v <- SummarizedExperiment::assay(DESeq2::vst(dds, blind = TRUE))
  list(vst = v, info = p$info, n_raw = p$n_raw)
}

# DESeq2 timepoint fit used by H02 and H03: ~ colony + timepoint. Colony is a
# blocking factor; timepoint levels are TP1..TP4 with TP1 as reference.
# test = "LRT" (H02) tests against ~ colony; test = "Wald" (H03) gives per-
# contrast p-values and supports lfcShrink(type = "apeglm"). Betas are the same.
fit_timepoint_deseq <- function(counts, info, test = c("LRT", "Wald")) {
  test <- match.arg(test)
  cd <- as.data.frame(info) |>
    dplyr::mutate(colony = factor(colony), timepoint = factor(timepoint, levels = c("TP1", "TP2", "TP3", "TP4")))
  dds <- DESeq2::DESeqDataSetFromMatrix(counts, colData = cd, design = ~ colony + timepoint)
  if (test == "LRT") DESeq2::DESeq(dds, test = "LRT", reduced = ~ colony, quiet = TRUE)
  else DESeq2::DESeq(dds, test = "Wald", quiet = TRUE)
}

# miRNA library QC (decision D-011): drop samples whose total miRNA count is
# below min_reads. Upstream Peve has eight libraries with 0 to 351 reads in
# total and Ptuh one with 401, against species medians of about 20k and 72k.
mirna_qc_samples <- function(m, min_reads = 1000) {
  colnames(m)[colSums(m) >= min_reads]
}

# Peve features on the scaffold_167 locus that dominates Peve libraries
# (decision D-017). Analyses that exclude it say so in hypothesis.md.
peve_dominant_locus <- c(paste0("lncRNA_", 4889:4893), paste0("Peve_0000961", 6:9))
