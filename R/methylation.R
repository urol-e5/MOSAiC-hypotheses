# CpG -> gene-body aggregation shared by H05 and H06.

# CpG ids are "CpG_<chrom>_<pos>"; chrom names contain underscores, so split
# at the last one.
parse_cpg_id <- function(id) {
  x <- sub("^CpG_", "", id)
  tibble::tibble(feature_id = id, chrom = sub("_[0-9]+$", "", x), pos = as.integer(sub("^.*_", "", x)))
}

# Gene-body methylation: for each gene, the mean percent methylation of the
# CpGs inside its start..end span, per sample. A CpG inside overlapping genes
# counts for each. `cpg` is a CpG x sample matrix (rownames CpG ids), `coords`
# from load_gene_coords(). Returns list(gbm = gene x sample matrix,
# n_cpg = named vector) for genes with >= min_cpg CpGs.
gene_body_methylation <- function(cpg, coords, min_cpg = 5) {
  pos <- parse_cpg_id(rownames(cpg))
  gr_cpg <- GenomicRanges::GRanges(pos$chrom, IRanges::IRanges(pos$pos, width = 1))
  gr_gene <- GenomicRanges::GRanges(coords$chrom, IRanges::IRanges(coords$start, coords$end))
  hits <- GenomicRanges::findOverlaps(gr_cpg, gr_gene, ignore.strand = TRUE)
  map <- Matrix::sparseMatrix(i = S4Vectors::subjectHits(hits), j = S4Vectors::queryHits(hits), x = 1,
                              dims = c(nrow(coords), nrow(cpg)))
  n <- Matrix::rowSums(map)
  keep <- n >= min_cpg
  gbm <- as.matrix(map[keep, , drop = FALSE] %*% cpg) / n[keep]
  rownames(gbm) <- coords$feature_id[keep]
  colnames(gbm) <- colnames(cpg)
  list(gbm = gbm, n_cpg = setNames(n[keep], coords$feature_id[keep]))
}

# CpG row indices inside each gene body, by the same overlap rule as
# gene_body_methylation(). Returns a list named by coords$feature_id for the
# genes in `genes` (default all). Used by H24 to subsample CpGs per gene.
gene_cpg_index <- function(cpg_ids, coords, genes = coords$feature_id) {
  coords <- coords[coords$feature_id %in% genes, ]
  pos <- parse_cpg_id(cpg_ids)
  gr_cpg <- GenomicRanges::GRanges(pos$chrom, IRanges::IRanges(pos$pos, width = 1))
  gr_gene <- GenomicRanges::GRanges(coords$chrom, IRanges::IRanges(coords$start, coords$end))
  hits <- GenomicRanges::findOverlaps(gr_cpg, gr_gene, ignore.strand = TRUE)
  split(S4Vectors::queryHits(hits), factor(coords$feature_id[S4Vectors::subjectHits(hits)], levels = coords$feature_id))
}

# Strand-aware windows of `width` bp immediately upstream of each gene, in the
# same shape as load_gene_coords(), for gene_body_methylation(). Used by H06.
upstream_coords <- function(coords, width = 2000) {
  dplyr::mutate(coords,
    new_start = ifelse(strand == "-", end + 1, pmax(1, start - width)),
    new_end   = ifelse(strand == "-", end + width, start - 1)) |>
    dplyr::filter(new_end >= new_start) |>
    dplyr::mutate(start = new_start, end = new_end) |>
    dplyr::select(-new_start, -new_end)
}
