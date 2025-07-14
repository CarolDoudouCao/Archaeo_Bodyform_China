# 03. Predictive Spatiotemporal Plots
# This script generates full-grid posterior predictions of male femur length (FXL),
# using both full model (environment + space) and coordinate-only (space only),
# and computes the environmental-only effect as their difference (environment only).

# Prerequisites: `fits_male_femur` (from 02_modeling), scaling parameters (e.g., male_longitude_center), and raster layers.

## 3.1 Build and Scale Prediction Grid (Full Imputed Model)
grid_geo <- expand.grid(
  Longitude = seq(70, 140, length.out = 400),
  Latitude  = seq(10,  60,  length.out = 400)
)

grid_scaled <- grid_geo %>%
  mutate(
    Mintemp    = raster::extract(Mintemp_raster,    cbind(Longitude, Latitude)),
    Maxtemp    = raster::extract(Maxtemp_raster,    cbind(Longitude, Latitude)),
    Minprecip  = raster::extract(Minprecip_raster,  cbind(Longitude, Latitude)),
    Maxprecip  = raster::extract(Maxprecip_raster,  cbind(Longitude, Latitude)),
    Altitude   = raster::extract(Altitude_raster,   cbind(Longitude, Latitude))
  ) %>%
  mutate(
    longitude_scaled = (Longitude - male_longitude_center) / male_longitude_scale,
    latitude_scaled  = (Latitude  - male_latitude_center)  / male_latitude_scale,
    mintemp_scaled   = (Mintemp - male_mintemp_center)     / male_mintemp_scale,
    maxtemp_scaled   = (Maxtemp - male_maxtemp_center)     / male_maxtemp_scale,
    minprecip_scaled = (Minprecip - male_minprecip_center) / male_minprecip_scale,
    maxprecip_scaled = (Maxprecip - male_maxprecip_center) / male_maxprecip_scale,
    altitude_scaled  = (Altitude - male_altitude_center)   / male_altitude_scale,
    true_date_z      = 0  # centered date
  ) %>%
  filter(!if_any(ends_with("_scaled"), is.na))

## 3.2 Chunk-wise Prediction (Full Model)
num_chunks <- 20
grid_segments <- split(grid_scaled, cut(seq_len(nrow(grid_scaled)), num_chunks))

final_preds_list <- vector("list", length(grid_segments))
out_dir <- here("output")
if (!dir.exists(out_dir)) dir.create(out_dir)

plan(sequential)

for (j in seq_along(grid_segments)) {
  message("Chunk ", j, " of ", length(grid_segments))
  
  chunk <- grid_segments[[j]]
  preds_list <- map(
    fits_male_femur,
    ~ add_epred_draws(.x, newdata = chunk, re_formula = ~0, ndraws = 200) %>%
      select(Longitude, Latitude, .draw, .epred)
  )
  
  final_preds_list[[j]] <- bind_rows(preds_list, .id = "imp") %>%
    group_by(Longitude, Latitude) %>%
    median_qi(.epred, .width = 0.89) %>%
    rename(FXL_pred_median = .epred, Lower_89 = .lower, Upper_89 = .upper)
  
  rm(preds_list); gc()
}

final_preds <- bind_rows(final_preds_list)
write_csv(final_preds, here("output", "final_male_fxl_predictions_z.csv"))

## 3.3 Predict Coordinates-Only Surface
grid_coords_only <- grid_geo %>%
  mutate(
    longitude_scaled = (Longitude - male_longitude_center) / male_longitude_scale,
    latitude_scaled  = (Latitude  - male_latitude_center)  / male_latitude_scale,
    mintemp_scaled   = 0,
    maxtemp_scaled   = 0,
    minprecip_scaled = 0,
    maxprecip_scaled = 0,
    altitude_scaled  = 0,
    true_date_z      = 0
  ) # Set all environmental variables to zero to isolate spatial smooth

grid_segments_coords <- split(grid_coords_only, cut(seq_len(nrow(grid_coords_only)), 80))
final_preds_coords <- vector("list", length(grid_segments_coords))

for (j in seq_along(grid_segments_coords)) {
  chunk <- grid_segments_coords[[j]]
  preds_list <- map(
    fits_male_femur,
    ~ add_epred_draws(.x, newdata = chunk, re_formula = ~0, ndraws = 500) %>%
      select(Longitude, Latitude, .draw, .epred)
  )
  
  final_preds_coords[[j]] <- bind_rows(preds_list, .id = "imp") %>%
    group_by(Longitude, Latitude) %>%
    median_qi(.epred, .width = 0.89) %>%
    rename(FXL_pred_median = .epred, Lower_89 = .lower, Upper_89 = .upper)
  
  rm(preds_list); gc()
}

