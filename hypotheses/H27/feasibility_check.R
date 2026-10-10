# H27 feasibility counts for completing the pre-registration. Uses ITS2
# profile abundances, the design table (site, haplotype) and whether
# cells.cm2 is present. No cell-density value is read.
# Run from the repo root: Rscript hypotheses/H27/feasibility_check.R

source("R/load.R")
out_dir <- "hypotheses/H27/output/feasibility"
dir.create(out_dir, showWarnings = FALSE, recursive = TRUE)

design <- load_design()
species_all <- c("Peve", "Ptuh")
its2 <- load_its2()
prof_cols <- names(its2)[vapply(its2, is.numeric, logical(1))]
phys_present <- load_physiology() |> transmute(sample_id, has_cells = !is.na(cells.cm2))

samples <- design |> filter(has_its2 %in% TRUE, species %in% species_all) |>
  select(sample_id, species, colony, timepoint, site, haplotype) |>
  inner_join(its2 |> select(sample_id, all_of(prof_cols)), by = "sample_id") |>
  left_join(phys_present, by = "sample_id") |> mutate(has_cells = has_cells %in% TRUE)
m <- as.matrix(samples[, prof_cols])
rs <- rowSums(m)
samples <- samples |> mutate(row_sum = rs, dominant = prof_cols[max.col(m, ties.method = "first")],
                             dominant_share = apply(m, 1, max) / rs) |>
  select(-all_of(prof_cols))

# paired timepoint = ITS2 and cells.cm2 both present
eligibility <- function(s, rule = c("stable", "tp1")) {
  rule <- match.arg(rule)
  s <- s |> filter(has_cells)
  col <- s |> group_by(species, colony, site) |>
    summarise(paired_tp = n(), all_four = all(c("TP1", "TP2", "TP3", "TP4") %in% timepoint),
              profiles_seen = n_distinct(dominant), min_share = min(dominant_share),
              tp1_profile = dominant[timepoint == "TP1"][1], tp1_share = dominant_share[timepoint == "TP1"][1],
              profile = if (n_distinct(dominant) == 1) dominant[1] else NA_character_,
              haplotype = paste(sort(unique(na.omit(haplotype))), collapse = "/"), .groups = "drop")
  col <- if (rule == "stable") {
    col |> mutate(qualifies = paired_tp >= 3 & profiles_seen == 1 & min_share >= 0.8)
  } else {
    col |> mutate(profile = tp1_profile, qualifies = paired_tp >= 3 & !is.na(tp1_profile) & tp1_share >= 0.8)
  }
  prof <- col |> filter(qualifies) |> group_by(species, profile) |>
    summarise(colonies = n(), sites = n_distinct(site), site_list = paste(sort(unique(site)), collapse = ","),
              all_four_colonies = sum(all_four), haplotypes = paste(sort(unique(haplotype)), collapse = ";"), .groups = "drop") |>
    mutate(eligible = colonies >= 5 & sites >= 2, rule = rule)
  list(colonies = col |> mutate(rule = rule), profiles = prof)
}

res <- lapply(c("stable", "tp1"), function(r) eligibility(samples, r))
colonies <- bind_rows(lapply(res, `[[`, "colonies"))
profiles <- bind_rows(lapply(res, `[[`, "profiles"))
summary_tab <- profiles |> group_by(rule, species) |>
  summarise(eligible_profiles = sum(eligible), colonies_in_eligible = sum(colonies[eligible]),
            all_four_in_eligible = sum(all_four_colonies[eligible]), .groups = "drop") |>
  left_join(colonies |> group_by(rule, species) |> summarise(colonies_total = n(), colonies_qualifying = sum(qualifies), .groups = "drop"),
            by = c("rule", "species"))

readr::write_csv(samples |> select(-row_sum), file.path(out_dir, "samples_dominant_profile.csv"))
readr::write_csv(colonies, file.path(out_dir, "colonies.csv"))
readr::write_csv(profiles, file.path(out_dir, "profiles.csv"))
readr::write_csv(summary_tab, file.path(out_dir, "summary.csv"))
cat("row sums of ITS2 matrix (should be ~1):\n"); print(summary(rs))
print(as.data.frame(summary_tab))
print(as.data.frame(profiles |> arrange(rule, species, desc(colonies))))
