# H13 result

**Status:** not supported

**Run on:** 2026-10-08 on raven against MOSAiC commit `86432e3` (see `config/upstream.lock.yml`).
R 4.3.3, MOFA2 1.12.1 (mofapy2 through basilisk), lme4 1.1-37, DESeq2 1.42.1.
Runtime 1 min 45 s for 15 MOFA2 fits. Reproduction gate and test suite passed
the same day. The analysis was committed (`e0836d2`) before the full run;
a smoke test of the code on Apul (primary and all-six models) was run before
that commit, and nothing in the analysis changed afterwards.

**Samples used:** about 10 colonies per species.

| Species | Samples (any view) | Samples with all six views | Summer / winter, all six | Colonies |
|---|---|---|---|---|
| Apul | 40 | 28 | 9 / 19 | 10 |
| Peve | 38 | 28 | 16 / 12 | 10 |
| Ptuh | 39 | 22 | 8 / 14 | 10 |

Features per view (top 5000 by variance; all miRNAs): genes 5000, lncRNA
5000, CpG 5000, miRNA 51 / 48 / 40, metabolomics 101 / 113 / 129, lipidomics
361 / 358 / 368 (Apul / Peve / Ptuh). miRNA libraries below 1,000 reads were
dropped (D-011), which removes 8 Peve and 1 Ptuh samples from that view.
Metabolomics and lipidomics have no TP2 samples for Apul and Ptuh.

**Headline numbers.** The factor with the highest total variance explained
(sum of per-view R²) in each species, primary model (missing views allowed):

| Species | Top factor total R² (%) | Views > 5% | Summer/winter AUC | Colony ICC | Largest views (R² %) | Rule outcome |
|---|---|---|---|---|---|---|
| Apul | 56.8 | 5 | 0.545 | 0.969 | lipidomics 23.3, CpG 14.3 | colony-dominated |
| Peve | 41.9 | 4 | 0.533 | 0.926 | CpG 14.9, lncRNA 7.9 | colony-dominated |
| Ptuh | 46.0 | 5 | 0.589 | 0.858 | CpG 17.9, lipidomics 10.7 | colony-dominated |

In every species the top factor spans several layers but separates colonies,
not seasons (ICC > 0.7, AUC < 0.6), so the rule's `not supported` clause
holds in all three. Colony structure dominates the whole model: 7 of 10
factors (Apul), 8 (Peve) and 9 (Ptuh) have colony ICC > 0.7, and no factor in
any species reaches AUC 0.8. The most seasonal factors are an expression-only
axis (Apul Factor 2, AUC 0.57, genes 26.7% and lncRNA 11.1%, ICC 0; Ptuh
Factor 3, AUC 0.72, genes 12.3% and lncRNA 12.6%, ICC 0) and a weak Peve
factor (Factor 8, AUC 0.58). The prediction's second part, a later factor that
separates colonies, is the rule here rather than the exception.

Sensitivity checks:

| Analysis | Apul | Peve | Ptuh | Verdict |
|---|---|---|---|---|
| All six views (pre-registered) | colony-dominated (AUC 0.54, ICC 0.97) | colony-dominated (0.52, 0.94) | passes (AUC 0.85, ICC 0.96, 3 views; lipidomics 34%) | inconclusive |
| Seeds 1, 2, 3 (not pre-registered) | colony-dominated | colony-dominated | colony-dominated | not supported (all three) |

The Ptuh all-six result should not be read as a seasonal factor. That set has
22 samples, 1 to 3 per colony, with two colonies sampled only in summer and
two only in winter, so colony and season are partly confounded; a factor with
colony ICC 0.96 can reach AUC 0.85 without any seasonal signal. Across seeds
the top-factor statistics change in the third decimal place.

**Caveats:** n is about 10 colonies per species; AUC compares about 20
summer with 20 winter samples and ICC rests on 10 colony levels. MOFA2 warned
that 10 factors is many for about 40 samples (it suggests at most about 7);
10 is pre-registered. In the Apul smoke test MOFA2 also flagged Factor 1 (the
top factor) and Factor 7 as correlated with total feature levels in at least
one view, which can indicate normalisation or depth differences between
samples; the notebook suppresses warnings, so this was not checked for the
other models. Variance explained is not comparable across views of very
different size (about 50 miRNAs against 5000 genes; views are not scaled), and
the colony-dominated top factors load most on CpG and lipidomics, the layers
where colony identity is strongest (compare H04 for CpG). Apul's season
signal in expression is mostly a TP2 (March) effect, not a TP1/TP2 vs TP3/TP4
split (gene PC1 has AUC 0.94 for TP2 vs the rest but 0.59 for summer vs
winter, checked during the smoke test), so the pre-registered season contrast
may miss the seasonal structure that exists. Peve miRNA depth falls with
timepoint (D-011). CpG matrices differ in construction across species (D-008,
D-015). Species is confounded with reference quality (Peve N50 0.17 Mb; Ptuh
mapped to *P. meandrina*).

**Current Findings:** not reported separately. Under CLAUDE.md §6 the verdict
is not `supported`, there was no power or simulation check, and AUC and ICC
are not effect sizes with intervals. It bears on the same question as the
seasonal transcriptome plasticity synthesis (H01–H03: colony vs season), which
could cite it.

**Outputs:** in `output/`
- `n_per_species.csv`, `n_per_view.csv`, `sample_view_overlap.csv`: samples, features and view overlap actually used
- `factors_primary.csv`, `decision_per_species.csv`: all factors and the decision, primary model
- `variance_explained.png`, `variance_explained_figure_data.csv`: figure and its data
- `sens_complete_factors.csv`, `sens_complete_decision.csv`: all-six-views sensitivity check
- `sens_seeds_decision.csv`: initialisation seeds (not pre-registered)
- `verdicts.csv`: verdict for each analysis

not supported
