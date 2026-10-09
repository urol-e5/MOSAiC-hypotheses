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
  tar_target(lock_file, "config/upstream.lock.yml", format = "file"),
  tar_target(raw_files, {
    lock_file
    fetch_all(manifest = manifest, write_lock = FALSE)
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
  # execute_params is evaluated at run time: declare both dependencies while
  # passing no extra Quarto parameters. Data changes must invalidate analyses
  # even when the reproduction gate returns the same successful test results.
  tar_quarto(H01, "hypotheses/H01/analysis.qmd",
             execute_params = { harmonized; reproduction_gate; list() },
             extra_files = c("R/expression.R", "R/varpart.R")),
  tar_quarto(H02, "hypotheses/H02/analysis.qmd",
             execute_params = { harmonized; reproduction_gate; list() },
             extra_files = "R/expression.R"),
  tar_quarto(H03, "hypotheses/H03/analysis.qmd",
             execute_params = { harmonized; reproduction_gate; list() },
             extra_files = "R/expression.R"),
  tar_quarto(H04, "hypotheses/H04/analysis.qmd",
             execute_params = { harmonized; reproduction_gate; list() },
             extra_files = c("R/expression.R", "R/varpart.R")),   # raven
  tar_quarto(H05, "hypotheses/H05/analysis.qmd",
             execute_params = { harmonized; reproduction_gate; list() },
             extra_files = c("R/expression.R", "R/methylation.R")),
  tar_quarto(H06, "hypotheses/H06/analysis.qmd",
             execute_params = { harmonized; reproduction_gate; list() },
             extra_files = c("R/expression.R", "R/methylation.R")),
  tar_quarto(H15, "hypotheses/H15/analysis.qmd",
             execute_params = { harmonized; reproduction_gate; list() },
             extra_files = c("R/expression.R", "R/methylation.R")),
  tar_quarto(H16, "hypotheses/H16/analysis.qmd",
             execute_params = { harmonized; reproduction_gate; list() },
             extra_files = c("R/expression.R", "R/methylation.R")),
  tar_quarto(H17, "hypotheses/H17/analysis.qmd",
             execute_params = { harmonized; reproduction_gate; list() },
             extra_files = c("R/expression.R", "R/neighbors.R")),
  tar_quarto(H18, "hypotheses/H18/analysis.qmd",
             execute_params = { harmonized; reproduction_gate; list() },
             extra_files = c("R/expression.R", "R/methylation.R", "R/neighbors.R")),
  tar_quarto(H19, "hypotheses/H19/analysis.qmd",
             execute_params = { harmonized; reproduction_gate; list() },
             extra_files = "R/expression.R"),
  tar_quarto(H21, "hypotheses/H21/analysis.qmd",
             execute_params = { harmonized; reproduction_gate; list() },
             extra_files = "R/expression.R"),
  tar_quarto(H22, "hypotheses/H22/analysis.qmd",
             execute_params = { harmonized; reproduction_gate; list() },
             extra_files = "R/expression.R"),
  tar_quarto(H07, "hypotheses/H07/analysis.qmd",
             execute_params = { harmonized; reproduction_gate; list() },
             extra_files = "R/expression.R"),
  tar_quarto(H08, "hypotheses/H08/analysis.qmd",
             execute_params = { harmonized; reproduction_gate; list() },
             extra_files = "R/expression.R"),   # raven
  tar_quarto(H09, "hypotheses/H09/analysis.qmd",
             execute_params = { harmonized; reproduction_gate; list() },
             extra_files = "R/expression.R"),   # raven
  tar_quarto(H12, "hypotheses/H12/analysis.qmd",
             execute_params = { harmonized; reproduction_gate; list() }),
  tar_quarto(H14, "hypotheses/H14/analysis.qmd",
             execute_params = { harmonized; reproduction_gate; list() }),
  tar_quarto(H10, "hypotheses/H10/analysis.qmd",
             execute_params = { harmonized; reproduction_gate; list() }),
  tar_quarto(H13, "hypotheses/H13/analysis.qmd",
             execute_params = { harmonized; reproduction_gate; list() },
             extra_files = "R/expression.R"),
  tar_quarto(H25, "hypotheses/H25/analysis.qmd",
             execute_params = { harmonized; reproduction_gate; list() },
             extra_files = c("R/expression.R", "R/neighbors.R")),
  tar_quarto(H26, "hypotheses/H26/analysis.qmd",
             execute_params = { harmonized; reproduction_gate; list() },
             extra_files = c("R/expression.R", "R/neighbors.R")),   # raven
  tar_quarto(H23, "hypotheses/H23/analysis.qmd",
             execute_params = { harmonized; reproduction_gate; list() },
             extra_files = c("R/expression.R", "R/methylation.R", "R/ortholog_gbm.R")),
  tar_quarto(H24, "hypotheses/H24/analysis.qmd",
             execute_params = { harmonized; reproduction_gate; list() },
             extra_files = c("R/expression.R", "R/methylation.R", "R/ortholog_gbm.R"))
)
