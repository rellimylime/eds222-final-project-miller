# Traffic, Land Use, and Roadkill in Denmark

**EDS 222: Statistics for Environmental Data Science - Final Project**

A reproducible analysis investigating how traffic volume and land use characteristics affect wildlife-vehicle collisions in Denmark using a hurdle model framework.

---

## What This Is

This project analyzes the relationship between roadkill frequency and:
- **Traffic volume** (AADT - Annual Average Daily Traffic)
- **Road characteristics** (type, speed limit, length)
- **Land use context** (forest, farmland, residential, protected areas)

The analysis uses a **hurdle model** to separately model:
1. Whether roadkill occurs on a road segment (presence/absence)
2. How many collisions happen when roadkill does occur (intensity)

This approach is appropriate for zero-inflated count data (83% of road segments have zero roadkill).

---

## Repository Structure

```
eds222-final-project-miller/
├── final-analysis.qmd                     # Main analysis (run this!)
├── eds222-final-project-scratch.qmd       # Scratch work/exploration
├── config.yml                             # Configuration file (paths, parameters)
├── data/
│   ├── raw/                              # Raw data files (not tracked)
│   │   ├── Global Roadkill data.csv
│   │   ├── OSM_dk_roads_shp/             # Road network
│   │   ├── ODN_dk_traffic_shp/           # Traffic monitoring points
│   │   └── OSM_dk_landuse_shp/           # Land use polygons
│   └── processed/                        # Cached files (auto-generated)
│       ├── roads_dk_epsg25832.rds
│       ├── traffic_dk_epsg25832.rds
│       ├── landuse_dk_epsg25832.rds
│       ├── distances_cache_2017_2019.rds
│       ├── roadkill_by_segment_2017_2019.rds
│       └── landuse_props_2017_2019.rds
├── .gitignore
└── README.md
```

---

## Data Sources

### Required Data

You will need to download these datasets and place them in `data/raw/`:

