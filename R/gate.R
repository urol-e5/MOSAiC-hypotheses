# Check individual expectations: testthat 3.2.1.1's data-frame summary and
# stop_on_failure can miss an error when a cleanup warning follows it.
run_reproduction_gate <- function(path = "tests", reporter = "summary") {
  res <- testthat::test_dir(path, reporter = reporter, stop_on_failure = FALSE)
  expectations <- unlist(lapply(res, `[[`, "results"), recursive = FALSE)
  failures <- sum(vapply(expectations, inherits, logical(1), "expectation_failure"))
  errors <- sum(vapply(expectations, inherits, logical(1), "expectation_error"))
  if (failures > 0 || errors > 0) {
    stop(sprintf("Reproduction gate failed: %d failed expectations, %d errors",
                 failures, errors), call. = FALSE)
  }
  res
}
