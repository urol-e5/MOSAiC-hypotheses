library(testthat)

# Load function definitions from the actual analysis, without loading data,
# fitting full models, or writing analysis outputs.
analysis_functions <- function(id) {
  root <- if (file.exists('_targets.R')) getwd() else normalizePath('..')
  script <- tempfile(fileext = '.R')
  on.exit(unlink(script))
  invisible(knitr::purl(file.path(root, 'hypotheses', id, 'analysis.qmd'),
                        output = script, quiet = TRUE))
  # Use public exports; newer dplyr namespaces contain internal stubs that
  # shadow base functions such as ncol() when used as the parent environment.
  env <- new.env(parent = globalenv())
  for (name in getNamespaceExports('dplyr')) env[[name]] <- getExportedValue('dplyr', name)
  source(file.path(root, 'R', 'expression.R'), local = env)
  for (e in parse(script)) {
    if (is.call(e) && identical(e[[1]], as.name('<-')) &&
        is.call(e[[3]]) && identical(e[[3]][[1]], as.name('function'))) eval(e, env)
  }
  env
}

forecast_fixture <- function() {
  set.seed(2201)
  X <- matrix(rnbinom(160 * 12, mu = 100, size = 5), nrow = 160,
              dimnames = list(paste0('g', 1:160), paste0('s', 1:12)))
  X <- rbind(X, held_out_only = c(rep(0, 9), rep(1000, 3)))
  rows <- tibble::tibble(sample_id = colnames(X), colony = rep(paste0('c', 1:4), each = 3),
                         t = rep(1:3, 4), row = 1:12,
                         y0 = seq(1, 4, length.out = 12),
                         y1 = seq(1, 4, length.out = 12) + sin(1:12))
  h22 <- analysis_functions('H22')
  h22$max_pc <- 6L
  h22$alpha_en <- 0.5
  h22$n_lambda <- 100L
  list(X = X, rows = rows, h22 = h22)
}

test_that('H22 held-out counts and responses cannot fit preprocessing or select penalties', {
  d <- forecast_fixture()
  tr <- d$rows[1:9, ]; te <- d$rows[10:12, ]
  original <- d$h22$prepare_outer_fold(d$X, tr, te)
  changed <- d$X
  changed[1:80, te$sample_id] <- changed[1:80, te$sample_id] * 100L
  te$y1 <- te$y1 * 1000
  perturbed <- d$h22$prepare_outer_fold(changed, tr, te)
  expect_false('held_out_only' %in% original$outer$gene_ids)
  expect_equal(perturbed$outer$gene_ids, original$outer$gene_ids)
  expect_equal(perturbed$outer$center, original$outer$center)
  expect_equal(perturbed$outer$rotation, original$outer$rotation)
  expect_equal(perturbed$outer$Z_tr, original$outer$Z_tr)
  for (i in seq_along(original$inner)) {
    expect_equal(perturbed$inner[[i]]$design$Z_tr, original$inner[[i]]$design$Z_tr)
    expect_equal(perturbed$inner[[i]]$design$Z_te, original$inner[[i]]$design$Z_te)
  }
  fit <- d$h22$fit_fold(original)
  fit_changed <- d$h22$fit_fold(perturbed)
  expect_equal(fit_changed$lambda_fraction, fit$lambda_fraction)
  expect_equal(fit_changed$lambda, fit$lambda)
  expect_equal(fit_changed$n_pc_selected, fit$n_pc_selected)
  expect_error(d$h22$prepare_fold(d$X, tr, tr[1:3, ]))
})

test_that('H22 inner validation colonies cannot fit their own expression representation', {
  d <- forecast_fixture()
  tr <- d$rows[1:9, ]; te <- d$rows[10:12, ]
  original <- d$h22$prepare_outer_fold(d$X, tr, te)
  changed <- d$X
  validation <- tr$sample_id[original$inner[[1]]$valid]
  changed[1:80, validation] <- changed[1:80, validation] * 100L
  perturbed <- d$h22$prepare_outer_fold(changed, tr, te)
  before <- original$inner[[1]]$design; after <- perturbed$inner[[1]]$design
  expect_false(any(validation %in% before$train_ids))
  expect_equal(after$gene_ids, before$gene_ids)
  expect_equal(after$center, before$center)
  expect_equal(after$rotation, before$rotation)
  expect_equal(after$Z_tr, before$Z_tr)
})

