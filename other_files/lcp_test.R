library(raster)
library(rgdal)
library(quadtree)

pythag = function(a,b){ sqrt(a^2 + b^2) }
dist_btw_points = function(pts1, pts2){ pythag(pts1[,1]-pts2[,1], pts1[,2]-pts2[,2]) } #gets the distance between two points

l = raster("/Users/dfriend/Documents/clark_county_project/data/CC Habitat model 250m/EnsembleModelccBuffered.img")

iv = readOGR("/Users/dfriend/Documents/cpp/abm/input/IvanpahValleyWatershed/IvanpahValleyWatershed.shp")
iv = spTransform(iv, crs(l))
l_iv = mask(crop(l,iv),iv)

qt = qt_create(1-l_iv, .9, adj_type="expand")
qt = qt_create(1-l_iv, .8, adj_type="expand")
qt_plot(qt, crop=TRUE)
pt1 = c(640000,3970000)
pt1 = c(0,0)
#pt1 = c(640000,3975000)
#pt1 = c(663000,3936000)

pt2 = c(645000,3910000)
pt3 = c(665000,3970000)
pt3 = c(665000,3980000)
pt3 = c(0,0)
qt_plot(qt, border_col="transparent", crop=TRUE)
qt_plot(qt, crop=TRUE)
points(rbind(pt1,pt2,pt3), col=c("red", "blue", "purple"), pch=16)


#spf = qt$getShortestPathFinder(pt1, qt$extent()[1:2],qt$extent()[3:4] )
spf = qt_lcp_finder(qt, pt1, xlims = qt$extent()[1:2], ylims = qt$extent()[3:4])
lcp1 = qt_find_lcp(spf, pt2)
lcp2 = qt_find_lcp(spf, pt3, use_original_end_points = TRUE)
lcp1
lcp2
lines(lcp1[,1:2])
lines(lcp2[,1:2])

lcp1_ds = sapply(2:nrow(lcp1), function(i){
  return(dist_btw_points(lcp1[i-1,1:2,drop=FALSE], lcp1[i,1:2,drop=FALSE]))
})
lcp1_ds_cm = c(0,cumsum(lcp1_ds))
cbind(lcp1[,4], lcp1_ds_cm)
all(lcp1[,4] == lcp1_ds_cm)
lcp1[,4]-lcp1_ds_cm
#test = c(0,lcp1_ds)*lcp1[,5]
#cumsum(test)
#lcp1[,3]


#spf2 = qt_lcp_finder(qt, pt3)
#qt_find_lcp(spf2,pt2)


cost_diff = c(0,diff(lcp1[,3]))
cost_diff
qt_plot(qt, crop=TRUE)
points(rbind(pt1,pt2,pt3), col=c("red", "blue", "purple"), pch=16)
lines(lcp1[,1:2])
points(lcp1[cost_diff < 0,1:2], pch=24, bg="red", col="black", lwd=1.3)

lcp12 = cbind(lcp1,dist = c(0,lcp1_ds),cost=cost_diff)
rownames(lcp12) = NULL
lcp12

#9-11
row_num = 16
row = lcp12[row_num,]
row_prev = lcp12[row_num-1,]
d = row[6]
c1 = row_prev[5]
c2 = row[5]
dc1 = (d/2)*c1
dc2 = (d/2)*c2
dc = dc1 + dc2

d
c1
c2
dc1
dc2
dc



dc
row[7]

qt$getCell(641842.7746,3968219.644)$xLims()
