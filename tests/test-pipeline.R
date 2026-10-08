library(testthat)

test_that('all hypothesis targets depend directly on validated harmonized inputs', {
  root <- if (file.exists('_targets.R')) getwd() else normalizePath('..')
  withr::local_dir(root)
  # Inspect in a separate process so this also works inside reproduction_gate.
  graph <- targets::tar_network(script = file.path(root, '_targets.R'),
                                store = tempfile('pipeline-graph-'), outdated = FALSE)
  edges <- graph$edges
  hypotheses <- graph$vertices$name[grepl('^H[0-9]+$', graph$vertices$name)]
  expect_gte(length(hypotheses), 14L)
  for (h in hypotheses) {
    parents <- edges$from[edges$to == h]
    expect_true('harmonized' %in% parents, info = h)
    expect_true('reproduction_gate' %in% parents, info = h)
  }
  expect_true('lock_file' %in% edges$from[edges$to == 'raw_files'])
})
