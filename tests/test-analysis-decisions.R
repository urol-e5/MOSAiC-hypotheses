library(testthat)

# Load function definitions from the actual analysis, without loading data,
# fitting full models, or writing analysis outputs.
analysis_functions <- function(id) {
  root <- if (file.exists('_targets.R')) getwd() else normalizePath('..')
  script <- tempfile(fileext = '.R')
  on.exit(unlink(script))
  invisible(knitr::purl(file.path(root, 'hypotheses', id, 'analysis.qmd'),
                        output = script, quiet = TRUE))
  env <- new.env(parent = asNamespace('dplyr'))
  for (e in parse(script)) {
    if (is.call(e) && identical(e[[1]], as.name('<-')) &&
        is.call(e[[3]]) && identical(e[[3]][[1]], as.name('function'))) eval(e, env)
  }
  env
}

test_that('H15 no-shift override precedes both support and rejection', {
  h15 <- analysis_functions('H15')
  s <- tibble::tibble(dP_boot_p = rep(.01, 3), b31_gbm_lo = rep(-1, 3),
                      b31_gbm_hi = rep(1, 3), dP_lo = rep(.1, 3),
                      P_gbm = rep(1, 3), P_T = rep(0, 3), dP = rep(.2, 3))
  expect_identical(h15$decide(s)$verdict, 'inconclusive')
  s$dP <- rep(-.2, 3)
  s$dP_lo <- rep(-.3, 3)
  expect_identical(h15$decide(s)$verdict, 'inconclusive')
  s$b31_gbm_lo[1:2] <- .1
  expect_identical(h15$decide(s)$verdict, 'not supported')
  s$dP[1:2] <- .2
  s$dP_lo[1:2] <- .1
  expect_identical(h15$decide(s)$verdict, 'supported')
  s$dP_lo[2] <- -.1
  expect_identical(h15$decide(s)$verdict, 'inconclusive')
})

test_that('H18 requires agreement on every R2 and commonality fraction', {
  h18 <- analysis_functions('H18')
  metrics <- c('R2_combined', 'R2_M', 'R2_L', 'unique_M', 'unique_L', 'shared')
  obs <- setNames(rep(0, length(metrics)), metrics)
  mixed <- as.list(setNames(rep(0, length(metrics)), paste0(metrics, '_lmer')))
  mixed$any_singular <- TRUE
  expect_true(h18$check_ols_equivalence(obs, mixed)$within_tolerance)
  for (metric in metrics) {
    for (value in c(1e-4, -1e-4, .1, NA_real_, Inf)) {
      bad <- mixed
      bad[[paste0(metric, '_lmer')]] <- value
      expect_error(h18$check_ols_equivalence(obs, bad), 'equivalence check failed', info = metric)
    }
  }
  mixed$R2_M_lmer <- 0.000099
  expect_true(h18$check_ols_equivalence(obs, mixed)$within_tolerance)
  mixed$R2_M_lmer <- NULL
  expect_error(h18$check_ols_equivalence(obs, mixed), 'equivalence check failed')
})

test_that('H18 blocks resampling before returning a result for any gene subset', {
  h18 <- analysis_functions('H18')
  metrics <- c('R2_combined', 'R2_M', 'R2_L', 'unique_M', 'unique_L', 'shared')
  h18$make_long <- function(...) NULL
  h18$stats_of <- function(...) setNames(rep(0, length(metrics)), metrics)
  h18$lmer_check <- function(...) as.list(setNames(rep(.1, length(metrics)), paste0(metrics, '_lmer')))
  h18$random_derangement <- function(...) stop('resampling must not start')
  h18$n_perm <- 1L
  d <- list(cols = letters[1:3], pairs = data.frame(n_cpg = c(5, 20)), species = 'fixture')
  expect_error(h18$analyse(d), 'equivalence check failed')
  expect_error(h18$analyse(d, rows = 2L), 'equivalence check failed')
})
