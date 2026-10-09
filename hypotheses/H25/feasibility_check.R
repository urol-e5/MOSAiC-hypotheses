# H25 feasibility counts for completing the pre-registration. Computes pair
# counts, scaffold spans and per-feature expression mean and residual SD only.
# No correlation between any two features is computed.
# Run from the repo root: Rscript hypotheses/H25/feasibility_check.R

source("R/load.R")
source("R/expression.R")
source("R/neighbors.R")
out_dir <- "hypotheses/H25/output/feasibility"
dir.create(out_dir, showWarnings = FALSE, recursive = TRUE)

design <- load_design()
species_all <- c("Apul", "Peve", "Ptuh")
bins <- c(2000, 10000, 50000, 100000)
bin_labels <- c("2-10 kb", "10-50 kb", "50-100 kb")

resid_sd <- function(m, info) {
  X <- model.matrix(~ factor(colony) + factor(timepoint), data = info)
  r <- t(qr.resid(qr(X), t(m)))
  sqrt(rowSums(r^2) / (ncol(m) - ncol(X)))
}

one_species <- function(sp) {
  ids <- design |> filter(species == sp, has_genes %in% TRUE, has_lncrna %in% TRUE) |> pull(sample_id)
  g <- prep_vst(load_genes(sp) |> select(feature_id, any_of(ids)), design)
  l <- prep_vst(load_lncrna(sp) |> select(feature_id, any_of(ids)), design)
  ids <- intersect(colnames(g$vst), colnames(l$vst))
  G <- g$vst[, ids]; L <- l$vst[, ids]
  info <- design_for(G, design)
  gc <- load_gene_coords(sp) |> filter(feature_id %in% rownames(G))
  lc <- lncrna_coords(sp) |> filter(feature_id %in% rownames(L))
  feat <- bind_rows(tibble(feature_id = rownames(G), class = "gene", mean = rowMeans(G), rsd = resid_sd(G, info)),
                    tibble(feature_id = rownames(L), class = "lncrna", mean = rowMeans(L), rsd = resid_sd(L, info)))
  span <- bind_rows(gc, lc) |> group_by(chrom) |> summarise(span = max(end), features = n(), .groups = "drop")
  lg <- neighbor_pairs(lc, gc, max_dist = 100000, bins = c(0, bins), bin_labels = c("0-2 kb", bin_labels)) |> mutate(class = "lncRNA-gene")
  gg <- neighbor_pairs(gc, gc, same = TRUE, max_dist = 100000, bins = c(0, bins), bin_labels = c("0-2 kb", bin_labels)) |> mutate(class = "gene-gene")
  pairs <- bind_rows(lg, gg) |> filter(!overlap, gap > 2000) |> left_join(span |> select(chrom, span), by = "chrom")
  # Matching retention (covariates only): stratum = gap tertile x anchor-gene
  # mean tertile x partner mean q x partner residual-SD q, within bin; a
  # stratum is kept if it holds >= 3 lncRNA-gene pairs and >= 3 gene-gene
  # orientations. q = quintiles, then tertiles as the fallback level.
  cut_q <- function(x, ref, k) findInterval(x, quantile(ref, seq(0, 1, length.out = k + 1)[-c(1, k + 1)]), left.open = TRUE) + 1
  fm <- setNames(feat$mean, feat$feature_id); fr <- setNames(feat$rsd, feat$feature_id)
  gmean <- feat$mean[feat$class == "gene"]
  orient <- bind_rows(lg |> filter(!overlap, gap > 2000) |> transmute(class, bin, gap, anchor = b, partner = a),
                      gg |> filter(!overlap, gap > 2000) |> transmute(class, bin, gap, anchor = a, partner = b),
                      gg |> filter(!overlap, gap > 2000) |> transmute(class, bin, gap, anchor = b, partner = a)) |>
    group_by(bin) |> mutate(gap_t = cut_q(gap, gap, 3)) |> ungroup() |>
    mutate(anchor_t = cut_q(fm[anchor], gmean, 3))
  retention <- bind_rows(lapply(c(quintile = 5, tertile = 3), function(k) {
    o <- orient |> mutate(pm = cut_q(fm[partner], feat$mean, k), pr = cut_q(fr[partner], feat$rsd, k))
    s <- o |> count(bin, gap_t, anchor_t, pm, pr, class) |> tidyr::pivot_wider(names_from = class, values_from = n, values_fill = 0) |>
      mutate(keep = `lncRNA-gene` >= 3 & `gene-gene` >= 3)
    s |> group_by(bin) |> summarise(strata = n(), strata_kept = sum(keep),
                                    lncrna_gene_pairs_kept = sum(`lncRNA-gene`[keep]), lncrna_gene_frac_kept = sum(`lncRNA-gene`[keep]) / sum(`lncRNA-gene`),
                                    gene_gene_orient_kept = sum(`gene-gene`[keep]), .groups = "drop") |>
      mutate(level = names(k), .before = 1)
  }), .id = NULL) |> mutate(species = sp, .before = 1)
  list(
    retention = retention,
    n = tibble(species = sp, samples = length(ids), colonies = n_distinct(info$colony),
               genes = nrow(G), lncrna = nrow(L), genes_with_coords = nrow(gc), lncrna_with_coords = nrow(lc),
               scaffolds_with_features = nrow(span)),
    bins = pairs |> count(class, bin, name = "pairs") |>
      left_join(pairs |> group_by(class, bin) |> summarise(scaffolds = n_distinct(chrom), median_span_kb = median(span) / 1000, .groups = "drop"),
                by = c("class", "bin")) |> mutate(species = sp, .before = 1),
    span = span |> mutate(species = sp, .before = 1),
    feat_summary = feat |> group_by(class) |>
      summarise(features = n(), mean_q05 = quantile(mean, 0.05), mean_q50 = median(mean), mean_q95 = quantile(mean, 0.95),
                rsd_q05 = quantile(rsd, 0.05), rsd_q50 = median(rsd), rsd_q95 = quantile(rsd, 0.95), .groups = "drop") |>
      mutate(species = sp, .before = 1),
    # share of lncRNAs whose mean vst lies within the central 90% of gene means,
    # a rough measure of how much matching on expression level is possible
    overlap = tibble(species = sp,
                     lncrna_within_gene_mean_q05_q95 = mean(feat$mean[feat$class == "lncrna"] >= quantile(feat$mean[feat$class == "gene"], 0.05) &
                                                          feat$mean[feat$class == "lncrna"] <= quantile(feat$mean[feat$class == "gene"], 0.95)),
                     lncrna_within_gene_rsd_q05_q95 = mean(feat$rsd[feat$class == "lncrna"] >= quantile(feat$rsd[feat$class == "gene"], 0.05) &
                                                         feat$rsd[feat$class == "lncrna"] <= quantile(feat$rsd[feat$class == "gene"], 0.95))),
    span_cut = pairs |> group_by(class) |>
      summarise(pairs = n(), on_span_ge_250kb = mean(span >= 250000), on_span_ge_500kb = mean(span >= 500000),
                on_span_ge_1mb = mean(span >= 1e6), .groups = "drop") |> mutate(species = sp, .before = 1)
  )
}

res <- lapply(setNames(species_all, species_all), one_species)
for (k in c("n", "bins", "feat_summary", "overlap", "span_cut", "retention")) {
  x <- bind_rows(lapply(res, `[[`, k))
  readr::write_csv(x, file.path(out_dir, paste0(k, ".csv")))
  cat("\n==", k, "\n"); print(as.data.frame(x), digits = 3)
}
