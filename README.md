
# Chapter 7 – Tracking Spatial and Temporal Variation in Body Size and Proportions across Ancient Chinese Groups

This repository supports Chapter 7 of Doudou Cao's PhD thesis _Adaptation at High Altitudes: A Comparative Analysis of Body Size and Proportions in Ancient Tibetan and Lowland Chinese Populations_ (University of Cambridge, 2025). It explores tempo-spatial trends in limb length and body proportions across 71 archaeological groups in China from the Early Neolithic to the Late Iron Age.

## 📂 Repository Structure

```text
├── data/
│   ├── archaeological_metadata.csv                # Site metadata: group names, periods, and data sources
│   └── individual_limb_measurements_indices.csv   # Osteometric data (e.g., male FXL example) with computed BI and CI
│
├── scripts/
│   ├── 01_data_preparation.R                      # Clean and standardise raw and metadata
│   ├── 02_bayesian_modeling.R                     # Fit Bayesian GAMMs with brms
│   ├── 03_predictive_spatiotemporal_plots.R       # Generate spatial prediction maps
│   ├── 04_fixed_and_random_effects_plotting.R     # Extract and plot model effects
│   ├── 05_marginal_effects.R                      # Conditional effect plots for each predictor
│   └── 06_figures_generation.R                    # Compile and export final publication figures
│
├── output/                                        # Tables and figures
│   ├── regression_coefficients/                   # CSV files with posterior summaries of fixed effects
│   ├── map_and_timeline/                          # Maps and chronological figures
│   ├── predictive_surfaces/                       # Spatial prediction surfaces
│   ├── posterior_draws/                           # Fixed and random effects
│   └── temporal_trends/                           # Marginal effect plots
│
└── README.md                                      # Project overview and documentation
```

> **Note:** This repository uses male femur length as an example to illustrate workflows.  
>>  The scripts are applicable to both sexes and all traits—simply change the predicted variable, e.g., from male femur length (male_FXL) to female crural index (female_CI).
>>> Additional scripts are therefore omitted to avoid duplication.


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
- **Variables**: Altitude, min/max annual temperature, precipitation
- **Tools**: Extracted using R `raster` package

## 🔍 Methods Summary

This study employed **Bayesian Generalised Additive Mixed Models (GAMMs)** to investigate long-term spatial and temporal variation in body size and proportions among ancient Chinese populations.

### 🧠 Model Overview

- **Traits modeled**: Femur length (FXL), femoral head diameter (FHD), tibiae length (TXL), humerus length (HXL), radius length (RXL), crural and brachial indices (see definations above)
- **Model type**: Bayesian GAMMs via `brms` and `Stan`, using Hamiltonian Monte Carlo (HMC) sampling  
- **Sex-specific models**: All traits were modeled separately for males and females
- **Standardisation**:  
  - All predictors and outcome variables were z-scored to improve numerical stability, aid model convergence, and enable effect size comparability across traits  
  - Time was modeled as a penalised spline on imputed calendar-year estimates; models were fitted across 50 imputed datasets to account for chronological uncertainty

### 📅 Temporal Modeling

- **Time variable**:  
  - Calendar-year estimates (in years BP) were sampled from group-level time ranges  
  - Ranges were based on either calibrated radiocarbon intervals or archaeological period boundaries  
  - Models were fit to 50 imputed datasets to incorporate chronological uncertainty
- **Spline smoothing**:  
  - Time modeled as `s(date_z, k = 10)` to capture non-linear trends without arbitrary binning

### 🌍 Spatial & Environmental Predictors

- **Fixed effects** (all standardised):
  - `mintemp_z`: Minimum temperature (coldest month)
  - `maxtemp_z`: Maximum temperature (warmest month)
  - `minprecip_z`: Minimum precipitation (driest month)
  - `maxprecip_z`: Maximum precipitation (wettest month)
  - `altitude_z`: Site altitude

- **Spatial smooth**:  
  - `t2(lon_z, lat_z)`: A 2D tensor-product spline modeling spatial autocorrelation using standardised longitude and latitude

- **Random effect**:  
  - `(1 | group)`: A random intercept for archaeological group, capturing group-level structure and allowing partial pooling

---

### 📐 Model Formula (Example)

```text
Trait_z ~ s(date_z, k = 10) + t2(lon_z, lat_z) +
β₁·mintemp_z + β₂·maxtemp_z +
β₃·minprecip_z + β₄·maxprecip_z +
β₅·altitude_z + (1 | group)
```

- **Trait_z**: The z-scored skeletal measurement or index (e.g., FXL_z, BI_z)

