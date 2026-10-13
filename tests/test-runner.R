library(testthat)

# Exercise the real CLI runner in a small isolated suite, including its exit
# status. Do not nest the repository's full suite inside itself.
run_gate_fixture <- function(code) {
  root <- if (file.exists('_targets.R')) getwd() else normalizePath('..')
  dir <- tempfile('gate-fixture-')
  dir.create(dir)
  dir.create(file.path(dir, 'tests'))
  dir.create(file.path(dir, 'R'))
  on.exit(unlink(dir, recursive = TRUE), add = TRUE)
  file.copy(file.path(root, 'tests', 'run.R'), file.path(dir, 'run.R'))
  file.copy(file.path(root, 'R', 'gate.R'), file.path(dir, 'R', 'gate.R'))
  writeLines(code, file.path(dir, 'tests', 'test-fixture.R'))
  withr::local_dir(dir)
  status <- system2(file.path(R.home('bin'), 'Rscript'), 'run.R',
                    stdout = 'run.log', stderr = 'run.log')
  list(status = status, log = paste(readLines('run.log', warn = FALSE), collapse = '\n'))
}

test_that('CLI gate rejects failures and errors even when a warning follows', {
  error <- run_gate_fixture(c(
    'testthat::test_that("error followed by cleanup warning", {',
    '  withr::defer(warning("fixture cleanup warning"))',
    '  stop("intentional fixture error")',
    '})'
  ))
  expect_equal(error$status, 1L)
  expect_match(error$log, 'intentional fixture error')
  expect_match(error$log, 'fixture cleanup warning')
  expect_match(error$log, '0 failed expectations, 1 errors', fixed = TRUE)
  expect_false(grepl('completed successfully', error$log, fixed = TRUE))

  failure <- run_gate_fixture('testthat::test_that("failed assertion", testthat::expect_true(FALSE))')
  expect_equal(failure$status, 1L)

  success <- run_gate_fixture('testthat::test_that("passing assertion", testthat::expect_true(TRUE))')
  expect_equal(success$status, 0L)
  expect_match(success$log, '1 tests completed successfully')

  warning <- run_gate_fixture(c(
    'testthat::test_that("warning without failure", {',
    '  warning("fixture warning only")',
    '  testthat::expect_true(TRUE)',
    '})'
  ))
  expect_equal(warning$status, 0L)
  expect_match(warning$log, 'fixture warning only')
})
