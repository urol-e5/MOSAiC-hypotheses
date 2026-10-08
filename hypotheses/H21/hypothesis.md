---
id: H21
slug: frontloading-plasticity-tradeoff
title: Colonies with higher constitutive stress-gene expression show smaller seasonal responses in those genes
status: inconclusive
tier: 3
layers: [genes]
species: [Apul, Peve, Ptuh]
depends_on: [H02, H11]
created: 2026-10-07
author: Steven Roberts (plan drafted with Claude)
---

## Question

Source question Q9 (cross-taxa generality of the plasticity–frontloading
trade-off). Barshis et al. (2013) described frontloading: tolerant corals
keep stress genes constitutively high and respond less. Does the trade-off
hold among colonies within each of three coral genera here, and in the same
direction in all three?

Generality beyond corals (bivalves etc.) is not testable with these data.
The analysis code goes in `R/` so it can be applied to other datasets.

## Hypothesis and prediction

Frontloading and plasticity trade off. Prediction: within each species,
across colonies, the constitutive level of each stress ortholog is
negatively correlated with its warm-season response, more negatively than
for background orthologs. Across species, the less plastic species (Peve,
Ptuh per H02) rank stress orthologs higher within their own transcriptome
than Apul does.

If false: correlation is zero or positive, or no different from background.

## Data

- `genes_<species>`, three-way orthologs. Stress set as in H11 (SwissProt
  names matching heat-shock protein, chaperone, HSF), extended with
  antioxidant (SOD, catalase, peroxiredoxin, glutathione peroxidase) and
  ubiquitin-proteasome terms. The final gene list is written to
  `output/stress_set.csv` before any statistic is computed.
- Colonies with TP3 and at least one of TP1/TP2. Expected about 10 per
  species.

## Model

Cool baseline = TP3 (Sep). Warm = mean of TP1 and TP2 where available.

1. Per gene, across colonies: level = (warm + cool)/2, response =
   warm − cool. Oldham's method: correlating these (rather than cool with
   warm − cool) removes the regression-to-the-mean artifact under equal
   variances. Pitman–Morgan test of equal variances reported per gene set.
2. Statistic per species: median Oldham r over stress orthologs, minus
   median over background orthologs (all other three-way orthologs passing
   the H01 filter, matched on mean expression deciles).
3. CI by colony bootstrap (2000); p for the stress-vs-background difference
   by permuting gene-set labels within expression deciles (1000).
4. Cross-species (secondary): percentile rank of each stress ortholog
   within its species' mean expression distribution; paired Wilcoxon over
   orthologs, Peve vs Apul and Ptuh vs Apul, Holm.

Multiple testing: one primary test per species, Holm across the three for
reporting; the decision uses CIs.

## Decision rule

- `supported` if median Oldham r for the stress set is < 0 with CI
  excluding 0, and lower than background (permutation p < 0.05), in at
  least two species.
- `not supported` if the stress-set median r is >= 0 in at least two
  species.
- `inconclusive` otherwise.

## Known confounds and sensitivity checks

- Oldham's method is unbiased only if warm and cool variances are equal.
  If Pitman–Morgan rejects in a species, also report the Blomqvist
  correction using the cool-vs-TP4 repeatability.
- "Warm" mixes TP1 and TP2 depending on availability. Sensitivity: TP1 vs
  TP3 only.
- Constitutive level across colonies can reflect symbiont load or tissue
  composition. Sensitivity: add `cells.cm2` as a covariate (partial r).
- Cross-species expression rank depends on mapping (Ptuh on
  *P. meandrina*; Peve N50 0.17 Mb). Repeat the cross-species comparison on
  orthologs with `avg_identity >= 60`.
- n is about 10 colonies per species.

## Amendments

### Amendment 1 (2026-10-08), before any H21 analysis was run

**Problem.** The stress set was defined "as in H11", but H11 was withdrawn
before its gene set was used. "Ubiquitin-proteasome terms" matches 189 of
10,381 three-way ortholog groups, mostly E3 ligases, deubiquitinases and
autophagy proteins, which would swamp the heat-shock signal. Several details
of the test were not fixed.

**Change.** The original text above is kept; these replace it where they
conflict. The decision rule is unchanged.

- *Stress set* (`output/stress_set.csv`, written before any statistic):
  (i) H11's documented successor rule: "heat shock", "heat-shock" or
  "chaperon" anywhere in the SwissProt protein name (21 groups; known
  false positives such as SPT6 and COQ8A are kept, not curated);
  (ii) antioxidants: superoxide dismutase, catalase, peroxiredoxin or
  glutathione peroxidase in the recommended name (text before the first
  parenthesis), 4 groups; (iii) proteasome: recommended name starting
  "Proteasome subunit" or "26S proteasome", 12 groups. Union 37 groups
  before the expression filter.
- *Sensitivity*: set (i) alone.
- *Oldham r*: Pearson correlation across colonies of (warm + cool)/2 with
  warm − cool, per gene. This is a monotone function of var(warm) −
  var(cool), so r < 0 means colonies converge in the warm season.
- *Colony bootstrap CI*: resample colonies, recompute every gene's r, take
  the median over the stress set.
- *Background and p*: null median r of random gene sets with the same
  mean-expression-decile composition as the stress set (1000 draws from
  non-stress orthologs). One-sided p = (1 + #{null median <= observed}) /
  1001; "lower than background" means p < 0.05. Reported difference =
  observed median − mean null median.
- *Pitman–Morgan*: reported as the fraction of stress and background genes
  with p < 0.05. Blomqvist: per gene, slope b of (warm − cool) on cool,
  corrected with k = 1 − R, R = cor(TP3, TP4) across colonies clipped to
  [0.05, 1]: beta = (b + k) / (1 − k); median per set, descriptive.
