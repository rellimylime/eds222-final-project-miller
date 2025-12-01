# Wildlife-Vehicle Collisions in Denmark: A Hurdle Model Analysis

**Author:** Emily Miller  
**Course:** EDS 222 - Statistics for Environmental Data Science  
**Institution:** UC Santa Barbara Bren School of Environmental Science & Management  
**Date:** December 2024

## Project Overview

This project analyzes the spatial and environmental factors influencing wildlife-vehicle collision rates on Danish roads using a hurdle modeling approach. By integrating roadkill occurrence data with traffic monitoring, road network characteristics, and land use patterns, this analysis identifies high-risk road segments where wildlife movement corridors intersect transportation infrastructure.

### Research Question

**How do traffic volume (AADT) and land use characteristics affect the frequency and intensity of roadkill on Danish roads?**

The analysis uses a two-component hurdle model to separately examine:
1. **Whether roadkill occurs** on a road segment (zero-hurdle component)
2. **How many collision events occur** given at least one event (count component)

### Key Findings

- **Forest cover** is the strongest predictor of roadkill occurrence (p < 2e-16), with roads adjacent to forests showing dramatically higher collision rates
- **Traffic volume** plays a surprisingly minor role compared to landscape context
- **Speed limits** significantly affect collision intensity, with faster roads experiencing more events
- **Urban development** (residential areas) has a strong negative effect on roadkill presence
- The analysis identifies specific high-risk road segments for targeted wildlife crossing mitigation

## Repository Structure
```
eds222-final-project-miller/
├── data/
│   ├── Global_Roadkill_data.csv          # Raw roadkill observations
│   ├── OSM_dk_roads_shp/                 # OpenStreetMap road network
│   ├── OSM_dk_landuse_shp/               # OpenStreetMap land use polygons
│   ├── ODN_dk_traffic_shp/               # Danish traffic monitoring points (MASTRA)
│   └── processed/                        # Cached processed data (after running once)
│       ├── roads_cached_2017_2019.rds
│       ├── traffic_cached_2017_2019.rds
│       ├── landuse_cached_2017_2019.rds
│       ├── distances_cache_2017_2019.rds
│       ├── roadkill_by_segment_2017_2019.rds
│       └── landcover_props_2017_2019.rds
├── config.yml                             # Project configuration file
├── eds222-final-analysis.qmd              # Main analysis document (Quarto)
├── README.md                              # This file
└── .gitignore
```

## Data Sources & Citations

### 1. Global Roadkill Dataset

**Citation:**  
Teixeira, F.Z., Coelho, A.V.P., Esperandio, I.B., & Kindel, A. (2021). *Global roadkill data 2010–2020* (Version 1.0) [Data set]. Zenodo. https://doi.org/10.5281/zenodo.5781390

**Description:**  
Citizen science and systematic survey data on wildlife-vehicle collisions worldwide. This analysis uses Danish observations from 2017-2019 (n ≈ 16,000 events).

**Fields used:**
- `country`: Filter to Denmark
- `year`: Temporal filtering (2017-2019)
- `decimalLatitude`, `decimalLongitude`: Spatial coordinates
- `numberOfRoadkill`: Count per observation

**License:** Creative Commons Attribution 4.0 International (CC BY 4.0)

---

### 2. OpenStreetMap Denmark Extract

**Citation:**  
Geofabrik GmbH. (2024). *Denmark OpenStreetMap Data* (Version 2024-10-26) [Shapefiles]. Retrieved from https://download.geofabrik.de/europe/denmark.html

**Description:**  
Comprehensive spatial data layers for Denmark including road networks, land use classification, and geographic features. Extracted October 26, 2024.

**Layers used:**
- **Roads** (`gis_osm_roads_free_1.shp`): Road geometry, classification (motorway through tertiary), speed limits, bridge/tunnel indicators
- **Land Use** (`gis_osm_landuse_a_free_1.shp`): Polygon features for forest, farmland, residential, parks, nature reserves

