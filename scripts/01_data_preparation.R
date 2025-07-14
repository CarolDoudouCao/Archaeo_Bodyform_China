# Install tidyverse and the spatial packages
install.packages(c("tidyverse","here", "raster", "sp", "sf", "RColorBrewer"))

# Load libraries
library(tidyverse)      # Includes readr, dplyr, tidyr, tibble, ggplot2, etc.
library(raster)         # For raster climate data
library(sp)             # For SpatialPoints
library(sf)             # For shapefiles and CRS transforms
library(RColorBrewer)   # For color palettes
library(here)

# 1. Import the dataset and prepare the data 
ancient_chi_detail <-  read_csv(here("data", "individual_limb_measurements_indices.csv"))

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

# Set Mapping Parameters

# Ensure SHX file restoration
Sys.setenv("SHAPE_RESTORE_SHX" = "YES")

# Load shapefile
chinashape <- st_read("bou1_4p.shp")
basemap_wgs84 <- st_transform(chinashape, crs = 4326)
basemap_sp_wgs84 <- as_Spatial(basemap_wgs84)

male_colors_z <- rev(brewer.pal(9, "RdBu"))
female_colors_z <- rev(brewer.pal(9, "PuOr"))

z_limits <- c(-5.2,5.2)

# Save scaling parameters for longitude and latitude
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
