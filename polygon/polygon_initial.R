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
nc1<- nc%>%dplyr::select("geometry") ##can use dpluy

##write a shapefile####
saveRDS(nc, "nc_county.rds")
nc <- readRDS("nc_county.rds")

##create some simple feature geometry####
##point
a_point<- st_point(c(2,1))
class(a_point)
##linestring
s1<- rbind(c(2,3),c(3,4),c(3,5),c(1,5))
a_linestring<- st_linestring(s1)
plot(a_linestring)

#polygon
p1 <- rbind(c(0, 0), c(3, 0), c(3, 2), c(2, 5), c(1, 3), c(0, 0))
a_polygon <- st_polygon(list(p1))
plot(a_polygon)
##polygon with hole
p2 <- rbind(c(1, 1), c(1, 2), c(2, 2), c(1, 1))
a_plygon_with_a_hole <- st_polygon(list(p1, p2))
plot(a_plygon_with_a_hole)
##mutipolygon
p3 <- rbind(c(4, 0), c(5, 0), c(5, 3), c(4, 2), c(4, 0))
a_multipolygon <- st_multipolygon(list(list(p1, p2), list(p3)))
plot(a_multipolygon)


#create an simple feature geometry list-column(sfc)
sfc_ex <- st_sfc(list(a_point, a_linestring, a_polygon, a_multipolygon))
#create a simple feature
df_ex <- data.frame(name = c("A", "B", "C", "D"))
df_ex$geometry <- sfc_ex ## add geometry column
sf_ex <- st_as_sf(df_ex)##set st as sf
class(sf_ex)



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
                                               