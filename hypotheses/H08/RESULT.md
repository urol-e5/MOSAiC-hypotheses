# H08 result

**Status:** supported

**Run on:** 2026-10-07 against MOSAiC commit `86432e3` (see `config/upstream.lock.yml`).
R 4.3.2, DESeq2 1.42.1, reference BLAS. Runtime 4 h 25 min on a 16 GB /
8-core laptop with 6 workers (machine shared with another job).

**Samples used:** about 10 colonies per species; samples with both lncRNA and
gene counts.

| Species | Samples | Colonies | lncRNAs kept | Genes kept | lncRNA x mRNA pairs |
|---|---|---|---|---|---|
| Apul | 40 | 10 | 15,559 | 21,108 | 328,419,372 |
| Peve | 38 | 10 | 8,319 | 20,841 | 173,376,279 |
| Ptuh | 39 | 10 | 11,236 | 20,796 | 233,663,856 |

The H01 filter removed no lncRNAs; they were filtered upstream.

**Headline numbers:** pairs with |r| >= threshold (Pearson on vst), observed
vs 200 full permutations of lncRNA sample labels (the decision null).
Empirical p = 1/201 = 0.005 (the floor) in every cell.

| Species | Observed, \|r\| >= 0.8 / 0.9 / 0.95 | Null median | Null 95th percentile |
|---|---|---|---|
| Apul | 337,796 / 17,285 / 832 | 0 / 0 / 0 | 4 / 0 / 0 |
| Peve | 65,442 / 3,707 / 586 | 0 / 0 / 0 | 4 / 0 / 0 |
| Ptuh | 91,823 / 2,203 / 282 | 0 / 0 / 0 | 32 / 0 / 0 |

The observed count exceeds the null 95th percentile at all three thresholds
in all three species, so the rule returns `supported`.

Sensitivity checks, each `supported` at every threshold and species:

| Analysis | Null | Apul, \|r\| >= 0.8: observed (null median, 95th pct) | Verdict |
|---|---|---|---|
| Primary | within-timepoint | 337,796 (865, 5,488) | supported |
| Colony-residualized | full permutation | 1,453,246 (0, 1) | supported |
| Colony-residualized | within-timepoint | 1,453,246 (20,547, 65,512) | supported |

At |r| >= 0.9 every within-timepoint null median is 0 to 5. Full table in
`edge_counts_vs_null.csv`.

**Caveats:** n is about 10 colonies per species, each sampled at four
timepoints. The pre-registered question is answered decisively: with about 40
samples, strong lncRNA-mRNA correlations vastly exceed what sample-label
noise produces, unlike the n = 5 setting in which the published 0.99 cut sat
near the null. This does **not** show lncRNA-specific co-regulation. lncRNA
and mRNA counts are quantified from the same RNA-seq libraries, so any
per-sample technical variation (RNA integrity, library composition, and reads
shared where a lncRNA overlaps or is antisense to a gene) appears in both
layers, and every lncRNA-label permutation breaks it; vst removes depth
differences, not quality. The within-timepoint null shows that shared
seasonal signal alone produces few strong edges, and colony residualization
*raises* the counts (Apul 338k to 1.45M at 0.8) rather than lowering them, so
the edges are driven by sample-level structure below colony and season, which
is where shared library effects would sit. Separating co-regulation from that
needs a different null (for example lncRNAs at least 10 kb from any gene, or
both layers residualized on a per-sample quality score), which would be a new
pre-registered hypothesis. Edge counts are not independent: one lncRNA
correlated with a gene module contributes many edges. Species is confounded
with reference quality (Peve N50 0.17 Mb; Ptuh mapped to *P. meandrina*),
which affects lncRNA annotation.

**Outputs:** in `output/`
- `n_per_species.csv`: samples, features and pairs
- `edge_counts_vs_null.csv`: observed and null summaries for every species x analysis x null x threshold
- `null_counts.csv`: all 2,400 permutation edge counts
- `edges_vs_null.png`: figure; data in the two CSVs above
- `verdicts.csv`: verdict for each analysis x null

supported
