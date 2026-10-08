# H15 result

**Status:** inconclusive

**Run on:** 2026-10-07 against MOSAiC commit `86432e3` (see `config/upstream.lock.yml`).
R 4.3.2, DESeq2 1.42.1. Runtime about 5 min on a 16 GB / 8-core laptop.
Reproduction gate (`tests/run.R`) passed before the run.

**Samples used:** colonies with both the CpG and gene layers at TP1, TP3 and
TP4. About 10 colonies per species before this restriction.

| Species | Colonies | Samples with both layers | Genes (>= 5 CpGs, expressed) | Selected per colony (top 10%) |
|---|---|---|---|---|
| Apul | 9 | 39 | 1,641 | 165 |
| Peve | 9 | 37 | 1,796 | 180 |
| Ptuh | 6 | 32 | 16,600 | 1,660 |

**Headline numbers:** b31 is the mean over colonies of the slope of a
colony's TP3−TP1 change on the leave-one-colony-out mean change (1 = the
colony shifts exactly like the others, 0 = no shared seasonal shift).
P = persistence at TP4 (fraction of the TP1→TP3 shift still present;
0 = full reversion). dP = P_GBM − P_expr. 95% colony-bootstrap intervals,
2000 resamples.

| Species | b31 GBM | b31 expression | P GBM | P expression | dP | P_T |
|---|---|---|---|---|---|---|
| Apul | −0.26 (−0.64 to 0.49) | 0.81 (0.29 to 0.85) | 0.69 (−3.7 to 5.5) | 0.18 (−0.44 to 0.56) | 0.51 (−3.6 to 5.0) | −0.12 |
| Peve | −0.10 (−0.28 to 0.11) | 0.54 (−0.16 to 0.72) | 1.03 (−9.6 to 14.5) | 0.01 (−3.4 to 4.6) | 1.02 (−13.3 to 17.0) | −0.12 |
| Ptuh | 0.13 (−0.01 to 0.16) | 0.25 (−0.47 to 0.65) | 0.87 (−3.9 to 3.4) | −1.12 (−11.8 to 7.4) | 2.00 (−12.4 to 10.2) | −0.10 |

The GBM b31 interval includes 0 in all three species: no seasonal
gene-body methylation shift is reproducible across colonies, so there is no
shift whose persistence can be measured. The pre-registered rule makes that
`inconclusive` (clause 3). Ptuh is borderline (lower bound −0.007 here and
between −0.07 and −0.002 in the checks), echoing the Ptuh-only hint in H06.
No species meets `supported` (dP CI excludes
0 in none). Bootstrap p for dP, Holm across species: 1, 1, 1.

Temperature: the 30-day site mean before TP4 was slightly warmer than before
TP1 at all three sites (TP1 about 27.6 °C, TP3 about 27.0 °C, TP4 about
27.6–27.7 °C), so the environment fully reverted (P_T about −0.1). Logger
coverage in the 30-day windows was 16 days at TP1 at all sites, and 6 days
at Hilton for TP3.

**Expression, descriptive:** in Apul the TP1→TP3 expression shift is
reproducible across colonies (b31 0.81, CI 0.29–0.85) and had mostly
reverted by TP4 (P 0.18, CI −0.44 to 0.56), tracking temperature. In Peve
and Ptuh the expression b31 interval also includes 0, consistent with H02
(Apul far more seasonally plastic than Ptuh or Peve).

**Rebound (secondary, descriptive):** share of a colony's selected genes
moving opposite to the shared shift. Expression, TP3 (noise floor) vs TP4:
Apul 0.17 vs 0.44, Peve 0.32 vs 0.52, Ptuh 0.39 vs 0.64, so many genes
cross back past their TP1 level by November, as temperature did. GBM is at
about 0.50 at both timepoints in all species, which is chance: there is no
shift to rebound from.

**Sensitivity checks (pre-registered):** all `inconclusive`, with the GBM
b31 interval including 0 in every species in each check.

| Check | Genes (Apul / Peve / Ptuh) | dP (Apul / Peve / Ptuh) |
|---|---|---|
| >= 20 CpGs per gene | 327 / 710 / 11,106 | 1.02 / 0.94 / 2.46 |
| Top 5% selected | 1,641 / 1,796 / 16,600 | 0.52 / 1.17 / 1.62 |
| Top 20% selected | 1,641 / 1,796 / 16,600 | 0.51 / 0.91 / 2.18 |
| Three-way orthologs only | 706 / 638 / 9,311 | 0.54 / 0.93 / 2.24 |

dP intervals are 26 to 49 units wide (widest: −26 to +23, >= 20 CpGs, Ptuh).

**Caveats:** n is 9, 9 and 6 colonies (about 10 per species before
restriction); Ptuh has only 6 and is mapped to *P. meandrina*, and the
Peve reference has N50 0.17 Mb. The positive dP point estimates in every
species and check should not be read as weak support: P is a ratio, and
with the GBM denominator b31 indistinguishable from 0 the GBM persistence
values are ratios of noise, which is why their intervals span tens of units.
The informative result is upstream of the hypothesis: across colonies there
is no reproducible seasonal gene-body methylation shift between January and
September, in line with H04 (methylation more colony-stable than expression)
and H06 (no within-colony coupling of methylation change to expression
change, powered for T >= 0.03). Persistence of methylation states therefore
cannot be measured on this two-month (TP3→TP4) timescale with these data; a
manipulated exposure with a clear induced methylation shift would be needed.
Each colony's change rests on one sample per timepoint per layer. Gene sets
differ about 10-fold across species because of unequal upstream CpG
filtering (D-008). TP3→TP4 also spans the *Acropora* spawning window.

**Current Findings:** <https://robertslab.github.io/current-findings/reports/coral-gene-body-methylation-stable-not-seasonal/> (gene-body methylation synthesis, with H04–H06, H15, H16, H18).

**Outputs:** in `output/`
- `n_per_species.csv`: colonies, samples and genes used
- `temperature_30d.csv`: 30-day site temperature means and logger days per window
- `persistence_summary.csv`: b31, P and dP with bootstrap CIs, P_T, decision columns
- `persistence_bootstrap.csv`: all bootstrap replicates (1.3 MB)
- `persistence_trajectory.png`, `trajectory_normalized.csv`: figure and the data behind it
- `rebound.csv`: opposite-sign fractions at TP3 and TP4
- `sens_mincpg20_summary.csv`, `sens_top5_summary.csv`, `sens_top20_summary.csv`, `sens_orthologs_summary.csv`: sensitivity checks
- `verdicts.csv`: verdict for each analysis

inconclusive
