library(raster)
library(rgdal)
library(quadtree)
l = raster("/Users/dfriend/Documents/clark_county_project/data/CC Habitat model 250m/EnsembleModelccBuffered.img")

#==================
#TEST 1
#qt_1 = qt_create(1-l_iv, .2, adj_type="expand")
qt_1 = qt_create(1-l, .2, adj_type="expand")
#qt_plot(qt_1, crop=TRUE)
#pt1 = c(640000,3970000)
#pt2 = c(645000,3910000)
#pt1 = c(575000,4000000)
pt1 = c(710000,3830000)
pt2 = c(775000,4100000)
pt3 = c(575000,4000000)
qt_plot(qt_1, border_col="transparent", crop=TRUE)
points(rbind(pt1,pt2,pt3), col=c("red", "blue", "purple"), pch=16)


#time it 
t1 = system.time(qt_1$getShortestPathFinder(pt1, qt_1$extent()[1:2],qt_1$extent()[3:4] ))
spf = qt_1$getShortestPathFinder(pt1, qt_1$extent()[1:2],qt_1$extent()[3:4] )
t2 = system.time(spf$getShortestPath(pt2))
t3 = system.time(spf$getShortestPath(pt3))
t1+t2
t3
#vals = spf$getVals()

#now get the actual paths
spf = qt_1$getShortestPathFinder(pt1, qt_1$extent()[1:2],qt_1$extent()[3:4] )
path1 = spf$getShortestPath(pt2)
path2 = spf$getShortestPath(pt3)

#qt_plot(qt_1, border_col="gray60", crop=TRUE)

library(geosphere)
library(gdistance)
myfun <- function(x){1/mean(x)}

st = Sys.time()
tr.s <- transition(1-l,myfun,8, symm=T) ### this the the key to get this working
tr.sc <- geoCorrection(tr.s, type="r", scl=T)
shortest <- shortestPath(tr.sc, pt1, pt2, output = 'SpatialLines')
et = Sys.time()
et-st

qt_plot(qt_1, border_col="transparent", crop=TRUE)
points(rbind(pt1,pt2), col="red", pch=16)
lines(path1)
plot(shortest, add=TRUE, col="red")



#==================
#TEST 2 - try it on a smaller extent (Ivanpah)
iv = readOGR("/Users/dfriend/Documents/cpp/abm/input/IvanpahValleyWatershed/IvanpahValleyWatershed.shp")
iv = spTransform(iv, crs(l))
l_iv = mask(crop(l,iv),iv)

qt_2 = qt_create(1-l_iv, .1, adj_type="expand")
qt_plot(qt_2, crop=TRUE)
pt1_2 = c(640000,3970000)
pt2_2 = c(645000,3910000)
pt3_2 = c(665000,3970000)
qt_plot(qt_2, border_col="transparent", crop=TRUE)
points(rbind(pt1_2,pt2_2,pt3_2), col=c("red", "blue", "purple"), pch=16)


spf_2_1 = qt_2$getShortestPathFinder(pt1_2, qt_2$extent()[1:2],qt_2$extent()[3:4] )
spf_2_2 = qt_1$getShortestPathFinder(pt1_2, qt_2$extent()[1:2],qt_2$extent()[3:4] )

system.time(spf_2_1$getShortestPath(pt2_2))
system.time(spf_2_2$getShortestPath(pt2_2))
system.time(qt_2$getShortestPathFinder(pt1_2, qt_2$extent()[1:2],qt_2$extent()[3:4] ))
system.time(qt_1$getShortestPathFinder(pt1_2, qt_2$extent()[1:2],qt_2$extent()[3:4] ))
#time it 
t1_2 = system.time(qt_2$getShortestPathFinder(pt1_2, qt_2$extent()[1:2],qt_2$extent()[3:4] ))
spf_2 = qt_2$getShortestPathFinder(pt1_2, qt_2$extent()[1:2],qt_2$extent()[3:4] )

t2_2 = system.time(spf_2$getShortestPath(pt2_2))
t3_2 = system.time(spf_2$getShortestPath(pt3_2))
t1_2+t2_2
#vals = spf$getVals()

#now get the actual paths
spf_2 = qt_2$getShortestPathFinder(pt1_2, qt_2$extent()[1:2],qt_2$extent()[3:4] )
path1_2 = spf_2$getShortestPath(pt2_2)
path2_2 = spf_2$getShortestPath(pt3_2)
lines(path1_2)
lines(path2_2, col="red")
#qt_plot(qt_1, border_col="gray60", crop=TRUE)

