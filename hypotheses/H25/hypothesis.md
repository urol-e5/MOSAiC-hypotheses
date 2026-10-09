---
id: H25
slug: distal-coexpression-class-equivalence
title: Beyond 2 kb, local co-expression is practically equivalent for lncRNA–gene and gene–gene pairs
status: inconclusive
tier: 2
layers: [lncrna, genes, annotation]
species: [Apul, Peve, Ptuh]
depends_on: [H08, H17]
created: 2026-10-08
author: Steven Roberts (plan drafted with Claude)
---

Completed 2026-10-09 from the proposal in
[docs/follow-up-hypotheses.md](../../docs/follow-up-hypotheses.md). This file
supersedes the proposal. Changes from the proposal, all made before any H25
statistic was computed:

- **Margin.** The proposal's absolute margin (±0.05 correlation units) is
  replaced by a relative one: ±25% of the gene–gene signal. H17's published
  gene–gene bin medians beyond 2 kb (colony-residualized only) are 0.02 to
  0.15 (Peve 50–100 kb 0.02, Apul 0.05, Ptuh 0.08), so ±0.05 is about as large
  as the whole far-bin signal and equivalence could pass while saying little.
  Those gene–gene medians are the only correlations consulted; no
  lncRNA–gene vs gene–gene difference was computed.
- **Scaffold matching is dropped.** Peve pairs are spread over about 2,000
  small scaffolds (median span about 0.2 Mb), so exact scaffold matching is
  not workable there; genomic dependence is handled by the scaffold-block
  bootstrap in every species.
- **Matching is stratified reweighting**, not pair-to-pair matching, with
  strata fixed below. Retention was checked on covariates only
  (`feasibility_check.R`; `output/feasibility/`).

Feasibility counts (no correlations computed): non-overlapping pairs
2–100 kb, lncRNA–gene / gene–gene: Apul 167k / 133k, Peve 39k / 54k, Ptuh
131k / 151k; smallest bin cell 5,632 (Peve lncRNA–gene, 2–10 kb). Quintile
strata keep 62–100% of lncRNA–gene pairs per bin (Ptuh about 63%, the
lowest). lncRNAs are less expressed and noisier than genes (median residual
SD about 0.8 against 0.54), which is why matching on the partner's
expression matters.

## Question

H17 supported cis co-expression, but its descriptive gene–gene comparison
showed similar correlations for lncRNA–gene pairs beyond 2 kb. H08
established abundant co-expression without showing lncRNA specificity. Is
local co-expression beyond 2 kb a property of transcript class at all?

## Hypothesis and prediction

At matched distances from 2–100 kb, lncRNA–gene and gene–gene pairs have
practically equivalent correlations: the lncRNA–gene signal is within ±25%
of the gene–gene signal. Shared local transcriptional structure is one
possible explanation; chromatin domains are not measured here.

This formalizes a pattern already seen in H17's secondary results, so it is
exploratory follow-up on the same data. Confirmation needs independent
colonies or a new year.

## Data

- Samples: `has_genes & has_lncrna`, both layers vst'd on the same samples
  with the H01 filter (`prep_vst`), as in H17 (40 / 38 / 39 samples, 10
  colonies per species).
- Coordinates: `load_gene_coords()` and `lncrna_coords()` (R/neighbors.R).
- Pairs: `neighbor_pairs()` as in H17, every lncRNA–gene pair and every
  unordered gene–gene pair on the same scaffold with gap (nearest ends)
  in (2, 100] kb; overlapping pairs and pairs within 2 kb excluded. Bins
  (2, 10], (10, 50], (50, 100] kb.

## Model

**Correlation.** Residualize each feature on colony + timepoint (fixed
effects, least squares); Pearson r of the residuals for each pair.

**Covariates**, computed once per species on the full data: each feature's
mean vst, and its residual SD after colony + timepoint.

**Orientations.** A lncRNA–gene pair has anchor = gene, partner = lncRNA.
Each gene–gene pair enters twice, once with each gene as anchor, each with
weight ½.

