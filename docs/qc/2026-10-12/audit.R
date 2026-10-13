# Run from the repository root after fetch/harmonize and the reproduction gate.
# This descriptive audit writes evidence, never corrected physiology inputs.
source('R/load.R')
source('R/assay-qc.R')
source('R/host-qc.R')
out <- 'docs/qc/2026-10-12'
x <- calcification_unit_audit(load_calcification_assay_qc()) |>
  mutate(timepoint = sub('.*-', '', sample_id))
write_csv(x, file.path(out, 'calcification_time_units.csv'))
units <- x |> group_by(timepoint, inferred_time_unit) |>
  summarise(records = n(), invalid_duration = sum(!duration_valid), .groups='drop')
write_csv(units, file.path(out, 'calcification_unit_summary.csv'))
# Match the saved assay rate to the delivered master, averaging repeated assay
# records exactly as in TP1's upstream export. This is provenance evidence.
a <- x |> group_by(sample_id) |>
  summarise(assay_rate = if(all(is.na(reported_rate))) NA_real_ else mean(reported_rate,na.rm=TRUE),
            invalid_duration = any(!duration_valid), .groups='drop')
matched <- load_physiology() |> select(sample_id, master_rate = calc.umol.cm2.hr) |>
  inner_join(a, by='sample_id') |>
  mutate(matches = is.finite(master_rate) & is.finite(assay_rate) &
           abs(master_rate-assay_rate) <= 1e-10 * pmax(1,abs(master_rate)))
write_csv(matched, file.path(out,'calcification_master_match.csv'))
write_csv(classify_host_annotations(load_design(),load_its2()),
          file.path(out,'host_annotation_audit.csv'))
print(units)
print(matched |> mutate(timepoint=sub('.*-','',sample_id)) |>
  group_by(timepoint) |> summarise(matched_records=n(),equal=sum(matches),
                                  invalid_duration=sum(invalid_duration),.groups='drop'))
print(matched |> filter(!matches))
