
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

crs(ken_rast) = NULL
ken_rast
ext = extent(ken_rast)
extent(ken_rast) = ext - c(ext[1], ext[1], ext[3], ext[3])
ken_rast

habitat = ken_rast
usethis::use_data(habitat)