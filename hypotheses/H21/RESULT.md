# H21 result

**Status:** inconclusive

**Run on:** 2026-10-08 against MOSAiC commit `86432e3` (see `config/upstream.lock.yml`).
R 4.3.2, DESeq2 1.42.1. Runtime about 20 s on a 16 GB / 8-core laptop.
Reproduction gate and test suite passed on 2026-10-08. The hypothesis listed
H11 as a dependency, but H11 was withdrawn; H21 used it only for the
stress-gene set. Amendment 1 in `hypothesis.md`, written before any
analysis, fixes that set as 37 ortholog groups:

- H11's documented successor rule: heat shock or chaperone in the SwissProt
  name, 21 groups.
- Antioxidants: 4 groups.
- Proteasome subunits: 12 groups.

The amendment also fixes the bootstrap, the decile-matched background null
and the Blomqvist correction.

**Samples used:** colonies with TP3 and at least one of TP1/TP2.

| Species | Colonies | Ortholog genes (after filter) | Stress genes | Heat shock / chaperone |
|---|---|---|---|---|
| Apul | 10 | 9,820 | 36 | 20 |
| Peve | 9 | 9,282 | 36 | 20 |
| Ptuh | 10 | 9,946 | 37 | 21 |

**Headline numbers:** per gene, Oldham r across colonies between level
((warm + cool)/2) and warm-season response (warm − cool), where warm is the
mean of TP1 and TP2 and cool is TP3. The CI comes from 2000 colony bootstraps.
The background is 1000 decile-matched random sets of non-stress orthologs,
and p is one-sided ("stress lower than background").

| Species | Median r, stress (95% CI) | Background median | Difference | p | Passes |
|---|---|---|---|---|---|
| Apul | −0.41 (−0.70 to −0.15) | −0.16 | −0.24 | 0.001 | yes |
| Peve | −0.32 (−0.58 to −0.11) | −0.20 | −0.12 | 0.079 | no |
| Ptuh | −0.24 (−0.56 to 0.04) | −0.21 | −0.03 | 0.38 | no |

One species passes and none has median r >= 0, so the rule returns
`inconclusive`.

**A bias in the pre-registered statistic (found on this run, not
corrected):** Oldham r is a monotone function of var(warm) − var(cool)
across colonies. "Warm" averages two samples (TP1, TP2) where both exist,
and "cool" is one sample (TP3). Averaging shrinks colony-to-colony variance,
so r is pushed negative for nearly every gene. Background medians are
−0.16 to −0.21, and the CI-excludes-0 half of the rule is biased toward
passing. The pre-registered TP1-vs-TP3 sensitivity check (one sample on
each side) removes the bias. There, background medians are +0.25 / +0.05 /
+0.12 and stress-set medians are about 0 (−0.01 / −0.09 / +0.09). The
comparison against the background is the meaningful part, because the
background shares the bias. On that comparison, Apul's stress genes
converge in the warm season more than matched background genes in both
versions: difference −0.24 (p = 0.001) and −0.26 (p = 0.006, TP1 vs TP3).
Peve's are weaker (−0.12, p = 0.079; −0.14, p = 0.057), and Ptuh shows
nothing (−0.03 and −0.03).

**Sensitivity checks (pre-registered or Amendment 1):**

| Check | Verdict | Apul / Peve / Ptuh: median r (p vs background) |
|---|---|---|
| Heat shock / chaperone only (20–21 genes) | supported | −0.39 (0.010) / −0.40 (0.028) / −0.18 (0.63) |
| TP1 vs TP3 only | inconclusive | −0.01 (0.006) / −0.09 (0.057) / +0.09 (0.38) |
| cells.cm2 partial r | inconclusive | −0.44 (0.001) / −0.27 (0.42) / −0.26 (0.30) |

The heat-shock-only check passes in Apul and Peve, but it inherits the same
averaging bias in the absolute criterion.

**Pitman–Morgan and Blomqvist (reported as pre-registered):**

| Species | Stress genes with Pitman–Morgan p < 0.05 | Background genes with Pitman–Morgan p < 0.05 | Median Blomqvist slope, stress / background |
|---|---|---|---|
| Apul | 25% | 10% | −1.80 / −0.55 |
| Peve | 28% | 11% | −0.44 / −0.52 |
| Ptuh | 3% | 12% | −0.87 / −0.39 |

**Secondary, cross-species constitutive rank:** the prediction failed, with
the effect in the opposite direction. Within their own transcriptomes, Peve
and Ptuh rank stress orthologs *lower* than Apul does: median percentile
difference −0.12 (Peve − Apul) and −0.04 (Ptuh − Apul), one-sided p of
about 1 for "higher". This is unchanged on orthologs with
`avg_identity >= 60` (−0.13, −0.04).

**Current Findings:** not reported separately. Under CLAUDE.md §6 the
verdict is not `supported`. The one robust signal (Apul stress genes
converge more than background) is a single-species result from about 10
colonies.

**Caveats:** n is about 10 colonies per species, so each gene's r rests on
9–10 points. The averaging bias above was not anticipated in the
pre-registration. It is reported, not fixed, because fixing it would change
the statistic after seeing the result; a successor hypothesis should use
single-sample warm and cool. Oldham r tests whether colonies converge in the
warm season. It is the pre-registered frontloading statistic, but it cannot
separate frontloading from any other process that makes colonies converge.
The stress set is a name-matching rule with known false positives (SPT6,
COQ8A; see `stress_set.csv`). Cross-species ranks depend on mapping quality
(Ptuh on *P. meandrina*; Peve N50 0.17 Mb). Generality beyond these three
coral genera (Q9: bivalves and others) is not tested; the code would apply
unchanged to another time series with the same structure. The figure's
background violin shows all background genes; the test uses decile-matched
draws.

**Outputs:** in `output/`
- `stress_set.csv`: the 37 groups, category and names (written before any statistic)
- `n_per_species.csv`: colonies and genes
- `oldham_summary.csv`, `stress_genes_oldham_r.csv`: primary numbers and per-gene r
- `oldham_r_stress_vs_background.png`, `figure_data.csv`: figure and its data
- `pitman_morgan_blomqvist.csv`: pre-registered reporting
- `sensitivity.csv`: sensitivity checks with verdicts
- `cross_species_ranks.csv`, `cross_species_tests.csv`: secondary
- `verdicts.csv`: verdict for each analysis

inconclusive
