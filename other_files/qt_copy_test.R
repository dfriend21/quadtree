library(raster)
library(rgdal)
library(quadtree)

pythag = function(a,b){ sqrt(a^2 + b^2) }
dist_btw_points = function(pts1, pts2){ pythag(pts1[,1]-pts2[,1], pts1[,2]-pts2[,2]) } #gets the distance between two points

l = raster("/Users/dfriend/Documents/clark_county_project/data/CC Habitat model 250m/EnsembleModelccBuffered.img")

iv = readOGR("/Users/dfriend/Documents/cpp/abm/input/IvanpahValleyWatershed/IvanpahValleyWatershed.shp")
iv = spTransform(iv, crs(l))
l_iv = mask(crop(l,iv),iv)


qt1 = qt_create(1-l_iv, .2, adj_type="expand")
qt_plot(qt1, crop=TRUE, na_col=NULL, border_col="gray30")
points(pts[,1:2], col="red", pch=16)

pts = sampleRandom(l_iv, 100, xy=TRUE)


qt2 = qt1
qt3 = qt_copy(qt1)

qt_plot(qt1)
qt_plot(qt2)
qt_plot(qt3)
# n_pts = 100
# qe = qt_extent(qt)
# pts = cbind(runif(n_pts, qe[1], qe[2]), runif(n_pts,qe[3],qe[4]))
# head(pts)


qt_extract(qt1, pts[,1:2])
qt_set_values(qt1, pts, rep(10,nrow(pts)))
qt_extract(qt1, pts[,1:2])

qt_plot(qt1,border_col="gray30")


qt_plot(qt1, crop=TRUE, na_col=NULL, border_col="gray30")
qt_plot(qt2, crop=TRUE, na_col=NULL, border_col="gray30")
qt_plot(qt3, crop=TRUE, na_col=NULL, border_col="gray30")
