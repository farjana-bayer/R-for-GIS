if (!require("pacman")) install.packages("pacman")
pacman::p_load(
  sf, # vector data operations
  dplyr, # data wrangling
  data.table, # data wrangling
  tmap, # make maps
  mapview, # create an interactive map
  patchwork,# arranging maps
  geosphere,
  sp,
  raster,
  terra,
  tidyverse
)


##create buffer around points
#--- read wells location data ---#
urnrd_wells_sf <-
  readRDS("urnrd_wells.rds") %>%
  #--- project to UTM 14N WGS 84 ---#
  st_transform(32614)

tm_shape(urnrd_wells_sf) +
  tm_symbols(col = "red", size = 0.1) +
  tm_layout(frame = FALSE)

#--- create a one-mile buffer around the wells ---#
wells_buffer <- st_buffer(urnrd_wells_sf, dist = 1600)

tm_shape(wells_buffer) +
  tm_polygons(alpha = 0) +
  tm_shape(urnrd_wells_sf) +
  tm_symbols(col = "red", size = 0.1) +
  tm_layout(frame = NA)

##create buffer around polygon
NE_counties <-
  readRDS("NE_county_borders.rds") %>%
  filter(NAME %in% c("Perkins", "Dundy", "Chase")) %>%
  st_transform(32614)

tm_shape(NE_counties) +
  tm_polygons("NAME", palette = "RdYlGn", contrast = .3, title = "County") +
  tm_layout(frame = NA)

NE_buffer <- st_buffer(NE_counties, dist = 2000)

tm_shape(NE_buffer) +
  tm_polygons(col = "blue", alpha = 0.2) +
  tm_shape(NE_counties) +
  tm_polygons("NAME", palette = "RdYlGn", contrast = .3, title = "County") +
  tm_layout(
    legend.outside = TRUE,
    frame = FALSE
  )
