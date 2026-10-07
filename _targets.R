# targets pipeline: fetch -> harmonize -> design -> reproduction gate -> QC report.
# Run with:  Rscript -e 'targets::tar_make()'
# Inspect:   Rscript -e 'targets::tar_visnetwork()'

library(targets)
library(tarchetypes)

tar_option_set(packages = c("yaml", "digest", "readr", "dplyr", "tidyr", "stringr", "tibble"))
tar_source("R")

list(
  # ---- Upstream --------------------------------------------------------------
  tar_target(manifest_file, "config/upstream.yml", format = "file"),
  tar_target(manifest, yaml::read_yaml(manifest_file)),
  tar_target(raw_files, {
    fetch_all(manifest = manifest, write_lock = TRUE)
    vapply(manifest$files, `[[`, "", "dest")
  }, format = "file"),

  # ---- Harmonize --------------------------------------------------------------
  tar_target(harmonized, {
    raw_files
    harmonize_all(manifest = manifest)
    c(list.files("data/derived", full.names = TRUE), "config/design.csv")
  }, format = "file"),

  # ---- Reproduction gate -------------------------------------------------------
  tar_target(reproduction_gate, {
    harmonized
    res <- testthat::test_dir("tests", reporter = "summary", stop_on_failure = TRUE)
    as.data.frame(res)
  }),

  # ---- QC report (Quarto site in reports/) --------------------------------------
  tar_target(reports, {
    harmonized; reproduction_gate
    quarto::quarto_render("reports", as_job = FALSE)
    "reports/_site"
  }, format = "file"),

  # ---- Hypotheses (local or raven; not run in Actions, see D-004) ---------------
  tar_quarto(H01, "hypotheses/H01/analysis.qmd", extra_files = "R/expression.R"),
  tar_quarto(H02, "hypotheses/H02/analysis.qmd", extra_files = "R/expression.R")
)
