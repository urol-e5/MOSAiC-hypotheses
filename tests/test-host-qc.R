library(testthat)

test_that("host restriction uses each record and excludes absent or conflicting labels", {
  root <- if (file.exists("R/host-qc.R")) "." else ".."
  source(file.path(root, "R", "host-qc.R"), local = TRUE)
  design <- tibble::tibble(sample_id = c("POR-1-TP1", "POR-1-TP2", "POC-2-TP1", "ACR-3-TP1"),
                           species = c("Peve", "Peve", "Ptuh", "Apul"),
                           colony = c("POR-1", "POR-1", "POC-2", "ACR-3"),
                           timepoint = c("TP1", "TP2", "TP1", "TP1"))
  its2 <- tibble::tibble(sample_id = design$sample_id,
                         haplotype = c("Porites evermanni", "Porites lobata lutea", NA, "Acropora pulchra"))
  qc <- classify_host_annotations(design, its2)
  expect_equal(qc$sample_id[qc$annotation_matches], c("POR-1-TP1", "ACR-3-TP1"))
  expect_equal(qc$colony, design$colony)
  expect_error(classify_host_annotations(design, dplyr::bind_rows(its2, its2[1, ])),
               "Duplicate ITS2")
})
