---
id: H17
slug: lncrna-cis-neighbor-coupling
title: lncRNAs co-vary with neighboring protein-coding genes more than with expression-matched distant genes, decaying with distance
status: planned
tier: 2
layers: [lncrna, genes, annotation]
species: [Apul, Peve, Ptuh]
depends_on: [H08]
created: 2026-10-07
author: Steven Roberts (plan drafted with Claude)
---

## Question

Source question Q5 (ncRNA functional validation). Are the cis-regulatory
effects inferred for lncRNAs on neighboring genes detectable above
background in these data, and how large are they? H08 tests genome-wide
(trans) co-expression; this tests the cis claim specifically.

This is a correlational test. It can show that a cis signal exists and
bound its size; it cannot validate function, which needs perturbation.

## Hypothesis and prediction

lncRNAs regulate or share regulation with nearby genes. Prediction: for
lncRNA–gene pairs within 10 kb (not overlapping), the correlation of
colony-adjusted expression is shifted positive relative to a null of the
same lncRNA paired with expression-matched genes on other scaffolds, and
the shift decreases with distance.

If false: cis pairs look like the trans null at all distances.

## Data

- `lncrna_<species>` + `lncrna_<species>_features` (coordinates, strand);
  `genes_<species>` + `gene_coords_<species>`. Samples with both layers
  (about 38–40 per species).
- Features filtered as in H01. Pairs: each lncRNA with every gene whose
  nearest edge is within 100 kb on the same scaffold. Overlapping pairs
  (any shared bases) are excluded from the primary test, because shared
  reads can create correlation; they are reported separately.

## Model

1. vst both layers on the same samples; residualize each feature on colony
   (fixed effect) so r reflects within-colony co-variation across time.
   Seasonal co-variation is kept on purpose; a timepoint-residualized
   version is a sensitivity.
2. Pearson r per pair. Distance bins: 0–2, 2–10, 10–50, 50–100 kb.
3. Null per lncRNA: 100 genes from other scaffolds in the same mean-
   expression decile as the true neighbor; null distribution of median r
   by drawing one null partner per cis pair, 1000 times.
4. Effect size: dr = median r(cis, <= 10 kb) − median r(null), with a
   95% interval from the null draws; and the median standardized slope of
   gene on lncRNA for cis pairs with a bootstrap CI over pairs.
5. Distance decay: Spearman of bin median r on bin rank.
6. Descriptive split by orientation: divergent / convergent / same-strand.

Multiple testing: one primary test per species. No per-pair calls in the
decision; if per-pair significance is reported, BH across pairs.

## Decision rule

- `supported` if dr > 0 with null p < 0.01 and dr >= 0.05 in all three
  species, and the distance-decay rho is negative in at least two.
- `not supported` if dr < 0.02 or null p >= 0.05 in at least two species.
- `inconclusive` otherwise.

## Known confounds and sensitivity checks

- Unannotated read-through or alternative UTRs can look like a lncRNA next
  to its gene. Sensitivity: exclude pairs within 2 kb on the same strand.
- Local chromatin domains raise correlation for any neighbors. Sensitivity:
  repeat with gene–gene neighbor pairs at the same distances; a lncRNA
  effect should exceed the gene–gene baseline.
- Assembly contiguity limits the 50–100 kb bins (Peve N50 0.17 Mb; Ptuh on
  *P. meandrina*). Report the number of pairs per bin per species.
- Colony residualization uses 10 parameters from about 40 samples; report
  effective df.
- n is about 10 colonies per species.

## Amendments

(Leave empty. Dated entries only, added if the decision rule has to change.)
