library(raster)
library(rgdal)
library(quadtree)
library(bench)
l = raster("/Users/dfriend/Documents/clark_county_project/data/CC Habitat model 250m/EnsembleModelccBuffered.img")

#==================
#TEST 1
qt = qt_create(1-l, .2, adj_type="expand")

n = 100000
ext = extent(l)
pts = cbind(runif(n,ext[1],ext[2]), runif(n,ext[3],ext[4]))

bench::mark(extract(l, pts),qt_extract(qt, pts), check=FALSE)

#==================
#TEST 2
iv = readOGR("/Users/dfriend/Documents/cpp/abm/input/IvanpahValleyWatershed/IvanpahValleyWatershed.shp")
iv = spTransform(iv, crs(l))
l_iv = mask(crop(l,iv),iv)

plot(1-l_iv)
qt_iv = qt_create(1-l_iv, 1.1, adj_type="expand")
n_iv = 10000 #if this is really low (like 100) qt_extract is faster... but as it gets bigger extract is faster
ext_iv = extent(l_iv)
pts_iv = cbind(runif(n_iv,ext_iv[1],ext_iv[2]), runif(n_iv,ext_iv[3],ext_iv[4]))

bench::mark(extract(l_iv, pts_iv),qt_extract(qt_iv, pts_iv), check=FALSE)