**Relevant OSM road codes:**
- 5111-5115: Major roads (motorway, trunk, primary, secondary, tertiary)
- 5121-5124: Minor roads (unclassified, residential, living_street)
- 5131-5135: Links and ramps

**Relevant OSM land use codes:**
- 7201: Forest
- 7228: Farmland
- 7203: Residential
- 7202: Park
- 7210: Nature reserve

**License:** Open Database License (ODbL) 1.0  
**Attribution:** © OpenStreetMap contributors

**Technical documentation:**  
Ramm, F. (2022). *OpenStreetMap Data in Layered GIS Format* (Version 12). Geofabrik GmbH. https://download.geofabrik.de/osm-data-in-gis-formats-free.pdf

---

### 3. Danish Road Traffic Data (MASTRA)

**Citation:**  
Vejdirektoratet (Danish Road Directorate). (2018). *Traffic Counts – Key Figures* [Spatial dataset]. Retrieved from https://www.opendata.dk/vejdirektoratet/taellinger-nogletal-mastra

**Description:**  
Annual Average Daily Traffic (AADT/Årsdøgnstrafik) measurements from the MASTRA traffic monitoring system. Data from 2018 used to temporally match roadkill observations (2017-2019).

**Access method:**  
WFS endpoint: `https://vmgeoserver.vd.dk/geosmastra/opendata/ows`  
Layer: `OPEN_DATA_NOEGLETAL_VIEW`  
CQL Filter: `AAR=2018` (Year 2018)

**Fields used:**
- `AAR`: Year of measurement
- `AADT`: Annual Average Daily Traffic (vehicles/day)
- `VEJNR`: Road number
- `KOMMUNE`: Municipality code
- `KOOR_SDO`: Point geometry (EPSG:25832)

**Coverage:**  
~3,000 monitoring stations covering Danish state roads and participating municipal roads (64 municipalities)

**License:** Creative Commons Attribution 4.0 (CC BY 4.0)  
**Contact:** opendata@vd.dk

---

## Methods Summary

### Spatial Data Processing

1. **Road Network Preparation**
   - Filtered to car-accessible roads (OSM codes 5111-5135)
   - Calculated segment lengths for exposure control
   - Matched to nearest traffic monitoring stations (75th percentile distance threshold: 3,699m)

2. **Land Use Extraction**
   - Created 500m buffers around road segments
   - Rasterized OSM land use polygons at 100m resolution
   - Calculated percentage cover for forest, farmland, residential, and park/nature reserve
   - Combined ecologically-similar classes (e.g., forest + scrub)

3. **Roadkill Aggregation**
   - Spatial join: roadkill points to nearest road segment
   - Counted events per segment (2017-2019)
   - 97.2% zero-inflation rate (n = 241,765 segments)

### Statistical Model

**Hurdle Model Specification:**

$$
P(Y_i = y) = \begin{cases}
\pi_i & \text{if } y = 0 \\
(1 - \pi_i) \cdot f_{\text{NB}}(y; \mu_i, \theta) & \text{if } y > 0
\end{cases}
$$

**Components:**
- **Zero-hurdle (binomial with logit link):** Models probability of ANY roadkill occurrence
- **Count (truncated negative binomial with log link):** Models intensity given presence
- **Offset:** `log(segment_length_km)` controls for road exposure

**Predictors:**
- Traffic: `log(AADT)`, `road_type`, `speed_limit`
- Land use: `pct_forest`, `pct_farmland`, `pct_residential`, `pct_park`

**R Implementation:**
```r
library(pscl)

hurdle_model <- hurdle(
  roadkill_count ~ log_AADT + road_type + speed_limit +
                   pct_forest + pct_farmland + pct_residential + pct_park |
                   log_AADT + road_type + speed_limit +
                   pct_forest + pct_farmland + pct_residential + pct_park,
  data = model_data,
  offset = log(len_km),
  dist = "negbin",
  zero.dist = "binomial"
)
```

---

## Requirements

