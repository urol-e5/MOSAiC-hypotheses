---
id: H26
slug: distal-lncrna-heldout-prediction
title: Distal lncRNA–mRNA co-expression predicts gene expression in held-out colonies
status: not supported
tier: 2
layers: [lncrna, genes, annotation]
species: [Apul, Peve, Ptuh]
depends_on: [H08, H17]
created: 2026-10-08
author: Steven Roberts (plan drafted with Claude)
---

Completed 2026-10-09 from the proposal in
[docs/follow-up-hypotheses.md](../../docs/follow-up-hypotheses.md). This file
supersedes the proposal. Changes and additions, all made before any H26
statistic was computed:

- **Peve locus excluded.** In Peve a median 69% of reads fall on one
  scaffold_167 locus (D-017). Its nine features (`peve_dominant_locus` in
  R/expression.R) are removed from Peve inputs and from the composition
  covariates. Without this, the top-10 composition proxy is about 0.70 in
  every Peve library and the composition check flags none.
- **"Composition-dominated"** libraries are fixed as top-10-feature read
  fraction above Q3 + 1.5 × IQR within species (flags Apul 2, Peve 1, Ptuh 2).
- **Improvement metric, model forms, counts and the permutation scheme** are
  fixed below; the proposal left them open. The metric was first written as
  the mean over targets of 1 − MSE_full / MSE_nuisance. A smoke test of the
  analysis code on Poisson-noise counts (no real H26 data) showed that form is
  unbounded: in the Peve fold holding out POR-236 (2 samples), one target
  with a nuisance error of about 1e-10 gave −13,618 and moved the fold mean
  to −140. It was replaced, before this file was pushed and before any real
  H26 statistic, by the pooled variance-scaled form in step 4.
- **Compute:** raven.

Feasibility (`feasibility_check.R`, coordinates and per-library totals only;
`output/feasibility/`): isolated lncRNAs (below) 656 / 297 / 1,317 on 38 /
137 / 54 scaffolds (Apul / Peve / Ptuh); each leave-one-colony-out fold
allows 4! × 5! = 2,880 distinct within-site permutations of the training
colonies, and the full 10-colony set 5! × 5! = 14,400. Isolated filtered
genes for the C1 benchmark: 742 / 878 / 732.

## Question

H08 found abundant strong lncRNA–mRNA edges, but shared libraries could
contribute. H17 showed that genomic proximity accounts for some
co-expression. Do distal associations reproduce outside the colonies used
to find them?

## Hypothesis and prediction

A subset of lncRNAs at least 10 kb from any annotated protein-coding gene
predicts expression of genes on other scaffolds in colonies not used to
select the associations, after accounting for season and measured library
composition. Prediction: adding the selected lncRNA lowers held-out
prediction error by at least 5%.

## Data

- Samples: `has_genes & has_lncrna` (40 / 38 / 39; 10 colonies per species,
  5 per site). Peve: D-017 locus features removed first.
- Expression filters, fixed on all samples (count thresholds, not
  estimated): the H01 filter (>= 10 counts in >= 25% of samples) on each
  layer.
- Isolated lncRNA: passes the filter; no annotated gene (any GFF gene, not
  only filtered ones) within 10 kb of either end (`neighbor_pairs`, gap
  <= 10 kb); and >= 10 kb of assembled sequence on both sides (start > 10 kb
  and end + 10 kb <= scaffold span, span = largest feature end on the
  scaffold).
- Candidate targets for a lncRNA: filtered genes on a different scaffold.
- Composition covariates per library, from raw gene + lncRNA counts:
  log library size and the fraction of reads in the ten most abundant
  features.

## Model

**Outer loop:** leave one colony out (10 folds per species). Everything below
inside a fold uses training samples (9 colonies) only, except where it says
held-out.

1. **Normalization.** DESeq2 size factors (median of ratios) and vst
   dispersion trend fitted on training samples, separately for genes and
   for lncRNAs. Held-out samples are size-factored against the training
   geometric means and transformed with the training dispersion function.
