# Harmonization: turn every upstream layer into a matrix keyed on the same
# sample IDs, and every gene identifier into the form used by the ortholog
# table. Writes data/derived/*.csv. Pure functions; no downloads here.

suppressPackageStartupMessages({
  library(readr); library(dplyr); library(tidyr); library(stringr); library(tibble)
})

# ---- Vocabulary -------------------------------------------------------------

SPECIES <- tibble::tribble(
  ~prefix, ~species, ~species_name,               ~genome_ref,
  "ACR",   "Apul",   "Acropora pulchra",          "Acropora pulchra (Conn et al. 2025)",
  "POR",   "Peve",   "Porites evermanni",         "Porites evermanni (Genoscope)",
  "POC",   "Ptuh",   "Pocillopora tuahiniensis",  "Pocillopora meandrina HIv1 (Stephens et al. 2022)"
)

TIMEPOINTS <- tibble::tribble(
  ~timepoint, ~tp_num, ~tp_month,        ~tp_date,     ~season,
  "TP1",      1L,      "January 2020",   "2020-01-15", "austral summer",
  "TP2",      2L,      "March 2020",     "2020-03-15", "austral late summer",
  "TP3",      3L,      "September 2020", "2020-09-15", "austral winter/spring",
  "TP4",      4L,      "November 2020",  "2020-11-15", "austral spring"
) |> mutate(tp_date = as.Date(tp_date))

# ---- Sample IDs -------------------------------------------------------------

# Canonical sample id is "{PREFIX}-{COLONY}-TP{n}", e.g. "ACR-139-TP1".
# Accepts every upstream variant seen so far:
#   "ACR-139-TP1", "ACR-139_TP1", "1A1_ACR-173_TP1" (plate prefix),
#   "/path/ACR-139-TP1.sorted.bam", "ACR-139-TP1...2" (readr dedup suffix),
#   "ACR-139 - timepoint1".
norm_sample_id <- function(x) {
  m <- str_match(x, "(ACR|POR|POC)[-_ ]?(\\d+)[-_ .]*(?:TP|timepoint)[-_ ]?(\\d)")
  ifelse(is.na(m[, 1]), NA_character_, sprintf("%s-%s-TP%s", m[, 2], m[, 3], m[, 4]))
}

split_sample_id <- function(sample_id) {
  m <- str_match(sample_id, "^(ACR|POR|POC)-(\\d+)-TP(\\d)$")
  tibble(sample_id = sample_id,
         prefix    = m[, 2],
         colony    = paste0(m[, 2], "-", m[, 3]),
         timepoint = paste0("TP", m[, 4])) |>
    left_join(SPECIES, by = "prefix")
}

# ---- Gene IDs ---------------------------------------------------------------

# Count matrices and the ortholog table disagree on decoration:
#   Apul: counts "FUN_002326"; orthologs "FUN_000185-T1"      -> strip "-T\\d+$"
#   Peve: counts "gene-Peve_00000032"; orthologs "Peve_00037402" -> strip "^gene-"
#   Ptuh: counts "gene-Pocillopora_meandrina_HIv1___RNAseq.g20905.t1";
#         orthologs "Pocillopora_meandrina_HIv1___RNAseq.g28886.t1"  -> strip "^gene-"
norm_gene_id <- function(x, species) {
  x <- sub("^gene-", "", x)
  if (species == "Apul") x <- sub("-T\\d+$", "", x)
  x
}

# ---- Generic wide-matrix harmonizer ----------------------------------------

# Read a features x samples matrix, rename sample columns to canonical ids,
# rename the feature column to `feature_id`, drop non-sample columns.
harmonize_matrix <- function(path, delim = ",", feature_col = 1, drop_cols = character(),
                             species = NULL, gene_ids = FALSE) {
  df <- readr::read_delim(path, delim = delim, show_col_types = FALSE, progress = FALSE,
                          name_repair = "minimal")
  if (is.numeric(feature_col)) names(df)[feature_col] <- "feature_id"   # upstream may leave it unnamed ("")
  nm <- names(df)
  feat_name <- if (is.numeric(feature_col)) "feature_id" else feature_col
  keep_meta <- setdiff(drop_cols, feat_name)
  sample_cols <- setdiff(nm, c(feat_name, keep_meta))
  canon <- norm_sample_id(sample_cols)
  if (anyNA(canon)) stop("Unparseable sample columns in ", basename(path), ": ",
                         paste(head(sample_cols[is.na(canon)], 5), collapse = ", "))
  if (anyDuplicated(canon)) {
    dups <- unique(canon[duplicated(canon)])
    stop("Duplicate sample columns after normalisation in ", basename(path), ": ",
         paste(dups, collapse = ", "), ". Decide a replicate policy in docs/decisions.md.")
  }
  if (!is.null(species)) {
    sp_of_cols <- split_sample_id(canon)$species
    if (any(sp_of_cols != species)) stop("Foreign-species samples in ", basename(path))
  }
  out <- df[, c(feat_name, sample_cols)]
  names(out) <- c("feature_id", canon)
  out$feature_id <- as.character(out$feature_id)
  if (gene_ids && !is.null(species)) out$feature_id <- norm_gene_id(out$feature_id, species)
  # order samples by colony then timepoint
  ord <- order(split_sample_id(canon)$colony, split_sample_id(canon)$timepoint)
  out <- out[, c("feature_id", canon[ord])]
  meta <- if (length(keep_meta)) df[, c(feat_name, keep_meta)] |> rename(feature_id = all_of(feat_name)) else NULL
  list(matrix = tibble::as_tibble(out), meta = meta)
}

