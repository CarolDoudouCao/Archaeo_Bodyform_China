
# 04_fixed_and_random_effects_plotting.R

# ---------------------------------------------------------------
# 📌 Prerequisites (see Script 02: Bayesian Modeling):
# - Models must be pre-fitted: `fits_male_femur` (list of 50 brms models, one per imputation).
# - Pooled and thinned posterior draws available as `draws_thin_male_femur`.
# - Consistent site ID structure across imputations.
# - Required libraries: tidyverse, brms, tidybayes, ggdist, stringr, purrr.
# ---------------------------------------------------------------

## 4.1 Fixed Effects Posterior Distribution (Male FXL)
theme_set(theme_minimal(base_size = 11))

# Helper function to tidy parameter names
clean_labels <- function(x) {
  x %>%
    str_remove("^b_") %>%
    str_remove("_scaled$") %>%
    str_to_sentence()
}

# Select and rename fixed effect parameters (excluding intercept)
fixef_df_male_femur <- draws_thin_male_femur %>%
  dplyr::select(starts_with("b_"), -b_Intercept) %>%
  rename_with(clean_labels)

# Half-eye plot of posterior distributions
p_fixed_male_femur <- fixef_df_male_femur %>%
  pivot_longer(cols = everything(),
               names_to = "parameter",
               values_to = "beta") %>%
  ggplot(aes(x = beta, y = reorder(parameter, beta))) +
  stat_halfeye(
    .width        = c(.89, .95),
    point_interval = median_hdi,
    slab_colour    = "grey70",
    height         = 0.6
  ) +
  geom_vline(xintercept = 0, linetype = "dashed", colour = "red") +
  labs(
    x = "Posterior β",
    y = "",
    title = "Male FXL: Fixed-effects (50-imputation pooled posterior)"
  )

ggsave("figures/male_femur_fixed_effects.tiff",
       p_fixed_male_femur, dpi = 300, width = 8, height = 5, units = "in",
       device = "tiff", compression = "lzw")


## 4.2 Random Intercepts by Site (Male FXL)

# Helper function to extract random intercepts per imputation
tidy_one_site <- function(fit, imp) {
  as_draws_df(fit) %>%
    dplyr::select(matches("^r_site_id\\[.*?,Intercept\\]$")) %>%
    pivot_longer(
      everything(),
      names_pattern = "r_site_id\\[(.*),Intercept\\]",
      names_to  = "site",
      values_to = ".value"
    ) %>%
    mutate(imp = imp)
}

# Combine random intercepts from all imputations
site_draws_male_fxl <- map2_dfr(fits_male_femur,
                                seq_along(fits_male_femur),
                                tidy_one_site)

# Summarise posterior for each site and identify those with nonzero CIs
site_sum_male_fxl <- site_draws_male_fxl %>%
  group_by(site) %>%
  median_qi(.value, .width = .89) %>%
  rename(mean = .value, lower89 = .lower, upper89 = .upper) %>%
  mutate(nonzero = lower89 > 0 | upper89 < 0) %>%
  arrange(mean) %>%
  mutate(site = factor(site, levels = site))  # preserve ordering in plot

# Plot site-level random intercepts with 89% CI
p_sites_male_fxl <- ggplot(site_sum_male_fxl,
                           aes(x = mean, y = site, color = nonzero)) +
  geom_point() +
  geom_errorbarh(aes(xmin = lower89, xmax = upper89), height = 0) +
  geom_vline(xintercept = 0, linetype = "dashed") +
  scale_color_manual(values = c("TRUE" = "firebrick", "FALSE" = "grey60"),
                     guide = "none") +
  labs(
    x = "Random intercept (pooled posterior)",
    y = "",
    title = "Male FXL: Site-level random intercepts (89% CI)"
  )

ggsave("figures/male_fxl_site_ranefs.tiff",
       p_sites_male_fxl, dpi = 300, width = 8, height = 8, units = "in",
       device = "tiff", compression = "lzw")

