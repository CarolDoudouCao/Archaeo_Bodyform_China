# set wdir

# 0 Set up a personal library and make R use it first
userlib <- path.expand("~/R/libs")
if (!dir.exists(userlib)) dir.create(userlib, recursive = TRUE, showWarnings = FALSE)
.libPaths(c(userlib, .libPaths()))  # put user lib first
options(repos = c(CRAN = "https://cloud.r-project.org"))

# ---- Packages ----
required_packages <- c(
  "tidyverse", "MASS", "car", "performance","raster",
  "splines", "brms", "elevatr", "akima", "furrr", "tidybayes", "purrr",
  "fields", "sf", "sp", "gstat", "broom.mixed", "patchwork", "here", "bayesplot",
  "terra", "tidyterra"
)

auto_install <- FALSE

missing <- required_packages[!vapply(required_packages, requireNamespace, logical(1), quietly = TRUE)]

if (auto_install && length(missing) > 0) {
  install.packages(missing)
}

invisible(lapply(required_packages, function(pkg) {
  suppressPackageStartupMessages(library(pkg, character.only = TRUE))
}))

# 1. Import the dataset and prepare the data 
library(readxl)
ancient_chi_detail <- read_excel("ancient_chinese_detail_for_mixed_effects_2025May_1.xlsx")
str(ancient_chi_detail)

# Convert relevant columns to numeric
num_cols <- c("FXL", "FBL","FHD", "TXL", "HXL", "RXL", "longitude", "latitude")
ancient_chi_detail[num_cols] <- lapply(ancient_chi_detail[num_cols], function(x) as.numeric(replace(x, x == "-", NA)))
# Remove rows with missing coordinates
ancient_chi_detail <- ancient_chi_detail %>% drop_na(longitude, latitude)

# Extract coordinates
coordinates <- ancient_chi_detail %>% dplyr::select(longitude, latitude)

# Convert to spatial points
points <- SpatialPoints(coordinates)
# Load raster layers
climate_paths <- list(
  Mintemp   = "climatic data/wc2.1_30s_bio/wc2.1_30s_bio_6.tif",
  Maxtemp   = "climatic data/wc2.1_30s_bio/wc2.1_30s_bio_5.tif",
  Minprecip = "climatic data/wc2.1_30s_bio/wc2.1_30s_bio_14.tif",
  Maxprecip = "climatic data/wc2.1_30s_bio/wc2.1_30s_bio_13.tif",
  Altitude  = "climatic data/wc2.1_30s_elev.tif"
)
Mintemp_raster   <- raster("climatic data/wc2.1_30s_bio/wc2.1_30s_bio_6.tif")
Maxtemp_raster   <- raster("climatic data/wc2.1_30s_bio/wc2.1_30s_bio_5.tif")
Minprecip_raster <- raster("climatic data/wc2.1_30s_bio/wc2.1_30s_bio_14.tif")
Maxprecip_raster <- raster("climatic data/wc2.1_30s_bio/wc2.1_30s_bio_13.tif")
Altitude_raster  <- raster("climatic data/wc2.1_30s_elev.tif")
# Extract raster values
climate_data <- lapply(climate_paths, function(path) extract(raster(path), points))

# Add extracted climate variables to the dataset
ancient_chi_detail <- bind_cols(ancient_chi_detail, as.data.frame(climate_data))

# Keep only rows with complete climate data
ancient_chi_detail <- ancient_chi_detail %>% drop_na(Mintemp, Maxtemp, Minprecip, Maxprecip, Altitude)

## Seperate males and females
ancient_chi_male <- ancient_chi_detail %>%
  filter(sex == '0')
ancient_chi_female <- ancient_chi_detail %>%
  filter(sex == '1')

## Set Mapping Parameters
# Ensure SHX file restoration
Sys.setenv("SHAPE_RESTORE_SHX" = "YES")

# Load shapefile
chinashape <- st_read("bou1_4p.shp")
basemap_wgs84 <- st_transform(chinashape, crs = 4326)
basemap_sp_wgs84 <- as_Spatial(basemap_wgs84)