# ---- Layer-specific wrappers ------------------------------------------------

harmonize_genes <- function(path, species) harmonize_matrix(path, ",", 1, species = species, gene_ids = TRUE)$matrix

harmonize_mirna <- function(path, species) harmonize_matrix(path, "\t", "Name", species = species)$matrix

# ShortStack Results.txt -> one row per confirmed miRNA locus (MIRNA == "Y"),
# with the raw known-miRNA annotation string (NA for novel loci). H07.
harmonize_mirna_results <- function(path) {
  readr::read_tsv(path, col_types = readr::cols(.default = "c"), progress = FALSE) |>
    filter(MIRNA == "Y") |>
    transmute(feature_id = Name, locus = Locus, major_rna = MajorRNA, dicer_call = DicerCall,
              known_mirnas = na_if(known_miRNAs, "NA"))
}

harmonize_lncrna <- function(path, species) {
  h <- harmonize_matrix(path, "\t", "Geneid",
                        drop_cols = c("Chr", "Start", "End", "Strand", "Length"),
                        species = species)
  h  # list(matrix, meta) ; meta holds coordinates
}

harmonize_cpg <- function(path, species) harmonize_matrix(path, ",", 1, species = species)$matrix

# metabolomics / lipidomics: all species in one matrix, first column unnamed
harmonize_multi_species_matrix <- function(path) harmonize_matrix(path, ",", 1)$matrix

# Physiology master: one row per colony x timepoint, many trait columns.
harmonize_physiology <- function(path) {
  df <- readr::read_csv(path, show_col_types = FALSE, progress = FALSE)
  df |>
    mutate(sample_id = norm_sample_id(paste(colony_id, timepoint))) |>
    filter(!is.na(sample_id)) |>
    select(sample_id, everything(), -any_of(c("code", "time", "sample_id.1"))) |>
    distinct(sample_id, .keep_all = TRUE)
}

# ITS2 relative abundance: one row per sample, profile columns.
harmonize_its2 <- function(path) {
  df <- readr::read_csv(path, show_col_types = FALSE, progress = FALSE)
  meta_cols <- c("sample_id", "colony_id", "colony_id_corr", "timepoint", "site", "nutrient",
                 "site_code", "month", "haplotype", "species")
  df |>
    mutate(sample_id = norm_sample_id(sample_id)) |>
    filter(!is.na(sample_id)) |>
    select(all_of(intersect(meta_cols, names(df))), everything()) |>
    distinct(sample_id, .keep_all = TRUE)
}

# Ortholog table: add canonical per-species gene ids.
harmonize_orthologs <- function(path) {
  readr::read_csv(path, show_col_types = FALSE, progress = FALSE) |>
    mutate(apul_gene = norm_gene_id(apul, "Apul"),
           peve_gene = norm_gene_id(peve, "Peve"),
           ptuh_gene = norm_gene_id(ptua, "Ptuh")) |>
    select(group_id, type, apul_gene, peve_gene, ptuh_gene, everything())
}

# Temperature: daily per-site summary (raw stays in data/raw).
# Gene coordinates from a GFF/GFF3: one row per `gene` feature, id normalized
# to match the count matrices. Used to aggregate CpGs to gene bodies (H05, H06).
harmonize_gff <- function(path, species) {
  readr::read_tsv(path, comment = "#", col_names = FALSE, col_types = "ccciicccc", progress = FALSE) |>
    filter(X3 == "gene") |>
    transmute(feature_id = norm_gene_id(sub(";.*$", "", sub("^.*?ID=", "", X9)), species),
              chrom = X1, start = X4, end = X5, strand = X7) |>
    distinct(feature_id, .keep_all = TRUE)
}

