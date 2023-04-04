if (!require("pacman")) install.packages("pacman")
pacman::p_load(
  terra, # handle raster data
  raster, # handle raster data
  mapview, # create interactive maps
  dplyr, # data wrangling
  sf,
  geosphere# vector data handling
)

##extract values for points####
##read the raster stack
setwd("~/Documents/Code example/spatial analysis")
t<- stack("raster_stack.tif")
nam<- readRDS("raster_stack_name.Rdata")
names(t)<- nam
st_crs(t)

setwd("/Users/egyfn/projects/NDVI yld/build/input")
pointCoordinates_19=read.csv("CFV_corn_yld_2019.csv")
pointCoordinates_19<- pointCoordinates_19%>%dplyr::filter(anonymous_persistent_field_key %in% c(6,9))
#check crs
st_crs(pointCoordinates_19)
#assign crs if there is none (turn lat lon into spatial data points)
coordinates(pointCoordinates_19)= c("lon","lat") 
proj4string(pointCoordinates_19) <- CRS("+init=epsg:4326") ##epsg for WGS84 to match raster stack
st_crs(pointCoordinates_19)


#extract raster value for points
raster_val<- extract(t, pointCoordinates_19)
save_data<- cbind(pointCoordinates_19,raster_val)
write.table(save_data,file = "extract_ras_val.csv", append = FALSE, sep = ",", row.names = FALSE, col.names = TRUE)

##extract raster values for polygon####

##read the raster stack
setwd("~/Documents/Code example/spatial analysis")
t<- stack("raster_stack.tif")
nam<- readRDS("raster_stack_name.Rdata")
names(t)<- nam
st_crs(t)

##read polygon
setwd("/Users/egyfn/projects/all maps/tl_2019_us_state")
state<- st_read("tl_2019_us_state.shp")

#check crs
st_crs(state)

##change state crs from NAD83 to WGS84
state <- st_transform(state, crs = 4326)
st_crs(state)
#choose only the states we need like corn belt
state_n<- state%>%filter(STATEFP %in% c("17","18","19"))

#extract raster value for polygon
#poly_ras_val<- extract(t, state_n, fun = mean,na.rm = TRUE)


