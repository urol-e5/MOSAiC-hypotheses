# Genomic neighbor pairs, shared by H17 and H18.

# All pairs of `xa` x `xb` intervals on the same scaffold within `max_dist`
# bp, with gap distance between nearest ends (<= 0 means overlap). `xa`, `xb`
# have feature_id, chrom, start, end. `same = TRUE` drops self-pairs and keeps
# each unordered pair once (gene-gene). `bins` / `bin_labels` cut the gap.
neighbor_pairs <- function(xa, xb, same = FALSE, max_dist = 100000,
                           bins = c(0, 2000, 10000, 50000, 100000),
                           bin_labels = c("0-2 kb", "2-10 kb", "10-50 kb", "50-100 kb")) {
  ga <- GenomicRanges::GRanges(xa$chrom, IRanges::IRanges(xa$start, xa$end))
  gb <- GenomicRanges::GRanges(xb$chrom, IRanges::IRanges(xb$start, xb$end))
  h <- GenomicRanges::findOverlaps(ga, gb, maxgap = max_dist, ignore.strand = TRUE)
  i <- S4Vectors::queryHits(h); j <- S4Vectors::subjectHits(h)
  if (same) { keep <- i < j; i <- i[keep]; j <- j[keep] }
  tibble::tibble(a = xa$feature_id[i], b = xb$feature_id[j], chrom = xa$chrom[i],
                 gap = pmax(xa$start[i], xb$start[j]) - pmin(xa$end[i], xb$end[j])) |>
    dplyr::filter(gap <= max_dist) |>
    dplyr::mutate(overlap = gap <= 0, bin = cut(gap, bins, labels = bin_labels, right = TRUE))
}

# lncRNA feature table -> the coordinate shape of load_gene_coords().
lncrna_coords <- function(species) {
  load_lncrna_features(species) |> dplyr::transmute(feature_id, chrom = Chr, start = Start, end = End)
}
