# H01 result

**Status:** not supported

**Run on:** 2026-10-06 against MOSAiC commit `86432e3` (see `config/upstream.lock.yml`).
R 4.3.2, variancePartition 1.32.5, lme4 1.1-37, DESeq2 1.42.1. Runtime about
21 min on a 16 GB / 8-core laptop.

**Samples used:** about 10 colonies per species, 5 per site (Mahana, Manava).

| Species | Samples | Colonies | Genes in | Genes kept (>= 10 counts in >= 25%) | Three-way orthologs kept |
|---|---|---|---|---|---|
| Apul | 40 | 10 | 44,371 | 21,108 | 9,820 |
| Peve | 38 | 10 | 40,389 | 20,841 | 9,282 |
| Ptuh | 39 | 10 | 31,840 | 20,796 | 9,946 |

Missing samples: POR-236 TP3 and TP4, POC-201 TP4.

**Headline numbers:** median fraction of expression variance across genes,
95% bootstrap CI over genes (1000 resamples).

| Species | Colony | Timepoint | Rule outcome |
|---|---|---|---|
| Apul | 0.081 (0.077–0.084) | 0.104 (0.101–0.107) | timepoint > colony, CIs separate |
| Peve | 0.133 (0.130–0.138) | 0.00003 (0–0.001) | colony > timepoint, CIs separate |
| Ptuh | 0.086 (0.083–0.089) | 0.013 (0.012–0.015) | colony > timepoint, CIs separate |

The decision rule returns `not supported` because timepoint exceeds colony
with non-overlapping intervals in Apul. Colony dominates in Peve and Ptuh.
Residual variance is the largest component in all three species (median
0.65 Apul, 0.73 Peve, 0.80 Ptuh).

Sensitivity checks (pre-registered):

| Check | Apul colony / timepoint | Peve colony / timepoint | Ptuh colony / timepoint | Verdict |
|---|---|---|---|---|
| Site dropped | 0.112 / 0.100 | 0.209 / ~0 | 0.125 / 0.011 | supported |
| Three-way orthologs | 0.025 / 0.156 | 0.067 / 0.004 | 0.035 / 0.017 | not supported |

**Caveats:** n is about 10 colonies per species, and the intervals resample
genes, not colonies, so they are much narrower than the true uncertainty in
the colony and timepoint fractions; with 10 colony levels and 4 timepoint
levels the per-gene variance components are themselves poorly estimated. The
Apul call depends on how site is handled: site has 2 levels and is nested in
colony, and dropping it moves enough variance back to colony that Apul flips
to colony > timepoint (0.112 vs 0.100) and the overall verdict becomes
`supported`. The pre-registered model includes site, so the primary verdict
stands, but the Apul colony-vs-season ordering should be read as close, not
decisive. In contrast, the ortholog-only check widens the Apul gap (timepoint
0.156 vs colony 0.025), so the Apul seasonal signal is concentrated in
conserved genes and is not an artifact of reference-genome quality. Peve's
near-zero timepoint share may partly reflect its two missing late-year
samples and its lower-contiguity reference (N50 0.17 Mb).

**Outputs:** in `output/`
- `n_per_species.csv`, `design_per_colony.csv`: samples and design actually used
- `varpart_per_gene.csv`: per-gene variance fractions, primary model (5.7 MB)
- `varpart_violin.png`, `varpart_violin_summary.csv`: figure and the data behind it
- `median_fraction_ci.csv`, `decision_per_species.csv`: primary decision-rule numbers
- `sens_nosite_median_fraction_ci.csv`, `sens_ortho_median_fraction_ci.csv`: sensitivity checks
- `verdicts.csv`: verdict for each analysis

not supported
