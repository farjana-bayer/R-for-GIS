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

##read,check and plot polygons####
setwd("/Users/egyfn/Documents/Code example/spatial analysis")
nc<- st_read("nc.shp")##
class(nc) ##check class
st_geometry(nc[1,])[[1]][[1]]##check the geometry/points
plot(st_geometry(nc[1,]))##plot geometry
nc1<- nc%>%dplyr::select("geometry") ##can use dplyr

##write a shapefile####
saveRDS(nc, "nc_county.rds")
nc <- readRDS("nc_county.rds")

###Coordinate reference system (CRS)####
st_crs(nc)
##EPSG for famous crs
#NAD27 = EPSG 4267
#WGS84 = EPSG 4326
#NAD83/ UTM zone 17N = EPSG 26917
#transform CRS
nc_wgs84<- st_transform(nc,4326)##transform CRS from nad27 to WGS84 with EPSG number
nc_new <- st_transform(nc_wgs84, st_crs(nc)) ##transform CRS without EPSG number
st_crs(nc_new)
st_crs(nc_wgs84)

##turn data frame to sf objects####
(
  wells <- readRDS("well_registration.rds")
)
class(wells)
#set as sf
wells_sf <- st_as_sf(wells, coords = c("longdd", "latdd"))
head(wells_sf[, 1:5])
#set CRS
wells_sf <- st_set_crs(wells_sf, 4269)
head(wells_sf[, 1:5])

##turn sf into sp
wells_sp <- as(wells_sf, "Spatial")
class(wells_sp)

##turn sf to data frame
wells_no_longer_sf <- st_drop_geometry(wells_sf)


##measure area
#--- generate area by polygon ---#
(
  NE_counties <- mutate(NE_counties, area = st_area(NE_counties))
)

##measure length
#--- import US railroad data and take only the first 10 of it ---#
(
  a_railroad <- rail_roads <- st_read(dsn = "Data", layer = "tl_2015_us_rails")[1:10, ]
)

(
  a_railroad <- mutate(a_railroad, length = st_length(a_railroad))
)


##centroids####


setwd("/Users/egyfn/projects/all maps/tl_2018_us_county (1)")
county<- st_read("tl_2018_us_county.shp")
county<- county%>%filter(STATEFP %in% c("17","18","19"))

#create centroids
cen = st_centroid(county)
cen<- cen%>%mutate(lon = unlist(map(cen$geometry,1)), lat = unlist(map(cen$geometry,2)))


#measure distance between all the counties in a state
dist<- cen%>%group_by(STATEFP)%>%mutate(order = row_number())%>%
  mutate(dist = distVincentyEllipsoid(matrix(c(lon[order = 1],lat[order = 1]),ncol = 2),
                                      matrix(c(lon,lat),ncol = 2)))
                                               