male_colors_z <- rev(brewer.pal(9, "RdBu"))
female_colors_z <- rev(brewer.pal(9, "PuOr"))

# shared colour scale across all maps
z_limits <- c(-2.5, 2.5)

common_z_scale_male <- scale_fill_gradientn(
  colours = male_colors_z,
  limits  = z_limits,
  oob     = scales::squish,
  name    = "z-score",
  na.value = "transparent",
  guide = guide_colourbar(
    direction = "vertical",
    barheight = unit(35, "mm"),
    barwidth  = unit(4, "mm"),
    frame.colour = "black",
    ticks.colour = "black"
  )
)

common_z_scale_female <- scale_fill_gradientn(
  colours  = female_colors_z,
  limits   = z_limits,
  oob      = scales::squish,
  name     = "z-score",
  na.value = "transparent",
  guide = guide_colourbar(
    direction = "vertical",
    barheight = unit(35, "mm"),
    barwidth  = unit(4, "mm"),
    frame.colour = "black",
    ticks.colour = "black"
  )
)

# Save scaling parameters for males
male_longitude_center <- attr(scale(ancient_chi_male$longitude), "scaled:center")
male_longitude_scale  <- attr(scale(ancient_chi_male$longitude), "scaled:scale")
male_latitude_center  <- attr(scale(ancient_chi_male$latitude), "scaled:center")
male_latitude_scale   <- attr(scale(ancient_chi_male$latitude), "scaled:scale")
male_mintemp_center   <- attr(scale(ancient_chi_male$Mintemp), "scaled:center")
male_mintemp_scale    <- attr(scale(ancient_chi_male$Mintemp), "scaled:scale")
male_maxtemp_center   <- attr(scale(ancient_chi_male$Maxtemp), "scaled:center")
male_maxtemp_scale    <- attr(scale(ancient_chi_male$Maxtemp), "scaled:scale")
male_minprecip_center <- attr(scale(ancient_chi_male$Minprecip), "scaled:center")
male_minprecip_scale  <- attr(scale(ancient_chi_male$Minprecip), "scaled:scale")
male_maxprecip_center <- attr(scale(ancient_chi_male$Maxprecip), "scaled:center")
male_maxprecip_scale  <- attr(scale(ancient_chi_male$Maxprecip), "scaled:scale")
male_altitude_center  <- attr(scale(ancient_chi_male$Altitude), "scaled:center")
male_altitude_scale   <- attr(scale(ancient_chi_male$Altitude), "scaled:scale")

# Save scaling parameters for females
female_longitude_center <- attr(scale(ancient_chi_female$longitude), "scaled:center")
female_longitude_scale  <- attr(scale(ancient_chi_female$longitude), "scaled:scale")
female_latitude_center  <- attr(scale(ancient_chi_female$latitude), "scaled:center")
female_latitude_scale   <- attr(scale(ancient_chi_female$latitude), "scaled:scale")
female_mintemp_center   <- attr(scale(ancient_chi_female$Mintemp), "scaled:center")
female_mintemp_scale    <- attr(scale(ancient_chi_female$Mintemp), "scaled:scale")
female_maxtemp_center   <- attr(scale(ancient_chi_female$Maxtemp), "scaled:center")
female_maxtemp_scale    <- attr(scale(ancient_chi_female$Maxtemp), "scaled:scale")
female_minprecip_center <- attr(scale(ancient_chi_female$Minprecip), "scaled:center")
female_minprecip_scale  <- attr(scale(ancient_chi_female$Minprecip), "scaled:scale")
female_maxprecip_center <- attr(scale(ancient_chi_female$Maxprecip), "scaled:center")
female_maxprecip_scale  <- attr(scale(ancient_chi_female$Maxprecip), "scaled:scale")
female_altitude_center  <- attr(scale(ancient_chi_female$Altitude), "scaled:center")
female_altitude_scale   <- attr(scale(ancient_chi_female$Altitude), "scaled:scale")

dem <- rast("NE1_HR_LC_SR_W_DR.tif")

# Ensure it is WGS84
if (!grepl("4326", crs(dem))) {
  dem <- project(dem, "EPSG:4326")
}

