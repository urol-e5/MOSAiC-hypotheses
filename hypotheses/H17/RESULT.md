# H17 result

**Status:** supported

**Run on:** 2026-10-07 against MOSAiC commit `86432e3` (see `config/upstream.lock.yml`).
R 4.3.2, DESeq2 1.42.1. Runtime about 75 s on a 16 GB / 8-core laptop.
Reproduction gate (`tests/run.R`) passed earlier the same day. Analysis
follows Amendment 1 in `hypothesis.md` (lncRNA strand unknown upstream,
D-014; null construction fixed), written before any H17 analysis ran.

**Samples used:** samples with both lncRNA and gene counts; both layers vst'd
on the same samples and residualized on colony. About 10 colonies per species.

| Species | Samples | Colonies | Residual df | lncRNAs | Genes | Cis pairs (<= 10 kb, not overlapping) | lncRNAs in cis pairs |
|---|---|---|---|---|---|---|---|
| Apul | 40 | 10 | 30 | 15,559 | 21,108 | 21,666 | 11,092 |
| Peve | 38 | 10 | 28 | 8,319 | 20,841 | 8,528 | 5,270 |
| Ptuh | 39 | 10 | 29 | 11,236 | 20,796 | 16,220 | 7,962 |

**Headline numbers:** median Pearson r over cis pairs vs 1000 null medians,
each from one expression-decile-matched partner per pair taken from other
scaffolds. dr = observed median − mean null median, 95% interval from the
null draws; one-sided p (floor 1/1001). Distance decay = Spearman of the four
bin medians on bin rank.

| Species | Median r, cis (95% CI over pairs) | Null median | dr (95% interval) | p | Decay rho |
|---|---|---|---|---|---|
| Apul | 0.138 (0.132–0.144) | 0.020 | 0.117 (0.112–0.123) | 0.001 | −1 |
| Peve | 0.193 (0.184–0.201) | 0.002 | 0.191 (0.184–0.199) | 0.001 | −1 |
| Ptuh | 0.176 (0.169–0.182) | 0.049 | 0.127 (0.121–0.133) | 0.001 | −1 |

dr > 0.05 with p < 0.01 in all three species, and r falls monotonically with
distance in all three, so the rule returns `supported`.

Median r by distance bin (non-overlapping pairs), lncRNA–gene vs the
pre-registered gene–gene neighbor baseline:

| Species | Pair type | 0–2 kb | 2–10 kb | 10–50 kb | 50–100 kb |
|---|---|---|---|---|---|
| Apul | lncRNA–gene | 0.202 (5,925) | 0.114 (15,741) | 0.059 (67,602) | 0.042 (83,901) |
| Apul | gene–gene | 0.182 (6,624) | 0.121 (14,608) | 0.073 (54,703) | 0.051 (63,318) |
| Peve | lncRNA–gene | 0.352 (2,896) | 0.124 (5,632) | 0.046 (18,321) | 0.011 (14,663) |
| Peve | gene–gene | 0.139 (3,947) | 0.092 (9,390) | 0.042 (24,850) | 0.020 (19,775) |
| Ptuh | lncRNA–gene | 0.262 (4,543) | 0.143 (11,677) | 0.088 (54,081) | 0.064 (65,706) |
| Ptuh | gene–gene | 0.174 (7,136) | 0.152 (16,249) | 0.106 (62,654) | 0.080 (71,775) |

Pairs per bin in parentheses.

**Sensitivity checks (pre-registered):**

| Check | dr Apul / Peve / Ptuh (all p = 0.001) | Verdict |
|---|---|---|
| Timepoint also residualized | 0.095 / 0.187 / 0.127 | supported |
| Pairs within 2 kb dropped (Amendment 1: all strands) | 0.094 / 0.124 / 0.094 | supported |
| Gene–gene neighbors, same null (<= 10 kb) | 0.109 / 0.099 / 0.089 | baseline, no verdict |
| lncRNA dr minus gene–gene dr | 0.009 / 0.092 / 0.038 | descriptive |

Overlapping lncRNA–gene pairs, excluded from the test: 9,555 / 3,949 / 6,520
pairs with median r 0.54 / 0.71 / 0.61, as expected from shared reads.

**Orientation split (pre-registered Model step 6):** not estimable; upstream
lncRNA features carry no strand (D-014).

**Caveats:** n is about 10 colonies per species (38–40 samples, 28–30
residual df after colony). By the pre-registered rule lncRNAs co-vary with
nearby genes well above an expression-matched trans background, and the
coupling decays with distance, in all three species and all checks. The
magnitude is modest: median r 0.14–0.19 within 10 kb, or about 2–4% of
within-colony variance. Two qualifications limit what this says about
lncRNA *regulation* (source question Q5). First, the pre-registered
gene–gene baseline shows that most of the effect is generic local
co-expression: beyond 2 kb, lncRNA–gene pairs track neighboring gene–gene
pairs closely in every species (Apul and Ptuh slightly below; Peve slightly
above at 2–10 kb), and in Apul the overall lncRNA excess over gene–gene is
only 0.009. Second, the lncRNA-specific excess is concentrated within 2 kb
(Peve 0.35 vs 0.14, Ptuh 0.26 vs 0.17), which is exactly where unannotated
UTRs, read-through and antisense transcripts would sit. Without lncRNA
strand those cannot be separated from regulation. Peve, the species with the
largest near-gene excess, also has the most fragmented assembly (N50
0.17 Mb) and so the least complete gene models; Ptuh is mapped to
*P. meandrina*. The bootstrap CI on the median treats pairs as independent,
which they are not (a lncRNA can pair with several genes), so it is
optimistic; the null-based dr interval keeps that structure. Because null
partners are measured in the same samples, the per-sample library effects
flagged in H08 are in both the observed and null medians and cancel in dr.
Correlation is not function: functional validation still needs perturbation.

**Current Findings:** <https://robertslab.github.io/current-findings/reports/coral-lncrna-cis-coexpression/> (lncRNA co-expression, with H08 and H17).

**Outputs:** in `output/`
- `n_per_species.csv`: samples, colonies, residual df, features
- `cis_vs_null_summary.csv`: median r, null median, dr with interval, p, decay rho, overlap pairs, decision columns
- `null_medians.csv`: all null medians
- `r_by_distance_bin.csv`, `r_by_distance.png`: bins and figure
- `sens_gene_gene_summary.csv`, `sens_gene_gene_bins.csv`: gene–gene baseline
- `lncrna_vs_gene_gene_bins.csv`, `lncrna_vs_gene_gene.png`: comparison figure and its data
- `sens_timepoint_resid_summary.csv`, `sens_timepoint_resid_bins.csv`, `sens_no_2kb_summary.csv`: sensitivity checks
- `verdicts.csv`: verdict for each analysis

supported