### Software
- R ≥ 4.2.0
- RStudio (optional, for Quarto rendering)
- GDAL ≥ 3.0 (for spatial data handling)

### R Packages
```r
# Core data manipulation
install.packages(c("tidyverse", "here", "yaml"))

# Spatial analysis
install.packages(c("sf", "terra"))

# Statistical modeling
install.packages(c("pscl", "MASS"))

# Visualization
install.packages(c("ggplot2", "patchwork"))

# Quarto document rendering
install.packages("quarto")
```

---

## Reproducibility & Computational Notes

### Caching System

This analysis implements caching to reduce computational time:

- **Shapefiles cached** after first load (`.rds` format)
- **Distance calculations cached** (road-to-traffic matching: ~2-5 min first run)
- **Land use extraction cached** (rasterization + extraction: ~5-10 min first run)
- **Roadkill aggregation cached** (spatial join: ~2-5 min first run)

**Cache location:** `data/processed/`

**To force recalculation:** Delete specific `.rds` files or clear entire `data/processed/` directory

### Runtime Expectations

| Step | First Run | Cached |
|------|-----------|--------|
| Load shapefiles | <2 min | <5 sec |
| Traffic matching | <5 min | <1 sec |
| Land use extraction | <10 min | <1 sec |
| Roadkill aggregation | <5 min | <1 sec |
| Model fitting | 30 sec | 30 sec |
| **Total** | **<25 min** | **~1 min** |

### Configuration

Project parameters are managed in `config.yml`:
```yaml
# Coordinate reference system
crs: "EPSG:25832"  # ETRS89 / UTM zone 32N (Denmark)

# Road filtering codes
road_car_codes_major: [5111, 5112, 5113, 5114, 5115]  # Motorway through tertiary
road_car_codes_minor: [5121, 5122, 5123, 5124]        # Unclassified through living_street
road_car_codes_links: [5131, 5132, 5133, 5134, 5135]  # Ramps and links

# Land use codes
landuse_forest_code: "forest"
landuse_farmland_code: "farmland"
landuse_residential_code: "residential"
landuse_park_code: "park"
landuse_nature_reserve_code: "nature_reserve"

# Spatial parameters
road_buffer_distance: 500  # meters for land use extraction
distance_threshold_percentile: 0.75  # For traffic matching

# Model parameters
model_distribution: "negbin"
model_zero_dist: "binomial"
model_offset: "log(len_km)"
model_predictors: ["log_AADT", "road_type", "speed_limit", 
                   "pct_forest", "pct_farmland", "pct_residential", "pct_park"]

# Random seed
seed: 42
```

---

## Usage

### Basic Workflow

1. **Clone repository:**
```bash
git clone https://github.com/your-username/eds222-final-project-miller.git
cd eds222-final-project-miller
```

2. **Download data** (place in `data/` directory):
   - Global Roadkill CSV
   - OSM Denmark shapefiles (roads, land use)
   - Danish traffic data (MASTRA shapefile or WFS download)

3. **Update `config.yml`** with correct file paths

4. **Render analysis:**
```r
# In R/RStudio
quarto::quarto_render("eds222-final-analysis.qmd")
```

Or from terminal:
```bash
quarto render eds222-final-analysis.qmd
```

5. **Output:** HTML document with analysis, figures, and model results

---

## Results Interpretation

### Zero-Hurdle Component (Roadkill Presence)

| Predictor | Coefficient | p-value | Interpretation |
|-----------|-------------|---------|----------------|
| Forest cover | +0.031 | <2e-16 *** | Strong positive effect - roads near forests dramatically more likely to have roadkill |
| Farmland | +0.021 | <2e-16 *** | Moderate positive effect - agricultural landscapes facilitate movement |
| Residential | -0.014 | <2e-16 *** | Negative effect - urban areas reduce wildlife presence |
| Speed limit | +0.006 | <2e-16 *** | Faster roads more likely to have collisions |
| Major roads | +1.563 | <2e-16 *** | Major roads dramatically increase odds of roadkill |