bbox <- sf::st_bbox(basemap_wgs84)
ext_cn <- ext(bbox$xmin, bbox$xmax, bbox$ymin, bbox$ymax)

dem_cn <- crop(dem, ext_cn)

plot(dem_cn)
mk_line <- function(mat) st_sfc(st_linestring(mat), crs = 4326)

# 2. Influences from the environment and time periods
## Set common priors 
priors_common <- c(
  prior(normal(0,1),        class = "Intercept"),
  prior(normal(0,1),        class = "b"),
  
  # <-- same for both sexes: moderately heavy‐tailed scale priors
  prior(student_t(3, 0, 1), class = "sigma"),
  prior(student_t(3, 0, 1), class = "sd",    group = "site_id"),
  
  # spline regularization (if you’re using sds)
  prior(exponential(1),     class = "sds"),
  
  # Student‐t df prior
  prior(gamma(2, 0.1),      class = "nu")
)
brms_control <- list(adapt_delta = 0.99, max_treedepth = 15)

## For FXL
### Male
#### Prepare the data
ancient_chi_male_FXL <- ancient_chi_male %>%
  filter(!is.na(FXL), !is.na(Time_minus), !is.na(Time_plus)) %>%
  mutate(
    # scale covariates
    longitude_scaled = as.numeric(scale(longitude)[,1]),
    latitude_scaled  = as.numeric(scale(latitude)[,1]),
    mintemp_scaled   = as.numeric(scale(Mintemp)[,1]),
    maxtemp_scaled   = as.numeric(scale(Maxtemp)[,1]),
    minprecip_scaled = as.numeric(scale(Minprecip)[,1]),
    maxprecip_scaled = as.numeric(scale(Maxprecip)[,1]),
    altitude_scaled  = as.numeric(scale(Altitude)[,1]),
    FXL_z            = as.numeric(scale(FXL)[,1])
  )

mean_fxl_male <- mean(ancient_chi_male_FXL$FXL, na.rm = TRUE)
sd_fxl_male   <- sd(ancient_chi_male_FXL$FXL, na.rm = TRUE)

mean_fxl_male
sd_fxl_male

#### Fit the model
# ordering + sum coding BEFORE fitting
levs <- c("E_Neo","M_Neo","L_Neo","Bronze","E_M_Iron","M_Iron","L_Iron")

ancient_chi_male_FXL <- ancient_chi_male_FXL %>%
  mutate(period = factor(period, levels = levs))

contrasts(ancient_chi_male_FXL$period) <- contr.sum(length(levs))

# fit
fit_male_FXL <- brm(
  FXL_z ~ 
    period +
    t2(longitude_scaled, latitude_scaled) +
    mintemp_scaled + maxtemp_scaled +
    minprecip_scaled + maxprecip_scaled +
    altitude_scaled +
    (1 | site_id),
  data    = ancient_chi_male_FXL,
  family  = student(),
  prior   = priors_common,
  iter    = 4000, warmup = 1000,
  chains  = 4, cores = 4,
  control = list(adapt_delta = 0.95, max_treedepth = 12),
  refresh = 0
)

##### Summary
levels(fit_male_FXL$data$period)
contrasts(fit_male_FXL$data$period)
summary(fit_male_FXL, prob = 0.89)
draws <- as_draws_df(fit_male_FXL)

#### Temporal trends
out_dir <- here::here("output")
fig_dir <- here::here("figures")

if (!dir.exists(out_dir)) dir.create(out_dir, recursive = TRUE)
if (!dir.exists(fig_dir)) dir.create(fig_dir, recursive = TRUE)

ce_time_male_fxl <- conditional_effects(
  fit_male_FXL,
  effects    = "period",
  re_formula = NA,
  prob       = 0.89
)

ce_df <- as.data.frame(ce_time_male_fxl$period) %>%
  mutate(
    period = factor(period, levels = levs),
    period_num = as.integer(period),
    period_label = factor(
      period_num,
      levels = 1:7,
      labels = c(
        "Early\nNeolithic",
        "Middle\nNeolithic",
        "Late\nNeolithic",
        "Bronze\nAge",
        "Early–Middle\nIron Age",
        "Middle\nIron Age",
        "Late\nIron Age"
      )
    )
  )

