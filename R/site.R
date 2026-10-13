# Emit the authoritative result record with working links between current and
# superseded reports. Quarto executes these pages from the reports/ directory.
render_result <- function(path) {
  id <- basename(dirname(path))
  body <- readLines(path, warn = FALSE, encoding = "UTF-8")[-1]
  body <- gsub("\\(RESULT-original-[0-9-]+\\.md\\)",
               paste0("(", id, "-original.qmd)"), body)
  body <- gsub("(RESULT.md)", paste0("(", id, ".qmd)"), body, fixed = TRUE)
  body <- gsub("(../../docs/qc/2026-10-12/QC-follow-up.md)",
               "(../qc-follow-up.qmd)", body, fixed = TRUE)
  cat(body, sep = "\n")
}
