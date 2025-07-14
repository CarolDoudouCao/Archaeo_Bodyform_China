# 02. Bayesian Modeling (FXL, Male, as an example)
# This script assumes data preparation is complete (see Script 01)

## 2.1 Packages for modelling

library(brms)        # brm(), priors
library(cmdstanr)    # cmdstan backend
library(future)      # plan()
library(furrr)       # future_map()
library(mgcv)        # s(), t2()
library(tidybayes)   # gather_draws(), median_qi()
library(posterior)   # as_draws_df(), subset_draws()

## 2.2 Define common priors
priors_common <- c(
  prior(normal(0,1),        class = "Intercept"),
  prior(normal(0,1),        class = "b"),
  prior(student_t(3, 0, 1), class = "sigma"),
  prior(student_t(3, 0, 1), class = "sd",    group = "site_id"),
  prior(exponential(1),     class = "sds"),         # for splines
  prior(gamma(2, 0.1),      class = "nu")           # student-t df
)

## 2.3 Prepare male data for FXL modeling
ancient_chi_male_FXL <- ancient_chi_male %>%
  filter(!is.na(FXL), !is.na(Time_minus), !is.na(Time_plus)) %>%
  mutate(
    longitude_scaled = scale(longitude)[,1],
    latitude_scaled  = scale(latitude)[,1],
    mintemp_scaled   = scale(Mintemp)[,1],
    maxtemp_scaled   = scale(Maxtemp)[,1],
    minprecip_scaled = scale(Minprecip)[,1],
    maxprecip_scaled = scale(Maxprecip)[,1],
    altitude_scaled  = scale(Altitude)[,1],
    FXL_z            = scale(FXL)[,1]
  )

## Summary stats (optional)
mean_fxl_male <- mean(ancient_chi_male_FXL$FXL, na.rm = TRUE)
sd_fxl_male   <- sd(ancient_chi_male_FXL$FXL, na.rm = TRUE)

## 2.4 Calculate central date stats for imputation
set.seed(1)
tmp_male_fxl <- ancient_chi_male_FXL %>%
  mutate(true_date = runif(n(), Time_minus, Time_plus))

sc_male_fxl      <- scale(tmp_male_fxl$true_date)
mu_date_male_fxl <- attr(sc_male_fxl, "scaled:center")
sd_date_male_fxl <- attr(sc_male_fxl, "scaled:scale")


## 2.5 Fit 50 models with imputed dates (in-memory version)
plan(multisession, workers = 5)
brms_control <- list(adapt_delta = 0.95, max_treedepth = 12)

fit_one_femur <- function(i, data, priors) {
  set.seed(i)
  data_i <- data %>%
    mutate(
      true_date   = runif(n(), Time_minus, Time_plus),
      true_date_z = scale(true_date)[,1]
    )
  brm(
    FXL_z ~ 
      s(true_date_z, k = 10) +
      t2(longitude_scaled, latitude_scaled) +
      mintemp_scaled + maxtemp_scaled +
      minprecip_scaled + maxprecip_scaled +
      altitude_scaled +
      (1 | site_id),
    data     = data_i,
    family   = student(),
    prior    = priors,
    iter     = 4000,
    warmup   = 1000,
    chains   = 4,
    cores    = 4,
    control  = brms_control,
    refresh  = 0
  )
}

fits_male_femur <- future_map(
  1:50,
  fit_one_femur,
  data   = ancient_chi_male_FXL,
  priors = priors_common,
  .options = furrr_options(seed = TRUE)
) %>%
  discard(is.null)

## 2.6 Combine and thin posterior draws
combined_draws_male_femur <- fits_male_femur %>%
  map(as_draws_df) %>%
  bind_rows()

draws_thin_male_femur <- combined_draws_male_femur %>%
  slice_sample(n = 10000)

## 2.7 Summarise posterior draws for climate predictors
summary_dtpa_male_femur <- draws_thin_male_femur %>%
  gather_draws(
    b_mintemp_scaled,
    b_maxtemp_scaled,
    b_minprecip_scaled,
    b_maxprecip_scaled,
    b_altitude_scaled
  ) %>%
  group_by(.variable) %>%
  median_qi(.value, .width = 0.89) %>%
  rename(
    Estimate = .value,
    `5.5%`   = .lower,
    `94.5%`  = .upper
  )

write_csv(summary_dtpa_male_femur, "output/summary_dtpa_male_femur.csv")