p_time_male_fxl <- ggplot(ce_df, aes(x = period_num, y = estimate__)) +
  geom_hline(
    yintercept = 0,
    linetype = "dashed",
    colour = "grey40",
    linewidth = 0.4
  ) +
  geom_ribbon(
    aes(ymin = lower__, ymax = upper__),
    fill = "grey70",
    alpha = 0.45
  ) +
  geom_line(
    aes(group = 1),
    linewidth = 0.5,
    alpha = 0.7
  ) +
  geom_point(
    size = 2,
    alpha = 0.95
  ) +
  scale_x_continuous(
    breaks = 1:7,
    labels = levels(ce_df$period_label)
  ) +
  labs(
    x = NULL,
    y = "Estimated effect (FXL)",
    title = "Male"
  ) +
  coord_cartesian(ylim = c(-2, 2)) +
  theme_bw(base_size = 11) +
  theme(
    panel.background = element_rect(fill = "grey95", colour = NA),
    panel.grid.major = element_line(colour = "white", linewidth = 0.6),
    panel.grid.minor = element_line(colour = "white", linewidth = 0.3),
    panel.grid.major.y = element_line(linewidth = 0.25, colour = "grey85"),
    panel.grid.minor.y = element_blank(),
    axis.title.x = element_text(margin = margin(t = 10)),
    axis.title.y = element_text(margin = margin(r = 8)),
    axis.text.x  = element_text(angle = 0, hjust = 0.5, vjust = 0.5, lineheight = 0.9)
  )
p_time_male_fxl

#### Fixed effects
fixef_long_male_fxl <- as_draws_df(fit_male_FXL) %>% 
  gather_draws( b_mintemp_scaled, 
                b_maxtemp_scaled, 
                b_minprecip_scaled, 
                b_maxprecip_scaled, 
                b_altitude_scaled ) %>% 
  mutate(parameter = case_when( .variable == "b_mintemp_scaled" ~ "Min temp", 
                                .variable == "b_maxtemp_scaled" ~ "Max temp", 
                                .variable == "b_minprecip_scaled" ~ "Min precip", 
                                .variable == "b_maxprecip_scaled" ~ "Max precip", 
                                .variable == "b_altitude_scaled" ~ "Altitude" )) %>% mutate(parameter = factor(parameter, levels = c( "Min temp","Max temp","Min precip","Max precip","Altitude" )))

param_order_abs <- c("Min temp", "Max temp", "Min precip", "Max precip", "Altitude", "FXL")

fixef_long_male_fxl_ranked <- fixef_long_male_fxl %>% mutate(parameter = factor(parameter, levels = param_order_abs))

p_fixed_male_fxl <- ggplot(fixef_long_male_fxl_ranked, aes(x = .value, y = parameter)) +
  stat_halfeye(
    point_interval = NULL,
    slab_fill   = "skyblue",
    slab_alpha  = 0.55,
    slab_colour = NA,
    height = 0.9
  ) +
  stat_interval(
    .width = .89,
    colour = "steelblue",
    linewidth = 0.8
  ) +
  stat_summary(
    fun = median,
    geom = "point",
    shape = 16,
    colour = "black",
    size = 2
  ) +
  geom_vline(xintercept = 0, linetype = "dashed", colour = "grey40", linewidth = 0.5) +
  labs(
    title = "Male",
    x = NULL,
    y = "FXL"
  ) +
  theme_classic(base_size = 10) +
  theme(
    plot.title = element_text(face = "bold", hjust = 0.5, size = 12,
                              margin = margin(b = 10)),
    axis.text.y = element_text(size = 11),
    axis.text.x = element_text(size = 11),
    axis.title.y = element_text(size = 12, face = "bold"),
    plot.margin = margin(5.5, 5.5, 5.5, 30)
  ) 
p_fixed_male_fxl

