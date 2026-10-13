# Diagnose saved assay denominators; do not change the physiology table.
calcification_unit_audit <- function(assays) {
  start <- as.POSIXct(assays$start_time, tz = "UTC")
  stop <- as.POSIXct(assays$stop_time, tz = "UTC")
  assays$duration_hours <- as.numeric(difftime(stop, start, units = "hours"))
  ratio <- assays$stored_timediff / assays$duration_hours
  near <- function(x) is.finite(ratio) & abs(ratio - x) < 1e-6
  assays$inferred_time_unit <- ifelse(near(1), "hours",
    ifelse(near(60), "minutes", ifelse(near(3600), "seconds", "unresolved")))
  assays$duration_valid <- is.finite(assays$duration_hours) & assays$duration_hours > 0
  assays$hourly_candidate <- ifelse(!assays$duration_valid | assays$inferred_time_unit == "unresolved", NA_real_,
                                   assays$reported_rate * ratio)
  assays
}
