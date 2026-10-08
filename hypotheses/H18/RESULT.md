# H18 result

**Status:** not supported

**Run on:** 2026-10-07 against MOSAiC commit `86432e3` (see `config/upstream.lock.yml`).
R 4.3.2, DESeq2 1.42.1, lme4 1.1-37. Runtime 37 min on a 16 GB / 8-core
laptop (7 cores). Reproduction gate (`tests/run.R`) passed earlier the same
day. Analysis follows Amendment 1 in `hypothesis.md` (separate nulls for
the two unique fractions; ordered per-species classification), written
before any H18 analysis ran.

**Samples used:** samples with CpG, lncRNA and gene data. About 10 colonies
per species.

| Species | Samples | Colonies | GBM genes | Gene–lncRNA pairs (nearest, <= 10 kb) | Pairs with lncRNA-locus methylation (>= 5 CpGs) |
|---|---|---|---|---|---|
| Apul | 39 | 10 | 1,641 | 801 | 101 |
| Peve | 37 | 10 | 1,796 | 386 | 63 |
| Ptuh | 32 | 10 | 16,600 | 6,578 | 4,681 |

Genes with a cis-lncRNA partner have slightly higher GBM and expression than
those without (Apul median GBM 4.7 vs 3.1%, median vst 7.7 vs 7.2; Peve 4.8
vs 3.1%, 6.9 vs 6.1; Ptuh 1.24 vs 1.20%, 7.4 vs 7.3).

**Headline numbers:** commonality analysis of within-colony gene expression
(every variable centered on its gene×colony mean, standardized within gene).
p: one-sided, against 1000 colony permutations of the relevant layer (floor
0.001). Intervals: 2000 colony bootstraps.

| Species | Combined R² | unique methylation (p) | unique lncRNA (p) | shared (95% CI) |
|---|---|---|---|---|
| Apul | 0.0226 | 0.0013 (0.059) | 0.0212 (0.001) | 0.00009 (−0.00003 to 0.00019) |
| Peve | 0.0679 | 0.0003 (0.076) | 0.0676 (0.001) | 0.00000 (−0.00021 to 0.00038) |
| Ptuh | 0.0300 | 0.0004 (0.021) | 0.0295 (0.001) | 0.00008 (−0.00000 to 0.00022) |

Hierarchical path, lncRNA-locus methylation (M_L) → lncRNA (L) → gene (E),
standardized coefficients:

| Species | Rows | a: M_L → L (95% CI) | indirect a×b (95% CI) | total c: M_L → E (95% CI) | a×b / c |
|---|---|---|---|---|---|
| Apul | 3,939 | 0.043 (0.003 to 0.072) | 0.008 (0.001 to 0.013) | 0.029 (−0.016 to 0.077) | 0.27 |
| Peve | 2,331 | 0.045 (0.010 to 0.082) | 0.017 (0.004 to 0.028) | 0.044 (−0.008 to 0.082) | 0.38 |
| Ptuh | 149,792 | 0.014 (−0.003 to 0.028) | 0.002 (−0.000 to 0.005) | 0.013 (−0.005 to 0.031) | 0.18 |

Per-species classification (Amendment 1 order): Apul **hierarchical**, Peve
**hierarchical**, Ptuh **independent** (both unique fractions above null,
shared far below 25% of combined R²). Two species are hierarchical, so the
rule returns `not supported`.

OLS vs the pre-registered `lmer` fits on the observed data: largest
difference in any R² or commonality fraction 9e-6 (tolerance 1e-4), all
`lmer` fits singular as expected after centering. Refits used the
closed-form OLS solution.

**Sensitivity check (pre-registered), genes with >= 20 CpGs:**
`inconclusive`. Apul 164 pairs, unclassified (unique methylation p = 0.18;
path a −0.005, CI −0.058 to 0.044); Peve 155 pairs, hierarchical (a 0.046,
indirect 0.016, ratio 0.39); Ptuh 4,390 pairs, independent (unique
methylation p = 0.023). Unique lncRNA p = 0.001 and shared about 0 in all
three.

**Caveats:** n is about 10 colonies per species, with at most four
timepoints per colony. The verdict follows the pre-registered rule, but the
`hierarchical` calls are fragile. They rest on 101 (Apul) and 63 (Peve)
lncRNAs with enough CpGs to measure locus methylation. The path a effect is
about r = 0.04 (0.2% of within-colony lncRNA variance). The total effect c
of lncRNA-locus methylation on the gene has a CI that includes 0 in both,
so the a×b / c ratio is unstable. The Apul call does not survive the
>= 20 CpG check. The robust results are simpler. First, the two channels
are nearly disjoint: the shared fraction is about 0 in every species and
check, so methylation and lncRNA are not redundant. Second, methylation
explains almost no within-colony expression variance (unique fraction
0.03–0.13%, above the null only in Ptuh). This is consistent with H06 and
H16, which found no coupling between methylation change and expression
change. Third, the nearest cis-lncRNA explains 2–7%. Per H17 that is mostly
generic local co-expression, so "lncRNA channel" here means "a nearby
transcript", not demonstrated regulation. In the Amendment 1 ordering,
hierarchical is checked before independent; Apul and Peve would not have
been independent anyway, because their unique methylation fractions are not
above the null. lncRNA strand is unknown (D-014). miRNA, a third channel, is
out of scope. CpG density differs about 20-fold across species (D-008),
which is why Ptuh has 10 times more pairs.

**Current Findings:** <https://robertslab.github.io/current-findings/reports/coral-gene-body-methylation-stable-not-seasonal/> (gene-body methylation synthesis, with H04–H06, H15, H16, H18).

**Outputs:** in `output/`
- `n_per_species.csv`, `included_vs_excluded_genes.csv`: samples, pairs, and the selected-subset check
- `commonality_summary.csv`: R², commonality fractions, nulls, path coefficients, CIs, `lmer` values, classification
- `null_draws.csv`: all permutation draws for both nulls (1.6 MB)
- `ols_vs_lmer.csv`: equivalence check
- `commonality.png`, `commonality_figure_data.csv`: figure and its data
- `sens_mincpg20_summary.csv`: >= 20 CpG check
- `verdicts.csv`: verdict for each analysis

not supported
