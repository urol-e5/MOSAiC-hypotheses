# H25 result

**Status:** inconclusive

**Run on:** 2026-10-09 on raven against MOSAiC commit `86432e3` (see `config/upstream.lock.yml`).
R 4.3.3, DESeq2 1.42.1. Runtime 29 min with 47 cores (2,000 colony-bootstrap
and 1,000 scaffold-block replicates per species). The pre-registration was
completed and committed first (`cb42e81`), then the analysis (`ca7213b`); the
analysis code was smoke-tested only on noise-replaced expression matrices
before that commit, so no H25 statistic was seen before the run. Reproduction
gate and test suite passed the same day.

**Samples used:** about 10 colonies per species, 5 per site.

| Species | Samples | Colonies | Genes | lncRNAs | lncRNA–gene pairs (2–100 kb) | gene–gene pairs | Scaffolds |
|---|---|---|---|---|---|---|---|
| Apul | 40 | 10 | 21,108 | 15,559 | 167,244 | 132,629 | 74 |
| Peve | 38 | 10 | 20,841 | 8,319 | 38,616 | 54,015 | 3,191 |
| Ptuh | 39 | 10 | 20,796 | 11,236 | 131,464 | 150,678 | 114 |

Matching used the quintile level in every bin (no fallback); it kept 73–80%
(Apul), 77–100% (Peve) and 62–65% (Ptuh) of lncRNA–gene pairs.

**Headline numbers.** Δ = bin-averaged (lncRNA–gene − matched gene–gene)
median residual r, relative to the bin-averaged gene–gene median; margin
±0.25; 95% colony-bootstrap interval.

| Species | Gene–gene reference (mean of G_b) | Δ (95% CI) | p_TOST (Holm) | Rule outcome |
|---|---|---|---|---|
| Apul | 0.078 | −0.34 (−0.48, −0.13) | 0.76 (1) | not equivalent; not wholly beyond margin |
| Peve | 0.077 | −0.31 (−0.47, −0.10) | 0.77 (1) | not equivalent; not wholly beyond margin |
| Ptuh | 0.122 | −0.32 (−0.42, −0.05) | 0.66 (1) | not equivalent; not wholly beyond margin |

No species establishes equivalence and none has an interval wholly beyond
±0.25, so the verdict is `inconclusive`. The estimates agree across species:
after matching on distance and on the partner's expression level and noise,
lncRNA–gene pairs carry about a third less co-expression than gene–gene
pairs. Every interval excludes 0 (99.6–100% of bootstrap Δ below 0), but each
also includes −0.25, so the data cannot say whether the shortfall exceeds the
pre-registered margin.

Per bin (C4, primary), median residual r, lncRNA–gene / matched gene–gene
(difference, 95% CI):

| Species | 2–10 kb | 10–50 kb | 50–100 kb |
|---|---|---|---|
| Apul | 0.085 / 0.120 (−0.035, −0.065 to −0.008) | 0.042 / 0.072 (−0.030, −0.048 to −0.012) | 0.028 / 0.041 (−0.013, −0.032 to 0.001) |
| Peve | 0.117 / 0.124 (−0.007, −0.043 to 0.011) | 0.041 / 0.078 (−0.037, −0.062 to −0.014) | 0.002 / 0.029 (−0.027, −0.057 to 0.011) |
| Ptuh | 0.135 / 0.166 (−0.032, −0.065 to 0.012) | 0.070 / 0.121 (−0.051, −0.084 to −0.010) | 0.045 / 0.080 (−0.035, −0.079 to −0.004) |

Sensitivity checks (descriptive):

| Check | Apul Δ (CI) | Peve Δ (CI) | Ptuh Δ (CI) | Verdict |
|---|---|---|---|---|
| C1 colony-only residualization | −0.27 (−0.32, −0.13) | −0.24 (−0.41, −0.06) | −0.27 (−0.41, −0.02) | inconclusive |
| C2 scaffolds spanning >= 500 kb | −0.35 (−0.49, −0.15) | 0.62 (−10.2, 9.9) | −0.32 (−0.42, −0.05) | inconclusive |
| C3 scaffold-block bootstrap | −0.34 (−0.40, −0.250) | −0.31 (−0.48, −0.05) | −0.32 (−0.41, −0.19) | inconclusive |

C1 moves Δ toward 0 by 0.05–0.07 but leaves every interval below 0. In C2,
Peve keeps 22% of its orientations and its gene–gene reference drops to
0.026 (G at 50–100 kb 0.0003), so the ratio is unstable and uninformative;
Apul and Ptuh are essentially unchanged (> 99% of their pairs are on such
scaffolds). Under scaffold-block resampling Apul's upper bound is −0.24996,
within 4 × 10⁻⁵ of the margin.

**Caveats:** n is about 10 colonies per species, and the colony bootstrap
resamples 5 colonies per site, so the intervals are wide relative to the
margin; equivalence at ±25% would need either more colonies or a smaller true
difference. The direction (lncRNA–gene weaker) holds in all three species and
under both resampling schemes, but the rule treats a failure to establish
equivalence as inconclusive, not as evidence for a class difference, and the
result is reported that way. The comparison describes lncRNAs whose expression
overlaps genes' (Ptuh keeps about 63% of lncRNA–gene pairs). lncRNA strand is
unknown (D-014) and gene models are incomplete. Pair correlations share
members; the two bootstraps handle sample-level and genomic dependence
separately. This is follow-up on the same data as H17, whose descriptive
comparison (colony-only residualization, no matching) motivated it; it is not
an independent replication. Species is confounded with reference quality
(Peve N50 0.17 Mb; Ptuh mapped to *P. meandrina*).

**Current Findings:** qualifies under CLAUDE.md §6 (b) and (c): it bounds the
lncRNA–gene shortfall (Δ intervals −0.48 to −0.05, all below 0) and answers
the same question as the lncRNA co-expression synthesis
(<https://robertslab.github.io/current-findings/reports/coral-lncrna-cis-coexpression/>,
H08 and H17). Adding H25 to that report is pending.

**Outputs:** in `output/`
- `n_per_species.csv`, `matching_per_bin.csv`: samples, pairs, matching level and share kept
- `feasibility/`: covariate-only counts used to complete the pre-registration
- `delta_summary.csv`, `decision_per_species.csv`: Δ, intervals, TOST p-values for the primary and checks C1–C3
- `per_bin_C4.csv`: per-bin L_b, G_b and differences with intervals (all analyses)
- `per_bin_medians.png`, `per_bin_figure_data.csv`: figure and its data
- `colony_bootstrap_draws.csv`, `scaffold_bootstrap_draws.csv`: bootstrap Δ draws
- `verdicts.csv`: verdict for each analysis

inconclusive
