if (!require("pacman")) install.packages("pacman")
pacman::p_load(
  sf, # vector data operations
  dplyr, # data wrangling
  sp,
  raster,
  terra,
  tidyverse
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
