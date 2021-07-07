library(raster)
library(rgdal)
library(quadtree)
l = raster("/Users/dfriend/Documents/clark_county_project/data/CC Habitat model 250m/EnsembleModelccBuffered.img")
#l = raster("/Volumes/CC_Connectivity_Modeling/ModelingCodeKen/Outputs_IV_No_Barrier_V4/No_Barrier_V4.img")
#l = trim(l)
ext = extent(c(620842.8, 684842.8, 3899220, 3963220)) #Ivanpah valley, 256*256
ext = extent(c(600000, 660000, 3920000, 3980000)) #Ivanpah valley, 256*256
iv = crop(l,ext)
plot(1-iv)
#==================
#TEST 1
#qt_1 = qt_create(1-l_iv, .2, adj_type="expand")
qt = qt_create(1-iv, .2, adj_type="expand")
qt_plot(qt, crop=TRUE)
#pt1 = c(640000,3970000)
#pt2 = c(645000,3910000)
#pt1 = c(575000,4000000)
pt1 = c(630000,3948000)
pt2 = c(625000,3970000)
#pt2 = c(775000,4100000)
#pt3 = c(575000,4000000)
# qt_plot(qt, border_col="gray30", crop=TRUE)
# points(rbind(pt1,pt2), col=c("red", "blue"), pch=16)
# 
lf = qt_lcp_finder(qt, pt1)
lp = qt_find_lcp(lf, pt2)
# lines(lp[,1:2])
lp
# sum = lf$getAllPathsSummary()
# points(sum[,2:3], pch=16, col="black", cex=.5)
# 
# 
# dim(sum)
# tail(sum,100)
# head(sum,100)

get_pts = function(thing){
  df = data.frame(thing)
  df$x = (df$xmin + df$xmax)/2
  df$y = (df$ymin + df$ymax)/2
  return(df)
}

lf_c = qt_lcp_finder(qt, pt1)
lf_c$makeNetworkCost(5000)
pts_c = get_pts(lf_c$getAllPathsSummary())

lf_d = qt_lcp_finder(qt, pt1)
lf_d$makeNetworkDist(5000)
pts_d = get_pts(lf_d$getAllPathsSummary())


lf_cd = qt_lcp_finder(qt, pt1)
lf_cd$makeNetworkCostDist(15000)
pts_cd = get_pts(lf_cd$getAllPathsSummary())

qt_plot(qt, border_col="gray30", crop=TRUE, na_col=NULL)
points(pts_c$x, pts_c$y, col="red", pch=16)
points(pts_d$x, pts_d$y, col="blue", pch=16)
points(pts_cd$x, pts_cd$y, col="green", pch=16)

pts_cd

lf = qt_lcp_finder(qt, pt1)
qt_find_lcps(lf, "costdistance", 3000)

# paths = data.frame(lf$_cgetAllPathsSummary())
# x = (paths$xmin + paths$xmax)/2
# y = (paths$ymin + paths$ymax)/2
# points(x,y, pch=16, col="black", cex=.5)
# points(rbind(pt1),col="red", pch=16)


#plot(x,y,asp=1)
paths = data.frame(lf_cd$getAllPathsSummary())
#paths = paths[paths$cost_tot > 4000,]
prob = paths$cell_area/sum(paths$cell_area)
n_pts = 100000
inds = sample(1:nrow(paths),n_pts, prob=prob, replace=TRUE)
pts_x = runif(n_pts,min=paths$xmin[inds], max=paths$xmax[inds])
pts_y = runif(n_pts,min=paths$ymin[inds], max=paths$ymax[inds])
pts = cbind(x=pts_x, y=pts_y)
qt_plot(qt, border_col="gray30", crop=TRUE, na_col=NULL)
points(pts, col="blue", pch=16, cex=.5)
plot(pts, col="black", pch=16, cex=.5)










pt1 = c(630000, 3948000)
lf = qt_lcp_finder(qt, pt1) #make the LCP finder
paths = qt_find_lcps(lf, limit_type="costdistance", limit=5000) #find all paths whose cost-distance is less than 5000
# paths = paths[paths$cost_tot + paths$dist_tot > 2000,] #optionally, we could limit the possible end points to ones that are between a min and max cost-distance
prob = paths$cell_area/sum(paths$cell_area) #use the area of each cell as its probability of being selected
inds = sample(1:nrow(paths),1, prob=prob, replace=TRUE) #pick one of the reachable cells, using cell area to weight the probability of being selected
end_pt = c(runif(1,min=paths$xmin[inds], max=paths$xmax[inds]), runif(1,min=paths$ymin[inds], max=paths$ymax[inds])) #pick a random point within the selected cell

qt_plot(qt, crop=TRUE, na_col=NULL, border_col="gray60")
points((paths$xmin + paths$xmax)/2, (paths$ymin + paths$ymax)/2, pch=16)
points(pt1[1], pt1[2], col="red", pch=16)
points(pt[1], pt[2], col="green", pch=16)
pt
paths
#pts_cd = get_pts(lf_cd$getAllPathsSummary())
prob = paths$cell_area/sum(paths$cell_area)
n_pts = 100000
inds = sample(1:nrow(paths),n_pts, prob=prob, replace=TRUE)
pts_x = runif(n_pts,min=paths$xmin[inds], max=paths$xmax[inds])
pts_y = runif(n_pts,min=paths$ymin[inds], max=paths$ymax[inds])
pts = cbind(x=pts_x, y=pts_y)
qt_plot(qt, border_col="gray30", crop=TRUE, na_col=NULL)
points(pts, col="blue", pch=16, cex=.5)
plot(pts, col="black", pch=16, cex=.5)
