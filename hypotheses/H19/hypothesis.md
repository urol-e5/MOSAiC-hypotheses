---
id: H19
slug: methylation-turnover-energetic-cost
title: Colonies with higher methylome turnover have lower host biomass and storage-lipid reserves
status: planned
tier: 4
layers: [cpg, genes, physiology, lipidomics, metabolomics]
species: [Apul, Peve, Ptuh]
depends_on: [H04, H14]
created: 2026-10-07
author: Steven Roberts (plan drafted with Claude)
---

## Question

Source question Q7 (energetic cost of plasticity). Is maintaining a
high-turnover methylation state metabolically costly? If so, colonies that
remodel their methylome more across the year should carry less energy
reserve.

## Hypothesis and prediction

Methylome remodeling draws on energy and methyl-donor budgets. Prediction:
colony-level excess methylation turnover is negatively associated with
colony-mean `Host_AFDW.mg.cm2` within species. Secondary: also negatively
with the storage:membrane lipid ratio (H14 definition) and positively with
the methionine:SAM ratio (methyl-donor drawdown).

If false: no association, or a positive one (well-resourced colonies can
afford more remodeling, which would read as the opposite).

## Data

- `cpg_<species>`: CpGs with >= 10x in all of a colony's samples.
- Colonies with cpg at >= 3 timepoints: about 9–10 (Apul, Peve), 7–9
  (Ptuh). Pooled n about 27.
- `physiology` colony means across timepoints; `lipidomics` (TP1, TP3,
  TP4 for Apul/Ptuh; all four for Peve); `metabolomics` (SAM and
  Methionine are present).
- Comparator: expression turnover from `genes_<species>` vst.

## Model

1. Excess turnover per colony: for each CpG, the variance of methylation
   proportion across the colony's timepoints minus the binomial sampling
   variance expected from its coverage (mean of p(1−p)/n_reads). Colony
   score = median over CpGs. This removes the part of turnover that is only
   coverage noise.
2. Expression turnover per colony: median over genes of the vst variance
   across timepoints.
3. Primary: `lm(z(AFDW_mean) ~ z(turnover_meth) + species)`, z within
   species, pooled; standardized slope with 95% CI. Also per-species
   Spearman with bootstrap CI (descriptive).
4. Secondary: same model with storage:membrane ratio and
   log(Methionine/SAM) as responses, and with turnover_expr added as a
   covariate (is methylation turnover costly beyond transcriptional
   plasticity in general?). BH across the three secondary tests.

Cross-species: report species means of both turnover and AFDW, but no
species-ranking claim (CLAUDE.md §3: confounded with genome quality).

## Decision rule

- `supported` if the pooled slope is negative with 95% CI excluding 0 and
  the per-species estimate is negative in at least two species.
- `not supported` if the pooled slope is >= 0, or the CI includes 0 and
  |slope| < 0.2 SD.
- `inconclusive` otherwise.

## Known confounds and sensitivity checks

- Power: with n about 27 pooled colonies the 95% CI half-width is about 0.4
  SD; only a large effect is detectable. State this in RESULT.md.
- Turnover is computed from 3 or 4 timepoints depending on colony. Recompute
  on TP1, TP3, TP4 only for all colonies.
- AFDW depends on skeletal morphology and site. Sensitivity: add site as a
  covariate; use `Host_AFDW` per protein instead.
- Coverage correction assumes binomial noise; overdispersion leaves residual
  noise. Sensitivity: restrict to CpGs >= 20x.
- Turnover may reflect cell-type composition change (e.g. symbiont load)
  rather than remodeling within cells. Add `cells.cm2` colony mean as a
  covariate.
- n is about 10 colonies per species.

## Amendments

(Leave empty. Dated entries only, added if the decision rule has to change.)
