---
id: H07
slug: mirna-conservation
title: Seasonal miRNA expression profiles are conserved across species for shared miRNA families
status: inconclusive
tier: 2
layers: [mirna]
species: [Apul, Peve, Ptuh]
depends_on: []
created: 2026-10-06
author: Steven Roberts (plan drafted with Claude)
---

## Question

Do miRNAs that are homologous across the three species (same cnidarian miRBase
annotation) show the same seasonal expression pattern?

## Hypothesis and prediction

Conserved miRNAs have conserved temporal regulation. Prediction: for
miRNAs annotated to the same family in two species, per-timepoint z-score
profiles are positively correlated more often than expected by chance.

## Data

`mirna_<species>` (51 / 48 / 40 confirmed loci). Family assignment from the
ShortStack `Results.txt` known-miRNA column; this is NOT in the manifest yet
and must be added (`timeseries_molecular` ShortStack outputs; see
MOSAiC `docs/mirna-notes.md`). Until then the hypothesis cannot run.

## Model

DESeq2-normalized counts, per-timepoint colony means, z-scored within miRNA.
Pearson r between homologous pairs; null from all non-homologous cross-species
pairs. Test: Wilcoxon rank-sum of homologous vs non-homologous r.

## Decision rule

`supported` if the median r among homologous pairs exceeds the non-homologous
median by > 0.3 with Wilcoxon p < 0.05, for at least two species pairs.
`not supported` if homologous pairs are not higher in any species pair.
Otherwise `inconclusive`.

## Known confounds and sensitivity checks

- Only tens of miRNAs; few homologous pairs. Report the pair count.
- Novel (de novo) miRNAs cannot be matched; they are excluded by design.

## Amendments
