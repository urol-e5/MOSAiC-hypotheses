# Calcification exports mix minute/hour denominators and contain nonpositive incubation durations

Proposed repository: `urol-e5/timeseries`. Not yet posted.

At commit `92b60b34c481eb170a061925e673297b76a8225c`, all four
`timepoint_*/scripts/calcification_rates.Rmd` scripts use
`timediff = as.numeric(stop.time - start.time)` without explicit units and
then divide by `timediff` to produce `umol.cm2.hr`.

The saved `timepoint_*/output/*_calcification_rates.csv` files confirm that
TP1 and TP4 numeric denominators are elapsed minutes (131 and 107 assay
records), while TP2 and TP3 denominators are elapsed hours (189 and 117).
All 439 finite sample-level rates matched against the MOSAiC-hypotheses
locked `master_timeseries.csv` agree with those exports (TP1 repeated assays
averaged). Thus the unit inconsistency reaches the delivered master.

Example: TP1 ACR-247 has start 14:10, stop 15:32, `timediff=82`,
`umol.cm2.hr=0.00897683068425941`. TP4 ACR-234 has 13:29 to 15:27 and
`timediff=118`. TP3 POC-386 has 12:00 to 13:34 and
`timediff=1.56666666666667`. A minute denominator requires a factor of 60 to
express the otherwise identical calculation per hour; we have not changed
any measurements downstream.

Separately, TP1 has nine and TP2 has 55 nonpositive saved durations. Eight
invalid-duration records have positive reported rates; other rates are
clamped to zero. Eight distinct TP2 core molecular samples are affected.
For example TP2 POR-214 is saved as 12:37 to 02:26, giving -10.1833 hours.
We cannot infer whether this is an AM/PM or field-record error. Saved date
parts appear to reflect script execution, not collection dates.

Please verify the field clocks/dates, use
`as.numeric(difftime(stop.time, start.time, units="hours"))`, explicitly
reject unresolved/nonpositive durations before rate calculation, check
volume, salinity and blank corrections, and regenerate the timepoint
exports and master. Do not fix this solely by dividing middle timepoints
by 60 or converting negative rates to zero.

Evidence is recorded locally in `docs/qc/2026-10-12/QC-follow-up.md` and
its three calcification audit CSVs in MOSAiC-hypotheses. Four assay outputs
were pinned and checksummed for this investigation; the original physiology
checksum remains `a88028dd07a17945fc1e61d2e6cbefe3`.

Affected downstream analyses include H09, H10's secondary physiology
models, H14's secondary calcification analysis, H16 and H22. Reanalysis
awaits validated assay exports. Existing verdicts are preserved as records
of the registered analyses, with explicit assay qualifications.
