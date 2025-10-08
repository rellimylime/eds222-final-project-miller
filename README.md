# PRODES-SEM: Spatial Error Modeling of Amazon Deforestation

A small, focused repo for a final project that fits a 5-week timeline. It demonstrates a spatial error model on annual deforestation from PRODES and tests whether adjacency to Indigenous lands is associated with lower deforestation rates.

## What this is

- A reproducible workflow to:
1. load PRODES annual deforestation,
2. aggregate to Brazilian municipalities,
3. construct an exposure for adjacency to Indigenous territories,
4. test for spatial autocorrelation and fit a spatial error model,
5. report effect sizes with uncertainty and publish figures for a technical blog post.

Why it is useful: shows end-to-end use of a spatial econometric model on real environmental data with clear policy relevance.

## Repository structure
```
eds222-final-project-miller
├─ 1_explore_data.R        # minimal data prep + OLS + SEM
├─ data/
│  └─ prodes_amazonia_nb.gpkg/            
├─ docs/
├─ figs/
├─ blog/
|  └─ blog.qmd
├─ R
|  └─ 01_prepare.R               
├─ output
├─ eds222-final-project-miller.Rproj
├─ .gitignore
└─ README.md
```

## Data access

You will download raw data yourself and place it in data/. Large files are not tracked.

Required

- PRODES Amazônia, complete vector GeoPackage (about 860 MB). Download and unzip to data/prodes_amazonia_nb.gpkg.
Source: https://terrabrasilis.dpi.inpe.br/en/download-files

- Direct path example: https://terrabrasilis.dpi.inpe.br/download/dataset/amz-prodes/vector/prodes_amazonia_nb.gpkg.zip

- Brazilian municipalities (IBGE, 2020 or similar). Save the shapefile or GeoPackage in data/.
Source: https://www.ibge.gov.br/en
 (Geosciences, Municipal Mesh) or the geobr R package.

- Indigenous and Community Lands (LandMark). Save the Brazil Indigenous territories layer to data/.
Source: https://landmarkmap.org

Optional

- WDPA protected areas if you want a sensitivity check.
Source: https://www.protectedplanet.net

## Notes on licenses

- PRODES: Creative Commons Attribution ShareAlike 4.0 International. Cite INPE and the specific product page.

- LandMark and IBGE have their own licenses and terms. Keep raw files out of version control and cite sources in your blog post and figures.

## Quick start

Install once:
```
install.packages(c("sf","terra","dplyr","readr","stringr","lwgeom",
                   "spdep","spatialreg","ggplot2","units","arrow","geobr"))
```

Run the minimal pipeline:
```
source("R/01_prepare.R")
```

## Outputs:

...

## References and acknowledgements

- INPE, PRODES Amazônia. TerraBrasilis download portal.

- IBGE, Malha Municipal.

- LandMark Global Platform of Indigenous and Community Lands.

- R packages: sf, spdep, spatialreg, geobr

- Python packages: geopandas, libpysal, esda, spreg

## License

- Code in this repository: MIT License.

- Documentation and figures: CC BY-NC 4.0.

- External datasets retain their original licenses and terms. Cite them wherever they appear.

