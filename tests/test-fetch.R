library(testthat)

fetch_fixture <- function() {
  root <- if (file.exists('R/fetch.R')) getwd() else normalizePath('..')
  env <- new.env(parent = globalenv())
  sys.source(file.path(root, 'R/fetch.R'), envir = env)
  td <- tempfile('fetch-test-')
  dir.create(td)
  env$lock_path <- file.path(td, 'lock.yml')
  dest <- file.path(td, 'data.txt')
  remote <- file.path(td, 'remote.txt')
  writeLines('original', dest)
  writeLines('original', remote)
  manifest <- list(mosaic = list(commit = 'fixture'), files = list(
    list(id = 'fixture', layer = 'test', species = 'test', dest = dest, url = remote)))
  # Local fixture stands in for downloading; never contacts upstream.
  env$download_one <- function(url, dest, quiet = TRUE) file.copy(url, dest, overwrite = TRUE)
  env$fetch_all(manifest = manifest, refresh_lock = TRUE)
  list(env = env, dir = td, dest = dest, remote = remote, manifest = manifest)
}

test_that('normal fetch verifies cached and downloaded content without rewriting the lock', {
  f <- fetch_fixture()
  on.exit(unlink(f$dir, recursive = TRUE))
  before <- readBin(f$env$lock_path, 'raw', n = 10000)
  expect_no_error(f$env$fetch_all(manifest = f$manifest))
  unlink(f$dest)
  expect_no_error(f$env$fetch_all(manifest = f$manifest))
  expect_identical(readBin(f$env$lock_path, 'raw', n = 10000), before)
})

test_that('cached and forced-download mismatches fail without accepting drift', {
  f <- fetch_fixture()
  on.exit(unlink(f$dir, recursive = TRUE))
  before <- readBin(f$env$lock_path, 'raw', n = 10000)
  writeLines('changed cache', f$dest)
  expect_error(f$env$fetch_all(manifest = f$manifest), 'Checksum mismatch for fixture')
  writeLines('changed remote', f$remote)
  expect_error(f$env$fetch_all(manifest = f$manifest, force = TRUE), 'Checksum mismatch for fixture')
  expect_identical(readBin(f$env$lock_path, 'raw', n = 10000), before)
})

test_that('new entries and missing locks require explicit refresh', {
  f <- fetch_fixture()
  on.exit(unlink(f$dir, recursive = TRUE))
  new_manifest <- f$manifest
  new_manifest$files[[1]]$id <- 'new-entry'
  expect_error(f$env$fetch_all(manifest = new_manifest), 'Files missing from checksum lock')
  unlink(f$env$lock_path)
  expect_error(f$env$fetch_all(manifest = f$manifest), 'Files missing from checksum lock')
  expect_false(file.exists(f$env$lock_path))
  expect_no_error(f$env$fetch_all(manifest = f$manifest, refresh_lock = TRUE))
  expect_true(file.exists(f$env$lock_path))
})

test_that('explicit refresh accepts a changed baseline only after all files succeed', {
  f <- fetch_fixture()
  on.exit(unlink(f$dir, recursive = TRUE))
  writeLines('reviewed change', f$remote)
  expect_message(f$env$fetch_all(manifest = f$manifest, force = TRUE, refresh_lock = TRUE), 'Refreshing: fixture')
  expect_identical(f$env$read_lock()[['fixture']]$md5, f$env$md5_file(f$dest))
  before <- readBin(f$env$lock_path, 'raw', n = 10000)
  bad_manifest <- f$manifest
  bad_manifest$files[[2]] <- list(id = 'failure', layer = 'test', species = 'test',
                                 dest = file.path(f$dir, 'missing'), url = 'missing')
  f$env$download_one <- function(...) FALSE
  expect_error(f$env$fetch_all(manifest = bad_manifest, refresh_lock = TRUE), 'Could not fetch failure')
  expect_identical(readBin(f$env$lock_path, 'raw', n = 10000), before)
})