#### Random Effects
# 0) Extract posterior draws for site random intercepts
site_re_male_FXL <- fit_male_FXL %>%
  spread_draws(r_site_id[site_id, Intercept]) %>%
  transmute(
    site_id_raw = as.character(site_id),
    site_id = site_id_raw %>%
      stringi::stri_trans_nfkc() %>%
      stringr::str_replace_all("\u00A0", " ") %>%
      stringr::str_replace_all("\\s+", " ") %>%
      stringr::str_trim(),
    r_site_id = as.numeric(r_site_id)
  )

# 1) Rank sites by posterior median
site_rank_male_FXL <- site_re_male_FXL %>%
  group_by(site_id) %>%
  summarise(med = median(r_site_id), .groups = "drop") %>%
  arrange(med)

# 2) 89% HDI + median
site_hdi89_male_FXL <- site_re_male_FXL %>%
  group_by(site_id) %>%
  median_hdi(r_site_id, .width = 0.89) %>%
  ungroup() %>%
  transmute(
    site_id,
    .lower = as.numeric(.lower),
    .upper = as.numeric(.upper)
  )

site_point_male_FXL <- site_re_male_FXL %>%
  group_by(site_id) %>%
  summarise(.point = median(r_site_id), .groups = "drop")

site_hdi89_male_FXL <- site_hdi89_male_FXL %>%
  left_join(site_point_male_FXL, by = "site_id") %>%
  mutate(
    deviated_89 = !(.lower <= 0 & .upper >= 0)
  ) %>%
  distinct(site_id, .keep_all = TRUE)

# 3) Select sites to show
keep_extremes <- c(
  head(site_rank_male_FXL$site_id, 15),
  tail(site_rank_male_FXL$site_id, 15)
)

keep_deviated <- site_hdi89_male_FXL %>%
  filter(deviated_89) %>%
  pull(site_id)

keep_sites_male_FXL <- union(keep_extremes, keep_deviated)

max_sites_to_show <- 60
keep_sites_male_FXL <- site_rank_male_FXL %>%
  filter(site_id %in% keep_sites_male_FXL) %>%
  arrange(desc(abs(med))) %>%
  slice_head(n = max_sites_to_show) %>%
  pull(site_id)

# 4) Plotting data
site_re_plot_male_FXL <- site_re_male_FXL %>%
  filter(site_id %in% keep_sites_male_FXL) %>%
  left_join(site_rank_male_FXL, by = "site_id") %>%
  mutate(site_id = forcats::fct_reorder(site_id, med))

site_levels_male_FXL <- levels(site_re_plot_male_FXL$site_id)

site_hdi_plot <- site_hdi89_male_FXL %>%
  distinct(site_id, .lower, .upper, .point) %>%
  mutate(site_id = factor(site_id, levels = site_levels_male_FXL)) %>%
  filter(!is.na(site_id))

# 5) Plot
p_random_male_FXL <- ggplot(site_re_plot_male_FXL, aes(x = r_site_id, y = site_id)) +
  geom_vline(xintercept = 0, linetype = "dashed", colour = "grey35") +
  stat_halfeye(
    point_interval = NULL,
    height = 0.55,
    slab_colour = NA,
    fill = "grey80",
    alpha = 0.55
  ) +
  geom_segment(
    data = site_hdi_plot,
    aes(x = .lower, xend = .upper, y = site_id, yend = site_id),
    linewidth = 0.35,
    colour = "grey20",
    lineend = "round",
    inherit.aes = FALSE
  ) +
  geom_point(
    data = site_hdi_plot,
    aes(x = .point, y = site_id),
    size = 1.1,
    colour = "black",
    inherit.aes = FALSE
  ) +
  labs(x = "Group random intercept", y = "Groups", title = "Male") +
  theme_bw(base_size = 10) +
  theme(
    legend.position = "none",
    panel.grid.major.y = element_blank()
  )

p_random_male_FXL

#### Predictions
# ============================================================
# 0) Setup
# ============================================================

levs <- c("E_Neo", "M_Neo", "L_Neo", "Bronze", "E_M_Iron", "M_Iron", "L_Iron")

out_dir <- here::here("output")
fig_dir <- here::here("figures")

if (!dir.exists(out_dir)) dir.create(out_dir, recursive = TRUE)
if (!dir.exists(fig_dir)) dir.create(fig_dir, recursive = TRUE)