harmonize_temperature <- function(path) {
  readr::read_csv(path, col_types = "Tcd", progress = FALSE) |>
    filter(between(temp.C, 10, 40)) |>
    mutate(day = as.Date(date.time)) |>
    group_by(site, day) |>
    summarise(n = n(), min_c = min(temp.C), mean_c = mean(temp.C), max_c = max(temp.C), .groups = "drop")
}

# ---- Design table -----------------------------------------------------------

# Union of every sample id seen in any layer, joined to colony-level metadata
# from the physiology master. One row per sample; has_<layer> flags.
build_design <- function(layers, physiology) {
  # layers: named list of harmonized matrices (name = layer id like "genes_Apul")
  ids <- lapply(names(layers), function(nm) {
    m <- layers[[nm]]
    cols <- if ("sample_id" %in% names(m)) m$sample_id else setdiff(names(m), "feature_id")
    tibble(layer = sub("_.*$", "", nm), sample_id = cols)
  }) |> bind_rows()
  flags <- ids |> distinct() |> mutate(v = TRUE) |>
    pivot_wider(names_from = layer, values_from = v, values_fill = FALSE, names_prefix = "has_")

  colony_meta <- physiology |>
    mutate(colony = sub("-TP\\d$", "", sample_id)) |>
    group_by(colony) |>
    summarise(site = first(na.omit(site)), nutrient = first(na.omit(nutrient)),
              site_code = first(na.omit(site_code)), haplotype = first(na.omit(haplotype)),
              .groups = "drop")

  split_sample_id(flags$sample_id) |>
    left_join(TIMEPOINTS, by = "timepoint") |>
    left_join(colony_meta, by = "colony") |>
    left_join(flags, by = "sample_id") |>
    arrange(species, colony, timepoint) |>
    select(sample_id, species, species_name, prefix, colony, timepoint, tp_num, tp_date, season,
           site, nutrient, site_code, haplotype, starts_with("has_"), genome_ref)
}

# ---- Driver -----------------------------------------------------------------

write_derived <- function(x, name, dir = "data/derived") {
  dir.create(dir, recursive = TRUE, showWarnings = FALSE)
  p <- file.path(dir, paste0(name, ".csv"))
  readr::write_csv(x, p, na = "")
  p
}

harmonize_all <- function(manifest = yaml::read_yaml("config/upstream.yml"), out_dir = "data/derived") {
  files <- setNames(lapply(manifest$files, `[[`, "dest"), vapply(manifest$files, `[[`, "", "id"))
  layers <- list()
  for (sp in c("Apul", "Peve", "Ptuh")) {
    layers[[paste0("genes_", sp)]] <- harmonize_genes(files[[paste0("genes_", sp)]], sp)
    layers[[paste0("mirna_", sp)]] <- harmonize_mirna(files[[paste0("mirna_", sp)]], sp)
    write_derived(harmonize_mirna_results(files[[paste0("mirna_results_", sp)]]), paste0("mirna_", sp, "_features"), out_dir)
    l <- harmonize_lncrna(files[[paste0("lncrna_", sp)]], sp)
    layers[[paste0("lncrna_", sp)]] <- l$matrix
    write_derived(l$meta, paste0("lncrna_", sp, "_features"), out_dir)
    layers[[paste0("cpg_", sp)]] <- harmonize_cpg(files[[paste0("cpg_", sp)]], sp)
    write_derived(harmonize_gff(files[[paste0("gff_", sp)]], sp), paste0("gene_coords_", sp), out_dir)
  }
  layers$metabolomics <- harmonize_multi_species_matrix(files$metabolomics)
  layers$lipidomics   <- harmonize_multi_species_matrix(files$lipidomics)
  layers$physiology   <- harmonize_physiology(files$physiology)
  layers$its2         <- harmonize_its2(files$its2)
  orthologs <- harmonize_orthologs(files$orthologs_three_way)
  orthologs_all <- harmonize_orthologs(files$orthologs_annotated)
  temperature <- harmonize_temperature(files$temperature)

  for (nm in names(layers)) write_derived(layers[[nm]], nm, out_dir)
  write_derived(orthologs, "orthologs_three_way", out_dir)
  write_derived(orthologs_all, "orthologs_all", out_dir)
  write_derived(temperature, "temperature_daily", out_dir)
  design <- build_design(layers, layers$physiology)
  write_derived(design, "design", "config")
  invisible(list(layers = layers, design = design, orthologs = orthologs))
}

if (sys.nframe() == 0L) {
  res <- harmonize_all()
  cat("Harmonized", length(res$layers), "layers;", nrow(res$design), "samples in config/design.csv\n")
}
