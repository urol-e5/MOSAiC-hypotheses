# Quarto pre-render hook; runs from reports/.
# Package the dated QC evidence without duplicating it in version control.
evidence <- "../docs/qc/2026-10-07"
dir.create("qc-evidence", showWarnings = FALSE)
assets <- list.files(evidence, pattern = "\\.(csv|png)$", full.names = TRUE)
stopifnot(all(file.copy(assets, "qc-evidence", overwrite = TRUE)))
audit <- readLines(file.path(evidence, "QC-review.md"), warn = FALSE, encoding = "UTF-8")[-1]
audit <- gsub("\\(([A-Za-z0-9_-]+\\.(csv|png))\\)", "(qc-evidence/\\1)", audit)
writeLines(audit, "qc-evidence/audit.md", useBytes = TRUE)

follow_up <- "../docs/qc/2026-10-12"
dir.create("qc-follow-up-evidence", showWarnings = FALSE)
assets <- list.files(follow_up, pattern = "\\.csv$", full.names = TRUE)
assets <- c(assets, file.path(follow_up, "calcification-issue-draft.md"))
stopifnot(all(file.copy(assets, "qc-follow-up-evidence", overwrite = TRUE)))
audit <- readLines(file.path(follow_up, "QC-follow-up.md"), warn = FALSE, encoding = "UTF-8")[-1]
audit <- gsub("(../2026-10-07/QC-review.md)", "(qc-review.qmd)", audit, fixed = TRUE)
audit <- gsub("\\(([A-Za-z0-9_-]+\\.(csv|md))\\)", "(qc-follow-up-evidence/\\1)", audit)
writeLines(audit, "qc-follow-up-evidence/audit.md", useBytes = TRUE)
