---
id: H19
slug: methylation-turnover-energetic-cost
title: Colonies with higher methylome turnover have lower host biomass and storage-lipid reserves
status: not supported
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

### Amendment 1 (2026-10-08), before any H19 analysis was run

**Problem.** The CpG layer holds percent methylation only, already filtered
to >= 10x in every sample; per-sample read counts are not in the manifest
(D-015). Model step 1 needs n_reads per CpG per sample. The ">= 20x"
sensitivity check needs coverage too. H14 has not run, so "storage:membrane
ratio (H14 definition)" is not yet defined, and the lipidome has only TG,
DG, CE, FA, LPC and Cer (no PC or PE).

**Change.** The original text above is kept; these replace it where they
conflict. The decision rule is unchanged.

- *Excess turnover*: per CpG, variance of the methylation proportion across
  a colony's timepoints minus mean p(1−p)/10, the binomial variance at the
  10x coverage floor (the largest sampling variance any retained CpG can
  have). Colony score = median over CpGs. This removes the same amount of
  noise for every colony; it does **not** correct for colony differences in
  depth, which remain a confound (stated in RESULT.md).
- *>= 20x check*: not estimable; replaced by the uncorrected variance
  (median over CpGs of the raw variance), to show how much the floor
  correction changes the ranking of colonies.
- *Storage:membrane ratio*: storage = TG + DG + CE, membrane = LPC + Cer,
  summed intensities per sample, log ratio, colony mean over available
  timepoints. FA (free fatty acids) is in neither. The ratio is invariant to
  per-sample normalization. H14 should adopt or explicitly amend this.
- *"Host_AFDW per protein"*: Host_AFDW.mg.cm2 / prot_mg.cm2.
- *Per-species estimate* in the decision rule = per-species Spearman rho of
  AFDW on methylation turnover (point estimate).

### Amendment 2 (2026-10-08), after computing colony turnover, before any association was seen

**Problem.** The first run of Amendment 1's statistic showed it is
degenerate. Most coral CpGs are unmethylated (species-mean methylation below
10% for 71% of Apul, 81% of Peve and 95% of Ptuh CpGs), so the median CpG has
zero variance across timepoints. Every Ptuh colony scored exactly 0, and
Apul and Peve scores were small, quantized negatives (the same value repeated
across colonies). That run also wrote outcome tables before stopping on an
error; they were deleted unread. No association between turnover and any
outcome was looked at.

**Change.** Replaces Amendment 1's colony score; everything else stands.

- *CpG set*: per species, a fixed set of CpGs whose species-mean
  methylation is between 10% and 90% (Apul 28,355; Peve 47,014; Ptuh
  96,410), the same set for every colony of that species.
- *Colony score*: **mean** over that set of (variance across the colony's
  timepoints minus mean p(1−p)/10).
- *Sensitivity*: the median over the same set, and the uncorrected-variance
  version over the same set.

