---
id: H16
slug: methylation-expression-lag-direction
title: Expression change precedes gene-body methylation change, not the reverse
status: not supported
tier: 2
layers: [cpg, genes, annotation, physiology]
species: [Apul, Peve, Ptuh]
depends_on: [H05, H06]
created: 2026-10-07
author: Steven Roberts (plan drafted with Claude)
---

## Question

Source question Q3 (causal direction). H06 asks whether methylation and
expression change together. This asks which one moves first: does a
gene's methylation at one timepoint predict its expression at the next
(methylation leads), or does expression predict later methylation
(expression leads)?

## Hypothesis and prediction

In invertebrates, gene-body methylation is thought to accumulate as a
consequence of transcription (H3K36me3-guided DNMT3 activity), so
expression should lead. Prediction: in a cross-lagged panel model, the
expression→methylation coefficient (beta_EM) is positive and larger than
the methylation→expression coefficient (beta_ME).

If false: beta_ME >= beta_EM, or neither differs from the null.

This is temporal precedence in observational data, not proof of causation;
RESULT.md must say so.

## Data

- Gene-level GBM (H05 definition) and vst expression (H01 filter) for
  samples with both layers at all four timepoints.
- Transitions TP1→TP2, TP2→TP3, TP3→TP4 per colony where both ends exist.
  Expected about 9–10 colonies (Apul, Peve), 7 (Ptuh); report n per
  transition.
- Gene set: the H06 DM genes (top 10% by |mean dGBM|) as primary; all GBM
  genes as sensitivity.
- Secondary (phenotype leg): `physiology` colony×timepoint means of
  `Host_AFDW.mg.cm2` and `calc.umol.cm2.hr`.

## Model

Random-intercept cross-lagged panel logic, fit on long data per species:

1. For each gene×colony, center GBM and expression on their own
   gene×colony mean (removes stable between-gene and between-colony
   differences, including the H05 level association).
2. Standardize the centered values within gene.
3. Expression model: `E[t+1] ~ E[t] + M[t] + interval + (1|colony) + (1|gene)`
   → beta_ME is the M[t] coefficient.
   Methylation model: `M[t+1] ~ M[t] + E[t] + interval + (1|colony) + (1|gene)`
   → beta_EM is the E[t] coefficient.
4. Null for each beta: pair each colony's methylation series with another
   colony's expression series (permute colony labels in the expression
   layer, 1000 times), refit.
5. Contrast beta_EM − beta_ME with a colony bootstrap 95% CI (2000).

Secondary: the same two-direction model at colony level between the
expression seasonal score (PC1 of vst on orthologs) and each physiology
trait. Descriptive, BH across the two traits.

Multiple testing: two primary coefficients per species, Holm within species
for the permutation p-values.

## Decision rule

- `supported` if, in at least two species, beta_EM > 0 with permutation
  p < 0.05 (Holm) and beta_EM − beta_ME has a CI excluding 0 on the
  positive side.
- `not supported` if beta_ME − beta_EM has a CI excluding 0 on the positive
  side in any species (methylation leads), or if neither beta differs from
  its null in all three species.
- `inconclusive` otherwise.

## Known confounds and sensitivity checks

- Unequal intervals (2, 6, 2 months). The interval term absorbs mean
  differences; sensitivity: fit TP1→TP2 and TP3→TP4 (both 2 months) only.
- Within-unit centering with 3–4 timepoints biases autoregressive terms
  (Nickell bias), and cross-lagged terms to a lesser extent. Both directions
  share the bias; the colony-permutation null carries it too.
- Methylation measurement noise is larger than expression noise, which
  attenuates beta_ME more than beta_EM and could favour "expression leads"
  artifactually. Sensitivity: genes with >= 20 CpGs, and a simulation at
  observed noise levels with no true lag to quantify the asymmetry.
- Species confounded with reference quality; repeat on three-way orthologs.
- n is about 10 colonies per species.

## Amendments

(Leave empty. Dated entries only, added if the decision rule has to change.)
