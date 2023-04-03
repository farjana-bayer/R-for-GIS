if (!require("pacman")) install.packages("pacman")
pacman::p_load(
  terra, # handle raster data
  raster, # handle raster data
  dplyr, # data wrangling
  sf, # vector data handling
  tidyverse,
  ncdf4 #read netCDF files
)

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

plot(ras)
plot(ras1)