# ============================================================
# A) Build prediction grid + extract environmental covariates
# ============================================================

grid_geo <- expand.grid(
  Longitude = seq(70, 140, length.out = 350),
  Latitude  = seq(10,  60, length.out = 350)
)

grid_scaled_base <- as_tibble(grid_geo) %>%
  mutate(
    Mintemp   = raster::extract(Mintemp_raster,   cbind(Longitude, Latitude)),
    Maxtemp   = raster::extract(Maxtemp_raster,   cbind(Longitude, Latitude)),
    Minprecip = raster::extract(Minprecip_raster, cbind(Longitude, Latitude)),
    Maxprecip = raster::extract(Maxprecip_raster, cbind(Longitude, Latitude)),
    Altitude  = raster::extract(Altitude_raster,  cbind(Longitude, Latitude))
  ) %>%
  mutate(
    longitude_scaled = (Longitude - male_longitude_center) / male_longitude_scale,
    latitude_scaled  = (Latitude  - male_latitude_center)  / male_latitude_scale,
    mintemp_scaled   = (Mintemp   - male_mintemp_center)   / male_mintemp_scale,
    maxtemp_scaled   = (Maxtemp   - male_maxtemp_center)   / male_maxtemp_scale,
    minprecip_scaled = (Minprecip - male_minprecip_center) / male_minprecip_scale,
    maxprecip_scaled = (Maxprecip - male_maxprecip_center) / male_maxprecip_scale,
    altitude_scaled  = (Altitude  - male_altitude_center)  / male_altitude_scale
  ) %>%
  filter(
    !if_any(
      c(
        longitude_scaled, latitude_scaled,
        mintemp_scaled, maxtemp_scaled,
        minprecip_scaled, maxprecip_scaled,
        altitude_scaled
      ),
      is.na
    )
  )

# Expand to all 7 periods
grid_scaled <- grid_scaled_base %>%
  tidyr::crossing(period_num = 1:7) %>%
  mutate(
    period = factor(levs[period_num], levels = levels(fit_male_FXL$data$period))
  )

# Match model contrasts
contrasts(grid_scaled$period) <- contrasts(fit_male_FXL$data$period)

# ============================================================
# B) Chunked posterior epred summaries by grid cell and period
# ============================================================

num_chunks <- 20

grid_segments <- split(
  grid_scaled,
  cut(seq_len(nrow(grid_scaled)), breaks = num_chunks, labels = FALSE)
)

final_preds_list <- vector("list", length(grid_segments))

for (j in seq_along(grid_segments)) {
  message("Predicting chunk ", j, " / ", length(grid_segments))
  
  chunk <- grid_segments[[j]]
  
  summary_chunk <- add_epred_draws(
    fit_male_FXL,
    newdata    = chunk,
    re_formula = NA,   # population-level prediction
    ndraws     = 200
  ) %>%
    group_by(Longitude, Latitude, period_num, period) %>%
    median_qi(.epred, .width = 0.90) %>%
    rename(
      male_FXL_epred_median  = .epred,
      male_FXL_epred_lower90 = .lower,
      male_FXL_epred_upper90 = .upper
    ) %>%
    ungroup()
  
  final_preds_list[[j]] <- summary_chunk
  
  rm(summary_chunk)
  gc()
}

male_FXL_grid_7periods <- bind_rows(final_preds_list)

pred_csv <- file.path(out_dir, "male_FXL_grid_epred_7periods_median_PI90.csv")
write.csv(male_FXL_grid_7periods, pred_csv, row.names = FALSE)

message("Prediction CSV written to: ", pred_csv)


#### Spatial trends
# ============================================================
# C) Read saved predictions
# ============================================================

pred_csv <- file.path(out_dir, "male_FXL_grid_epred_7periods_median_PI90.csv")

male_FXL_grid_7periods <- readr::read_csv(pred_csv, show_col_types = FALSE)

dplyr::glimpse(male_FXL_grid_7periods)

# ============================================================
# D) Build all-periods summary surface
#     (mean across the 7 modelled periods at each grid cell)
# ============================================================

