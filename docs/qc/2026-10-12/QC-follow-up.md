# QC follow-up — 2026-10-12

This follow-up addresses the assay-unit and broader-cohort taxonomy concerns
in the preserved [2026-10-07 audit](../2026-10-07/QC-review.md). It preserves
all delivered measurements and registered primary verdicts. The complete
calcification correction remains pending upstream verification.

## Calcification: the time denominator mismatch is confirmed

The four saved assay outputs pinned in `config/upstream.yml` at timeseries
commit `92b60b34c481eb170a061925e673297b76a8225c` contain start/stop timestamps,
`timediff`, and `umol.cm2.hr`. Comparing the numeric denominator with explicit
elapsed hours gives:

| Timepoint | Saved denominator unit | Assay records | Nonpositive durations |
|---|---|---:|---:|
| TP1 | minutes | 131 | 9 |
| TP2 | hours | 189 | 55 |
| TP3 | hours | 117 | 0 |
| TP4 | minutes | 107 | 0 |

All four upstream scripts calculate `as.numeric(stop.time - start.time)`
without declaring a unit. R's automatic `difftime` units depend on the vector
of durations. For example, a vector of 45- and 90-minute incubations returns
45 and 90; a 90-minute incubation alone returns 1.5. A numeric denominator
from this expression cannot consistently represent hours.

The 439 finite sample-level rates matched between these assay outputs and the
locked physiology master agree to numerical tolerance (1e-10 relative to a
floor of one). Nine additional matched records are missing in both sources.
TP1 repeated assays are averaged for this comparison, matching its upstream
export. The evidence therefore traces the inconsistency into the delivered
physiology values, rather than merely identifying an unused code pattern.

**TP1/TP4 rates computed with positive minute denominators would need to be
multiplied by 60 to express the same calculation per hour.** Dividing TP2/TP3
by 60, as suggested only as a diagnostic in the older audit, would instead
put them on a per-minute scale. Neither operation is an approved correction.
Other assay terms (including volume, blanks, and salinity) were not validated.

There are also **64 nonpositive stored durations** across assay records,
including **eight distinct core molecular samples at TP2**. Some yield zero
rates because the upstream scripts clamp negative results to zero; eight
invalid-duration records have positive rates. Saved timestamp dates reflect
script execution, not 2020 collection dates. Verify start/stop clocks, AM/PM,
and dates from field records before recomputation. Do not guess a 12-hour or
24-hour adjustment, replace invalid rates with zero, or treat their current
values as validated measurements.

The audit's `hourly_candidate` column is diagnostic only, requires a positive
duration, and is never substituted into `load_physiology()`. The source
physiology checksum and harmonized physiology values are unchanged.

Evidence: [time-unit summary](calcification_unit_summary.csv),
[record-level audit](calcification_time_units.csv),
[match to physiology master](calcification_master_match.csv).
Reproduce after fetch/harmonization: `Rscript docs/qc/2026-10-12/audit.R`.

Source calculations at the inspected commit:
[TP1](https://github.com/urol-e5/timeseries/blob/92b60b34c481eb170a061925e673297b76a8225c/timepoint_1/scripts/calcification_rates.Rmd#L138),
[TP2](https://github.com/urol-e5/timeseries/blob/92b60b34c481eb170a061925e673297b76a8225c/timepoint_2/scripts/calcification_rates.Rmd#L139),
[TP3](https://github.com/urol-e5/timeseries/blob/92b60b34c481eb170a061925e673297b76a8225c/timepoint_3/scripts/calcification_rates.Rmd#L108),
[TP4](https://github.com/urol-e5/timeseries/blob/92b60b34c481eb170a061925e673297b76a8225c/timepoint_4/scripts/calcification_rates.Rmd#L119).

## Taxonomy: qualify the broad cohort and test the intended annotations

The broad ITS2 cohort contains 43 POR-coded records annotated *Porites lobata
lutea* and 47 POC-coded records annotated *Pocillopora meandrina*. This is an
intentional mixed-annotation cohort, not evidence that these records were
mislabeled upstream: the assembly script imports host annotations separately
from genus/code, and the upstream [haplotype discussion, issue 61](https://github.com/urol-e5/timeseries/issues/61)
recognizes this distinction. A prefix cannot establish host species.

H10's registered all-sample results remain code-group estimates. Its dated
amendment adds a record-level intended-host-annotation sensitivity, with the
same decision thresholds, 999 permutations, and 500 colony bootstraps:

| Intended annotation | Samples | Colonies | R2 colony (95% CI) | R2 timepoint (95% CI) | Paired within < between p |
|---|---:|---:|---|---|---:|
| Acropora pulchra | 120 | 50 | 0.885 (0.727–0.960) | 0.003 (0.001–0.025) | 6.69e-8 |
| Porites evermanni | 119 | 33 | 0.703 (0.496–0.846) | 0.011 (0.006–0.049) | 4.14e-6 |
| Pocillopora tuahiniensis | 112 | 30 | 0.636 (0.538–0.728) | 0.017 (0.011–0.069) | 4.02e-6 |

All three satisfy the registered rule, so the sensitivity is **supported**.
This strengthens the intended-annotation interpretation, but does not
independently validate host identity, eliminate site/annotation confounding,
or imply that every colony's symbiont profile is constant. Peve's bootstrap
interval crosses the 0.5 threshold, although the registered rule uses its
point estimate. The sensitivity does not validate H10's secondary physiology
models, whose calcification response remains under assay review.

Evidence: [per-record annotation audit](host_annotation_audit.csv) and
`hypotheses/H10/output/sens_intended_host_*.csv`.

The physiology master has one differing original/corrected colony ID,
`POR-206-TP2` versus `POR-251`. The upstream assembly explicitly creates this
mapping. This report preserves both delivered fields; applying the corrected
key globally requires reconciliation across layers and collection metadata.
It is outside the molecular cohort and excluded from the intended-annotation
H10 sensitivity. No colony IDs are merged here.

## What remains before stronger physiology claims

1. Verify field start/stop times, AM/PM and dates; explicitly calculate elapsed
   hours; check volume, salinity, blanks and negative-value handling upstream.
2. Regenerate the per-timepoint exports and master, then review and checksum
   the new inputs. Archive existing estimates before reanalysis.
3. Rerun calcification-dependent H09, H10's secondary analysis, H14's secondary
   analysis, H16 and H22. H20 is withdrawn. Re-evaluate any decision or adjusted
   p-value depending on calcification; H14's registered AFDW decision is separate.

The local [upstream issue draft](calcification-issue-draft.md) contains the
concrete evidence and requested checks. It has not been posted. The Peve
lncRNA locus, methylation coverage, and other earlier QC limits remain open;
this follow-up does not resolve them.
