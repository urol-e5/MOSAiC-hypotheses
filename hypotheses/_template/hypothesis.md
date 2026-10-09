---
id: Hxx
slug: short-slug
title: One-sentence hypothesis as a claim
status: planned        # proposed | planned | running | supported | not supported | inconclusive | withdrawn
tier: 1                # 1 variance structure, 2 regulatory, 3 phenotype/environment, 4 integration
layers: [genes]        # layers from config/design.csv has_<layer> flags
species: [Apul, Peve, Ptuh]
depends_on: []         # other hypothesis ids whose results this one needs
created: YYYY-MM-DD
author:
---

## Question

What biological question does this answer, in one or two sentences?

## Hypothesis and prediction

State the hypothesis as a claim. Then state what you expect to see in the data
if it is true, and what you expect if it is false.

## Data

Which layers, which species, which samples (link to `config/design.csv` flags).
State the n you expect to have after filtering.

## Model

The exact model or test. Include the formula, the random-effect structure
(colony is always in it), the filtering thresholds, and the multiple-testing
correction.

## Decision rule

Written before running anything. What numeric outcome counts as `supported`,
what counts as `not supported`, and what leaves it `inconclusive`.

## Known confounds and sensitivity checks

Reference-genome quality, sample overlap across layers, site imbalance, etc.
Name the sensitivity analysis you will run for each.

## Amendments

(Leave empty. Dated entries only, added if the decision rule has to change.)
