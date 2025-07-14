# Archaeo_Bodyform_China
Code and data for the study "Tracking Spatial and Temporal Variation in Body Size and Proportions across Ancient Chinese Groups", as part of Doudou Cao's PhD thesis. 

Includes data processing, Bayesian modeling, visualisations, and figure generation.


# Tracking Spatial and Temporal Variation in Body Size and Proportions across Ancient Chinese Groups

This repository accompanies the analyses for Chapter 7 of my PhD thesis, which investigates how body size and limb proportions varied across time, space, and ecology among archaeological groups in China spanning from the Early Neolithic to the Late Imperial period (~10,000–38 BP). It includes original osteometric measurements from newly analyzed highland and lowland populations, combined with published datasets from 64 archaeological sites, and integrates climatic, geographic, and ecological data to evaluate temporal and spatial trends.

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