write_csv(bind_rows(final_preds_coords),
          here("output", "final_male_fxl_predictions_coords_only.csv"))

## 3.4 Compute Environmental-Only Effect

full_df  <- read_csv(here("output", "final_male_fxl_predictions_z.csv"))
coord_df <- read_csv(here("output", "final_male_fxl_predictions_coords_only.csv"))

env_only <- full_df %>%
  rename(Full_Median = FXL_pred_median, Full_Lower_89 = Lower_89, Full_Upper_89 = Upper_89) %>%
  inner_join(coord_df %>%
               rename(Coord_Median = FXL_pred_median,
                      Coord_Lower_89 = Lower_89,
                      Coord_Upper_89 = Upper_89),
             by = c("Longitude", "Latitude")) %>%
  mutate(
    Env_Median   = Full_Median   - Coord_Median,
    Env_Lower_89 = Full_Lower_89 - Coord_Upper_89,
    Env_Upper_89 = Full_Upper_89 - Coord_Lower_89
  ) %>%
  select(Longitude, Latitude, Env_Median, Env_Lower_89, Env_Upper_89)

write_csv(env_only, here("output", "male_fxl_env_only_effect.csv"))

## 3.5 Plot: Full Model Prediction Surface
df <- read_csv(here("output", "final_male_fxl_predictions_z.csv"))

df <- df %>% rename(FXL_z = FXL_pred_median)

spatial_trends <- df %>%
  group_by(Longitude, Latitude) %>%
  summarise(FXL_z = mean(FXL_z, na.rm = TRUE), .groups = "drop")

china_sf <- st_read("bou1_4p.shp", quiet = TRUE) %>% st_transform(4326)
china_sp <- as(china_sf, "Spatial")
rast_z <- rasterFromXYZ(spatial_trends[c("Longitude", "Latitude", "FXL_z")])
crs(rast_z) <- CRS("+proj=longlat +datum=WGS84")
rast_z_masked <- mask(rast_z, china_sp)

spatial_df <- as.data.frame(rasterToPoints(rast_z_masked))
colnames(spatial_df) <- c("Longitude", "Latitude", "FXL_z")

p_male_fxl <- ggplot(spatial_df, aes(Longitude, Latitude, fill = FXL_z)) +
  geom_raster() +
  geom_sf(data = st_boundary(china_sf), inherit.aes = FALSE, colour = "grey50", size = 0.1) +
  geom_point(data = ancient_chi_male_FXL, aes(x = longitude, y = latitude),
             shape = 24, fill = "red", colour = "red", size = 0.3, stroke = 0.1, inherit.aes = FALSE) +
  scale_fill_gradientn(colors = male_colors_z, limits = z_limits, name = "z-score", na.value = "transparent") +
  coord_sf(xlim = c(70, 140), ylim = c(10, 60), expand = FALSE) +
  theme_minimal(base_size = 11)

ggsave("figures/male_FXL_spatial_trends_z.tiff", p_male_fxl, width = 6, height = 5, dpi = 300, device = "tiff", compression = "lzw")

## 3.6 Plot: Coordinates-Only Prediction Surface
coords_df <- read_csv(here("output", "final_male_fxl_predictions_coords_only.csv")) %>%
  rename(FXL_z = FXL_pred_median)

spatial_coords <- coords_df %>%
  group_by(Longitude, Latitude) %>%
  summarise(FXL_z = mean(FXL_z, na.rm = TRUE), .groups = "drop")

rast_coords <- rasterFromXYZ(spatial_coords[c("Longitude", "Latitude", "FXL_z")])
crs(rast_coords) <- CRS("+proj=longlat +datum=WGS84")
rast_coords_masked <- mask(rast_coords, china_sp)

spatial_coords_df <- as.data.frame(rasterToPoints(rast_coords_masked))
colnames(spatial_coords_df) <- c("Longitude", "Latitude", "FXL_z")