#### 1. **Roadkill Data**
- **File**: `Global Roadkill data.csv`
- **Source**: Global Roadkill Database
- **Description**: Wildlife-vehicle collision observations with coordinates
- **Filter to**: Denmark, years 2017-2019
- **Download**: [Global Roadkill Database](https://doi.org/10.1111/geb.13030)

#### 2. **Road Network**
- **Folder**: `OSM_dk_roads_shp/`
- **File**: `gis_osm_roads_free_1.shp` (shapefile)
- **Source**: OpenStreetMap via Geofabrik
- **Description**: Danish road network with road types and attributes
- **Download**: [Geofabrik Denmark](https://download.geofabrik.de/europe/denmark.html)
  - Download "Denmark (free shapefile)" → Extract to `data/raw/`

#### 3. **Traffic Data**
- **Folder**: `ODN_dk_traffic_shp/`
- **File**: `OPEN_DATA_NOEGLETAL_VIEWPoint.shp` (shapefile)
- **Source**: Vejdirektoratet (Danish Road Directorate)
- **Description**: Traffic monitoring points with AADT (Annual Average Daily Traffic)
- **Download**: [Danish Road Directorate Open Data](https://www.vejdirektoratet.dk/side/hvordan-faar-jeg-adgang-til-aabne-data)

#### 4. **Land Use Data**
- **Folder**: `OSM_dk_landuse_shp/`
- **File**: `gis_osm_landuse_a_free_1.shp` (shapefile)
- **Source**: OpenStreetMap via Geofabrik
- **Description**: Land use polygons (forest, farmland, residential, parks)
- **Download**: Same as roads - included in Geofabrik Denmark download

### Data Not Tracked in Git

Raw data files are **not tracked** in version control due to size. The `.gitignore` excludes:
- `data/raw/*` (original datasets)
- `data/processed/*` (cached files - regenerated automatically)

Store raw data on:
- Google Drive
- Institutional storage
- Or download fresh for each use

---

## Quick Start

### 1. Install R Packages

```r
install.packages(c(
  "tidyverse",   # Data manipulation
  "sf",          # Spatial data
  "terra",       # Raster data (if using CORINE)
  "here",        # File paths
  "pscl",        # Hurdle models
  "yaml",        # Config file reading
  "patchwork"    # Plot layouts
))
```

### 2. Download Data

Place all raw data in the `data/raw/` folder following the structure above.

### 3. Run the Analysis

Open `final-analysis.qmd` in RStudio and render it:

```r
# Option 1: Render to HTML
quarto::quarto_render("final-analysis.qmd")

# Option 2: Run chunks interactively in RStudio
# Click "Run All" or run chunk-by-chunk
```

**First run**: Takes ~10-20 minutes to process shapefiles and create caches

**Subsequent runs**: Takes ~2-5 minutes (loads from cache)

---

## Analysis Workflow

The analysis proceeds in these steps:

1. **Setup & Configuration** - Load libraries and config file
2. **Data Loading** - Load roadkill, roads, traffic, land use (with caching)
3. **Spatial Processing**:
   - Filter to car-accessible roads
   - Match traffic data to roads using nearest neighbor
   - Extract land use proportions within 500m buffers
   - Aggregate roadkill counts by road segment
4. **Exploratory Analysis** - Visualize distributions and relationships
5. **Statistical Modeling** - Fit hurdle model (negative binomial + logistic)
6. **Results & Interpretation** - Examine coefficients and implications

---

## Model Specification

**Hurdle Model** with two components:

### Zero-Inflation Component (Logistic Regression)
Models probability of **any** roadkill occurring:

```
logit(P(Y = 0)) ~ log(AADT) + road_type + speed_limit +
                  pct_forest + pct_farmland + pct_residential + pct_park
```

### Count Component (Negative Binomial)
Models **how many** roadkill events, given Y > 0:

```
log(E[Y | Y > 0]) ~ log(AADT) + road_type + speed_limit +
                    pct_forest + pct_farmland + pct_residential + pct_park
                    + offset(log(road_length_km))
```

**Offset**: Controls for road length exposure (models **rate per km**)

---

## Configuration

All file paths and parameters are in `config.yml`:

- **File paths**: Raw data locations, cache locations
- **CRS**: EPSG:25832 (Denmark ETRS89 / UTM zone 32N)
- **Analysis parameters**: Buffer distance (500m), traffic matching threshold (75th percentile)
- **Model settings**: Distribution (negbin), predictors, offset

Edit `config.yml` to change parameters without modifying code.

---

## Caching System

The analysis caches expensive operations in `data/processed/`:

| Cache File | What It Contains | Time Saved |
|------------|-----------------|------------|
| `roads_dk_epsg25832.rds` | Roads (cropped & reprojected) | ~10 sec |
| `traffic_dk_epsg25832.rds` | Traffic points (cropped & reprojected) | ~5 sec |
| `landuse_dk_epsg25832.rds` | Land use (cropped & reprojected) | ~15 sec |
| `distances_cache_2017_2019.rds` | Road-to-traffic distances | ~5-10 min |
| `roadkill_by_segment_2017_2019.rds` | Roadkill counts per segment | ~2-5 min |
| `landuse_props_2017_2019.rds` | Land use % in 500m buffers | ~2-5 min |

**To regenerate caches**: Delete files in `data/processed/` and re-run analysis

---

## Key Results

*(This section will be updated after running the analysis)*

The analysis will show:
- Which land use types increase roadkill risk
- Effect of traffic volume controlling for land use
- Differences between road types
- High-risk segments for targeted mitigation

---

## Technical Notes

### Coordinate Systems
- **Input data**: WGS84 (EPSG:4326) for coordinates, various CRS for shapefiles
- **Analysis CRS**: EPSG:25832 (Denmark ETRS89 / UTM zone 32N)
- All data reprojected to common CRS for analysis

### Land Use Classification
OpenStreetMap `fclass` codes used:
- Forest: 7201
- Farmland: 7228
- Residential: 7203
- Parks/Protected: 7202, 7210

### Traffic Matching
- Nearest neighbor approach with distance threshold
- 75th percentile threshold (~1-2 km) balances coverage vs quality
- Roads > threshold distance assigned NA for AADT

### Data Filtering
- Analysis restricted to roads with measured traffic (75% of network)
- Represents monitored road network (major corridors, developed areas)
- May not generalize to remote rural roads

---

## References & Citations

### Data Sources
- **Roadkill**: Global Roadkill Database (Santos et al. 2020)
- **Roads & Land Use**: OpenStreetMap contributors via Geofabrik
- **Traffic**: Vejdirektoratet (Danish Road Directorate)

### Methods
- **Hurdle Models**: Zeileis, A., Kleiber, C., & Jackman, S. (2008). Regression models for count data in R. *Journal of Statistical Software*, 27(8).
- **Spatial Analysis**: Pebesma, E. (2018). Simple Features for R. *The R Journal*, 10(1), 439-446.

### Software
- R version 4.x
- Key packages: `tidyverse`, `sf`, `pscl`, `here`, `yaml`

---

## License

- **Code**: MIT License (see LICENSE file)
- **Documentation**: CC BY 4.0
- **External datasets**: Retain original licenses - cite sources in publications

---

## Acknowledgements

This project was completed as part of EDS 222: Statistics for Environmental Data Science at the Bren School of Environmental Science & Management, UC Santa Barbara.

---

## Contact

For questions about this analysis, please open an issue in this repository.

---

## Project Status

🚧 **In Progress** - Final project for EDS 222 (Fall 2025)

**Completed**:
- ✅ Data acquisition and preprocessing
- ✅ Shapefile caching system
- ✅ Land use extraction workflow
- ✅ Model specification

**In Progress**:
- 🔄 Model fitting and diagnostics
- 🔄 Results interpretation
- 🔄 Visualization enhancement

**Planned**:
- 📋 Marginal effects plots
- 📋 High-risk segment mapping
- 📋 Final blog post formatting
