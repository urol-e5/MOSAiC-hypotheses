# Loaders for harmonized data. Every analysis should start from these, never
# from data/raw. All matrices are features x samples with a `feature_id`
# column; sample columns are canonical ids ("ACR-139-TP1").

suppressPackageStartupMessages({ library(readr); library(dplyr); library(tibble) })

.derived <- function(name, dir = "data/derived") {
  p <- file.path(dir, paste0(name, ".csv"))
  if (!file.exists(p)) stop("Missing ", p, ". Run `Rscript R/fetch.R && Rscript R/harmonize.R` (or tar_make()).")
  readr::read_csv(p, show_col_types = FALSE, progress = FALSE)
}

load_design      <- function() readr::read_csv("config/design.csv", show_col_types = FALSE)
load_genes       <- function(species) .derived(paste0("genes_", species))
load_mirna       <- function(species) .derived(paste0("mirna_", species))
load_lncrna      <- function(species) .derived(paste0("lncrna_", species))
load_lncrna_features <- function(species) .derived(paste0("lncrna_", species, "_features"))
load_cpg         <- function(species) .derived(paste0("cpg_", species))
load_metabolomics <- function() .derived("metabolomics")
load_lipidomics  <- function() .derived("lipidomics")
load_physiology  <- function() .derived("physiology")
load_its2        <- function() .derived("its2")
load_orthologs   <- function(three_way_only = TRUE) .derived(if (three_way_only) "orthologs_three_way" else "orthologs_all")
load_temperature_daily <- function() .derived("temperature_daily")
load_gene_coords <- function(species) .derived(paste0("gene_coords_", species))

# Convert a feature x sample tibble to a numeric matrix with rownames.
as_count_matrix <- function(df) {
  m <- as.matrix(df[, setdiff(names(df), "feature_id")])
  rownames(m) <- df$feature_id
  storage.mode(m) <- "numeric"
  m
}

# Design rows for the columns of a matrix, in matching order.
design_for <- function(m, design = load_design()) {
  ids <- if (is.data.frame(m)) setdiff(names(m), "feature_id") else colnames(m)
  d <- design[match(ids, design$sample_id), ]
  if (anyNA(d$sample_id)) stop("Samples missing from design: ", paste(ids[is.na(d$sample_id)], collapse = ", "))
  d
}

# Restrict a species' gene matrix to three-way orthologs; rownames become group_id.
genes_by_ortholog <- function(species, genes = load_genes(species), orthologs = load_orthologs()) {
  key <- switch(species, Apul = "apul_gene", Peve = "peve_gene", Ptuh = "ptuh_gene")
  og <- orthologs |> select(group_id, gene = all_of(key)) |> filter(!is.na(gene)) |> distinct(gene, .keep_all = TRUE)
  out <- genes |> inner_join(og, by = c(feature_id = "gene")) |>
    distinct(group_id, .keep_all = TRUE) |>
    select(group_id, everything(), -feature_id)
  names(out)[1] <- "feature_id"
  out
}
