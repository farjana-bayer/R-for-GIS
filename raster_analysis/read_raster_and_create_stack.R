if (!require("pacman")) install.packages("pacman")
pacman::p_load(
  terra, # handle raster data
  raster, # handle raster data
  mapview, # create interactive maps
  dplyr, # data wrangling
  sf # vector data handling
)

##read a single raster and change projection
setwd("~/Documents/Code example/spatial analysis")
ras<- raster("permanent_gridmetPDSI_20180101.tif")
ras<- projectRaster(ras,crs = "+init=epsg:4326") ##change CRS
st_crs(ras) ##check CRS

#create raster stack to reduce the file size
#prerequisite: All raster files need to cover same geometry/area 
setwd("~/Documents/Code example/spatial analysis")
rast <- list.files(pattern = "^per.*\\.tif")
ras_stack = stack(rast) ##create raster stack

#save raster stack and associated layer name
writeRaster(ras_stack,"raster_stack.tif", overwrite = TRUE)
#save raster layer name separately
ras_n<- substr(rast,23,30)
saveRDS(ras_n,file = "raster_stack_name.RData")

#read raster stack
t<- stack("raster_stack.tif")
nam<- readRDS("raster_stack_name.Rdata")
names(t)<- nam

##create subset from rater stack and plot
ch<- subset(t,subset = 1:2)
plot(ch)

##check value of raster
ch_values<- values(ch) #check values of raster

#turning raster stack to data frame
t_data_fr<- as.data.frame(t,xy = TRUE)

