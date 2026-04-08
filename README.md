
# Tracking Spatial and Temporal Variation in Body Size and Proportions across Ancient Chinese Groups

## About This Repository

This repository accompanies the paper, *Spatiotemporal Variation in Human Body Form across Ancient Chinese Populations*. The paper investigates spatial and temporal trends in limb length and body proportions across 71 archaeological groups in China, spanning from the Early Neolithic to the Late Iron Age.

Special thanks to **Dr. Enrico Crema** for his invaluable guidance and support in developing the spatial and statistical modelling presented in this chapter.

## 📂 Repository Structure

```text
├── data/
│   ├── ancient_chinese_detail_for_mixed_effects_2025May_1.xlsx   # Osteometric data
│   ├── archaeological_metadata.csv                               # Site metadata: group names, periods, and data sources
│   ├── climatic data                                             # From WorldClim 2 dataset, temperatures, precipitations and elevation
│   ├── NE1_HR_LC_SR_W_DR.tif                                     # World map
│   └── bou1_4p.shp                                               # China shape
│
├── scripts/
│   ├── 01_Example_ancient_chinese_body_size_analysis_male_fxl.R                  # Example codes for male FXL (R scripts)
│   ├── 02_example_codes_male_fxl.docx                                            # Example codes for male FXL (doc file) 
│   └── 03_Example_ancient_chinese_body_size_analysis_male_fxl.html               # Example codes for male FXL (rendered html) 
│
├── output/                                                  # Figures
│   ├── FXL_male_period_CE_89PI.png                          # Temporal trend
│   ├── male_FXL_fixed_effects_89PI.png                      # Fixed effects
│   ├── male_FXL_site_random_intercepts.png                  # Random effects
│   ├── male_FXL_spatial_ALLperiods_median_only.png          # Spatial prediction surfaces (median)
│   └── male_FXL_spatial_all_periods_lower_upper_PI90.png    # Spatial prediction surfaces (upper and loower 90% boundaries)
│
└── README.md                                      # Project overview and documentation
```

> **Note:** This repository uses male femur length as an example to illustrate the modelling process.
>> The same workflow applies to all traits and sexes by changing the predicted variable (e.g., male femur length to female crural index).
>> Additional scripts are therefore omitted to avoid duplication and redundancy.


## 📚 Study Overview

- **Time span**: Early Neolithic to Late Iron Age (~10,000–38 BP)
- **Sample size**:  
  - 2,969 individuals (1,583 males, 1,386 females)  
  - 71 cultural/temporal groups from 64 sites  
- **Data sources**:  
  - New measurements (5 highland + 2 lowland sites)  
  - Published osteometric datasets  
  - Climate data from WorldClim v2.1

### 💡 Research Questions
- How did body size and proportions (e.g., femur length, crural index) vary across space and time?
- Do altitude and climatic conditions (temperature, precipitation) correlate with skeletal variation?
- What do inter-limb and intra-limb differences reveal about adaptation and variation in ancient Chinese populations?

## 🧪 Data Description

Measurements included:

| Variable | Description | Sample Size |
|----------|-------------|-------------|
| FXL | Femur maximum length (proxy for stature) | 3,027 |
| TXL | Tibia maximum length | 1,252 |
| HXL | Humerus maximum length | 1,047 |
| RXL | Radius maximum length | 803 |
| FBL | Bicondylar femur length | 102 |
| FHD | Femoral head diameter (proxy for body mass) | 1,587 |

### 🧍‍♂️ Indices Computed
- **Brachial Index (BI)** = RXL / HXL
- **Crural Index (CI)** = TXL / FBL  
  - If FBL is missing, approximated using FXL (n = 2,227)

### 🧭 Time Period Categories

