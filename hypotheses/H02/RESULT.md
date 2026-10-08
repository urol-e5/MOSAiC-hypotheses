# H02 result

**Status:** supported

**Run on:** 2026-10-06 against MOSAiC commit `86432e3` (see `config/upstream.lock.yml`).
R 4.3.2, DESeq2 1.42.1. Runtime about 2 min on a 16 GB / 8-core laptop.

**Samples used:** about 10 colonies per species.

| Species | Samples | Colonies | Ortholog groups in | Pass H01 filter | Common to all three | Tested after DESeq2 independent filtering |
|---|---|---|---|---|---|---|
| Apul | 40 | 10 | 10,223 | 9,820 | 9,017 | 9,017 |
| Peve | 38 | 10 | 10,346 | 9,282 | 9,017 | 6,919 |
| Ptuh | 39 | 10 | 10,346 | 9,946 | 9,017 | 8,667 |

Missing samples: Peve has 9 at TP3 and TP4, Ptuh 9 at TP4. Median library
size (all genes): Apul 11.4 M, Peve 8.75 M, Ptuh 11.8 M.

**Headline numbers:** timepoint-DE ortholog groups (LRT `~ colony + timepoint`
vs `~ colony`, BH FDR < 0.05) and median of per-group max |log2 FC| over six
pairwise timepoint contrasts.

| Species | DE groups | Proportion DE (95% CI) | Median max \|LFC\| |
|---|---|---|---|
| Apul | 5,007 | 0.555 (0.545–0.566) | 0.877 |
| Ptuh | 505 | 0.058 (0.053–0.063) | 0.581 |
| Peve | 414 | 0.060 (0.054–0.066) | 0.559 |

Pairwise Wilcoxon rank-sum on max |LFC| (Hodges-Lehmann shift in log2 units,
95% CI, Holm-adjusted p); Kruskal-Wallis chi-squared = 2314.9, df = 2,
p < 1e-300.

| Pair | Shift (95% CI) | Holm p |
|---|---|---|
| Apul − Ptuh | 0.280 (0.267–0.294) | < 1e-300 |
| Ptuh − Peve | 0.014 (0.004–0.023) | 0.004 |
| Apul − Peve | 0.284 (0.271–0.298) | < 1e-300 |

Both orderings follow Apul > Ptuh > Peve and both adjacent tests are
significant, so the rule returns `supported`.

Sensitivity checks (pre-registered), all `supported`:

| Check | Groups | DE: Apul / Ptuh / Peve | Ptuh − Peve shift (95% CI) |
|---|---|---|---|
| avg_identity >= 60 | 7,252 | 4,151 / 401 / 285 | 0.023 (0.013–0.032) |
| SwissProt name | 3,709 | 2,058 / 194 / 141 | 0.033 (0.019–0.046) |
| Downsampled to 8.75 M | 8,897 | 4,999 / 501 / 402 | 0.017 (0.007–0.026) |

**Caveats:** n is about 10 colonies per species. The result is carried by
*Acropora*: over half of its ortholog groups change across the year, against
about 6% in the other two, and that gap is large and stable across every
check. The Ptuh > Peve step is not: the max-|LFC| shift is 0.014 log2 units
(about 1% fold change), significant only because about 9,000 groups enter the
test, and those groups are not independent observations, so the p-values are
optimistic. The Ptuh > Peve DE count is also partly an artifact of DESeq2
independent filtering, which tested 6,919 Peve groups against 8,667 Ptuh
groups; as a proportion of groups tested, Peve (0.060) and Ptuh (0.058) are
indistinguishable in the primary analysis. In the annotation subsets, where
all species are tested on the same groups, Ptuh does exceed Peve (5.5% vs
3.9% for `avg_identity >= 60`). Max |LFC| uses unshrunken MLEs. Species is
confounded with reference quality (Peve N50 0.17 Mb; Ptuh mapped to
*P. meandrina*) and with any species-specific sequencing-batch structure
across timepoints, which this analysis cannot separate from season. The
defensible reading is "Acropora is far more seasonally plastic than
Pocillopora or Porites", not a three-way ranking.

**Current Findings:** <https://robertslab.github.io/current-findings/reports/coral-seasonal-transcriptome-plasticity/> (seasonal transcriptome plasticity synthesis, with H01–H03).

**Outputs:** in `output/`
- `n_per_species.csv`, `design_per_timepoint.csv`, `library_sizes.csv`: samples, groups, and depth used
- `de_per_group.csv`: LRT statistics, all six pairwise LFCs, and max |LFC| per group and species (6.2 MB)
- `de_counts.csv`, `pairwise_wilcoxon.csv`: primary decision-rule numbers
- `de_counts_own_filter.csv`: DE counts with each species on its own filtered set
- `max_abs_lfc_violin.png`: figure; data in `de_per_group.csv`
- `sens_annotation_*.csv`, `sens_downsampled_*.csv`: sensitivity checks
- `verdicts.csv`: verdict for each analysis

supported
