
# 05_conditional_effects.R
# ---------------------------------------------------------------
# 📌 Prerequisites (see Script 02: Bayesian Modeling):
# - Models must be pre-fitted and stored as `fits_male_femur` (list of 50 brms models).
# - Pooled modeling data should be available: `imputed_male_fxl <- fits_male_femur[[1]]$data`.
# - Scalers must be defined: `male_altitude_center`, `male_altitude_scale`.
# - Libraries assumed: tidyverse, brms, tidybayes, stringr, purrr, ggplot2.
# 
# 🌟 Purpose:
# - Define a plotting function for marginal conditional effects of climate, altitude, and time.
# - Plot posterior medians and uncertainty (89% & 95% intervals), jittered data rug, and annotate key ranges.
# - Save conditional plots to `figures/` directory as TIFFs.
# ---------------------------------------------------------------

## 5.1 Define Conditional Effect Plot Function
make_conditional_plot <- function(focal,
                                  fits,
                                  data_raw,
                                  scalers,
                                  fxl_is_in_model = FALSE,
                                  grid_n = 601,
                                  ndraws = 600) {
  v_min <- min(data_raw[[focal]], na.rm = TRUE)
  v_max <- max(data_raw[[focal]], na.rm = TRUE)
  
  if (focal == "altitude_scaled") {
    alt2500 <- (2500 - scalers$center["altitude"]) / scalers$scale["altitude"]
  }
  
  base_row <- tibble(
    longitude_scaled  = 0,
    latitude_scaled   = 0,
    mintemp_scaled    = 0,
    maxtemp_scaled    = 0,
    minprecip_scaled  = 0,
    maxprecip_scaled  = 0,
    altitude_scaled   = 0,
    true_date_z       = 0
  )
  if (fxl_is_in_model) base_row$FXL_z <- 0
  
  grid <- base_row %>%
    slice(rep(1, grid_n)) %>%
    mutate(!!focal := seq(v_min, v_max, length.out = grid_n))
  
  pred_draws <- map(fits,
                    ~ add_epred_draws(.x,
                                      newdata    = grid,
                                      re_formula = ~0,
                                      ndraws     = ndraws)) %>%
    bind_rows()
  
  pred_sum <- pred_draws %>%
    group_by(.data[[focal]]) %>%
    median_qi(.epred, .width = c(.89, .95))
  
  is_reversed <- (focal == "true_date_z")
  x_range     <- v_max - v_min
  x_nudge     <- 0.02 * x_range
  
  hjust_min <- if (is_reversed) 1 else 0
  nudge_min <- if (is_reversed) -x_nudge else x_nudge
  hjust_max <- if (is_reversed) 0 else 1
  nudge_max <- if (is_reversed) x_nudge else -x_nudge
  
  nice_name <- str_to_sentence(str_remove(focal, "_scaled$"))
  
  p <- ggplot(pred_sum, aes(x = .data[[focal]], y = .epred)) +
    geom_ribbon(aes(ymin = .lower, ymax = .upper), fill = "grey80") +
    geom_line(size = 1) +
    geom_jitter(data = data_raw,
                aes(x = .data[[focal]], y = -Inf),
                inherit.aes  = FALSE,
                shape        = 124,
                size         = 3,
                alpha        = 0.5,
                colour       = "blue",
                position     = position_jitter(width = 0.01, height = 0),
                clip         = "off") +
    coord_cartesian(clip = "off") +
    geom_vline(xintercept = v_min, linetype = "dashed", colour = "salmon") +
    geom_vline(xintercept = v_max, linetype = "dashed", colour = "salmon") +
    geom_text(aes(x = v_min, y = Inf,
                  label = paste0("Min=", round(v_min, 2))),
              inherit.aes = FALSE,
              hjust       = hjust_min,
              vjust       = 2,
              nudge_x     = nudge_min,
              size        = 3.5,
              colour      = "red") +
    geom_text(aes(x = v_max, y = Inf,
                  label = paste0("Max=", round(v_max, 2))),
              inherit.aes = FALSE,
              hjust       = hjust_max,
              vjust       = 2,
              nudge_x     = nudge_max,
              size        = 3.5,
              colour      = "red") +
    labs(title = nice_name,
         x     = paste("Scaled", nice_name),
         y     = "Predicted outcome (z)") +
    theme_minimal(base_size = 12) +
    theme(plot.title = element_text(face = "bold"))
  
  if (focal == "altitude_scaled") {
    p <- p +
      geom_rect(aes(xmin = alt2500, xmax = Inf, ymin = -Inf, ymax = Inf),
                fill = "lightblue", alpha = 0.001, inherit.aes = FALSE) +
      geom_vline(xintercept = alt2500, linetype = "dotted", colour = "blue") +
      annotate("text", x = alt2500, y = max(pred_sum$.upper),
               label = "High Altitude (>2,500 m)", hjust = -0.05,
               vjust = 1, colour = "blue", size = 3.5)
  }
  
  if (focal == "true_date_z") {
    p <- p + scale_x_reverse() +
      labs(x = "Scaled true date (earlier → later)")
  }
  p
}

## 5.2 Prepare Inputs
imputed_male_fxl <- fits_male_femur[[1]]$data
scalers_male_fxl <- list(
  center = c(altitude = male_altitude_center),
  scale  = c(altitude = male_altitude_scale)
)

## 5.3 Generate and Save Conditional Effect Plots

# Altitude
p_male_fxl_alt <- make_conditional_plot("altitude_scaled", fits_male_femur, imputed_male_fxl, scalers_male_fxl)
ggsave("figures/male_fxl_altitude_ce_pooled.tiff", p_male_fxl_alt, dpi = 300, width = 8, height = 5, units = "in", device = "tiff", compression = "lzw")

# True date
p_male_fxl_td <- make_conditional_plot("true_date_z", fits_male_femur, imputed_male_fxl, scalers_male_fxl)
ggsave("figures/male_fxl_true_date_ce_pooled.tiff", p_male_fxl_td, dpi = 300, width = 8, height = 5, units = "in", device = "tiff", compression = "lzw")

# Minimum temperature
p_male_fxl_MinT <- make_conditional_plot("mintemp_scaled", fits_male_femur, imputed_male_fxl, scalers_male_fxl)
ggsave("figures/male_fxl_mintemp_ce_pooled.tiff", p_male_fxl_MinT, dpi = 300, width = 8, height = 5, units = "in", device = "tiff", compression = "lzw")

# Maximum temperature
p_male_fxl_MaxT <- make_conditional_plot("maxtemp_scaled", fits_male_femur, imputed_male_fxl, scalers_male_fxl)
ggsave("figures/male_fxl_maxtemp_ce_pooled.tiff", p_male_fxl_MaxT, dpi = 300, width = 8, height = 5, units = "in", device = "tiff", compression = "lzw")

# Minimum precipitation
p_male_fxl_MinP <- make_conditional_plot("minprecip_scaled", fits_male_femur, imputed_male_fxl, scalers_male_fxl)
ggsave("figures/male_fxl_minprecip_ce_pooled.tiff", p_male_fxl_MinP, dpi = 300, width = 8, height = 5, units = "in", device = "tiff", compression = "lzw")

# Maximum precipitation
p_male_fxl_MaxP <- make_conditional_plot("maxprecip_scaled", fits_male_femur, imputed_male_fxl, scalers_male_fxl)
ggsave("figures/male_fxl_maxprecip_ce_pooled.tiff", p_male_fxl_MaxP, dpi = 300, width = 8, height = 5, units = "in", device = "tiff", compression = "lzw")


