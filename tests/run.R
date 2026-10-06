# Run the reproduction gate from the repo root: Rscript tests/run.R
library(testthat)
res <- testthat::test_dir("tests", reporter = "summary", stop_on_failure = FALSE)
df <- as.data.frame(res)
cat(sprintf("\n%d tests, %d failed, %d skipped\n", nrow(df), sum(df$failed > 0), sum(df$skipped)))
if (any(df$failed > 0) || any(df$error)) quit(status = 1)
