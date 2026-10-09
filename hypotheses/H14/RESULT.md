# H14 result

**Status:** inconclusive

**Run on:** 2026-10-08 against MOSAiC commit `86432e3` (see `config/upstream.lock.yml`).
R 4.3.2, lme4 1.1-37, pls 2.8.5 (newly added to `DESCRIPTION`). Runtime
about 40 s on a 16 GB / 8-core laptop. Reproduction gate and test suite
passed on 2026-10-08. Analysis follows Amendment 1 in `hypothesis.md`,
written before any analysis. It sets the ratio as
log((TG + DG + CE) / (LPC + Cer)), H19's definition, since the lipidome has
no wax esters, PC or PE. It replaces the normalization check, which cannot
differ for a within-sample ratio, with storage as a fraction of total lipid.
It also fixes the PLS procedure.

**Samples used:** samples with lipidomics, metabolomics and physiology. 10
colonies per species; no TP2 lipids for Apul and Ptuh.

| Species | Samples | Colonies | TP1 / TP2 / TP3 / TP4 |
|---|---|---|---|
| Apul | 29 | 10 | 10 / 0 / 10 / 9 |
| Peve | 38 | 10 | 10 / 10 / 9 / 9 |
| Ptuh | 29 | 10 | 10 / 0 / 10 / 9 |

**Headline numbers:**

The lipid-ratio model is `lmer(ratio ~ scale(trait) + (1|colony))`. The
slope is in log-ratio units per SD of trait, with a Wald 95% CI. The
within-colony r comes from colony-demeaned values, with a 2000-colony
bootstrap CI.

| Species | Trait | Slope (95% CI) | Within-colony r (95% CI) |
|---|---|---|---|
| Apul | AFDW | 0.24 (0.05 to 0.43) | 0.57 (0.18 to 0.83) |
| Apul | calcification | −0.14 (−0.35 to 0.06) | −0.40 (−0.58 to −0.20) |
| Peve | AFDW | 0.13 (−0.08 to 0.33) | 0.22 (−0.14 to 0.53) |
| Peve | calcification | −0.06 (−0.26 to 0.15) | −0.15 (−0.48 to 0.24) |
| Ptuh | AFDW | −0.11 (−0.32 to 0.10) | −0.18 (−0.63 to 0.48) |
| Ptuh | calcification | −0.07 (−0.30 to 0.15) | −0.22 (−0.57 to 0.31) |

The metabolite step is PLS of the metabolites on AFDW. Q2 is from
leave-one-colony-out cross-validation, taking the best of 1–3 components.
The null is 1000 AFDW permutations using the same procedure.

| Species | Metabolites | Q2 | Null median | Null 95th percentile | p |
|---|---|---|---|---|---|
| Apul | 140 | −0.005 | −0.195 | 0.067 | 0.11 |
| Peve | 141 | −0.125 | −0.218 | 0.074 | 0.31 |
| Ptuh | 141 | −0.023 | −0.253 | 0.104 | 0.16 |

**Decision:** the AFDW slope is positive with a CI excluding 0 only in Apul,
and PLS Q2 exceeds its permutation 95th percentile in no species. No species
meets both conditions, so `supported` is out. The slope is positive in Apul
and Peve, so `not supported` (slope non-positive in all species) does not
apply. The rule returns `inconclusive`.

**Sensitivity (Amendment 1), storage fraction of total lipid:**
`inconclusive`. The AFDW slope is 0.18 (−0.03 to 0.40) in Apul, 0.21 (−0.002
to 0.42) in Peve and 0.01 (−0.15 to 0.18) in Ptuh.

**Current Findings:** not reported separately. Under CLAUDE.md §6 the
verdict is not `supported`, and with about 10 colonies the intervals are
wide. The one clear signal (Apul) is single-species and possibly seasonal;
see caveats.

**Caveats:**

- **Sample size.** n is about 10 colonies per species, with 2–4 lipid
  samples each.
- **Season.** The pre-registered model has no timepoint term. In Apul, the
  September samples are low on both storage ratio and AFDW
  (`ratio_vs_afdw.png`), so the positive association, within colonies too,
  may partly be a shared seasonal shift rather than energetic coupling at
  the colony level.
- **Calcification.** In Apul the ratio *falls* as calcification rises
  (within-colony r −0.40), opposite to the prediction.
- **Metabolites.** Every Q2 is negative, so the metabolome does not predict
  AFDW out of sample. The observed values beat the permutation median, but
  none reaches the 95th percentile.
- **Lipid classes.** Classes are assigned from lipid names
  (`lipid_class_map.csv`). Membrane lipids are represented only by LPC and
  one ceramide, so the "membrane" denominator is narrow.
- **AFDW.** AFDW is on the raw scale and includes negative values upstream.
- **Model fits.** Several mixed models had singular (zero) colony variance.
- **Relation to H19.** H19 used the same ratio at colony-mean level.

**Outputs:** in `output/`
- `n_per_species.csv`: samples and missingness
- `lipid_class_map.csv`: lipid name to class and storage/membrane group
- `ratio_slopes.csv`: slopes and within-colony r for AFDW and calcification
- `pls_q2.csv`: PLS Q2, permutation null, p
- `decision.csv`: per-species decision columns
- `ratio_vs_afdw.png`, `figure_data.csv`: figure and its data
- `sens_storage_fraction.csv`: storage-fraction check
- `verdicts.csv`: verdict for each analysis

inconclusive
