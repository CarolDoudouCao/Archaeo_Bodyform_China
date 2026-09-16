# Spatiotemporal Variation in Human Body Form across Ancient Chinese Populations

## About This Repository

This repository accompanies the paper *Spatiotemporal Variation in Human Body Form across Ancient Chinese Populations*.

The study investigates spatial and temporal variation in limb length and body proportions across **2,931 individuals (1,566 males and 1,365 females)**, representing **71 site-period groups from 64 archaeological sites** in China. The dataset spans from the **Early Neolithic to the Late Imperial period** and includes both lowland and high-altitude populations.

Bayesian Generalised Additive Mixed Models (GAMMs) are used to examine temporal trends, nonlinear spatial structure, environmental associations, and group-level variation while accounting for the hierarchical and uneven nature of archaeological skeletal data.

---

## Repository Structure

```text
├── data/
│   ├── bodyform_data_AUDITED_v2.xlsx
│   │   # Individual-level osteometric and contextual data
│   │
│   └── bou1_4p.shp
│       # China boundary shapefile
│
├── scirpts/
│   ├── Example_ancient_chinese_body_size_analysis_male_fxl.R
│   │   # Example R workflow for male femur maximum length
│   │
│   ├── Example_ancient_chinese_body_size_analysis_male_fxl.html
│   │   # Rendered version of the example workflow
│   │
│   └── example_codes_male_fxl.docx
│       # Example code in document format
│
├── output/
│   ├── FXL_male_period_CE_90PI.png
│   ├── male_FXL_fixed_effects_90PI.png
│   ├── male_FXL_site_random_intercepts.png
│   ├── male_FXL_spatial_ALLperiods_median_only.png
│   └── male_FXL_spatial_all_periods_lower_upper_PI90.png
│
└── README.md
```

> **Note:** The repository uses male femur maximum length (FXL) as an example to illustrate the modelling workflow. The same analytical structure was applied to the other skeletal traits and to female datasets, with the outcome variable and analytical sample changed accordingly.

---

## Study Overview

### Chronological coverage

The study covers seven broad analytical periods:

| Period                | Approximate date range | General archaeological / historical context                   |
| --------------------- | ---------------------- | ------------------------------------------------------------- |
| Early Neolithic       | ca. 7050–5050 BCE      | Early farming communities                                     |
| Middle Neolithic      | ca. 5050–2550 BCE      | Expansion and intensification of farming                      |
| Late Neolithic        | ca. 2550–1550 BCE      | Increasing settlement complexity and social differentiation   |
| Bronze–Early Iron Age | ca. 1550–221 BCE       | Bronze Age societies through the pre-Qin Iron Age             |
| Early Imperial        | 221 BCE–589 CE         | Qin–Han through the Northern and Southern Dynasties           |
| Middle Imperial       | 589–1368 CE            | Sui, Tang, Song, Yuan, and contemporaneous regional dynasties |
| Late Imperial         | 1368–1912 CE           | Ming and Qing dynasties                                       |

Neolithic assignments are based primarily on documented **local cultural phases** rather than rigid calendar cut-offs. The date ranges above therefore represent broad analytical categories used for cross-regional comparison.

Site-specific cultural attributions and chronologies are reported separately in the supplementary archaeological metadata.

---

## Sample

The primary analytical dataset comprises:

* **2,931 individuals**

  * **1,566 males**
  * **1,365 females**
* **71 site-period groups**
* **64 archaeological sites**

The primary dataset excludes the **Sding-Chung** assemblage because sex for that highly commingled assemblage had been estimated using femoral dimensions, creating potential non-independence between sex classification and femoral measurements used as analytical outcomes.

Sding-Chung is retained only for sensitivity analyses of femoral traits.

---

## Osteometric Variables

The following measurements are included:

| Variable | Description             | Individuals with data |
| -------- | ----------------------- | --------------------: |
| FXL      | Femur maximum length    |                 2,416 |
| TXL      | Tibia maximum length    |                 1,009 |
| HXL      | Humerus maximum length  |                   636 |
| RXL      | Radius maximum length   |                   493 |
| FBL      | Femur bicondylar length |                   103 |
| FHD      | Femoral head diameter   |                 1,118 |

FXL is used as a proxy for adult linear body size / stature, while FHD is used as an indicator related to body mass and articular breadth.

Measurements collected directly by DC for **Gaoshan, Zhijiaozhongxin, Phiyang-Dungkar, Pukar Gongma, Buta-Siongqu, and Gulie** follow the osteometric definitions summarised by Ruff (2018, pp. 5–7). Measurements for the remaining comparative groups were compiled from published osteological sources.

---

## Limb Proportion Indices

Two conventional intra-limb proportion indices were calculated:

* **Brachial Index (BI)** = RXL / HXL
* **Crural Index (CI)** = TXL / FBL

Where FBL was unavailable but FXL was present, FBL was estimated from FXL following Auerbach (2011), providing approximately **2,300 additional FBL estimates for calculation of CI**.

Final index availability:

* **BI: n = 383**
* **CI: n = 799**

