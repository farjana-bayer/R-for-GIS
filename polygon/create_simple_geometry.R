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