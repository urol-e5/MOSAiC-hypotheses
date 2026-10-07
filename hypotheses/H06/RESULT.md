# H06 result

**Status:** inconclusive

**Run on:** 2026-10-07 against MOSAiC commit `86432e3` (see `config/upstream.lock.yml`).
R 4.3.2, DESeq2 1.42.1, lme4 1.1-37. Runtime about 2 min on a 16 GB / 8-core
laptop. Analysis follows Amendment 1 in `hypothesis.md` (committed in
`3732734` before the full run).

**Samples used:** colonies with TP1 and TP3 in both the CpG and gene layers.
About 10 colonies per species before pairing.

| Species | Paired colonies | Samples with both layers | Genes (>= 5 CpGs, expressed) | DM genes (top 10% \|dGBM\|) |
|---|---|---|---|---|
| Apul | 9 | 39 | 1,641 | 165 |
| Peve | 9 | 37 | 1,796 | 180 |
| Ptuh | 7 | 32 | 16,600 | 1,660 |

**Headline numbers:** T = mean over paired colonies of Spearman rho between a
colony's TP3−TP1 gene-body methylation change and its TP3−TP1 expression
change across genes; one-sided p from 1000 permutations pairing each colony's
methylation change with another colony's expression change. Mixed model
`expr ~ gbm + (1|colony) + (1|gene)` on DM genes, slope in vst units per 10
percentage points of GBM, Wald 95% CI.

| Species | T | Permutation p | T, DM genes (p) | Mixed-model slope (95% CI) | Passes |
|---|---|---|---|---|---|
| Apul | −0.014 | 0.95 | −0.047 (0.96) | 0.027 (0.003–0.051) | no |
| Peve | 0.006 | 0.42 | −0.003 (0.45) | 0.020 (−0.006 to 0.046) | no |
| Ptuh | 0.018 | 0.088 | 0.024 (0.030) | 0.071 (0.054–0.088) | no |

No species has T > 0 with p < 0.05, so `supported` is impossible; T > 0 in
Peve and Ptuh, so `not supported` (T <= 0 in all three) does not apply. The
rule returns `inconclusive`.

Descriptive, colony-averaged rho (the originally stated statistic; includes
the seasonal shift shared by all colonies): Apul −0.014 (−0.059 to 0.040),
Peve 0.033 (−0.012 to 0.076), Ptuh 0.038 (0.023–0.053).

**Power (pre-registered):** coupling of strength b added to colony-shuffled
(uncoupled) data, 200 simulations per b, 199 permutations each.

| Species | b = 0.01 | b = 0.02 | b = 0.03 | b = 0.05 |
|---|---|---|---|---|
| Apul | T 0.014, power 0.22 | T 0.024, 0.64 | T 0.034, 0.92 | T 0.052, 1.00 |
| Peve | T 0.016, 0.35 | T 0.027, 0.77 | T 0.037, 0.99 | T 0.058, 1.00 |
| Ptuh | T 0.021, 0.43 | T 0.031, 0.90 | T 0.042, 1.00 | T 0.063, 1.00 |

The test was adequately powered (>= 0.8) for per-colony coupling of about
T = 0.03 and above in every species. All observed T values are below 0.02.

Sensitivity check (pre-registered), 2 kb upstream windows (529 / 570 / 15,754
genes): T −0.006 / −0.012 / 0.002, p 0.66 / 0.84 / 0.29; `inconclusive`.

**Caveats:** n is 7 to 9 paired colonies per species (about 10 before
pairing). The verdict is `inconclusive` by the rule, but the power analysis
makes it informative: within-colony coupling between seasonal gene-body
methylation change and expression change, if it exists, is weaker than a
per-colony rho of about 0.03 across genes in all three species, which the
test would have detected. Ptuh is the only species with a hint (DM genes
p = 0.030, all genes p = 0.088), with 10 times more genes and only 7
colonies; one species does not meet the two-species rule. The positive
mixed-model slopes in Apul and Ptuh should not be read as support: with only
gene and colony random effects they largely reflect the static GBM-expression
association already shown in H05, not coupling of changes. Likewise, the
Ptuh colony-averaged rho (0.038) is driven by the seasonal shift that all
colonies share, which the amended null removes. Each per-colony change rests
on one TP1 and one TP3 sample per layer, so it carries the full sampling
noise of both; gene sets differ about 10-fold across species because of the
unequal upstream CpG filtering (decision D-008). TP1 and TP3 differ in
temperature, light, nutrients and reproductive timing, so no driver can be
assigned.

**Outputs:** in `output/`
- `n_per_species.csv`: paired colonies, samples and genes used
- `coupling_summary.csv`: T, permutation p, DM-gene T, colony-averaged rho, mixed-model slope
- `coupling_per_colony.csv`, `coupling_matrix.csv`: per-colony rho and the full colony x colony matrix
- `coupling_same_vs_other_colony.png`: figure; data in `coupling_matrix.csv`
- `deltas_per_gene.csv`: colony-averaged dGBM and dExpr per gene
- `power.csv`: simulated power at the observed n
- `sens_upstream2kb_summary.csv`: 2 kb upstream check
- `verdicts.csv`: verdict for each analysis

inconclusive