test_that('H22 species preparation retains raw counts until a fold is defined', {
  d <- forecast_fixture()
  X <- rbind(d$X, never_expressed = rep(0, ncol(d$X)))
  h22 <- d$h22
  h22$genes_by_ortholog <- function(...) X
  h22$as_count_matrix <- function(x) x
  h22$prep_vst <- h22$norm_fold <- function(...) stop('Preprocessing must wait for a fold')
  h22$orth <- NULL
  h22$tps <- paste0('TP', 1:4)
  h22$traits <- c(AFDW = 'biomass')
  h22$design <- d$rows |>
    dplyr::mutate(species = 'Apul', has_genes = TRUE, site = 'Mahana',
                  nutrient = 'Low', timepoint = paste0('TP', t))
  h22$phys <- tibble::tibble(sample_id = d$rows$sample_id, biomass = d$rows$y0)
  prepared <- h22$prep_species('Apul')
  expect_equal(prepared$counts, X)
  expect_true('never_expressed' %in% rownames(prepared$counts))
})

test_that('H26 held-out normalization uses the frozen training scale', {
  h26 <- analysis_functions('H26')
  train <- cbind(a = c(100, 200, 300, 0), b = c(200, 400, 600, 99))
  held_out <- train[, 'a', drop = FALSE] * 10
  sf <- h26$fold_size_factors(train, held_out)
  expect_equal(sf$train, DESeq2::estimateSizeFactorsForMatrix(train,
               geoMeans = h26$geo_means(train)))
  expect_equal(unname(sf$train), c(1 / sqrt(2), sqrt(2)))
  expect_equal(unname(sf$test), 10 / sqrt(2))
  expect_equal(train[1:3, 'a'] / sf$train['a'],
               held_out[1:3, 'a'] / sf$test['a'])

  # Adding a deeper held-out library must not change another sample's factor.
  batch <- cbind(held_out, deeper = held_out[, 1] * 5)
  sf_batch <- h26$fold_size_factors(train, batch)
  expect_equal(sf_batch$train, sf$train)
  expect_equal(sf_batch$test[1], sf$test[1])
  expect_equal(unname(sf_batch$test[2]), 5 * unname(sf$test[1]))
  expect_error(h26$fold_size_factors(train * 0, held_out), 'positive training')
  expect_error(h26$fold_size_factors(train, held_out * 0), 'fold size factors')
})

test_that('H26 VST preserves training scale for a deeper held-out library', {
  h26 <- analysis_functions('H26')
  set.seed(2601)
  train <- matrix(rnbinom(400 * 8, mu = 100, size = 5), nrow = 400,
                  dimnames = list(paste0('g', 1:400), paste0('s', 1:8)))
  held_out <- train[, 1, drop = FALSE] * 10L
  colnames(held_out) <- 'held_out'
  transformed <- h26$norm_fold(train, held_out)
  expect_equal(unname(transformed$test[, 1]), unname(transformed$train[, 1]),
               tolerance = 1e-8)
  together <- h26$norm_fold(train, cbind(held_out, deeper = held_out[, 1] * 5L))
  expect_equal(together$train, transformed$train)
  expect_equal(together$test[, 'held_out'], transformed$test[, 'held_out'])
})

test_that('H26 frozen local VST matches DESeq2 on training data', {
  h26 <- analysis_functions('H26')
  train <- cbind(a = seq(10L, 1000L, 10L), b = seq(20L, 2000L, 20L))
  rownames(train) <- paste0('g', seq_len(nrow(train)))
  dds <- suppressWarnings(DESeq2::DESeqDataSetFromMatrix(train,
                data.frame(row.names = colnames(train)), ~ 1))
  DESeq2::sizeFactors(dds) <- h26$fold_size_factors(train, train)$train
  dispersion <- function(mu) 0.1 + 1 / mu
  attr(dispersion, 'fitType') <- 'local'
  DESeq2::dispersionFunction(dds) <- dispersion
  frozen <- h26$frozen_local_vst(dds)
  expect_equal(frozen(DESeq2::counts(dds, normalized = TRUE)),
               SummarizedExperiment::assay(DESeq2::varianceStabilizingTransformation(dds, blind = FALSE)),
               tolerance = 1e-10)
})

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
