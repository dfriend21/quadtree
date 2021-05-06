library(raster)
library(rgdal)
library(quadtree)

pythag = function(a,b){ sqrt(a^2 + b^2) }
dist_btw_points = function(pts1, pts2){ pythag(pts1[,1]-pts2[,1], pts1[,2]-pts2[,2]) } #gets the distance between two points

l = raster("/Users/dfriend/Documents/clark_county_project/data/CC Habitat model 250m/EnsembleModelccBuffered.img")

iv = readOGR("/Users/dfriend/Documents/cpp/abm/input/IvanpahValleyWatershed/IvanpahValleyWatershed.shp")
iv = spTransform(iv, crs(l))
l_iv = mask(crop(l,iv),iv)

qt = qt_create(1-l_iv, .8, adj_type="expand")

pt1 = c(640000,3970000)
pt2 = c(645000,3910000)
pt3 = c(665000,3970000)
pt4 = c(700000,3920000) #NA
pt5 = c(625000,3940000) #outside quadtree extent
mat = rbind(pt1,pt2,pt3,pt4,pt5)

qt_plot(qt, crop=TRUE, border_col="gray50")
points(mat,col="black", pch=16)

qt_extract(qt,mat,extents = TRUE)