#library(geosphere)
#library(gdistance)
myfun <- function(x){1/mean(x)}

st_2 = Sys.time()
tr.s_2 <- transition(1-l_iv,myfun,8, symm=T) ### this the the key to get this working
tr.sc_2 <- geoCorrection(tr.s_2, type="r", scl=T)
shortest_2 <- shortestPath(tr.sc_2, pt1_2, pt2_2, output = 'SpatialLines')
et_2 = Sys.time()
et_2-st_2
ac = accCost(tr.s_2, pt1_2)
plot(ac)


qt_plot(qt_2, border_col="gray60", crop=TRUE)
points(rbind(pt1_2,pt2_2), col="red", pch=16)
lines(path1_2)
plot(shortest_2, add=TRUE, col="red")



#==================
#TEST 2 - try it on a even smaller extent ~5km
size = 5000
xmin = 652000
ymin = 3957000
small_ext = extent(xmin, xmin+size, ymin, ymin+size)
plot(1-l_iv)
plot(small_ext, add=TRUE)
l_small = crop(l, small_ext)

plot(1-l_small)
# pt1_3 = c(652250, 3960000)
# pt2_3 = c(656000, 3960000)
pt1_3 = c(652250, 3961500)
pt2_3 = c(656000, 3957000)


st_3 = Sys.time()
tr.s_3 <- transition(1-l_small,myfun,8, symm=T) ### this the the key to get this working
tr.sc_3 <- geoCorrection(tr.s_3, type="r", scl=T)
shortest_3 <- shortestPath(tr.sc_3, pt1_3, pt2_3, output = 'SpatialLines')
et_3 = Sys.time()
dif_3 = et_3-st_3
units(dif_3) = "secs"
dif_3

st_3_2 = Sys.time()
spf_3 = qt_2$getShortestPathFinder(pt1_3, small_ext[1:2], small_ext[3:4])
path1_3 = spf_3$getShortestPath(pt2_3)
et_3_2 = Sys.time()
dif_3_2 = et_3_2 - st_3_2
units(dif_3_2) = "secs"
dif_3_2
as.numeric(dif_3)/as.numeric(dif_3_2)

par(mfrow=c(1,2))
plot(1-l_small, main = paste0("raster representation (LCP time: ", round(dif_3,4), " sec)"))
points(rbind(pt1_3, pt2_3), col=c("blue", "red"), pch=16, cex=1.3)
plot(rasterToPolygons(l_small), add=TRUE, border='gray70', lwd=1) 
plot(shortest_3, add=TRUE)
points(shortest_3@lines[[1]]@Lines[[1]]@coords, pch=16, cex=.5)
lines(path1_3, col="blue")
points(path1_3, col="blue", pch=16, cex=.5)
legend(x="bottomright", legend = c("start point", "end point", "raster LCP", "quadtree LCP"), lwd=c(NA,NA,1,1), pch=c(16,16,16,16), pt.cex=c(1.3,1.3,.5,.5), col=c("blue", "red", "black", "blue"))

qt_plot(qt_2, xlim=small_ext[1:2], ylim = small_ext[3:4], border_col="gray70", main = paste0("quadtree representation (range_lim = ", qt_2$rangeLim(), ") (LCP time: ", round(dif_3_2,4), " sec)"))
points(rbind(pt1_3, pt2_3), col=c("blue", "red"), pch=16, cex=1.3)
plot(small_ext,add=TRUE, col="black", lwd=3)
plot(shortest_3, add=TRUE)
points(shortest_3@lines[[1]]@Lines[[1]]@coords, pch=16, cex=.5)
points(path1_3, col="blue", pch=16, cex=.5)
lines(path1_3, col="blue")
legend(x="bottomright", legend = c("start point", "end point", "raster LCP", "quadtree LCP"), lwd=c(NA,NA,1,1), pch=c(16,16,16,16), pt.cex=c(1.3,1.3,.5,.5), col=c("blue", "red", "black", "blue"))






#make a picture for the ABM package
png("/Users/dfriend/Documents/r_packages/quadtree/other_files/output/gitlab_abm_pic.png", width = 100, height = 100)
par(mar = c(0,0,0,0))
qt_plot(qt_2, xlim=c(small_ext[1]-200,small_ext[2]), ylim = c(small_ext[3], small_ext[4]+200), border_col="gray70", main = paste0("quadtree representation (range_lim = ", qt_2$rangeLim(), ") (LCP time: ", round(dif_3_2,4), " sec)"))
points(path1_3, col="black", pch=16, cex=.5)
lines(path1_3, col="black")
dev.off()
