# Reproduction gate. Run with: Rscript tests/run.R
#
# The harmonized data must reproduce the numbers MOSAiC publishes
# (quarto/counts.qmd "Sample Counts by Data Type", docs/corrected_sample_counts.md,
# and ortho.qmd's "Loaded N ortholog groups"). If any of these fail, do not run
# hypotheses: either upstream changed or the harmonizer broke.

library(testthat)
# testthat runs with the working directory set to tests/; analyses expect the repo root.
root <- if (file.exists("_targets.R")) getwd() else normalizePath("..")
setwd(root)
source("R/load.R")

# Published in MOSAiC docs/corrected_sample_counts.md (2025-09), except lncRNA:
# that doc reported 45/43/44 for an earlier upstream file; the files pinned on
# 2026-10-06 have exactly the same samples as the gene matrices (decision D-007).
expected_samples <- tibble::tribble(
  ~species, ~genes, ~mirna, ~lncrna, ~cpg,
  "Apul",   40L,    40L,    40L,     39L,
  "Peve",   38L,    37L,    38L,     37L,
  "Ptuh",   39L,    39L,    39L,     32L
)

n_samples <- function(df) length(setdiff(names(df), "feature_id"))

test_that("sample counts per species and layer match MOSAiC's published table", {
  for (i in seq_len(nrow(expected_samples))) {
    sp <- expected_samples$species[i]
    expect_equal(n_samples(load_genes(sp)),  expected_samples$genes[i],  info = paste(sp, "genes"))
    expect_equal(n_samples(load_mirna(sp)),  expected_samples$mirna[i],  info = paste(sp, "mirna"))
    expect_equal(n_samples(load_lncrna(sp)), expected_samples$lncrna[i], info = paste(sp, "lncrna"))
    expect_equal(n_samples(load_cpg(sp)),    expected_samples$cpg[i],    info = paste(sp, "cpg"))
  }
})

test_that("three-way ortholog groups match ortho.qmd (10,381)", {
  expect_equal(nrow(load_orthologs()), 10381L)
})

test_that("every sample column is a canonical id and the design covers it", {
  design <- load_design()
  expect_true(all(grepl("^(ACR|POR|POC)-\\d+-TP[1-4]$", design$sample_id)))
  for (sp in c("Apul", "Peve", "Ptuh")) for (f in list(load_genes, load_mirna, load_lncrna, load_cpg)) {
    ids <- setdiff(names(f(sp)), "feature_id")
    expect_true(all(grepl("^(ACR|POR|POC)-\\d+-TP[1-4]$", ids)))
    expect_true(all(ids %in% design$sample_id))
    expect_false(anyDuplicated(ids) > 0)
  }
})

test_that("ortholog gene ids resolve in the count matrices (>= 95% per species)", {
  og <- load_orthologs()
  for (sp in c("Apul", "Peve", "Ptuh")) {
    key <- switch(sp, Apul = "apul_gene", Peve = "peve_gene", Ptuh = "ptuh_gene")
    hit <- mean(og[[key]] %in% load_genes(sp)$feature_id)
    expect_gte(hit, 0.95, label = paste(sp, "ortholog->count id match rate", round(hit, 3)))
  }
})

test_that("design has exactly three species and four timepoints", {
  d <- load_design()
  expect_setequal(unique(d$species), c("Apul", "Peve", "Ptuh"))
  expect_setequal(unique(d$timepoint), paste0("TP", 1:4))
})