2. **Selection.** Residualize training vst on colony + timepoint + log
   library size + top-10 fraction (least squares). For every isolated lncRNA
   × candidate target, Pearson r of residuals. Keep pairs with |r| >= 0.6;
   for each target keep only its strongest lncRNA; take the 100 targets with
   the largest |r| (fewer if fewer qualify).
3. **Prediction.** For each selected target, fit on training samples
   - nuisance model: `y ~ timepoint + loglib + top10 + (1 | colony)`
   - full model: the same plus the selected lncRNA's vst,
   and predict the held-out colony with the colony effect set to 0
   (`re.form = NA`), i.e. marginal over the unseen colony.
4. **Fold improvement.** For each selected target g, MSE_full,g and
   MSE_nuis,g over the held-out colony's samples, each divided by s_g², the
   variance of g's training residuals under colony + timepoint + log
   library size + top-10 fraction (the residuals used in selection), so
   every target carries equal weight. The fold's
   I_c = 1 − Σ_g MSE_full,g / s_g² ÷ Σ_g MSE_nuis,g / s_g². A fold with no
   qualifying pair has I_c = 0.
5. **Statistic.** I = mean over the 10 folds of I_c (equal weight per
   colony).

**Colony-block bootstrap.** B = 2,000 (seed 26): resample the 10 fold values
I_c with replacement within site (5 per site); 95% percentile interval for I.
The folds are already out-of-sample, so the selection is not re-run.

**Permutation null.** B = 1,000 permutations (seed 26), drawn without
replacement from the 14,400 within-site reassignments of whole colony
trajectories, excluding the identity. A permutation moves each colony's raw
lncRNA counts, timepoint by timepoint, onto another colony of the same site;
a sample whose new source colony lacks that timepoint has no lncRNA value
and is dropped from that permutation. Gene counts and the composition
covariates stay with their own samples. The whole pipeline (steps 1–5) is
re-run per permutation. One-sided p = (1 + #{I_perm >= I}) / (B + 1). Holm
correction across the three species. Fewer than 200 distinct permutations
would make a species `inconclusive`; with 14,400 available this cannot
happen here.

## Decision rule

`supported`: in at least two species, I >= 0.05, a bootstrap interval with
lower bound > 0, and Holm-adjusted permutation p < 0.05. `not supported`:
upper bound of the bootstrap interval below 0.05 in at least two species.
Otherwise `inconclusive`, including when matching leaves too few distinct
permutations (fewer than 200 for a species).

## Known confounds and sensitivity checks

Checks report I and its bootstrap interval per species. They are descriptive
and do not change the verdict; they are not permuted.

| Check | Change |
|---|---|
| C1 | Benchmark: replace isolated lncRNAs as predictors by isolated filtered genes (the same 10 kb isolation and flank rule, applied gene-to-gene: 742 / 878 / 732 available), one drawn per isolated lncRNA with replacement within the lncRNA's mean-vst decile (deciles over the pooled isolated features; an empty decile borrows from the nearest), seed 26; targets on other scaffolds as before |
| C2 | Exclude composition-dominated libraries (top-10 fraction > Q3 + 1.5 × IQR within species) |
| C3 | Peve only: keep the D-017 locus features (data as delivered) |

Known limits:

- Small training sets (9 colonies, about 36 samples) and scaffold
  fragmentation leave few isolated lncRNAs in Peve (297).
- The composition covariates are proxies, not full RNA-quality measures;
  lncRNA and gene counts come from the same libraries, so held-out success
  cannot rule out reproducible shared-library effects or prove trans
  regulation.
- lncRNA strand is unknown (D-014); "isolated" relies on incomplete gene
  models.
- About 10 colonies per species; species is confounded with reference
  quality (Peve N50 0.17 Mb; Ptuh mapped to *P. meandrina*).
- Follow-up on the same data as H08 and H17, not an independent replication.

Compute: raven. The full selection pipeline is re-run for each of 1,000
permutations per species.

## Amendments