pred_all <- male_FXL_grid_7periods %>%
  mutate(period_all = "All periods") %>%
  group_by(period_all, Longitude, Latitude) %>%
  summarise(
    med  = mean(male_FXL_epred_median,  na.rm = TRUE),
    low  = mean(male_FXL_epred_lower90, na.rm = TRUE),
    high = mean(male_FXL_epred_upper90, na.rm = TRUE),
    .groups = "drop"
  )

# ============================================================
# E) Site locations + hull mask
# ============================================================

sites_all <- ancient_chi_male_FXL %>%
  group_by(site_id) %>%
  summarise(
    longitude = dplyr::first(longitude),
    latitude  = dplyr::first(latitude),
    .groups = "drop"
  )

make_period_hull <- function(df, buffer_m = 20000) {
  pts <- st_as_sf(df, coords = c("longitude", "latitude"), crs = 4326)
  pts_proj <- st_transform(pts, 3857)
  
  if (nrow(df) == 1) {
    hull <- st_buffer(pts_proj, dist = buffer_m)
  } else if (nrow(df) == 2) {
    hull <- pts_proj |>
      st_union() |>
      st_buffer(dist = buffer_m)
  } else {
    hull <- pts_proj |>
      st_union() |>
      st_convex_hull() |>
      st_buffer(dist = buffer_m)
  }
  
  st_transform(hull, 4326)
}

hull_all <- if (nrow(sites_all) < 3) {
  make_period_hull(sites_all, buffer_m = 30000)
} else {
  make_period_hull(sites_all, buffer_m = 20000)
}

hull_all <- st_make_valid(hull_all)

pred_pts <- st_as_sf(pred_all, coords = c("Longitude", "Latitude"), crs = 4326)
inside <- st_intersects(pred_pts, hull_all, sparse = FALSE)[, 1]
pred_all_masked <- pred_all[inside, , drop = FALSE]

rm(pred_pts, inside)
gc()

# Shared colour scale across median / lower / upper
z_limits <- c(-2.5,2.5)

# ============================================================
# F) Geographic features: rivers and mountain ranges
# ============================================================

mk_line <- function(mat) {
  st_sfc(st_linestring(mat), crs = 4326)
}

feat_list <- list(
  list(
    name = "Yangtze River", type = "river",
    mat = matrix(c(
      91.2,33.8, 96.0,31.0, 98.9,28.5, 103.7,29.6, 110.0,30.2,
      112.9,29.5, 114.3,30.6, 118.1,31.8, 121.5,31.4
    ), ncol = 2, byrow = TRUE)
  ),
  list(
    name = "Yellow River", type = "river",
    mat = matrix(c(
      96.0,35.0, 100.0,36.5, 102.5,37.0, 105.0,38.5, 107.5,40.0,
      111.5,40.0, 113.0,38.5, 112.0,36.5, 110.0,35.0, 109.0,35.0,
      112.6,34.8, 115.0,35.6, 119.0,37.7
    ), ncol = 2, byrow = TRUE)
  ),
  list(
    name = "Huai River", type = "river",
    mat = matrix(c(
      111.5,33.7, 114.0,33.6, 117.0,33.6, 120.0,33.7
    ), ncol = 2, byrow = TRUE)
  ),
  list(
    name = "Qinling", type = "range",
    mat = matrix(c(
      104.0,33.8, 106.5,33.9, 108.8,33.9, 110.5,33.7
    ), ncol = 2, byrow = TRUE)
  ),
  list(
    name = "Himalayas", type = "range",
    mat = matrix(c(
      80.0,30.0, 83.0,29.5, 86.0,28.5, 89.0,28.2, 92.0,28.3, 95.0,28.1
    ), ncol = 2, byrow = TRUE)
  )
)

feats <- dplyr::bind_rows(
  lapply(feat_list, function(f) {
    st_sf(
      name = f$name,
      type = f$type,
      geometry = mk_line(f$mat)
    )
  })
)

lab_df <- data.frame(
  name = c("Yangtze River", "Yellow River", "Huai River", "Qinling", "Himalayas"),
  x    = c(111.5, 111.0, 116.0, 108.5, 87.0),
  y    = c(30.6,  37.3,  33.6,  33.9,  28.7),
  dx   = c(0.0,   0.0,   0.2,  -0.6,   0.0),
  dy   = c(0.0,   0.2,  -0.6,   0.3,   0.0)
) %>%
  mutate(
    x_lab = x + dx,
    y_lab = y + dy
  )

