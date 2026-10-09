# Five follow-up hypotheses from supported MOSAiC findings

Developed 2026-10-08 from the committed results of H02, H05, H08, H10,
and H17. H23–H27 each have a `hypotheses/Hxx/hypothesis.md` at
`status: proposed` (D-016); these are test plans, not completed
pre-registrations or tested results. No new
associations were calculated to choose these predictions or thresholds.

The strongest starting points are: Acropora has substantially greater
seasonal expression plasticity than the other two species; gene-body
methylation (GBM) associates with high, stable expression; lncRNA–mRNA
co-expression exceeds label-permutation nulls and increases with proximity;
and ITS2 composition is more similar within colonies than between colonies.
The small Pocillopora–Porites plasticity difference, lncRNA regulation,
and a causal effect of methylation are not established by those findings.

## H23. Acropora's excess seasonal plasticity is concentrated in low-methylation genes

*Pre-registered 2026-10-08 in [hypotheses/H23](../hypotheses/H23/hypothesis.md),
which supersedes this section: the joint gene set below has only 88
orthologs, so the primary test uses per-species gene sets.*

**Basis:** [H02](../hypotheses/H02/RESULT.md) found 5,007 timepoint-DE
ortholog groups in Acropora versus 505 and 414 in Pocillopora and Porites.
[H05](../hypotheses/H05/RESULT.md) found lower temporal variability with
higher GBM in all three species.

**New prediction:** The Acropora-versus-other-species difference in seasonal
expression amplitude is larger among low-GBM orthologs than among high-GBM
orthologs. This tests where the species difference resides, extending H05's
within-species association without claiming methylation causes buffering.

**Test:** Use three-way orthologs with expression and at least five gene-body
CpGs in every species. Expect approximately 10 colonies per species, with
the joint gene set smaller than H05's 1,641 Acropora genes. Estimate seasonal
amplitude as the SD of four fitted timepoint expression means, adjusting for
colony. Fit amplitude against species, within-species GBM percentile,
their interaction, mean expression, gene length, and CpG count; block on
ortholog. Define one primary contrast: the Acropora amplitude minus the
mean of the other two species at GBM percentile 25, minus that same species
difference at percentile 75. Express amplitude in log-expression units and
report the contrast also divided by a common pooled SD across species;
do not standardize away species differences in amplitude.

**Evidence criterion:** Support requires a positive primary contrast with
a 95% colony-bootstrap CI excluding zero. Resample entire colony trajectories
within species and site, refitting the full procedure. A CI entirely below
zero contradicts the prediction; otherwise the result is inconclusive.

**Checks:** Restrict to well-annotated, high-identity orthologs; raise the CpG
minimum to 20; repeat with raw amplitude and expression-matched GBM strata.
Report whether the restricted gene set retains H02's Acropora excess. Loss
of that contrast limits interpretation. Differential CpG availability may
exclude exactly the low-methylation genes of interest.

## H24. Orthologs retain similar gene-body methylation ranks across species

*Pre-registered 2026-10-08 in [hypotheses/H24](../hypotheses/H24/hypothesis.md),
which supersedes this section: correlations use per-pair ortholog sets (91,
678 and 610) instead of the 88-gene three-way set.*

**Basis:** [H05](../hypotheses/H05/RESULT.md) supported the same GBM–expression
relationship in all three species, but did not establish whether the same
genes occupy the methylated portion of each genome.

**New prediction:** Matched orthologs have more similar GBM ranks across
species than unrelated genes matched for expression, gene length, and CpG
count. This tests conservation of gene identity underlying the pattern,
rather than repeating the GBM–expression correlation.

**Test:** Use the same common, three-way ortholog set and approximately
10 colonies per species. Calculate mean GBM by first averaging within
colony, then equally across colonies. Compute Spearman correlations of
GBM ranks for all three species pairs. Compare each observed correlation
with 2,000 ortholog-label permutations constrained by prespecified bins of
mean expression, gene length, and CpG count. Define bin-merging rules before
analysis if matching strata are sparse. Obtain CIs by resampling whole
colonies within species and site, and adjust the three permutation p-values
with Holm's method.

