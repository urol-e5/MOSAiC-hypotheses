---
id: H18
slug: methylation-lncrna-channel-integration
title: Gene-body methylation and cis-lncRNA expression explain largely independent parts of within-colony expression change
status: planned
tier: 4
layers: [cpg, lncrna, genes, annotation]
species: [Apul, Peve, Ptuh]
depends_on: [H06, H17]
created: 2026-10-07
author: Steven Roberts (plan drafted with Claude)
---

## Question

Source question Q6 (channel integration). Are methylation-mediated and
ncRNA-mediated regulation of the same genes independent, redundant, or
hierarchical (one channel acting through the other)?

## Hypothesis and prediction

The two channels are independent. Prediction: across genes that have both
a GBM value and a cis-lncRNA within 10 kb, within-colony expression
variation is explained by unique GBM and unique lncRNA components that are
each above zero, with the shared component small.

The three outcomes are defined in advance:

- **Independent**: both unique fractions > 0 and shared < 25% of the total
  explained.
- **Redundant**: shared >= the larger unique fraction.
- **Hierarchical**: methylation of the lncRNA locus predicts lncRNA
  expression, and the indirect path (lncRNA-locus methylation → lncRNA →
  gene) has a CI excluding 0 and is at least 25% of the total effect of
  lncRNA-locus methylation on the gene.

miRNA is the obvious third channel but has no target predictions in the
manifest; it is out of scope until targets are added (see H07 note).

## Data

- Gene-level GBM (H05), lncRNA-locus methylation (same aggregation over
  lncRNA coordinates, >= 5 CpGs), lncRNA and gene vst.
- Pairs: the nearest non-overlapping lncRNA within 10 kb per gene (H17).
- Samples with cpg, lncrna and genes. Expected about 37–39 (Apul, Peve),
  about 32 (Ptuh). Report n.

## Model

Per species, long data over pairs × samples, every variable centered on its
gene×colony mean and standardized within gene (within-colony variation
only):

1. `E ~ M + L + (1|colony) + (1|gene)`, plus the two single-predictor
   models. Commonality analysis on marginal R² (Nakagawa): unique_M,
   unique_L, shared. 95% CI by colony bootstrap (2000).
2. Hierarchical path: `L ~ M_L + (1|colony) + (1|gene)` and
   `E ~ L + M_L + (1|colony) + (1|gene)`; indirect effect a×b with a
   colony-bootstrap CI.
3. Null for unique fractions: permute colony labels of the methylation
   layer (1000).

Multiple testing: one classification per species. Bootstrap CIs are 95%
without further correction; the classification requires agreement in two
of three species.

## Decision rule

- `supported` (independent) if the independent pattern holds in at least
  two species.
- `not supported` if the redundant or hierarchical pattern holds in at least
  two species. RESULT.md names which.
- `inconclusive` if unique_M and unique_L are both indistinguishable from
  the null in two or more species (too little within-colony signal to
  partition), or species disagree.

## Known confounds and sensitivity checks

- Depends on H06 and H17 finding any signal. If H06 finds no coupling
  between methylation and expression change, this is likely to come out
  `inconclusive`; that result is still kept.
- Restricting to genes with a cis-lncRNA selects a non-random gene subset.
  Report how GBM and expression level differ between included and excluded
  genes.
- Methylation noise biases unique_M downward. Sensitivity: >= 20 CpGs.
- Species confounded with reference quality and lncRNA annotation depth.
- n is about 10 colonies per species.

## Amendments

(Leave empty. Dated entries only, added if the decision rule has to change.)