| Period | Description            | Date Range (BP) | Cultural / Dynastic Context |
|--------|------------------------|-----------------|------------------------------|
| 1      | Early Neolithic        | 9,000–7,000  | Early farming communities (e.g., Jiahu, Jiangjialiang) |
| 2      | Middle Neolithic       | 7,000–4,500  | Agricultural intensification (e.g., Miaodigou, Qingtai) |
| 3      | Late Neolithic         | 4,500–3,500  | Emergiing social inequalities (e.g., Mougou, **Erlitou [Xia?]**) |
| 4      | Bronze–Early Iron Age  | 3,500–2,152  | Early states and metallurgy: Shang, Western Zhou, Spring–Autumn (pre-Qin) periods |
| 5      | Early–Mid Iron Age     | 2,152–1,530  | Warring States, Qin, Western Han, Eastern Han |
| 6      | Middle Iron Age        | 1,530–583    | Fragmentation and cosmopolitan empires: Three Kingdoms, Jin, Northern & Southern Dynasties, Sui, Tang, Song, Yuan |
| 7      | Late Iron Age          | 582–38       | Late imperial period: Ming, Qing Dynasties |

#### Notes:
- The **Erlitou culture**, often associated with the legendary **Xia Dynasty**,  is included in Period 3 due to its transitional position between Neolithic and Bronze Age phases.
- These categories integrate archaeological chronology with major cultural and dynastic phases to contextualise spatiotemporal variation in the dataset.
- For approximate conversion: **1,000 BP ≈ 950 CE** (assuming 1950 as the reference point).

### 🧬 Sex Estimation Protocols

- **Newly collected groups** (e.g., Gaoshan, Phiyang-Dungkar, Sding-Chung):  
  - Used direct sex estimation by this study (Chapter 2 and 3)  
- **Published groups**:  
  - Used published sex estimates

## 🌎 Environmental Data

- **Sources**: WorldClim v2.1 bioclimatic layers (~1 km² resolution)
  - > Fick, S. E. & Hijmans, R. J. (2017). *WorldClim 2: new 1-km spatial resolution climate surfaces for global land areas.* International Journal of Climatology, 37(12), 4302–4315. DOI: 10.1002/joc.5086
- **Variables**: Altitude, min/max annual temperature, precipitation
- **Tools**: Extracted using R `raster` package

## 🔍 Methods Summary

This study employed **Bayesian Generalised Additive Mixed Models (GAMMs)** to investigate long-term spatial and temporal variation in body size and proportions among ancient Chinese populations.

### 🧠 Model Overview

- **Traits modelled**: Femur length (FXL), femoral head diameter (FHD), tibia length (TXL), humerus length (HXL), radius length (RXL), and limb proportion indices including the crural index and brachial index
- **Model type**: Bayesian generalised additive mixed models (GAMMs) fitted in `brms` using `Stan` and Hamiltonian Monte Carlo (HMC)
- **Sex-specific models**: All models were fitted separately for males and females
- **Standardisation**:
  - Outcome variables and continuous predictors were z-scored within each sex-specific analytical dataset
  - Standardisation was used to improve numerical stability, support model convergence, and make effect sizes more comparable across predictors and traits


### 📅 Temporal Modeling

- **Time structure**:
  - Temporal variation was modelled using a categorical archaeological period variable rather than continuous imputed calendar dates
  - The period levels were ordered as:
    - `E_Neo`
    - `M_Neo`
    - `L_Neo`
    - `Bronze`
    - `E_M_Iron`
    - `M_Iron`
    - `L_Iron`
- **Coding**:
  - Period was treated as a factor with sum-to-zero contrasts (`contr.sum`), so period estimates represent deviations relative to the overall mean rather than a single reference category
- **Temporal visualisation**:
  - Population-level conditional effects for period were extracted using `conditional_effects(..., re_formula = NA)`
  - Temporal summaries were displayed with medians and 89% credible intervals

### 🌍 Spatial & Environmental Predictors