### Count Component (Collision Intensity)

| Predictor | Coefficient | p-value | Interpretation |
|-----------|-------------|---------|----------------|
| Speed limit | +0.008 | 1.65e-13 *** | Higher speeds = more mortality events |
| Forest cover | +0.010 | 6.15e-05 *** | Forest roads have higher intensity |
| Farmland | -0.006 | 0.015 * | Negative in count (lower intensity than forest) |
| Major roads | +1.379 | 0.002 ** | Major roads have higher event counts |

### Model Fit

- **Log-Likelihood:** -30,660.1
- **AIC:** 61,358.1
- **Sample size:** 241,765 road segments
- **Total roadkill events:** 10,834 (across 6,850 segments)
- **Zero-inflation rate:** 97.2%

---

## Conservation Implications

1. **Wildlife corridors identified:** Forest-adjacent roads represent critical crossing zones
2. **Priority segments:** Major roads + high forest cover + high speeds = highest mitigation priority
3. **Evidence-based placement:** Model predictions can guide wildlife overpass/underpass locations
4. **Landscape matters:** Land use context is MORE important than traffic volume for predicting collisions

---

## Limitations & Future Work

### Limitations

1. **Temporal mismatch:** OSM land use (2024) vs roadkill data (2017-2019)
2. **Detection bias:** Roadkill more likely reported on major, frequently-traveled roads
3. **Species aggregation:** All taxa combined (could stratify by taxonomic group)
4. **Spatial autocorrelation:** Neighboring segments not modeled as dependent
5. **Traffic data coverage:** Only 75% of roads have AADT measurements

### Future Extensions

1. **Species-specific models:** Separate analyses for mammals, amphibians, birds
2. **Seasonal variation:** Model roadkill by season (breeding migrations, etc.)
3. **Spatial random effects:** Incorporate spatial correlation structure
4. **Water proximity:** Add distance to rivers/streams (riparian corridors)
5. **Validation:** Compare predictions to new roadkill observations (2020+)
6. **Bridge/tunnel effects:** Incorporate infrastructure crossing features

---

## License

**Code:** MIT License (see LICENSE file)

**Data:** Each dataset retains its original license (see Data Sources section)
- Global Roadkill: CC BY 4.0
- OpenStreetMap: ODbL 1.0
- Danish Traffic (MASTRA): CC BY 4.0

**Analysis:** This educational project is for academic purposes (EDS 222 final project)

---

## Contact

**Emily Miller**  
Master of Environmental Data Science  
UC Santa Barbara Bren School  
GitHub: [@rellimylime]  
Email: ermiller@ucsb.edu

---

## Acknowledgments

- **Max Czapanskiy** - EDS 222 Statistics for Environmental Data Science
- **Global Roadkill consortium** - Citizen science data collection
- **OpenStreetMap contributors** - Open geographic data
- **Vejdirektoratet** - Danish traffic monitoring data
- **UC Santa Barbara Bren School** - MEDS program support

---

## References

Geofabrik GmbH. (2024). *Denmark OpenStreetMap Data* (Version 2024-10-26). https://download.geofabrik.de/europe/denmark.html

Ramm, F. (2022). *OpenStreetMap Data in Layered GIS Format* (Version 12). Geofabrik GmbH.

Teixeira, F.Z., Coelho, A.V.P., Esperandio, I.B., & Kindel, A. (2021). *Global roadkill data 2010–2020* (Version 1.0) [Data set]. Zenodo. https://doi.org/10.5281/zenodo.5781390

Vejdirektoratet (Danish Road Directorate). (2018). *Traffic Counts – Key Figures*. https://www.opendata.dk/vejdirektoratet/taellinger-nogletal-mastra

Zeileis, A., Kleiber, C., & Jackman, S. (2008). Regression Models for Count Data in R. *Journal of Statistical Software*, 27(8), 1-25. https://doi.org/10.18637/jss.v027.i08