- **s(date_z, k = 10)**: A univariate spline capturing non-linear temporal trends using the standardised imputed calendar date; k = 10 limits flexibility to avoid overfitting

- **t2(lon_z, lat_z)**: A 2D thin-plate spline modeling spatial autocorrelation using standardised longitude and latitude

- **β₁–β₅**: Coefficients for fixed effects of environmental variables (standardised)

- **(1 | group)**: A random intercept for archaeological group, accounting for shared variation within cultural or regional groups and allowing partial pooling across sites with different sample sizes

- **Likelihood**: Student-t (robust to outliers)
- **Priors**: Weakly informative  
  - Fixed effects: `Normal(0, 1)`  
  - Random and residual SDs: `Student-t(3, 0, 1)`  
  - Spline smoothness: `Exponential(1)`


### 🗺️ Prediction & Visualisation

Three prediction maps were generated:

1. **Full model**: includes spatial and environmental effects  
2. **Spatial-only**: holds climate variables constant at their mean (z = 0)  
3. **Environmental effect**: difference between full and spatial-only models

- Predictions were computed for a 400 × 400 grid (~16,000 locations) across China  
- Environmental rasters were extracted from **WorldClim v2.1** at 30 arc-second resolution  
- Posterior draws and conditional effect plots were generated using `tidybayes`

## 📊 Figures (Chapter 7 Outputs)

The following figures were generated from this study and correspond to those presented in Chapter 7 of the thesis:

| Figure No. | Title                                                                                     | 
|------------|--------------------------------------------------------------------------------------------|
| 7.1        | Geographical Divisions and Suggested Population Exchanges in Ancient China                | 
| 7.2        | Timeline of China’s Major Chronological Periods and Dynasties                              | 
| 7.3        | Locations of Archaeological Groups by Time Period and Sample Size                          | 
| 7.4        | Predicted Spatial Variation in Male Lower Limb Size and Proportions                        | 
| 7.5        | Predicted Spatial Variation in Male Upper Limb Size and Proportions                        | 
| 7.6        | Predicted Spatial Variation in Female Lower Limb Size and Proportions                      | 
| 7.7        | Predicted Spatial Variation in Female Upper Limb Size and Proportions                      | 
| 7.8        | Predicted Temporal Trends in Maximum Femoral Length (FXL) and Femoral Head Diameter (FHD) | 
| 7.9        | Predicted Temporal Trends in Brachial Index (BI) and Crural Index (CI)                     |
| 7.10       | Posterior Distributions of Fixed Effects on Lower Limb Dimensions and Proportions          | 
| 7.11       | Posterior Distributions of Fixed Effects on Upper Limb Dimensions and Proportions          | 
| 7.12       | Posterior Estimates of Group-Level Intercepts for Male Femoral Length (FXL)                |
| 7.13       | Posterior Estimates of Group-Level Intercepts for Female Femoral Length (FXL)              | 

> 📁 All figure files are available in the `figures/` directory as `.png`or `.tiff` images. 

## 🛠️ Software & Key Packages

The analysis was conducted in **R (≥ 4.2)** using the following core packages:

- `brms`, `rstan` – Bayesian modeling via Stan and HMC sampling  
- `tidyverse` – Data wrangling and plotting (`dplyr`, `ggplot2`, `readr`, etc.)  
- `sf`, `terra`, `raster` – Spatial data handling and environmental extraction  
- `sp` – Spatial points creation for raster-based climate extraction  
- `furrr` – Parallelised imputation–modeling workflow across multiple cores  
- `posterior` – Efficient manipulation and thinning of Stan draws  
- `cmdstanr` – On-disk sampling backend for `brms` models (faster & memory efficient)  
- `tidybayes` – Posterior summarization and uncertainty visualisation  
- `mgcv` – Spline terms (`s()`, `t2()`) in semiparametric models  
- `here` – Project-rooted file path management  
- `patchwork`, `cowplot` – Plot arrangement and multi-panel figure layout  
- `RColorBrewer` – Color palettes for maps and model coefficient plots  


## 📌 Citation and Credits

If you use this code, data structure, or methodology, please cite:

Cao, D. (2025). _Adaptation at High Altitudes: A Comparative Analysis of Body Size and Proportions in Ancient Tibetan and Lowland Chinese Populations_. PhD Thesis, University of Cambridge. Chapter 7: Tracking Spatial and Temporal Variation in Body Size and Proportions across Ancient Chinese Groups.


## 📫 Contact

Doudou Cao  
PhD Candidate, Biological Anthropology  
University of Cambridge  
Email: [dc798@cam.ac.uk]

