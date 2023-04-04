if (!require("pacman")) install.packages("pacman")
pacman::p_load(
  terra, # handle raster data
  raster, # handle raster data
  mapview, # create interactive maps
  dplyr, # data wrangling
  sf # vector data handling
)

##extract raster values for polygons
#read the polygon
setwd("/Users/egyfn/projects/all maps/tl_2019_us_state")
state<- st_read("tl_2019_us_state.shp")
st_crs(state) #check CRS
##change state crs from NAD83 to WGS84
state <- st_transform(state, crs = 4326)
#choose only the states we need like corn belt
state_n<- state%>%filter(STATEFP %in% c("17","18","19"))

##read the raster stack
setwd("~/Documents/Code example/spatial analysis")
t<- stack("raster_stack.tif")
nam<- readRDS("raster_stack_name.Rdata")
names(t)<- nam

##crop raster
crop1<- crop(t,extent(state_n))
mask1<- mask(crop1,state_n)

ch<- subset(mask1,subset = 1:2)
plot(ch)

