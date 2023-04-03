library(tidyverse)
library(dplyr)

library(ncdf4)
library(raster)
library(terra)

library(sp)
library(sf)
###

library(geosphere)

##read nc files####
setwd("~/Documents/Code example/spatial analysis")

##identify the varname in nc files
nc = ncdf4::nc_open("permanent_gridmetPDSI_20180101.nc")
variables = names(nc[['var']])
variables

##read list of nc files together

file.names<- list.files(pattern = "*\\.nc")
for(i in 1:length(file.names)){
  data<- file.names[i]
  ras<- raster(data, varnames  = "palmer_drought_severity_index")
  ##if want to reclassify
  ras1<- round(ras,1)
  ras1<- reclassify(ras1,c(-20,-5,4,-4.9,-4,3,-3.9,-3,2,-2.9,-2,1,-1.9,-1,0,-0.9,20,NA)) ##if value between (-20:-5) assign value 4
  ras1[!(ras1 == 2)]<- NA
  ##write raster as tif
  writeRaster(ras,filename = data,format = "GTiff",overwrite = TRUE)
  writeRaster(ras1,filename = paste0("D2",data),format = "GTiff",overwrite = TRUE)
}

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

##raster projection
setwd("~/Documents/Code example/spatial analysis")
ras<- raster("permanent_gridmetPDSI_20180101.tif")
ras<- projectRaster(ras,crs = "+init=epsg:4326")
st_crs(ras)

##raster####
#create raster stack to reduce the file size
setwd("~/Documents/Code example/spatial analysis")
rast <- list.files(pattern = "^per.*\\.tif")
ras_stack = stack(rast)

#save raster stack and associated layer name
writeRaster(ras_stack,"raster_stack.tif", overwrite = TRUE)
#save raster layer name separately
ras_n<- substr(rast,23,30)
saveRDS(ras_n,file = "raster_stack_name.RData")

#read raster stack
t<- stack("raster_stack.tif")
nam<- readRDS("raster_stack_name.Rdata")
names(t)<- nam

##check
ch<- subset(t,subset = 1:2)
plot(ch)
rm(nam,ras_n,rast,ras_stack)


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