**Evidence criterion:** Support requires rho > 0.30, a colony-bootstrap CI
above zero, and Holm-adjusted p < 0.05 for all three species pairs. A pair
with its CI entirely below zero contradicts universal conservation;
remaining outcomes are inconclusive. The 0.30 threshold is a proposed
minimum effect, not an estimate from these data.

**Checks:** Repeat with at least 20 CpGs, high-identity annotated orthologs,
and equal numbers of sampled CpGs per gene. The delivered methylation
matrices lack read coverage, so these checks cannot equalize sequencing
depth. Conservation of ranks would not establish evolutionary conservation
of a causal regulatory mechanism.

## H25. Beyond 2 kb, local co-expression is largely independent of transcript class

*Pre-registered 2026-10-09 in [hypotheses/H25](../hypotheses/H25/hypothesis.md),
which supersedes this section: the margin is ±25% of the gene–gene signal
instead of ±0.05, and scaffold matching is replaced by the scaffold-block
bootstrap.*

**Basis:** [H17](../hypotheses/H17/RESULT.md) supported cis co-expression,
but its descriptive gene–gene comparison showed similar correlations to
lncRNA–gene pairs beyond 2 kb. [H08](../hypotheses/H08/RESULT.md) established
abundant co-expression, without showing lncRNA specificity.

**New prediction:** At matched distances from 2–100 kb, lncRNA–gene and
gene–gene pairs have practically equivalent correlations. Shared local
transcriptional structure is one possible explanation; chromatin domains
are not directly measured here.

**Test:** Use gene and lncRNA expression and coordinates in each species
(38–40 samples; approximately 10 colonies). Exclude overlapping pairs and
pairs within 2 kb. Residualize both layers on colony and timepoint. Match
the two pair classes within the 2–10, 10–50, and 50–100 kb bins for distance,
expression mean and variance, and scaffold where possible. Equally weight
bins to calculate the difference in median residual correlation between
pair classes. Bootstrap whole colonies and recompute the statistic; assess
genomic dependence separately with a scaffold-block bootstrap.

**Evidence criterion:** Test equivalence using a prespecified margin of
−0.05 to +0.05 correlation units. Require both one-sided equivalence tests
to pass after Holm correction across species, in every species. An interval
wholly beyond either margin contradicts equivalence for that species;
failure to establish equivalence is otherwise inconclusive, not support
for a transcript-class difference.

**Checks:** Repeat without timepoint residualization, restrict to longer
scaffolds, and require concordant conclusions under colony and scaffold
resampling. Unknown lncRNA strand and incomplete gene models remain limits.
This explicitly formalizes a pattern already seen in H17's secondary
results: testing it again on MOSAiC is exploratory follow-up. Independent
colonies or a new year are needed for confirmation.

## H26. Distal lncRNA–mRNA co-expression generalizes to held-out colonies

**Basis:** [H08](../hypotheses/H08/RESULT.md) found abundant strong edges,
but shared libraries could contribute. [H17](../hypotheses/H17/RESULT.md)
showed that genomic proximity accounts for some co-expression.

**New prediction:** A subset of lncRNAs at least 10 kb from any annotated
protein-coding gene predicts expression of distant genes in colonies not
used to select the associations, after accounting for season and measured
library composition. This tests reproducibility outside local proximity.

**Test:** In each species, use approximately 10 colonies and outer
leave-one-colony-out validation. Candidate partners must lie on different
scaffolds; require at least 10 kb of assembled flanking sequence around
each lncRNA so scaffold ends do not masquerade as isolation. Use fixed
expression filters and estimate normalization, transformations, nuisance
coefficients, and pair selection from training samples only. In each fold,
select up to 100 strongest residual pairs with |r| >= 0.6 after adjusting
for timepoint, colony, log library size, and fraction of reads in the ten
most abundant features. These are composition proxies, not full RNA-quality
measurements. Compare held-out prediction error for a nuisance-only model
against the same model plus its selected lncRNA; marginalize over the unseen
colony effect. Give each target gene equal weight and each colony equal
weight in the final score.