**Strata**, within bin: gap tertile (within the bin, pooled classes) × anchor
mean-vst tertile (cut points from the species' genes) × partner mean-vst
quintile × partner residual-SD quintile (cut points from the pooled genes
and lncRNAs): 225 strata per bin. A stratum is kept if it holds >= 3
lncRNA–gene pairs and >= 3 gene–gene orientations. If kept strata hold
< 50% of a bin's lncRNA–gene pairs, the partner covariates are coarsened to
tertiles for that bin (81 strata). The level and the share kept are
reported.

**Matched medians per bin b.** L_b: median r over kept lncRNA–gene pairs.
G_b: weighted median r over kept gene–gene orientations, with weights
scaled so each stratum's total gene–gene weight equals its lncRNA–gene
count.

**Statistic per species.** Δ = mean_b(L_b − G_b) / mean_b(G_b), bins
equally weighted. Equivalently, the bin-averaged difference must lie within
±25% of the bin-averaged gene–gene signal. If mean_b(G_b) < 0.01 there is
no gene–gene reference and the species is `inconclusive` for H25.

**Colony bootstrap (primary).** B = 2,000 (indices drawn serially, seed 25):
resample colonies with replacement within site (5 per site), with each
drawn colony a separate level for residualization; recompute residuals and
r for every pair; strata and weights stay fixed from the full data;
recompute Δ.

**Equivalence test (TOST).** Margin ±0.25 on Δ. p_lower = (1 + #{Δ* <=
−0.25}) / (B + 1), p_upper = (1 + #{Δ* >= +0.25}) / (B + 1), p_TOST =
max(p_lower, p_upper). Holm correction of p_TOST across the three species.

**Scaffold-block bootstrap.** B = 1,000 (seed 25): resample scaffolds with
replacement, taking all pairs on each drawn scaffold, with r fixed from the
full data; recompute Δ and p_TOST the same way. This assesses genomic
dependence; it does not enter the verdict (check C3).

## Decision rule

`supported`: Holm-adjusted p_TOST < 0.05 (colony bootstrap) in every
species. `not supported`: in any species, the 95% percentile colony-bootstrap
interval for Δ lies wholly below −0.25 or wholly above +0.25. Otherwise
`inconclusive` (failure to establish equivalence is not evidence for a
transcript-class difference).

## Known confounds and sensitivity checks

Checks report Δ, its colony-bootstrap interval and p_TOST per species. They
are descriptive and do not change the verdict.

| Check | Change |
|---|---|
| C1 | Residualize on colony only (H17's primary residualization) |
| C2 | Pairs on scaffolds spanning >= 500 kb (span = largest feature end on the scaffold). Removes about 80% of Peve pairs; Apul and Ptuh keep > 99% |
| C3 | Scaffold-block bootstrap in place of the colony bootstrap; conclusion compared with the primary |
| C4 | Per-bin L_b, G_b and L_b − G_b with colony-bootstrap intervals |

Known limits:

- lncRNA strand is unknown (D-014) and gene models are incomplete; some
  "gene–gene" and "lncRNA–gene" pairs may be fragments of the same
  transcript, which pushes both classes up near 2 kb.
- A pair's two members share many partners; pair correlations are not
  independent. The colony bootstrap handles sample-level dependence and the
  scaffold-block bootstrap genomic dependence, not both at once.
- Matching on partner expression drops the least- and most-expressed
  lncRNAs (Ptuh keeps about 63% of pairs), so the comparison describes the
  lncRNAs that overlap genes in expression.
- About 10 colonies per species; species is confounded with reference
  quality (Peve N50 0.17 Mb; Ptuh mapped to *P. meandrina*).
- This is follow-up on the same data as H17, not an independent replication.

Compute: desktop (H17 ran in about 75 s; the colony bootstrap recomputes
about 300k correlations 2,000 times per species).

## Amendments
