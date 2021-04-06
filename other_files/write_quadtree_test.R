 
library(sp)
library(quadtreeNew)
#==================================================================
#get the landscape (250m habitat model)

#setwd("/Users/dfriend/Documents/clark_county_project/abm_poc/code/poc/irregular_grid")
#source("../abm/sim_poc_R6.R")
library(rgdal)
setwd("/Users/dfriend/Documents/r_packages/quadtreeNew/other_files")
source("sim_poc_R6.R")

l = raster("/Users/dfriend/Documents/clark_county_project/data/CC Habitat model 250m/EnsembleModelccBuffered.img")

us = readOGR("/Users/dfriend/Downloads/tl_2019_us_state (1)/tl_2019_us_state.shp")
head(us)
sw = us[us$STUSPS %in% c("CA", "NV", "UT", "AZ"),]
sw = spTransform(sw, proj4string(l))

#ext = extent(l, 100,611,100,611)
#x_lim = c(575,830)
#y_lim = c(375,630)
#x_lim = c(628, 755)
#y_lim = c(418, 545)
x_lim = c(628, 755)
y_lim = c(418, 545)

ext = extent(l, x_lim[1],x_lim[2],y_lim[1],y_lim[2])
#ext = extent(l, 1, 1024, 1, 1024)
plot(l)
plot(ext, add=TRUE)
plot(sw, add=TRUE)
#ext = drawExtent()
ext2 = extent(c(620842.8, 684842.8, 3899220, 3963220)) #Ivanpah valley, 256*256
#ext2
l_sub = crop(l, ext2)
#crs(l_sub) = NA
#extent(l_sub) <- extent(c(x_lim, y_lim))
#l_sub
plot(l_sub)

res = 1-l_sub

#rast = res
as.matrix(res)
# createQuadtree <- function(rast, range_limit){
#   qt <- new(quadtree, as.matrix(rast), extent(rast)[1:2], extent(rast)[3:4], range_limit)
#   return(qt)
# }
plot(res)
qt = createQuadtree(res,.1)
qtplot(qt)
filename = paste0("/Users/dfriend/Documents/r_packages/quadtreeNew/other_files/ivanpah.qtree")
qt$writeQuadtree(filename)

#res_mat = as.matrix(rast)
#res_mat[TRUE] = 0
#res_mat
#qt <- new(quadtree, res_mat, extent(res)[1:2], extent(res)[3:4], .1)

library(quadtreeNew)
n = 8192
mat = matrix(runif(n^2), nrow=n)
qt <- new(quadtree, mat, c(0,1), c(0,1), .2)
#qtplot(qt)
#filename = "/Users/dfriend/Documents/r_packages/quadtreeNew/other_files/random.json"
filename = paste0("/Users/dfriend/Documents/r_packages/quadtreeNew/other_files/random", n, ".qtree")
qt$writeQuadtree(filename)
qt$root()$xLims()

#filename = "/Users/dfriend/Documents/r_packages/quadtreeNew/other_files/quadtreeBinary2.qtree"
test123 = readQuadtree(filename)
qtplot(test123)