- **Environmental fixed effects** (all z-scored within sex):
  - `mintemp_scaled`: minimum temperature
  - `maxtemp_scaled`: maximum temperature
  - `minprecip_scaled`: minimum precipitation
  - `maxprecip_scaled`: maximum precipitation
  - `altitude_scaled`: altitude
- **Spatial smooth**:
  - `t2(longitude_scaled, latitude_scaled)`
  - A two-dimensional tensor-product smooth was used to model broad nonlinear spatial structure
- **Group-level term**:
  - `(1 | site_id)`
  - A varying intercept for archaeological site was included to capture clustering within sites and allow partial pooling across uneven sample sizes

---

### 📐 Model Formula (Example)

```text
Trait_z ~ period +
          t2(longitude_scaled, latitude_scaled) +
          mintemp_scaled + maxtemp_scaled +
          minprecip_scaled + maxprecip_scaled +
          altitude_scaled +
          (1 | site_id)
```

- **Trait_z**: The z-scored skeletal measurement or index (e.g., FXL_z, BI_z)

- **period**:  ordered archaeological period factor fitted with sum coding

- **t2(longitude_scaled, latitude_scaled)**: tensor-product spatial smooth for broad geographic structure

- **mintemp_scaled to altitude_scaled**: standardised environmental covariates

- **(1 | site_id)**: varying intercept for archaeological site

- **Likelihood**: Student-𝑡, used to provide robustness to outliers and heavy-tailed variation
- **Priors**: Weakly informative  
  - Fixed effects: `Normal(0, 1)`
  - Intercept: `Normal(0, 1)`
  - Residual SD (sigma): `Student-t(3, 0, 1)`
  - Smoothness parameters (sds): `Exponential(1)`
  - Degrees of freedom (nu): `Gamma(2, 0.1)`


### 🗺️ Prediction & Visualisation
**Prediction grid**: 
- Spatial predictions were generated over a regular grid spanning longitude 70–140 and latitude 10–60
- The grid used 350 × 350 locations before expansion across periods
**Environmental extraction**: 
- Raster values for temperature, precipitation, and elevation were extracted from WorldClim-derived layers and elevation rasters
**Period expansion**:
- The base grid was crossed with all seven archaeological periods so that predictions were generated for each period-specific surface
**Prediction level**:
- Predictions were generated from the population-level component of the model (re_formula = NA), excluding site-specific random effects
**Posterior summaries**:
- Predictions were computed using add_epred_draws() with 200 posterior draws per chunk
- Median fitted values and 90% posterior intervals were then summarised for each grid cell and period
**All-period summary surface**:
- For spatial visualisation, period-specific predictions were averaged across the seven modelled periods at each grid cell to produce an overall summary surface
**Masking**:
- Final mapped surfaces were restricted using a buffered convex hull based on observed site locations, reducing extrapolation far beyond the sampled regions
**Mapped outputs**:
- Median predicted surface
- Lower 90% bound
- Upper 90% bound
- 
**📊 Additional Outputs**
**Temporal effects**:
- Estimated marginal effects for archaeological periods with 89% credible intervals
**Environmental coefficients**:
- Posterior distributions of fixed effects summarised using half-eye plots and interval estimates
**Site-level deviations**:
- Posterior distributions of site-specific random intercepts were extracted and plotted to show group-level departures from the overall modelled pattern

## 🛠️ Software & Key Packages
The analysis was conducted in **R**. The modelling workflow was built primarily around **brms** and **Stan**, with additional packages used for data processing (**tidyverse**, **purrr**), posterior summarisation and visualisation (**tidybayes**, **bayesplot**, **broom.mixed**, **patchwork**), and spatial data handling and mapping (**raster**, **terra**, **sf**, **sp**, **tidyterra**, **elevatr**).


## 📌 Citation and Credits

If you use this code, data structure, or methodology, please cite:

## 📫 Contact

Doudou Cao  
Institute for the Humanities and Social Sciences (IHSS)
University of Hong Kong
✉️ dcao@hku.hk

