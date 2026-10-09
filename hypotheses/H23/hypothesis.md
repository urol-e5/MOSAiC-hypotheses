---
id: H23
slug: acropora-plasticity-low-gbm
title: Acropora's excess seasonal expression plasticity is concentrated in low-methylation orthologs
status: proposed
tier: 2
layers: [cpg, genes, annotation]
species: [Apul, Peve, Ptuh]
depends_on: [H02, H05]
created: 2026-10-08
author: Steven Roberts (plan drafted with Claude)
---

Proposal from [docs/follow-up-hypotheses.md](../../docs/follow-up-hypotheses.md).
Not yet a complete pre-registration: see "Before moving to planned".

## Question

H02 found 5,007 timepoint-DE ortholog groups in Acropora versus 505 and 414
in Pocillopora and Porites. H05 found lower temporal variability with higher
GBM in all three species. Where in the methylation spectrum does the
Acropora excess reside?

## Hypothesis and prediction

The Acropora-versus-other-species difference in seasonal expression
amplitude is larger among low-GBM orthologs than among high-GBM orthologs.
This locates the species difference; it does not claim methylation causes
buffering.

## Data

Three-way orthologs with expression and at least five gene-body CpGs in
every species. About 10 colonies per species; the joint gene set will be
smaller than H05's 1,641 Acropora genes.

## Model

Seasonal amplitude per gene and species = SD of the four fitted timepoint
expression means, adjusting for colony. Fit amplitude ~ species *
within-species GBM percentile + mean expression + gene length + CpG count,
blocking on ortholog. Primary contrast: (Acropora minus mean of the other two
species) at GBM percentile 25, minus the same difference at percentile 75.
Amplitude in log-expression units; also report the contrast divided by a
common pooled SD across species (do not standardize away species
differences). Single primary contrast, so no multiple-testing correction.

## Decision rule

`supported`: primary contrast positive with a 95% colony-bootstrap CI
excluding zero (resample entire colony trajectories within species and site,
refitting the full procedure). `not supported`: CI entirely below zero.
Otherwise `inconclusive`.

## Known confounds and sensitivity checks

- Annotation quality: restrict to well-annotated, high-identity orthologs.
- CpG density: raise the CpG minimum to 20.
- Repeat with raw amplitude and with expression-matched GBM strata.
- Report whether the restricted gene set retains H02's Acropora excess; loss
  of that contrast limits interpretation.
- Differential CpG availability may exclude exactly the low-methylation
  genes of interest.

## Before moving to planned

- Fix the bootstrap replicate count.
- Fix the definition of "well-annotated, high-identity" ortholog.

## Amendments
