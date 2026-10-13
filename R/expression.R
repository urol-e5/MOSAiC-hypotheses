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

# Frozen count normalization and VST shared by held-out prediction analyses.
geo_means <- function(m) exp(rowMeans(log(m)))

# Median-of-ratios factors on one frozen training scale. DESeq2's
# estimateSizeFactorsForMatrix(..., geoMeans = gm) recenters every supplied
# batch, which would put held-out samples on their own scale.
fold_size_factors <- function(train, test) {
  gm <- geo_means(train)
  keep <- is.finite(gm) & gm > 0
  if (!any(keep)) stop("No genes with positive training geometric means")
  raw_factors <- function(m) apply(m[keep, , drop = FALSE], 2, function(x) {
    positive <- is.finite(x) & x > 0
    exp(median(log(x[positive]) - log(gm[keep][positive])))
  })
  sf_train <- raw_factors(train)
  sf_test <- raw_factors(test)
  if (any(!is.finite(c(sf_train, sf_test)) | c(sf_train, sf_test) <= 0)) {
    stop("Non-finite or non-positive fold size factors")
  }
  training_scale <- exp(mean(log(sf_train)))
  list(train = sf_train / training_scale, test = sf_test / training_scale)
}

# DESeq2's local VST also calibrates its integral using the supplied batch.
# Freeze those quantities on training data, following getVarianceStabilizedData
# in DESeq2 1.42.1. Parametric and mean fits already use fixed functions.
frozen_local_vst <- function(dds) {
  q <- DESeq2::counts(dds, normalized = TRUE)
  xg <- sinh(seq(asinh(0), asinh(max(q)), length.out = 1000))[-1]
  noise <- mean(1 / DESeq2::sizeFactors(dds))
  variance <- DESeq2::dispersionFunction(dds)(xg) * xg^2 + noise * xg
  integrand <- 1 / sqrt(variance)
  integral <- splinefun(asinh((xg[-1] + xg[-length(xg)]) / 2),
                        cumsum(diff(xg) * (integrand[-1] + integrand[-length(integrand)]) / 2))
  h <- quantile(rowMeans(q), c(0.95, 0.999))
  eta <- diff(log2(h)) / diff(integral(asinh(h)))
  xi <- log2(h[1]) - eta * integral(asinh(h[1]))
  function(q) {
    out <- eta * integral(asinh(q)) + xi
    dim(out) <- dim(q)
    dimnames(out) <- dimnames(q)
    out
  }
}

# Fit size factors and dispersion trend on `train` counts; transform train
# and test. `disp_rows`: rows used for the dispersion trend (and returned).
norm_fold <- function(train, test, disp_rows = rownames(train)) {
  sf <- fold_size_factors(train, test)
  dds <- DESeq2::DESeqDataSetFromMatrix(train[disp_rows, , drop = FALSE], data.frame(row.names = colnames(train)), ~ 1)
  DESeq2::sizeFactors(dds) <- sf$train
  dds <- suppressMessages(DESeq2::estimateDispersions(dds, quiet = TRUE))
  dte <- DESeq2::DESeqDataSetFromMatrix(test[disp_rows, , drop = FALSE], data.frame(row.names = colnames(test)), ~ 1)
  DESeq2::sizeFactors(dte) <- sf$test
  DESeq2::dispersionFunction(dte) <- DESeq2::dispersionFunction(dds)
  if (identical(attr(DESeq2::dispersionFunction(dds), "fitType"), "local")) {
    transform <- frozen_local_vst(dds)
    vtr <- transform(DESeq2::counts(dds, normalized = TRUE))
    vte <- transform(DESeq2::counts(dte, normalized = TRUE))
  } else {
    vtr <- SummarizedExperiment::assay(DESeq2::varianceStabilizingTransformation(dds, blind = FALSE))
    vte <- SummarizedExperiment::assay(DESeq2::varianceStabilizingTransformation(dte, blind = FALSE))
  }
  list(train = vtr, test = vte)
}