p_coords_only <- ggplot(spatial_coords_df, aes(Longitude, Latitude, fill = FXL_z)) +
  geom_raster() +
  geom_sf(data = st_boundary(china_sf), inherit.aes = FALSE, colour = "grey50", size = 0.1) +
  geom_point(data = ancient_chi_male_FXL, aes(x = longitude, y = latitude),
             shape = 24, fill = "red", colour = "red", size = 0.3, stroke = 0.1, inherit.aes = FALSE) +
  scale_fill_gradientn(colors = male_colors_z, limits = z_limits, name = "Coords Only z", na.value = "transparent") +
  coord_sf(xlim = c(70, 140), ylim = c(10, 60), expand = FALSE) +
  theme_minimal(base_size = 11)

ggsave("figures/male_FXL_spatial_coords_only_z.tiff", p_coords_only, width = 6, height = 5, dpi = 300, device = "tiff", compression = "lzw")

## 3.7 Plot: Environmental-Only Effect Surface
full_df <- read_csv(here("output", "final_male_fxl_predictions_z.csv")) %>%
  rename(Full_FXL = FXL_pred_median, Full_Lower = Lower_89, Full_Upper = Upper_89)

coords_df <- read_csv(here("output", "final_male_fxl_predictions_coords_only.csv")) %>%
  rename(Coord_FXL = FXL_pred_median, Coord_Lower = Lower_89, Coord_Upper = Upper_89)

env_df <- full_df %>%
  inner_join(coords_df, by = c("Longitude", "Latitude")) %>%
  mutate(
    Env_Median    = Full_FXL   - Coord_FXL,
    Env_Lower_89  = Full_Lower - Coord_Upper,
    Env_Upper_89  = Full_Upper - Coord_Lower
  ) %>%
  select(Longitude, Latitude, Env_Median)

spatial_env_df <- env_df %>%
  group_by(Longitude, Latitude) %>%
  summarise(Env_Median = mean(Env_Median, na.rm = TRUE), .groups = "drop")

rast_env <- rasterFromXYZ(spatial_env_df[c("Longitude", "Latitude", "Env_Median")])
crs(rast_env) <- CRS("+proj=longlat +datum=WGS84")
rast_env_masked <- mask(rast_env, china_sp)

spatial_env_df <- as.data.frame(rasterToPoints(rast_env_masked))
colnames(spatial_env_df) <- c("Longitude", "Latitude", "Env_Median")

p_env_only <- ggplot(spatial_env_df, aes(Longitude, Latitude, fill = Env_Median)) +
  geom_raster() +
  geom_sf(data = st_boundary(china_sf), inherit.aes = FALSE, colour = "grey50", size = 0.1) +
  geom_point(data = ancient_chi_male_FXL, aes(x = longitude, y = latitude),
             shape = 24, fill = "blue", colour = "blue", size = 0.3, stroke = 0.1, inherit.aes = FALSE) +
  scale_fill_gradientn(colors = male_colors_z, limits = z_limits, name = "Env Only z", na.value = "transparent") +
  coord_sf(xlim = c(70, 140), ylim = c(10, 60), expand = FALSE) +
  theme_minimal(base_size = 11)

ggsave("figures/male_FXL_spatial_env_only_z.tiff", p_env_only, width = 6, height = 5, dpi = 300, device = "tiff", compression = "lzw")

## 3.8 Plot: Faceted Comparison of Full, Coords, and Env-Only
comparison_long <- bind_rows(
  full_df %>% transmute(Longitude, Latitude, FXL_z = Full_FXL, Model = "Full Model"),
  coords_df %>% transmute(Longitude, Latitude, FXL_z = Coord_FXL, Model = "Coords Only"),
  env_df %>% transmute(Longitude, Latitude, FXL_z = Env_Median, Model = "Environmental Only")
)

p_compare_male_fxl <- ggplot(comparison_long, aes(Longitude, Latitude, fill = FXL_z)) +
  geom_raster() +
  facet_wrap(~Model, ncol = 3) +
  geom_sf(data = st_boundary(china_sf), inherit.aes = FALSE, color = "grey50", size = 0.2) +
  geom_point(data = ancient_chi_male_FXL, aes(x = longitude, y = latitude),
             inherit.aes = FALSE, shape = 24, size = 0.4, fill = "red", color = "red", stroke = 0.1) +
  scale_fill_gradientn(colors = male_colors_z, limits = z_limits, name = "z-score", na.value = "transparent") +
  coord_sf(xlim = c(70, 140), ylim = c(10, 60), expand = FALSE) +
  theme_minimal(base_size = 10)

ggsave("figures/male_fxl_comparison_imputed_z.tiff", p_compare_male_fxl,
       width = 12, height = 4, dpi = 300, device = "tiff", compression = "lzw")
