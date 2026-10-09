# H26 feasibility counts for completing the pre-registration. Uses
# coordinates, the design table and per-library totals only. No correlation
# between any two features is computed.
# Run from the repo root: Rscript hypotheses/H26/feasibility_check.R

source("R/load.R")
source("R/expression.R")
source("R/neighbors.R")
out_dir <- "hypotheses/H26/output/feasibility"
dir.create(out_dir, showWarnings = FALSE, recursive = TRUE)

design <- load_design()
species_all <- c("Apul", "Peve", "Ptuh")
flank <- 10000

one_species <- function(sp) {
  ids <- design |> filter(species == sp, has_genes %in% TRUE, has_lncrna %in% TRUE) |> pull(sample_id)
  drop_f <- if (sp == "Peve") peve_dominant_locus else character(0)   # D-017
  graw <- as_count_matrix(load_genes(sp)); lraw <- as_count_matrix(load_lncrna(sp))
  graw <- graw[!rownames(graw) %in% drop_f, ]; lraw <- lraw[!rownames(lraw) %in% drop_f, ]
  ids <- Reduce(intersect, list(ids, colnames(graw), colnames(lraw)))
  g <- prep_vst(load_genes(sp) |> filter(!feature_id %in% drop_f) |> select(feature_id, any_of(ids)), design)
  l <- prep_vst(load_lncrna(sp) |> filter(!feature_id %in% drop_f) |> select(feature_id, any_of(ids)), design)
  ids <- intersect(colnames(g$vst), colnames(l$vst))
  info <- design_for(g$vst[, ids], design)

  # isolation: >= 10 kb from every annotated gene (all genes, not only
  # expressed ones) and >= 10 kb of flank on both sides within the scaffold
  # span (largest feature end on the scaffold; start 1)
  gc_all <- load_gene_coords(sp); lc <- lncrna_coords(sp) |> filter(feature_id %in% rownames(l$vst))
  span <- bind_rows(gc_all, lncrna_coords(sp)) |> group_by(chrom) |> summarise(span = max(end), .groups = "drop")
  near <- neighbor_pairs(lc, gc_all, max_dist = flank, bins = c(-Inf, flank), bin_labels = "near")
  iso <- lc |> left_join(span, by = "chrom") |>
    mutate(near_gene = feature_id %in% near$a, flank_ok = start > flank & end + flank <= span,
           isolated = !near_gene & flank_ok)

  # library composition from raw gene + lncRNA counts on the same samples
  # (Peve: without the D-017 locus)
  raw <- rbind(graw[, ids], lraw[, ids])
  lib <- tibble(sample_id = ids, lib_size = colSums(raw),
                top10_frac = apply(raw, 2, function(x) sum(sort(x, decreasing = TRUE)[1:10]) / sum(x))) |>
    left_join(info |> select(sample_id, colony, site, timepoint), by = "sample_id")
  q <- quantile(lib$top10_frac, c(0.25, 0.75))
  lib <- lib |> mutate(composition_outlier_iqr = top10_frac > q[2] + 1.5 * diff(q))

  # distinct within-site permutations of whole colony trajectories, per LOCO fold
  cols <- info |> distinct(colony, site)
  perms <- bind_rows(lapply(cols$colony, function(cc) {
    tr <- cols |> filter(colony != cc) |> count(site)
    tibble(held_out = cc, training_colonies = sum(tr$n), distinct_permutations = prod(factorial(tr$n)))
  }))

  list(
    n = tibble(species = sp, samples = length(ids), colonies = n_distinct(info$colony),
               genes_filtered = nrow(g$vst), lncrna_filtered = nrow(l$vst), lncrna_with_coords = nrow(lc),
               lncrna_far_from_genes = sum(!iso$near_gene), lncrna_flank_ok = sum(iso$flank_ok),
               lncrna_isolated = sum(iso$isolated), scaffolds_with_isolated = n_distinct(iso$chrom[iso$isolated]),
               min_distinct_permutations = min(perms$distinct_permutations),
               composition_outliers_iqr = sum(lib$composition_outlier_iqr)),
    lib = lib |> mutate(species = sp, .before = 1),
    perms = perms |> mutate(species = sp, .before = 1)
  )
}

res <- lapply(setNames(species_all, species_all), one_species)
for (k in c("n", "lib", "perms")) {
  x <- bind_rows(lapply(res, `[[`, k))
  readr::write_csv(x, file.path(out_dir, paste0(k, ".csv")))
}
print(as.data.frame(bind_rows(lapply(res, `[[`, "n"))))
print(bind_rows(lapply(res, `[[`, "lib")) |> group_by(species) |>
        summarise(lib_min = min(lib_size), lib_med = median(lib_size), lib_max = max(lib_size),
                  top10_med = median(top10_frac), top10_max = max(top10_frac), outliers = sum(composition_outlier_iqr)) |> as.data.frame())
print(bind_rows(lapply(res, `[[`, "lib")) |> filter(composition_outlier_iqr) |> select(species, sample_id, lib_size, top10_frac) |> as.data.frame())
