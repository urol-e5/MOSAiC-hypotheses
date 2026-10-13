# Compare each ITS2 record's delivered host annotation with the species implied
# by its design code. A matching annotation is not independent taxonomic proof.
classify_host_annotations <- function(design, its2) {
  if (anyDuplicated(its2$sample_id)) stop("Duplicate ITS2 sample IDs")
  if (anyDuplicated(design$sample_id)) stop("Duplicate design sample IDs")
  expected <- c(Apul = "Acropora pulchra", Peve = "Porites evermanni",
                Ptuh = "Pocillopora tuahiniensis")
  out <- dplyr::inner_join(
    dplyr::select(design, sample_id, species, colony, timepoint),
    dplyr::transmute(its2, sample_id, host_annotation = haplotype),
    by = "sample_id")
  out$expected_annotation <- unname(expected[out$species])
  out$annotation_matches <- !is.na(out$host_annotation) &
    !is.na(out$expected_annotation) & out$host_annotation == out$expected_annotation
  out
}
