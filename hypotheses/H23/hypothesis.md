---
id: H23
slug: acropora-plasticity-low-gbm
title: Acropora's excess seasonal expression plasticity is concentrated in low-methylation orthologs
status: planned
tier: 2
layers: [cpg, genes, annotation]
species: [Apul, Peve, Ptuh]
depends_on: [H02, H05]
created: 2026-10-08
author: Steven Roberts (plan drafted with Claude)
---

Completed 2026-10-08 from the proposal in
[docs/follow-up-hypotheses.md](../../docs/follow-up-hypotheses.md). This file
supersedes the proposal. Changes from the proposal, all made before any
H23 outcome was computed:

- Gene set is per species, not the joint set. A count of eligible genes
  (from H05's `per_gene.csv` and the ortholog table; no amplitudes or
  associations were examined) found 88 three-way orthologs with >= 5 CpGs in
  all three species, 9 with >= 20, and 3 with >= 20 among well-annotated
  orthologs, too few for the primary test or for the proposed checks. The
  joint set is kept as sensitivity check S1.
- A gate: the analysis gene set must reproduce H02's Acropora excess, or
  the verdict is `inconclusive`.
- "Raw amplitude" in the proposal is defined here as the covariate-free
  model (S4).
- Added S6, orthologs eligible in Apul and at least one other species.

## Question

H02 found 5,007 timepoint-DE ortholog groups in Acropora versus 505 and 414
in Pocillopora and Porites. H05 found lower temporal variability with higher
GBM in all three species. Where in each species' methylation spectrum does
the Acropora excess sit?

## Hypothesis and prediction

The Acropora-versus-other-species difference in seasonal expression
amplitude is larger among low-GBM orthologs than among high-GBM orthologs.
If true, the primary contrast (below) is positive. If the excess is spread
evenly across GBM, it is near zero; if it sits in high-GBM genes, it is
negative. This locates the species difference; it does not claim
methylation causes buffering.

## Data

- Samples: `has_genes & has_cpg`, as in H05 (39 / 37 / 32 samples, 10
  colonies per species, 5 per site at Mahana and Manava).
- Expression: `genes_by_ortholog(species)` counts for those samples, then
  `prep_vst()` (H01 filter: >= 10 counts in >= 25% of samples).
- Methylation: `gene_body_methylation(load_cpg(species), load_gene_coords(species), min_cpg = 5)`
  on the same samples, joined to ortholog groups through the species gene id.
- Gene length: `end - start + 1` from `load_gene_coords(species)`.
- Eligible gene: a three-way ortholog that passes the expression filter
  and has >= 5 gene-body CpGs **in that species**. Expected counts (from the
  H05 eligibility count): about 712 Apul, 640 Peve, 9,346 Ptuh. The gene set
  is fixed from the full data and held fixed in the bootstrap.

## Model

Per species and eligible gene:

1. **Amplitude.** Fit `vst ~ colony + timepoint` (colony sum-to-zero
   contrasts, so timepoint means are at the average colony). Amplitude =
   sample SD (n − 1) of the four fitted TP1–TP4 means, in vst
   (log2-like) units.
2. **GBM.** Mean percent methylation per colony across its samples, then
   the unweighted mean across colonies. `gbm_pct` = within-species percent
   rank of that value among eligible genes, 0–100.
3. **Covariates.** Mean expression (colony means, then mean across
   colonies), log10 gene length, log10 CpG count, each centered within
   species.

Then one model across species (`lme4::lmer`, REML):

```
amplitude ~ species * (gbm_pct + splines::ns(mean_expr_c, 3) + log_len_c + log_ncpg_c) + (1 | group_id)
```

`species` has Apul as reference. Covariate effects are species-specific so
that species differences in the expression–amplitude relation cannot leak
into the GBM term. `group_id` is the ortholog group: genes shared across
species share an intercept.

**Primary contrast.** Let Δ(p) = predicted amplitude for Apul minus the mean
of predicted amplitudes for Peve and Ptuh, at `gbm_pct = p` with all
centered covariates at 0. The contrast is Δ(25) − Δ(75). Reported in vst
units and also divided by the pooled SD of amplitude: the square root of
the unweighted mean of the three within-species variances of amplitude.
Species differences in amplitude are not standardized away.

**Gate (H02 excess in this gene set).** E = mean amplitude over eligible
Apul genes minus the mean of the corresponding Peve and Ptuh means.

**Intervals.** Colony bootstrap, B = 1000, percentile 95% CIs, seed 23.
Each replicate resamples colonies with replacement within species x site
(5 of 5 per stratum), relabels duplicated colonies as distinct colonies, and
redoes steps 1–3 and the model on the resampled columns. The vst and the
eligible gene set are computed once from the full data and held fixed;
everything downstream of them is recomputed. Replicates where `lmer` fails
or is singular in a way that drops `group_id` are counted and reported.

**Multiple testing.** One primary contrast and one gate; no correction.
Sensitivity checks are descriptive and do not change the verdict.

## Decision rule

1. Gate: if the 95% CI of E does not lie entirely above zero, the verdict
   is `inconclusive` (the gene set does not carry the excess H23 tries to
   locate), whatever the primary contrast.
2. If more than 5% of bootstrap replicates fail, `inconclusive`.
3. Otherwise:
   - `supported`: primary contrast > 0 with a 95% CI entirely above zero.
   - `not supported`: 95% CI entirely below zero.
   - `inconclusive`: CI includes zero.

## Known confounds and sensitivity checks

Each check reports the primary contrast and E with colony-bootstrap CIs
(B = 500, same procedure). Counts are from the eligibility count.

| Check | Change | Expected genes (Apul / Peve / Ptuh) | Addresses |
|---|---|---|---|
| S1 | Joint set: >= 5 CpGs in all three species | 88 each | Different genes behind each species' percentiles |
| S2 | `avg_identity >= 60` and a SwissProt `protein_name` (H02's definition) | 279 / 253 / 3,296 | Annotation quality, Ptuh mapped to *P. meandrina*, Peve N50 0.17 Mb |
| S3 | >= 20 CpGs | 116 / 233 / 6,470 | Noisy GBM from few CpGs |
| S4 | Covariate-free: `amplitude ~ species * gbm_pct + (1 | group_id)` | as primary | Model dependence |
| S5 | `gbm_pct` ranked within within-species mean-expression quintiles | as primary | GBM–expression collinearity |
| S6 | Orthologs eligible in Apul and in at least one of Peve, Ptuh | about 687 groups | Ptuh's much larger gene set |

If any check gives a CI entirely on the opposite side of zero from the
primary estimate, `RESULT.md` says so in its caveats. Known limits that no
check removes:

- The upstream 10x-in-all-samples CpG filter (D-008) leaves far fewer
  eligible genes in Apul and Peve, plausibly biased toward methylated
  genes, so the low-GBM percentiles in those species may not be truly
  unmethylated genes.
- The matrices carry no coverage (D-015); depth cannot be equalized.
- Amplitude is estimated from four timepoint means per gene, on about 10
  colonies per species.
- This is a follow-up on the same data as H02 and H05, not an independent
  replication.

Compute: desktop. The bootstrap fits about 1000 + 6 x 500 `lmer` models on
up to about 10,700 rows.

## Amendments