BI and CI were calculated only where the required component measurements were available.

---

## Missing Data

Missing skeletal measurements are common in archaeological samples because preservation, recovery, and reporting vary among skeletal elements and assemblages.

The analyses therefore **do not require individuals to have complete measurements across all skeletal variables**.

Instead:

* each skeletal trait is analysed separately;
* each model includes all individuals for whom the relevant outcome and required covariates are available;
* missing values for the primary skeletal traits are **not imputed**;
* effective sample size therefore differs among traits and sex-specific models.

This approach retains the maximum available sample for each skeletal outcome while recognising that differences in preservation and reporting may contribute to variation in sample composition across analyses.

---

## Sex Estimation

### Directly examined assemblages

For the six assemblages examined directly by DC, sex estimation for individuals retained in the primary analyses was based on sufficiently preserved **pelvic morphology**, following established osteological protocols.

No individual in these primary directly examined samples was sexed solely from cranial traits.

### Published comparative samples

For the remaining comparative groups:

* sex classifications were taken from the original publications;
* most sources reported individuals categorically as male or female;
* individuals reported only as **probable male** or **probable female** were excluded from sex-specific analyses.

The anatomical basis and confidence of published sex estimates were not consistently reported at the individual level, so sex-estimation uncertainty could not be modelled uniformly across the full comparative dataset.

### Sding-Chung sensitivity analysis

Sding-Chung consists of highly commingled and disarticulated human remains, and isolated femora could not be reliably reassociated with pelvic elements. Sex had therefore been estimated from femoral dimensions using discriminant functions.

Because femoral dimensions also form outcomes in the present study, Sding-Chung was excluded from the **primary analyses** to avoid classification-induced size bias.

Sensitivity models were additionally fitted with Sding-Chung included to assess whether its inclusion materially altered the FXL and FHD results.

---

## Environmental Data

Environmental variables were extracted for each archaeological location from **WorldClim v2.1** at approximately 30 arc-second (~1 km) resolution.

Variables include:

* minimum temperature of the coldest month;
* maximum temperature of the warmest month;
* precipitation of the driest month;
* precipitation of the wettest month;
* altitude.

Source:

Fick, S. E., & Hijmans, R. J. (2017). WorldClim 2: New 1-km spatial resolution climate surfaces for global land areas. *International Journal of Climatology, 37*(12), 4302–4315. https://doi.org/10.1002/joc.5086

---

# Methods Summary

## Bayesian Generalised Additive Mixed Models

Bayesian Generalised Additive Mixed Models (GAMMs) were fitted to individual-level osteometric data using the `brms` package, which interfaces with Stan for Hamiltonian Monte Carlo sampling.

All models were fitted separately by sex and skeletal trait.

The general model structure is:

```text
Trait_z ~ period +
          t2(longitude_scaled, latitude_scaled) +
          mintemp_scaled +
          maxtemp_scaled +
          minprecip_scaled +
          maxprecip_scaled +
          altitude_scaled +
          (1 | site_id)
```

For FHD models, FXL was additionally included as a covariate so that femoral head size could be interpreted relative to linear skeletal size.

---

## Hierarchical Structure

Individual skeletal observations are nested within archaeological **site-period groups**.

The term:

```r
(1 | site_id)
```

represents a group-specific varying intercept that accounts for shared group-level influences and enables partial pooling across groups with different sample sizes.

This structure allows group-level estimates to be informed by both local observations and the broader dataset.

---

## Standardisation

Continuous predictors were standardised before modelling, including:

* longitude;
* latitude;
* minimum temperature;
* maximum temperature;
* minimum precipitation;
* maximum precipitation;
* altitude.

Outcome variables were also standardised within the corresponding sex-specific analytical dataset.

Standardisation:

* improves numerical stability;
* expresses effects in standard-deviation units;
* facilitates comparison among predictors;
* facilitates comparison of relative patterns among skeletal traits and between male and female models.

The z-score results describe deviations relative to the corresponding trait- and sex-specific mean. Selected effects are additionally expressed in original measurement units in the manuscript to facilitate biological interpretation.

---

## Temporal Modelling

Temporal variation was modelled using a categorical archaeological-period variable rather than assigning artificial point estimates to assemblages with broad chronological ranges.

The seven ordered analytical periods correspond to:

```text
1. Early Neolithic
2. Middle Neolithic
3. Late Neolithic
4. Bronze–Early Iron Age
5. Early Imperial
6. Middle Imperial
7. Late Imperial
```

Period was fitted using sum-to-zero contrasts (`contr.sum`), so estimated period effects represent deviations relative to the overall mean rather than differences from a single reference category.

---

## Likelihood and Priors

Models use a **Student-t likelihood** to provide robustness to outliers and heavy-tailed residual variation.

Weakly informative priors include:

```text
Fixed effects:           Normal(0, 1)
Intercept:               Normal(0, 1)
Residual SD:             Student-t(3, 0, 1)
Group-level SD:          Student-t(3, 0, 1)
Smoothness parameters:   Exponential(1)
Degrees of freedom:      Gamma(2, 0.1)
```

