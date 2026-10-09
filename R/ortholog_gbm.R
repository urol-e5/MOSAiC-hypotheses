# Per-species ortholog x sample expression and gene-body methylation, shared by
# H23 and H24. Needs R/load.R, R/expression.R and R/methylation.R.

.ortholog_gene_key <- c(Apul = "apul_gene", Peve = "peve_gene", Ptuh = "ptuh_gene")

# Ortholog group -> species gene id, the same first-gene-per-group choice that
# genes_by_ortholog() makes, kept with both ids.
ortholog_map <- function(sp, genes = load_genes(sp), orthologs = load_orthologs()) {
  og <- orthologs |> select(group_id, gene = all_of(.ortholog_gene_key[[sp]])) |>
    filter(!is.na(gene)) |> distinct(gene, .keep_all = TRUE)
  tibble(gene = genes$feature_id) |> inner_join(og, by = "gene") |> distinct(group_id, .keep_all = TRUE)
}

# Samples with both CpG and gene data; vst of three-way orthologs (H01
# filter); gene-body methylation with >= min_cpg CpGs. Eligible genes pass
# both. Returns list(species, info, vst, gbm, genes, n): vst and gbm are
# eligible-gene x sample matrices in the same row order as `genes`
# (group_id, gene, n_cpg, len).
prep_ortholog_species <- function(sp, design = load_design(), orthologs = load_orthologs(), min_cpg = 5) {
  cpg <- as_count_matrix(load_cpg(sp))
  ids <- intersect(colnames(cpg), design$sample_id[design$has_cpg %in% TRUE & design$has_genes %in% TRUE])
  ex <- prep_vst(genes_by_ortholog(sp, orthologs = orthologs) |> select(feature_id, all_of(ids)), design)
  ids <- intersect(ids, colnames(ex$vst))
  coords <- load_gene_coords(sp)
  gb <- gene_body_methylation(cpg[, ids, drop = FALSE], coords, min_cpg = min_cpg)
  map <- ortholog_map(sp, load_genes(sp), orthologs) |>
    filter(group_id %in% rownames(ex$vst), gene %in% rownames(gb$gbm)) |>
    left_join(coords |> transmute(gene = feature_id, len = end - start + 1), by = "gene")
  stopifnot(!anyNA(map$len))
  info <- design_for(ex$vst[, ids, drop = FALSE], design)
  list(species = sp, info = info,
       vst = ex$vst[map$group_id, ids, drop = FALSE],
       gbm = gb$gbm[map$gene, ids, drop = FALSE],
       genes = tibble(species = sp, group_id = map$group_id, gene = map$gene,
                      n_cpg = unname(gb$n_cpg[map$gene]), len = map$len),
       n = tibble(species = sp, samples = length(ids), colonies = n_distinct(info$colony),
                  cpg_sites = nrow(cpg), orthologs_expressed = nrow(ex$vst),
                  genes_with_5_cpg = nrow(gb$gbm), eligible = nrow(map),
                  median_cpg_per_gene = median(gb$n_cpg[map$gene])))
}

# Row means over colonies of per-colony means: each colony counts once
# whatever its number of samples. `cols` may repeat (bootstrap); `colony`
# labels them.
colony_mean <- function(m, cols = seq_len(ncol(m)), colony) {
  rowMeans(sapply(split(seq_along(cols), colony), function(j) rowMeans(m[, cols[j], drop = FALSE])))
}

# One colony-bootstrap draw for a prep_ortholog_species() result: colonies
# with replacement within site, duplicates relabeled as distinct colonies.
draw_colonies <- function(d) {
  cols_by_col <- split(seq_len(ncol(d$vst)), d$info$colony)
  site <- d$info$site[match(names(cols_by_col), d$info$colony)]
  pick <- unlist(lapply(split(names(cols_by_col), site), function(cs) sample(cs, length(cs), replace = TRUE)))
  cols <- unlist(lapply(seq_along(pick), function(k) cols_by_col[[pick[k]]]))
  lab <- unlist(lapply(seq_along(pick), function(k) rep(paste0(pick[k], "_b", k), length(cols_by_col[[pick[k]]]))))
  list(cols = cols, colony = lab)
}
