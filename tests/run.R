# Run the reproduction gate from the repo root: Rscript tests/run.R
source("R/gate.R")
res <- run_reproduction_gate()
df <- as.data.frame(res)
cat(sprintf("\n%d tests completed successfully, %d skipped\n", nrow(df), sum(df$skipped)))
