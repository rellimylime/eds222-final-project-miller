library(sf)

# Check landuse data
cat("=== OSM_dk_landuse STRUCTURE ===\n")
lnd <- st_read("data/OSM_dk_landuse_shp/gis_osm_landuse_a_free_1.shp")
cat("Columns:", names(lnd), "\n\n")
cat("Unique landuse types:\n")
print(table(lnd$fclass))

# Check places data
cat("\n=== OSM_dk_places STRUCTURE ===\n")
plc <- st_read("data/OSM_dk_places_shp/gis_osm_places_a_free_1.shp")
cat("Columns:", names(plc), "\n\n")
cat("Unique place types:\n")
print(table(plc$fclass))
