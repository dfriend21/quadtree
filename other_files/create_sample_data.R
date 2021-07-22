
library(sp)
library(quadtree)
library(raster)


input_dir = "/Users/dfriend/Documents/abm/input"
input_dir
ken_rast0 = raster(paste0(input_dir,"/No_Barrier_V4.img"))
#ken_rast0 = raster("/Volumes/CC_Connectivity_Modeling/ModelingCodeKen/Outputs_IV_No_Barrier_V4/No_Barrier_V4.img")
ken_rast = trim(ken_rast0)
plot(ken_rast)
ken_rast

roads_rast0 = raster(paste0(input_dir,"/maj_roads_250m.img"))
plot(roads_rast0)
roads_rast = crop(roads_rast0, ken_rast)
roads_rast[is.na(roads_rast)] = 0
roads_rast = mask(roads_rast, ken_rast)
plot(roads_rast)


crs(roads_rast) = NULL
crs(ken_rast) = NULL
ken_rast
ext = extent(ken_rast)
extent(ken_rast) = ext - c(ext[1], ext[1], ext[3], ext[3])
extent(roads_rast) = extent(ken_rast)
ken_rast
plot(ken_rast)
plot(roads_rast)

habitat = ken_rast
habitat_roads = roads_rast
usethis::use_data(habitat, overwrite=TRUE)
usethis::use_data(habitat_roads, overwrite=TRUE)
