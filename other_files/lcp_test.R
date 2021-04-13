library(raster)
library(rgdal)
library(quadtree)

pythag = function(a,b){ sqrt(a^2 + b^2) }
dist_btw_points = function(pts1, pts2){ pythag(pts1[,1]-pts2[,1], pts1[,2]-pts2[,2]) } #gets the distance between two points

l = raster("/Users/dfriend/Documents/clark_county_project/data/CC Habitat model 250m/EnsembleModelccBuffered.img")

iv = readOGR("/Users/dfriend/Documents/cpp/abm/input/IvanpahValleyWatershed/IvanpahValleyWatershed.shp")
iv = spTransform(iv, crs(l))
l_iv = mask(crop(l,iv),iv)

qt = qt_create(1-l_iv, .1, adj_type="expand")
qt_plot(qt, crop=TRUE)
pt1 = c(640000,3970000)
pt2 = c(645000,3910000)
pt3 = c(665000,3970000)
qt_plot(qt, border_col="transparent", crop=TRUE)
points(rbind(pt1,pt2,pt3), col=c("red", "blue", "purple"), pch=16)


spf = qt$getShortestPathFinder(pt1, qt$extent()[1:2],qt$extent()[3:4] )

lcp1 = qt_find_lcp(spf, pt2)
lcp2 = qt_find_lcp(spf, pt3)

lines(lcp1[,1:2])
lines(lcp2[,1:2])

lcp1_ds = sapply(2:nrow(lcp1), function(i){
  return(dist_btw_points(lcp1[i-1,1:2,drop=FALSE], lcp1[i,1:2,drop=FALSE]))
})
lcp1_ds_cm = c(0,cumsum(lcp1_ds))
cbind(lcp1[,4], lcp1_ds_cm)
