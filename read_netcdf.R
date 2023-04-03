library(tidyverse)
library(dplyr)

library(ncdf4)
library(raster)
library(terra)

library(sp)
library(sf)
###

library(geosphere)


##crs####

setwd("/Users/egyfn/projects/NDVI yld/build/input")
pointCoordinates_19=read.csv("CFV_corn_yld_2019.csv")
pointCoordinates_19<- pointCoordinates_19%>%dplyr::filter(anonymous_persistent_field_key %in% c(6,9))

setwd("/Users/egyfn/projects/all maps/tl_2019_us_state")
state<- st_read("tl_2019_us_state.shp")

#check crs
st_crs(pointCoordinates_19)
st_crs(state)


#assign crs if there is none (turn lat lon into spatial data points)
coordinates(pointCoordinates_19)= c("lon","lat") 
proj4string(pointCoordinates_19) <- CRS("+init=epsg:4326") ##epsg for WGS84


##change state crs from NAD83 to WGS84
state <- st_transform(state, crs = 4326)



#crop raster
state_n<- state%>%filter(STATEFP %in% c("17","18","19"))
crop1<- crop(t,extent(state_n))
mask1<- mask(crop1,state_n)

ch<- subset(mask1,subset = 1:2)
plot(ch)

#extract raster value for points
raster_val<- extract(t, pointCoordinates_19)
save_data<- cbind(pointCoordinates_19,raster_val)
write.table(save_data,file = "extract_ras_val.csv", append = FALSE, sep = ",", row.names = FALSE, col.names = TRUE)

#extract raster value for polygon
#poly_ras_val<- extract(t, state_n, fun = mean,na.rm = TRUE)

##centroids####

rm(list = ls())

setwd("/Users/egyfn/projects/all maps/tl_2018_us_county (1)")
county<- st_read("tl_2018_us_county.shp")
county<- county%>%filter(STATEFP %in% c("17","18","19"))

#create centroids
cen = st_centroid(county)
cen<- cen%>%mutate(lon = unlist(map(cen$geometry,1)), lat = unlist(map(cen$geometry,2)))


#measure distance between all the counties in a state
dist<- cen%>%group_by(STATEFP)%>%mutate(order = row_number())%>%
  mutate(dist = distVincentyEllipsoid(matrix(c(lon[order = 1],
                                                                                                             lat[order = 1]),ncol = 2),
                                                                                                    matrix(c(lon,lat),ncol = 2)))