---

## MCMC Sampling

The standard fitting workflow uses:

```text
4 chains
4,000 iterations per chain
1,000 warm-up iterations
```

Convergence is assessed using R-hat and effective sample sizes.

---

# Reproducibility Option

The example script includes an explicit reproducibility switch:

```r
# FALSE = standard multi-core run
# TRUE  = single-core run with fixed seed for reproducibility checking

reproducible_run <- FALSE
```

When:

```r
reproducible_run <- TRUE
```

models are fitted using:

```r
cores = 1
seed  = 42
```

This provides a deterministic reproducibility check within the same computational environment.

When:

```r
reproducible_run <- FALSE
```

models use multiple cores for computational efficiency.

The same option is applied to the primary and sensitivity models.

---

# Posterior Summaries

Posterior uncertainty is summarised using **90% equal-tailed credible intervals (CrIs)**.

These intervals are defined by the:

```text
5th percentile – 95th percentile
```

of the posterior distribution.

For example:

```r
fixef(
  fit_male_FXL,
  probs = c(0.05, 0.95)
)
```

and posterior-draw summaries use corresponding 90% quantile intervals.

Highest posterior density intervals (HPDIs/HDIs) are not used for the reported primary interval summaries.

---

# Conditional Effects

Population-level conditional effects are generated using:

```r
conditional_effects(
  fit,
  re_formula = NA,
  prob = 0.90
)
```

Group-level random effects are therefore excluded from these conditional-effect plots.

For continuous focal predictors, other covariates are held at their scaled means.

---

# Spatial Prediction

Spatial predictions are generated over a regular grid spanning approximately:

```text
Longitude: 70–140° E
Latitude:  10–60° N
```

Environmental covariates are extracted for each grid location and standardised using the same parameters used in model fitting.

Predictions are generated from the **population-level component** of the model:

```r
re_formula = NA
```

and therefore exclude group-specific varying intercepts.

---

## Posterior Prediction Summaries

Spatial predictions use posterior draws and are summarised with medians and 90% equal-tailed CrIs.

Example:

```r
add_epred_draws(
  fit_male_FXL,
  newdata = chunk,
  re_formula = NA,
  ndraws = 200
) %>%
  median_qi(.epred, .width = 0.90)
```

For each grid cell and period, the workflow returns:

* posterior median;
* lower 90% CrI;
* upper 90% CrI.

---

## All-Period Spatial Surface

Predictions are first generated separately for all seven archaeological periods.

Period-specific predictions are then averaged at each grid cell to produce an overall spatial summary surface representing mean predicted variation across the chronological range of the study.

The mapped surface therefore does not represent any single historical period.

---

## Spatial Masking

To reduce extrapolation far beyond the geographic distribution of the archaeological sample, predicted surfaces are restricted using a buffered convex hull based on observed site locations.

Mapped outputs include:

* posterior median surface;
* lower 90% CrI surface;
* upper 90% CrI surface.

---

# Sensitivity Analysis: Sding-Chung

The primary models exclude Sding-Chung because femoral measurements contributed to sex classification in this commingled assemblage.

Sensitivity analyses reintroduce Sding-Chung into the FXL and FHD models to assess whether its inclusion materially alters the results.

The example workflow therefore distinguishes explicitly between:

```r
# Primary model
fit_male_FXL_main <- fit_male_FXL_noSDC
```

and sensitivity models that include Sding-Chung.

This allows robustness to its inclusion to be evaluated while retaining the more conservative analysis as the primary model.

---

# Software and Key Packages

The analysis was conducted in **R**.

Core modelling:

* `brms`
* `Stan`

Posterior processing and visualisation:

* `tidybayes`
* `bayesplot`
* `broom.mixed`

Data manipulation:

* `tidyverse`
* `purrr`

Spatial processing and mapping:

* `raster`
* `terra`
* `sf`
* `sp`
* `tidyterra`
* `elevatr`

Additional plotting and workflow packages include:

* `patchwork`
* `fields`
* `gstat`
* `akima`

---

# Data and Code Availability

This repository provides:

* individual-level osteometric data used in the analyses;
* archaeological metadata;
* an example model-fitting workflow;
* posterior prediction and visualisation code;
* representative analytical outputs.

The example script focuses on male FXL to avoid duplicating near-identical code for every skeletal trait and sex.

The same analytical framework was applied to the remaining outcomes.

---

# Citation

If you use the data, code structure, or analytical workflow, please cite the associated study:

**Cao, D., et al.** *Spatiotemporal Variation in Human Body Form across Ancient Chinese Populations.*

Citation details will be updated following publication.

For the associated doctoral thesis:

Cao, D. (2025). *Adaptation at High Altitudes: A Comparative Analysis of Body Size and Proportions in Ancient Tibetan and Lowland Chinese Populations*. Apollo – University of Cambridge Repository. https://doi.org/10.17863/CAM.123688

---

# Contact

**Doudou Cao**
Institute for the Humanities and Social Sciences (IHSS)
University of Hong Kong
[dcao@hku.hk](mailto:dcao@hku.hk)
