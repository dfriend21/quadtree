library(sp)
library(quadtree)
library(raster)
library(rgdal)

data_dir = "/Users/dfriend/Documents/quadtree/raw_data"

#read in the data
rst = raster(paste0(data_dir, "/habitat_model/EnsembleModelccBuffered.img"))
roads0 = readOGR(paste0(data_dir, "/roads/ALLmajorrds.shp"))
wshd0 = readOGR(paste0(data_dir, "/watershed/WBDHU10.shp"))

#get them in the same projection
roads = spTransform(roads0, proj4string(rst))
wshd = spTransform(wshd0, proj4string(rst))

#grab the poly we want and then crop the raster and the roads to that poly
wshd_i = wshd[5,]
rst_i = mask(crop(rst, wshd_i), wshd_i)
roads_i0 = raster::intersect(roads,wshd_i)
roads_i = roads_i0[-2,] #get rid of that short line in the NE

#take a look, make sure it looks fine
plot(rst_i)
plot(wshd_i, add=TRUE)
plot(roads_i, add=TRUE, col="red")

#make a binary raster for the roads that matches the footprint of the habitat raster
roads_rst = rasterize(roads_i, rst_i)
roads_rst[!is.na(roads_rst)] = 1
roads_rst[is.na(roads_rst)] = 0
roads_rst = mask(roads_rst, rst_i)
plot(roads_rst)

qt = qt_create(rst_i, split_method="sd", split_threshold=.05)
qt_plot(qt, border_lwd=.2)

#now get rid of the CRS info and make the x and y limits start at 0 to get rid of any info that could identify where it's at
habitat = 1-rst_i
habitat_roads = roads_rst
crs(habitat) = NULL
crs(habitat_roads) = NULL

#make the x and y limits start at 0
ext = extent(habitat)
extent(habitat) = ext - c(ext[1], ext[1], ext[3], ext[3])
extent(habitat_roads) = extent(habitat)

plot(habitat)
plot(habitat_roads)

usethis::use_data(habitat, overwrite=TRUE)
usethis::use_data(habitat_roads, overwrite=TRUE)