**Evidence criterion:** Support requires at least 5% lower held-out MSE,
a positive improvement CI from a colony-block bootstrap, and a
Holm-adjusted permutation p < 0.05 in at least two species. The null must
repeat the entire selection pipeline after reassigning whole lncRNA colony
trajectories within site, preserving timepoint and missingness patterns.
If matching makes permutations insufficient, classify the test as
inconclusive. An upper CI below 5% in at least two species rules out the
proposed minimum benefit there; other outcomes are inconclusive. Folds
with no qualifying edges contribute zero improvement.

**Checks:** Use expression-matched distant gene–gene pairs as a benchmark;
repeat after excluding unusually composition-dominated libraries. Small
training sets and scaffold fragmentation may leave few eligible pairs.
Held-out success still cannot eliminate reproducible shared-library effects
or prove trans regulation. Separate assays or perturbations would be the
next validation step.

## H27. Stable symbiont profiles predict different seasonal symbiont-density trajectories

**Basis:** [H10](../hypotheses/H10/RESULT.md) supported colony-associated
ITS2 composition in all species. Its secondary genus comparison tested
average physiology, not profile-specific seasonal trajectories.

**New prediction:** Colonies retaining different ITS2 profiles differ in
their seasonal change in symbiont cell density, even when community identity
remains stable. Stability of identity can therefore coexist with different
functional responses.

**Test:** Prioritize Porites and Pocillopora, which have more informative
profile diversity than Acropora. Join ITS2 and physiology through the
loaders. H10 includes 45 colonies per species, but the usable joint subset
must be counted before analysis. Define stable colonies as those with the
same dominant profile at every observed timepoint, at least three paired
timepoints, and dominant relative abundance >= 0.8 at each. Include profiles
represented by at least five colonies and occurring at both of at least
two sites; require at least two eligible profiles per species. Do not pool
rare profiles into an artificial biological category.

Fit `log1p(cells.cm2) ~ profile * timepoint + site * timepoint + (1|colony)`
to nonnegative cell-density observations. Compare with the model omitting
only `profile:timepoint`, using a parametric-bootstrap likelihood-ratio
test. Report fitted profile trajectories and the range among profiles of
TP3-minus-TP1 change, with colony-bootstrap CIs. Correct the two species'
interaction tests with Holm's method.

**Evidence criterion:** Support requires an estimable interaction with
Holm-adjusted p < 0.05 in both species. If a species fails the eligibility
rule or has a rank-deficient model, its result is inconclusive. A meaningful
effect threshold on the cell-density scale and power simulations must be
fixed before analysis to distinguish evidence against an effect from low
power; nonsignificance alone will not be called rejection.

**Checks:** Use profiles assigned at TP1 as a sensitivity analysis that
avoids conditioning eligibility on future stability; repeat in colonies
observed at all four timepoints. Account for site-by-timepoint differences
and assess profile–haplotype confounding where metadata permit. Profile
effects remain between-colony associations and may reflect host genotype.
The proposed inference concerns seasonal association, not symbiont causation.

## Implementation priorities and common safeguards

Start with **H23**, which integrates two supported findings into a new
species-by-methylation prediction, and **H24**, which tests whether the same
orthologs underpin the repeated GBM pattern. H25 sharpens interpretation of
an existing secondary finding; H26 needs careful validation; H27 first
needs an eligibility check on the joined data.

Before implementing any analysis, create its complete `hypothesis.md` using
the repository template, freeze remaining matching, filtering, effect-size,
and decision details, and commit it with `status: planned`. These proposals
are informed by prior analysis of this dataset; none is an independent
replication. New colonies or years provide stronger confirmation.

Use only `R/load.R` inputs and run the reproduction gate before hypothesis
analyses. Preserve colony trajectories in inference, report actual colony
counts and effect-size intervals, and retain inconclusive and negative
results. Thousands of genes or edges do not create thousands of independent
colonies. Per-hypothesis corrections are specified above; if reporting a
single discovery claim across this five-hypothesis slate, also prespecify
a slate-level multiplicity correction.
