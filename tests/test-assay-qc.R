library(testthat)

test_that("assay audit distinguishes minutes and hours without guessing invalid durations", {
  root <- if (file.exists("R/assay-qc.R")) "." else ".."
  source(file.path(root, "R", "assay-qc.R"), local = TRUE)
  x <- tibble::tibble(start_time = rep("2020-01-01 09:00:00", 4),
                      stop_time = c("2020-01-01 10:30:00", "2020-01-01 10:30:00",
                                    "2020-01-01 08:30:00", NA),
                      stored_timediff = c(90, 1.5, -30, NA), reported_rate = c(1, 60, 0, 1))
  qc <- calcification_unit_audit(x)
  expect_equal(qc$inferred_time_unit, c("minutes", "hours", "minutes", "unresolved"))
  expect_equal(qc$duration_valid, c(TRUE, TRUE, FALSE, FALSE))
  expect_equal(qc$hourly_candidate[1:2], c(60, 60))
  expect_true(all(is.na(qc$hourly_candidate[3:4])))
  expect_equal(qc$reported_rate, x$reported_rate)
})
