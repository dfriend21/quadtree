

library(sp)
library(quadtreeNew)
#==================================================================
#get the landscape (250m habitat model)

#setwd("/Users/dfriend/Documents/clark_county_project/abm_poc/code/poc/irregular_grid")
#source("../abm/sim_poc_R6.R")

setwd("/Users/dfriend/Documents/r_packages/quadtreeNew/other_files")
source("sim_poc_R6.R")

l = raster("/Users/dfriend/Documents/clark_county_project/data/CC Habitat model 250m/EnsembleModelccBuffered.img")

#ext = extent(l, 100,611,100,611)
#x_lim = c(575,830)
#y_lim = c(375,630)
#x_lim = c(628, 755)
#y_lim = c(418, 545)
x_lim = c(628, 755)
y_lim = c(418, 545)
ext = extent(l, x_lim[1],x_lim[2],y_lim[1],y_lim[2])
#ext = extent(l, 1, 1024, 1, 1024)
#plot(l)
#plot(ext, add=TRUE)

l_sub = crop(l, ext)
crs(l_sub) = NA
extent(l_sub) <- extent(c(x_lim, y_lim))
l_sub
plot(l_sub)

l_sub2 = l_sub
l_sub2[l_sub2 < .5] = NA
pts = sampleRandom(l_sub2, 1000, xy=TRUE)
points(pts[,1:2])

res = 1-l_sub

null_raster = setValues(res,0)
null_raster

#qt = new(quadtree, as.matrix(res), c(0,128), c(0,128), .25)
#qtplot(qt)

# qt$getValues(128,128)
#qt$getValues(0,0)
#test = qt$getCell(0,0)
#test$xLims()
# qt$getValues(64,64)
# qt$getValues(64.1,64.1)
# qt$getValues(64.1,63.9)
# qt$getValues(63.9,64.1)
# qt$getValues(63.9,63.9)
# 
# qt$getValues(2,2)


#==================================================================
#DISTANCE FUNCTIONS

#DESCRIPTION:
#given a and b, finds the value of c using the Pythagorean theorem (a^2 + b^2
#= c^2)
#PARAMETERS:
#a, b -> numbers
#RETURNS:
#a number - the value of c
pythag = function(a,b){ sqrt(a^2 + b^2) }

#DESCRIPTION:
#Calculates the straight-line distance between two points
#PARAMETERS:
#pt1, pt2 -> two-element numeric vectors, where the first element is the 
#x-coordinate and the second element is the y-coordinate
#RETURNS:
#A number - the straight line distance between the two points
dist_btw_points = function(pt1, pt2){ pythag(pt1[1]-pt2[1], pt1[2]-pt2[2]) }
#==================================================================

n_init = 100
init_val_cutoff = .3
prob_disperse = 1
max_disperse_dist = 9999
max_resistance = 99
max_cells = 20
step1_dist = 1
n_points = 16
max_steps = 6
max_substeps = 8
max_straight_line_dist = 3
max_total_dist = 10
max_total_dist_substep = 5
attract_pt_dist = 5
# attract_pt_exp1 = 1
# quality_exp1 = 1
# direction_exp1 = 1
# attract_pt_exp2 = 2
# quality_exp2 = 1
# direction_exp2 = 1
attract_pt_exp1 = 10
quality_exp1 = 0
direction_exp1 = 0
attract_pt_exp2 = 0
quality_exp2 = 0
direction_exp2 = 0
prob_reproduce = .8
max_age = 10
max_cell_capacity = 10
landscape = 1-l_sub
#landscape = null_raster
landscape_n_side = NA
quadtree_range_lim = .2
sim_length = 10



mat = matrix(.5, nrow=8, ncol=8)
raster(mat)
landscape=raster(mat)
plot(landscape)
extent(landscape) = extent(0,8,0,8)

as.matrix(landscape > .3)
test_qt = new(quadtree2, as.matrix(landscape), extent(landscape)[1:2], extent(landscape)[3:4], .2)
qtplot(test_qt)
test_qt
test = ABM$new(n_init, init_val_cutoff, prob_disperse, max_disperse_dist, max_resistance, max_cells, step1_dist, n_points, max_steps, max_substeps, max_total_dist, max_straight_line_dist, max_total_dist_substep, attract_pt_dist, attract_pt_exp1, quality_exp1, direction_exp1, attract_pt_exp2, quality_exp2, direction_exp2, prob_reproduce, max_age, max_cell_capacity, landscape_n_side, landscape, quadtree_range_lim, sim_length)


set.seed(64)
test$prepare()
qtplot(test$qtree, border_col="transparent")
points(test$live_agents[,c("x", "y")], col="red")

plot(1,1,type="n", xlim=c(-2,10), ylim=c(-2,10), asp=1)
test$move_quadtree_cpp()
movts = cbind(test$move_hist$x[[1]], test$move_hist$y[[1]])
qtplot(test$qtree, border_col="transparent")
points(test$live_agents[,c("x", "y")], col="red")

test$plot_movt_history(type="quadtree")
points(movts[c(1,nrow(movts)),], col=c("blue", "red"), pch=16)

movts

# qtplot(test$qtree, border_col="gray50", nb=TRUE)
#=============================================================
#=============================================================
#SCRATCHWORK

qtplot(test$qtree, border_col="gray50", xlim=xlim, ylim=ylim)

points(attr_pts[,2:3], pch=3, col="orange")
points(attr_pts[attr_pts[,1] %in% broken_seeds,2:3], col="black", bg="red", pch=21)
points(first_pts[,2:3], pch=3, col="skyblue")
points(first_pts[first_pts[,1] %in% broken_seeds, 2:3], col="black", bg="skyblue", pch=21)
text(first_pts[first_pts[,1] %in% broken_seeds, 2:3], labels=first_pts[first_pts[,1] %in% broken_seeds, 1])

library(spatstat)
broken_firsts = first_pts[first_pts[,1] %in% broken_seeds,]
broken_ppp = ppp(broken_firsts[,2], broken_firsts[,3], xrange = range(attr_pts[,2]), yrange=range(attr_pts[,3]))
plot(broken_ppp)
broken_dens = density(broken_ppp,sigma=5)
plot(broken_dens)
#------------------




test = ABM$new(n_init, init_val_cutoff, prob_disperse, max_disperse_dist, max_resistance, max_cells, step1_dist, n_points, max_steps, max_substeps, attract_pt_dist, attract_pt_exp1, quality_exp1, direction_exp1, attract_pt_exp2, quality_exp2, direction_exp2, prob_reproduce, max_age, max_cell_capacity, landscape_n_side, landscape, quadtree_range_lim, sim_length)

set.seed(7)
test$prepare()
test$move_quadtree_cpp_2()
movts = cbind(test$move_hist$x[[1]], test$move_hist$y[[1]])
test$plot_movt_history(type="quadtree")
points(movts[c(1,nrow(movts)),], col=c("blue", "red"), pch=16)


movts

movts
dists = sapply(2:nrow(movts), function(i){
  return(dist_btw_points(movts[i-1,], movts[i,]))
})
dists
any(dists>step1_dist)

test$move_hist
str(test$move_hist)

qt = test$qtree
qt$getValues(64,64)
