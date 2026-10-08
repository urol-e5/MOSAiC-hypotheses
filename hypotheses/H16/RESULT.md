# H16 result

**Status:** not supported

**Run on:** 2026-10-07 against MOSAiC commit `86432e3` (see `config/upstream.lock.yml`).
R 4.3.2, DESeq2 1.42.1, lme4 1.1-37. Runtime 2 h 48 min on a 16 GB / 8-core
laptop (7 cores), most of it the all-genes sensitivity check.
Reproduction gate (`tests/run.R`) passed earlier the same day.

**Samples used:** samples with both the CpG and gene layers; transitions
where a colony has both layers at both ends. About 10 colonies per species.

| Species | Colonies | Samples with both layers | DM genes (top 10% \|dGBM\|) | TP1→TP2 | TP2→TP3 | TP3→TP4 | Model rows |
|---|---|---|---|---|---|---|---|
| Apul | 10 | 39 | 165 | 9 | 10 | 10 | 4,785 |
| Peve | 10 | 37 | 180 | 9 | 8 | 9 | 4,680 |
| Ptuh | 9 in model (10 sampled) | 32 | 1,660 | 8 | 6 | 6 | 33,200 |

**Headline numbers:** cross-lagged `lmer` coefficients on gene×colony-
centered, gene-standardized data (SD per SD). beta_EM: expression[t] →
methylation[t+1]. beta_ME: methylation[t] → expression[t+1]. Null: each
colony's methylation paired with another colony's expression (1000
permutations). 95% colony-bootstrap intervals (2000).

| Species | beta_EM (null mean) | p, one-sided (Holm) | beta_ME (null mean) | beta_EM − beta_ME (95% CI) | Either beta differs from null (two-sided Holm p) |
|---|---|---|---|---|---|
| Apul | 0.023 (0.010) | 0.27 | −0.034 (−0.012) | 0.058 (0.019 to 0.101) | no (0.27, 0.080) |
| Peve | −0.010 (−0.008) | 1.0 | −0.012 (−0.005) | 0.002 (−0.023 to 0.041) | no (1.0, 1.0) |
| Ptuh | −0.039 (0.001) | 0.94 | 0.012 (0.002) | −0.051 (−0.083 to 0.008) | no (0.24, 0.47) |

No species passes (beta_EM is not above its null anywhere). Neither
coefficient differs from its null in any of the three species, which is the
second `not supported` condition. The rule returns `not supported`.

**Noise-asymmetry simulation (pre-registered):** with a shared seasonal
signal, the observed signal fractions (expression r_E 0.42 / 0.16 / 0.19,
methylation r_M 0.20 / 0.15 / 0.16) and no lag, beta_EM − beta_ME
averaged 0.006 / 0.002 / 0.001 with 95% ranges of −0.049 to 0.064 (Apul),
−0.042 to 0.053 (Peve) and −0.018 to 0.019 (Ptuh). The one positive
difference, Apul's 0.058, sits inside its no-lag range, so it is not evidence
that expression leads. Ptuh's −0.051 falls below its range, pointing the other
way.

**Sensitivity checks (pre-registered):** all `not supported`.

| Check | Genes (Apul / Peve / Ptuh) | beta_EM − beta_ME (Apul / Peve / Ptuh) | Note |
|---|---|---|---|
| Two-month transitions only | 165 / 180 / 1,660 | 0.061 / 0.005 / −0.058 | Apul diff CI 0.031–0.101; beta_EM not above null |
| DM genes with >= 20 CpGs | 11 / 40 / 580 | −0.045 / 0.016 / −0.049 | very few genes in Apul and Peve |
| DM genes in three-way orthologs | 94 / 85 / 1,159 | 0.010 / 0.000 / −0.059 | Ptuh CI −0.087 to −0.002: methylation-leads clause met |
| All GBM genes (200 perm / 200 boot) | 1,641 / 1,796 / 16,600 | −0.001 / −0.017 / −0.011 | all coefficients <= 0.012 in size |

**Secondary, expression seasonal score vs physiology (descriptive):** none
of the 12 colony-level cross-lagged coefficients survives BH (smallest
q = 0.084: in Apul, a higher expression score predicts lower calcification at
the next timepoint, beta −0.48, CI −0.94 to −0.02, 15 transitions).

**Caveats:** n is 9 to 10 colonies per species, with 6 to 10 colonies per
transition; Ptuh has only 6 colonies for TP2→TP3 and TP3→TP4. All
cross-lagged coefficients are small (|beta| <= 0.04 SD per SD) and none
stands out from the colony-permutation null. The hypothesis is not
supported in its directional form, and there is no robust evidence for the
reverse either. Apul's positive difference is about what noise asymmetry
alone produces (the pre-registered concern). Ptuh's negative difference
meets the methylation-leads clause in one sensitivity check (orthologs), but
not in the primary analysis or the others, rests on 6 to 8 colonies per
transition, and Ptuh is mapped to *P. meandrina*. This fits H06 and H15:
seasonal gene-body methylation change is not reproducible across colonies
and is not coupled to expression change, so neither the same-time nor the
lagged relationship carries detectable signal. This is temporal precedence
in observational data and could not establish causation even if positive;
within-unit centering over 3 to 4 timepoints adds Nickell bias, which the
permutation null shares. Intervals are unequal (2, 6, 2 months). Gene sets
differ about 10-fold across species because of unequal upstream CpG
filtering (D-008). Implementation note: an OLS shortcut for the refits was
tried in a smoke test and dropped because it differed from `lmer` by up to
0.006; all reported fits are `lmer`, as pre-registered.

**Current Findings:** <https://robertslab.github.io/current-findings/reports/coral-gene-body-methylation-stable-not-seasonal/> (gene-body methylation synthesis, with H04–H06, H15, H16, H18).

**Outputs:** in `output/`
- `n_per_species.csv`, `n_per_transition.csv`: colonies, samples, genes and transitions used
- `crosslag_summary.csv`: coefficients, null means, permutation p (raw and Holm), bootstrap CIs, Wald CIs, decision columns
- `crosslag_null.csv`: all permutation draws
- `crosslag_vs_null.png`: figure; data in `crosslag_summary.csv` and `crosslag_null.csv`
- `simulation_no_lag.csv`: noise-asymmetry simulation
- `secondary_phenotype.csv`: expression score vs physiology, both directions
- `sens_two_month_only_summary.csv`, `sens_mincpg20_summary.csv`, `sens_orthologs_summary.csv`, `sens_all_genes_summary.csv`: sensitivity checks
- `verdicts.csv`: verdict for each analysis

not supported