# ============================================================
# G) Plot helper
# ============================================================

make_map <- function(df, z_col, title = NULL, show_legend = TRUE) {
  ggplot() +
    tidyterra::geom_spatraster_rgb(
      data = dem_cn,
      alpha = 0.25,
      show.legend = FALSE
    ) +
    scale_fill_identity(guide = "none") +
    ggnewscale::new_scale_fill() +
    
    geom_tile(
      data = df,
      aes(x = Longitude, y = Latitude, fill = .data[[z_col]])
    ) +
    
    geom_sf(
      data = feats %>% filter(type == "river"),
      colour = "dodgerblue3",
      linewidth = 0.3,
      inherit.aes = FALSE
    ) +
    geom_sf(
      data = feats %>% filter(type == "river", name %in% c("Yangtze River", "Yellow River")),
      colour = "deepskyblue3",
      linewidth = 0.3,
      inherit.aes = FALSE
    ) +
    
    geom_sf(
      data = feats %>% filter(type == "range"),
      colour = "sienna4",
      linewidth = 0.3,
      linetype = "dashed",
      inherit.aes = FALSE
    ) +
    geom_sf(
      data = feats %>% filter(type == "range", name %in% c("Qinling", "Himalayas")),
      colour = "sienna4",
      linewidth = 0.3,
      linetype = "solid",
      inherit.aes = FALSE
    ) +
    
    geom_point(
      data = sites_all,
      aes(x = longitude, y = latitude),
      inherit.aes = FALSE,
      shape = 21,
      fill = "red",
      colour = "red",
      stroke = 0.1,
      size = 0.35,
      alpha = 0.85
    ) +
    
    geom_text(
      data = lab_df,
      aes(x = x_lab, y = y_lab, label = name),
      colour = "white",
      size = 2.8,
      fontface = "plain"
    ) +
    geom_text(
      data = lab_df,
      aes(x = x_lab, y = y_lab, label = name),
      colour = "black",
      size = 2.6,
      fontface = "plain"
    ) +
    
    common_z_scale_male +
    
    coord_sf(xlim = c(70, 140), ylim = c(10, 55), expand = FALSE) +
    scale_x_continuous(breaks = seq(70, 130, by = 20)) +
    scale_y_continuous(breaks = seq(10, 50, by = 20)) +
    labs(x = NULL, y = NULL, title = title) +
    theme_minimal(base_size = 11) +
    theme(
      panel.grid = element_blank(),
      plot.title = element_text(face = "bold", size = 11, hjust = 0.5),
      legend.position = if (show_legend) "right" else "none",
      legend.background = element_rect(fill = "white", colour = "grey80", linewidth = 0.2),
      plot.margin = margin(1, 1, 1, 1)
    )
}

# ============================================================
# H) Make maps
# ============================================================

p_male_FXL_spatial_median <- make_map(
  pred_all_masked,
  z_col = "med",
  title = "FXL",
  show_legend = FALSE
)+
  labs(y = NULL)+ 
  theme(
    axis.title = element_text(face = "bold", size = 12)
  )

p_male_FXL_spatial_lower90 <- make_map(
  pred_all_masked,
  z_col = "low",
  title = "Lower 90% bound",
  show_legend = TRUE)+
  labs(y = "FXL")+ 
  theme(
    axis.title = element_text(face = "bold", size = 12)
  )

p_male_FXL_spatial_upper90 <- make_map(
  pred_all_masked,
  z_col = "high",
  title = "Upper 90% bound",
  show_legend = TRUE
)

p_male_FXL_spatial_bounds <-
  (p_male_FXL_spatial_lower90 | p_male_FXL_spatial_upper90) +
  plot_layout(guides = "collect") &
  theme(
    legend.position = "right",
    legend.box.margin = margin(0, 5, 0, 0)
  )

p_male_FXL_spatial_median
p_male_FXL_spatial_bounds



