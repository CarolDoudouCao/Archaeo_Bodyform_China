
# Chapter 7 – Tracking Spatial and Temporal Variation in Body Size and Proportions across Ancient Chinese Groups

This repository supports Chapter 7 of my PhD thesis _Adaptation at High Altitudes: A Comparative Analysis of Body Size and Proportions in Ancient Tibetan and Lowland Chinese Populations_ (University of Cambridge, 2025). It explores tempo-spatial trends in limb length and body proportions across 71 archaeological groups in China from the Early Neolithic to the Late Iron Age.


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

| Period | Description | Date Range |
|--------|-------------|------------|
| 1 | Early Neolithic | 9,000–7,000 BP |
| 2 | Middle Neolithic | 7,000–4,500 BP |
| 3 | Late Neolithic | 4,500–3,500 BP |
| 4 | Bronze–Early Iron Age | 3,500–2,152 BP |
| 5 | Early–Mid Iron Age | 2,152–1,530 BP |
| 6 | Middle Iron Age | 1,530–583 BP |
| 7 | Late Iron Age | 582–38 BP |

### 🧬 Sex Estimation Protocols

- **Newly collected groups** (e.g., Gaoshan, Phiyang-Dungkar, Sding-Chung):  
  - Used direct sex estimation by this study (Chapter 2 and 3)  
- **Published groups**:  
  - Used published sex estimates

## 🌎 Environmental Data

- **Sources**: WorldClim v2.1 bioclimatic layers (~1 km² resolution)
- **Variables**: Altitude, min/max annual temperature, precipitation
- **Tools**: Extracted using R `raster` package

## 📂 Repository Structure

```text
├── data/
│   ├── archaeological_metadata.csv   # Site names, periods, coordinates
│   └── limb_measurements_indices.csv     # Raw osteometric data + computed BI, CI
│
├── scripts/
│   ├── 01_data_preparation.R
│   ├── 02_bayesian_modeling.R
│   ├── 03_predictive_spatiotemporal_plots.R
│   ├── 04_fixed_and_random_effects_plotting.R
│   ├── 05_marginal_effects.R
│   └── 06_figures_generation.R
│
├── figures/
│   ├── fig7_1_sample_distribution.png
│   ├── fig7_3_site_locations_by_period.png
│   └── ...
│
├── output/
│   ├── regression_coefficients.csv
│   ├── summary_statistics.xlsx
│   └── posterior_draws/
│
└── README.md
```
🔍 Methods Summary
This study employed Bayesian Generalized Additive Mixed Models (GAMMs) to investigate long-term spatial and temporal variation in body size and proportions among ancient Chinese populations.

🧠 Model Overview
Traits modeled: Femur length (FXL), femoral head diameter (FHD), crural and brachial indices

Model type: Bayesian GAMMs via brms and Stan, using HMC sampling

Sex-specific models: All traits were modeled separately for males and females

Standardization:

All predictors and outcomes were z-scored to improve numerical stability and comparability across variables

Time was modeled as a penalized spline using imputed calendar dates (see below)

📅 Temporal Modeling
Time variable:

Calendar-year estimates (in BP) were sampled from group-specific ranges (direct radiocarbon intervals or archaeological phase boundaries)

Each model was run across 50 imputed datasets to capture temporal uncertainty

Spline smoothing:

Time modeled as s(date_z) with 10 basis functions (k=10)

Avoids arbitrary binning and reflects uncertainty in archaeological chronology

🌍 Spatial & Environmental Predictors
Fixed effects:

Minimum and maximum temperature

Minimum and maximum precipitation

Altitude

Spatial smooth:

A tensor-product spline (t2(lon_z, lat_z)) captures residual geographic patterning

Random effect:

Archaeological group as a varying intercept (1 | group) to account for cultural or population-level differences

📐 Model Specification
Each model followed the form:

```text
Trait_z ~ s(date_z, k=10) + t2(lon_z, lat_z) + β1·mintemp_z + β2·maxtemp_z + β3·minprecip_z + β4·maxprecip_z + β5·altitude_z + (1 | group)
```

Likelihood: Student-t (robust to outliers)

Priors: Weakly informative priors (e.g., Normal(0,1), Student-t(3,0,1), Exponential(1))

🗺️ Prediction & Visualization
Three prediction maps were generated:

Full model: includes both spatial and environmental effects

Spatial-only: environmental variables held at mean (z = 0)

Environmental effect: difference between full and spatial-only models

Predictions were based on a ~16,000-point spatial grid across China, using climate rasters from WorldClim v2.1 (Fick & Hijmans 2017). Posterior draws and conditional effect plots were generated using tidybayes.

⚙️ Software & Tools
brms and Stan for Bayesian modeling

tidyverse, raster, sf, furrr, tidybayes for data wrangling and visualization

Parallelization used for efficiency across 50 imputed datasets

## 🛠️ Software and Packages

- **R version ≥ 4.2**
- Key packages:
  - `tidyverse`
  - `brms`, `rstan`
  - `sf`, `terra`, `raster`
  - `ggplot2`, `patchwork`, `cowplot`
 
## 📌 Citation and Credits

If you use this code, data structure, or methodology, please cite:

Cao, D. (2025). _Adaptation at High Altitudes: A Comparative Analysis of Body Size and Proportions in Ancient Tibetan and Lowland Chinese Populations_. PhD Thesis, University of Cambridge. Chapter 7: Tracking Spatial and Temporal Variation in Body Size and Proportions across Ancient Chinese Groups.


## 📫 Contact

Doudou Cao  
PhD Candidate, Biological Anthropology  
University of Cambridge  
Email: [dc798@cam.ac.uk]

