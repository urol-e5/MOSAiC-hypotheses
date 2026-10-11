# BLAS threading for forked parallel work (D-018).

# On raven R links multithreaded OpenBLAS, which starts one thread per core in
# every process. Analyses that fork cores - 1 workers (mclapply,
# MulticoreParam) then run workers x cores BLAS threads and spend their time
# contending. pin_blas_threads() sets the BLAS thread count for this process
# (inherited by forked workers) and the environment variables that child R
# processes (quarto renders launched by tar_make) read when OpenBLAS starts.
# A no-op on the BLAS side where RhpcBLASctl is not installed. Returns the
# previous thread count, or NA.
#
# Opt-in, not called by the pipeline (D-018): it pays off only together with
# fewer workers than cores - 1, and it shifts lme4 fits near the boundary
# (variancePartition) by up to about 0.02 in a variance fraction, because
# OpenBLAS picks different kernels for one thread.
pin_blas_threads <- function(n = 1L) {
  n <- as.integer(n)
  Sys.setenv(OPENBLAS_NUM_THREADS = n, OMP_NUM_THREADS = n, MKL_NUM_THREADS = n)
  if (!requireNamespace("RhpcBLASctl", quietly = TRUE)) return(invisible(NA_integer_))
  old <- RhpcBLASctl::blas_get_num_procs()
  RhpcBLASctl::blas_set_num_threads(n)
  RhpcBLASctl::omp_set_num_threads(n)
  invisible(old)
}
