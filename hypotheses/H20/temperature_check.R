# H20 withdrawal evidence. Uses only temperature, nominal dates (D-006) and the
# design table; no expression or physiology data.
#  1. 30-day mean temperature and slope (dT/dt) per molecular site and
#     timepoint, windows as in H11 (the 30 days before each nominal date).
#  2. Simulation: synthetic expression that tracks current temperature with no
#     memory, put through the pre-registered LOCO ridge axis and Part A model,
#     to show what slope the pipeline produces when the true slope is 0.
# Run from the repo root: Rscript hypotheses/H20/temperature_check.R

source("R/load.R")
out_dir <- "hypotheses/H20/output"
dir.create(out_dir, showWarnings = FALSE, recursive = TRUE)
set.seed(20261008)

design <- load_design()
sites <- sort(unique(design$site[design$has_genes %in% TRUE & !is.na(design$site)]))
temp <- load_temperature_daily() |> filter(site %in% sites)
tp_dates <- design |> distinct(timepoint, tp_date) |> arrange(timepoint)

window <- function(s, d) {
  x <- temp[temp$site == s & temp$day >= d - 30 & temp$day <= d - 1, ]
  tibble(days_with_data = nrow(x), T30 = mean(x$mean_c),
         dTdt_per_30d = if (nrow(x) > 2) 30 * unname(coef(lm(x$mean_c ~ as.numeric(x$day)))[2]) else NA_real_)
}
thermal <- tidyr::expand_grid(site = sites, tp_dates) |>
  rowwise() |> mutate(window(site, tp_date)) |> ungroup()
readr::write_csv(thermal, file.path(out_dir, "thermal_by_site_timepoint.csv"))
print(thermal)

# Simulation. Design: 10 colonies (5 per site), TP1-TP4, as in the expression
# data. Expression: 2000 features; each loads on the current 30-day mean
# temperature (immediate response, no lag), plus colony effects and noise.
# The true Part A slope is therefore 0. Signal strength is varied.
n_sim <- 100
cols <- tibble(colony = paste0("C", 1:10), site = rep(sites, each = 5))
samp <- tidyr::expand_grid(cols, timepoint = tp_dates$timepoint) |>
  left_join(thermal |> select(site, timepoint, T30, dTdt_per_30d), by = c("site", "timepoint"))

sim_once <- function(r2_temp) {
  p <- 2000
  load <- rnorm(p)
  tz <- as.numeric(scale(samp$T30))
  col_eff <- matrix(rnorm(10 * p), 10, p)[match(samp$colony, cols$colony), ]
  noise_sd <- sqrt((1 - r2_temp) / r2_temp)
  X <- outer(tz, load) + 0.5 * col_eff + matrix(rnorm(nrow(samp) * p, sd = noise_sd), nrow(samp), p)
  S <- numeric(nrow(samp))
  for (cc in cols$colony) {
    tr <- samp$colony != cc
    fit <- glmnet::cv.glmnet(X[tr, ], samp$T30[tr], alpha = 0, nfolds = 5)
    S[!tr] <- as.numeric(predict(fit, X[!tr, , drop = FALSE], s = "lambda.min"))
  }
  df <- samp |> mutate(m = S - T30)
  f <- lme4::lmer(m ~ dTdt_per_30d + (1 | colony), data = df)
  ci <- suppressMessages(confint(f, parm = "dTdt_per_30d", method = "Wald"))
  tibble(r2_temp = r2_temp, slope = unname(lme4::fixef(f)["dTdt_per_30d"]), lo = ci[1], hi = ci[2],
         cor_m_T = cor(df$m, df$T30))
}

sims <- bind_rows(lapply(c(0.05, 0.2, 0.5), function(r2) bind_rows(replicate(n_sim, sim_once(r2), simplify = FALSE))))
sim_summary <- sims |> group_by(r2_temp) |>
  summarise(n_sim = n(), median_slope = median(slope), frac_negative = mean(slope < 0),
            frac_ci_excludes_0_negative = mean(hi < 0), median_cor_m_T = median(cor_m_T), .groups = "drop")
readr::write_csv(sims, file.path(out_dir, "sim_no_memory_partA.csv"))
readr::write_csv(sim_summary, file.path(out_dir, "sim_no_memory_partA_summary.csv"))
print(sim_summary)
