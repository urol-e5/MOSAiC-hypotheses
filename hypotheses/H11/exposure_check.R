# H11 withdrawal evidence: 30-day thermal exposure per molecular site and
# timepoint, under the pre-registered threshold (warmest-month mean, MMM) and
# the Prediction's wording (climatological mean), with the +/- 15 day window
# shifts. Uses only temperature and nominal dates (D-006); no expression data.
# Run from the repo root: Rscript hypotheses/H11/exposure_check.R

source("R/load.R")
out_dir <- "hypotheses/H11/output"
dir.create(out_dir, showWarnings = FALSE, recursive = TRUE)

design <- load_design()
sites <- sort(unique(design$site[design$has_genes %in% TRUE & !is.na(design$site)]))
temp <- load_temperature_daily() |> filter(site %in% sites)
tp_dates <- design |> distinct(timepoint, tp_date) |> arrange(timepoint)
last_day <- max(temp$day)

thresholds <- temp |>
  mutate(month = format(day, "%Y-%m")) |>
  group_by(site, month) |> summarise(days = n(), month_mean = mean(mean_c), .groups = "drop") |>
  filter(days >= 20) |>
  group_by(site) |> summarise(mmm = max(month_mean), mmm_month = month[which.max(month_mean)], .groups = "drop") |>
  left_join(temp |> group_by(site) |> summarise(climatological_mean = mean(mean_c)), by = "site")

exposure <- tidyr::expand_grid(site = sites, tp_dates, shift_days = c(-15, 0, 15)) |>
  left_join(thresholds, by = "site") |>
  rowwise() |>
  mutate(window_end = min(tp_date + shift_days - 1, last_day),
         window_start = window_end - 29,
         days_with_data = sum(temp$site == site & temp$day >= window_start & temp$day <= window_end),
         mean_temp = mean(temp$mean_c[temp$site == site & temp$day >= window_start & temp$day <= window_end]),
         exposure_mmm = sum(pmax(0, temp$mean_c[temp$site == site & temp$day >= window_start & temp$day <= window_end] - mmm)),
         exposure_clim = sum(pmax(0, temp$mean_c[temp$site == site & temp$day >= window_start & temp$day <= window_end] - climatological_mean))) |>
  ungroup() |>
  select(site, timepoint, tp_date, shift_days, window_start, window_end, days_with_data,
         mean_temp, mmm, mmm_month, exposure_mmm, climatological_mean, exposure_clim)

readr::write_csv(thresholds, file.path(out_dir, "site_thresholds.csv"))
readr::write_csv(exposure, file.path(out_dir, "exposure_by_site_timepoint.csv"))
print(exposure |> filter(shift_days == 0) |> select(site, timepoint, days_with_data, mean_temp, exposure_mmm, exposure_clim))
