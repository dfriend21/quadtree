library(raster)
library(rgdal)
library(quadtree)

pythag = function(a,b){ sqrt(a^2 + b^2) }
dist_btw_points = function(pts1, pts2){ pythag(pts1[,1]-pts2[,1], pts1[,2]-pts2[,2]) } #gets the distance between two points

l = raster("/Users/dfriend/Documents/clark_county_project/data/CC Habitat model 250m/EnsembleModelccBuffered.img")

iv = readOGR("/Users/dfriend/Documents/cpp/abm/input/IvanpahValleyWatershed/IvanpahValleyWatershed.shp")
iv = spTransform(iv, crs(l))
l_iv = mask(crop(l,iv),iv)

l_iv
qt = qt_create(1-l_iv, .8, adj_type="expand")
qt = qt_create(1-l_iv, .2, adj_type="expand")
#qt = qt_create(1-l_iv, .8, max_cell_length = 10000, adj_type="resample", resample_n_side = 256)
qt_plot(qt, crop=TRUE)
qt$maxCellDims()
#qt_plot(qt, crop=TRUE,border_col="transparent")
