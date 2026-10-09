---
id: H24
slug: ortholog-gbm-rank-conservation
title: Orthologs retain similar gene-body methylation ranks across species
status: planned
tier: 2
layers: [cpg, genes, annotation]
species: [Apul, Peve, Ptuh]
depends_on: [H05]
created: 2026-10-08
author: Steven Roberts (plan drafted with Claude)
---

Completed 2026-10-08 from the proposal in
[docs/follow-up-hypotheses.md](../../docs/follow-up-hypotheses.md). This file
supersedes the proposal. Changes from the proposal, all made before any H24
outcome was computed:

- Gene sets are per species pair, not the three-way joint set. A count of
  eligible genes (from H23's eligibility table and the ortholog table; no
  methylation values or correlations were examined) found 88 orthologs
  eligible in all three species, against 91 (Apul–Peve), 678 (Apul–Ptuh) and
  610 (Peve–Ptuh) per pair. A correlation between two species needs only
  that pair. The joint set is kept as check C4.
- The matching strata follow a fixed coarsening hierarchy (below), because
  27 strata cannot be filled from 91 orthologs.
- Checks run on a pair only when it has at least 30 orthologs. On the
  eligibility count this drops the >= 20 CpG check for Apul–Peve (9).

## Question

H05 supported the same GBM–expression relationship in all three species, but
did not establish whether the same genes occupy the methylated portion of
each genome.

## Hypothesis and prediction

Matched orthologs have more similar GBM ranks across species than unrelated
genes matched for expression, gene length, and CpG count. This tests
conservation of gene identity, not the GBM–expression correlation again.
If true, each pair's Spearman rho is large and exceeds its matched-permutation
null. If GBM rank tracks only expression level, gene length and CpG content,
rho falls to the null.

## Data

- Samples: `has_genes & has_cpg`, as in H05 and H23 (39 / 37 / 32 samples, 10
  colonies per species, 5 per site).
- Eligible gene in a species: as in H23. A three-way ortholog that passes the
  H01 expression filter on `genes_by_ortholog()` vst and has >= 5 gene-body
  CpGs (`gene_body_methylation(min_cpg = 5)`) in that species.
- Pair set: orthologs eligible in both species of the pair. Expected
  (eligibility count): Apul–Peve 91, Apul–Ptuh 678, Peve–Ptuh 610.

## Model

**GBM per gene and species**: mean percent methylation per colony across its
samples, then the unweighted mean across colonies. Mean expression (vst) is
computed the same way.

**Statistic**: for each pair, Spearman rho between the two species' GBM
values across the pair set.

**Matching strata** (per pair, fixed from the full data): for each ortholog,
average the two species' within-species percentile ranks (among the pair
set) of mean expression, gene length (`end - start + 1`) and CpG count. Cut
each averaged rank into tertiles. Use the finest level of this hierarchy at
which every stratum holds >= 10 orthologs:

1. expression x length x CpG count tertiles (27 strata)
2. expression x length tertiles (9)
3. expression tertiles (3)
4. expression halves (2)
5. no stratification (1)

The level used for each pair is reported.

**Null**: 2,000 permutations per pair (seed 24). Within each stratum, shuffle
which ortholog's GBM in the second species of the pair is matched to each
ortholog in the first species, and recompute rho. One-sided permutation p =
(1 + number of null rho >= observed) / 2,001. Holm correction across the
three pairs. The excess, observed rho minus the mean null rho, is reported
but is not part of the rule.

**Intervals**: colony bootstrap, B = 1000, percentile 95% CIs, seed 24.
Each replicate resamples colonies with replacement within species x site,
independently per species, and recomputes the per-colony means, per-gene
GBM and each pair's rho. Gene sets and strata stay fixed.

## Decision rule

`supported`: for all three species pairs, rho > 0.30, a colony-bootstrap CI
entirely above zero, and Holm-adjusted p < 0.05. `not supported`: any pair
with its CI entirely below zero (contradicts universal conservation).
Otherwise `inconclusive`. The 0.30 threshold is a proposed minimum effect,
not an estimate from these data.

## Known confounds and sensitivity checks

Each check reports rho, a colony-bootstrap CI (B = 500) and a permutation p
(1,000 permutations, same strata procedure re-run on the check's gene set)
per pair. Checks are descriptive and do not change the verdict. A check runs
for a pair only if the pair has >= 30 orthologs under it.

| Check | Change | Expected orthologs (Apul–Peve / Apul–Ptuh / Peve–Ptuh) |
|---|---|---|
| C1 | >= 20 CpGs in both species | 9 (not run) / 97 / 197 |
| C2 | `avg_identity >= 60` and a SwissProt `protein_name` (H02's definition) | 30 / 271 / 242 |
| C3 | Equal CpGs per gene: GBM from 5 randomly drawn CpGs per gene (the eligibility minimum), 100 draws, seed 24; report median rho and the 2.5–97.5% range over draws (no bootstrap) | 91 / 678 / 610 |
| C4 | The 88 orthologs eligible in all three species | 88 / 88 / 88 |

Known limits:

- The upstream 10x-in-all-samples CpG filter (D-008) leaves few eligible
  genes in Apul and Peve, plausibly biased toward methylated genes. This
  truncates the GBM range and can lower rho in pairs with Apul or Peve.
- The matrices carry no coverage (D-015), so sequencing depth cannot be
  equalized; C3 equalizes only CpG count.
- Expression level is conserved across orthologs and tracks GBM (H05). The
  matched null removes the share of rho explained by those covariates at
  the resolution of the strata used. Coarser strata (smaller pairs) remove
  less of it.
- Species is confounded with reference quality (Peve N50 0.17 Mb; Ptuh mapped
  to *P. meandrina*).
- Rank conservation would not establish conservation of a causal regulatory
  mechanism. This is a follow-up on the same data as H05, not an independent
  replication.

Compute: desktop. Per-gene GBM and expression summaries reuse H23's
preparation, which moves to `R/` when this analysis is written
(CLAUDE.md section 4).

## Amendments
