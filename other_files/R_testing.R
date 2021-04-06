library(quadtreeNew)
library(dplyr)
library(tidyr)
library(spatstat)

# dat_files = list.files("C:\\Users\\derek\\Documents\\Programming\\cpp\\abm\\output",
#                        pattern = "liveAgents\\d+.csv", full.names=TRUE)
outputFolder = "/Users/dfriend/Documents/cpp/abm/output/"
dat_files = list.files(outputFolder,
                       pattern = "liveAgents\\d+.csv", full.names=TRUE)
                       
dat_files

dats = lapply(dat_files, read.csv)
mat = matrix(c(0,.1, 1, 1,.1,.2,.1, 0,
  .2,.2, 1, 1,.1,.2,.1, 0,
  .5,.6, 1,.1,.5,.6,.7,.6,
  .2,.4, 0, 0,.2,.6,.7,.5,
  .4,.5,.1,.1,.3,.3,.2,.2,
  .0,.0,.3,.3,.2,.2,.2,.2,
  1, 1,.7,.7,.3,.2,.2,.3,
  0, 1,.9,.9,.2,.3,.3,.3), nrow=8, byrow=TRUE)
#mat = matrix(.5, nrow=8, ncol=8)
mat
qt = new(quadtree, mat, c(0,8), c(0,8), .3)
qtplot(qt)




#mat
#dat0 = read.csv("C:\\Users\\derek\\Documents\\Programming\\cpp\\abm\\liveAgents0.csv")
#dat1 = read.csv("C:\\Users\\derek\\Documents\\Programming\\cpp\\abm\\liveAgents1.csv")
#movts = read.csv("C:\\Users\\derek\\Documents\\Programming\\cpp\\abm\\output\\movtHist.csv")
movts = read.csv(paste0(outputFolder,"movtHist.csv"));
tail(movts)

#any(is.na(dat0))
#any(is.na(dat1))
#any(is.na(movts))

dat_first_last = cbind(dats[[1]], dats[[length(dats)]])
names(dat_first_last) = c("id0", "x0", "y0", "id1", "x1", "y1")
#head(dat)

# pythag = function(a,b){ sqrt(a^2 + b^2) }
# dist_btw_points = function(pt1, pt2){ pythag(pt1[1]-pt2[1], pt1[2]-pt2[2]) }
# dat$dist = apply(dat, 1, function(row_i){
#   dist_btw_points(c(row_i[2], row_i[3]), c(row_i[5], row_i[6]))
# })
#dat
qtplot(qt, border_col="transparent")
#points(dat0$x, dat0$y,asp=1)
with(dat_first_last, points(x0, y0))
with(dat_first_last, points(x1, y1, pch=16))
with(dat_first_last, segments(x0, y0, x1, y1))


pythag = function(a,b){ sqrt(a^2 + b^2) }
dist_btw_points = function(pt1, pt2){ pythag(pt1[1]-pt2[1], pt1[2]-pt2[2]) }
showDetailedPaths = TRUE
density_bw = 1
x_range = c(0,8)
y_range = c(0,8)
max_dist = 3

plot_dir = paste0(outputFolder, "R_testing/")
dir.create(plot_dir)
for(i in 2:length(dats)){
  png(paste0(plot_dir, "iteration", i, ".png"), height=800, width=1600)
  par(mfrow = c(2,3), mar=c(2,2,3,1))
  
  #------------
  #plot start point and end point
  qtplot(qt, main=paste0(i, ": movements"))
  with(dats[[i-1]], points(x,y))
  with(dats[[i]], points(x,y, pch=16))
  cmb = cbind(dats[[i]], dats[[i-1]])
  names(cmb) = c("id0", "x0", "y0", "id1", "x1", "y1")
  with(cmb, segments(x0,y0,x1,y1))
  
  #------------
  #plot the entire path (rather than just start and end point)
  if(showDetailedPaths){
    movts_i = movts[movts$iter == i-2,]
    unq_ids = unique(movts_i$id)
    
    x_vals = movts_i %>% pivot_wider(id_cols=step, values_from=x, names_from=id)
    y_vals = movts_i %>% pivot_wider(id_cols=step, values_from=y, names_from=id)
    
    qtplot(qt, main=paste0(i, ": detailed movements"))
    matpoints(x_vals[,-1],y_vals[,-1], pch=16, cex=.5,type="p", col=rainbow(length(unq_ids)))
    matlines(x_vals[,-1], y_vals[,-1], lty=1, col=rainbow(length(unq_ids)))
    with(dats[[i-1]], points(x,y))
    with(dats[[i]], points(x,y, pch=16))
  }
  

  #------------
  #make a plot showing the "vectors" for each movement and the average vector
  dat_i0 = dats[[i-1]]
  dat_i1 = dats[[i]]
  vecs = dat_i1[,c("x", "y")] - dat_i0[,c("x", "y")]
  plot(vecs, asp=1, xlim = c(-1*max_dist,max_dist), ylim = c(-1*max_dist,max_dist), main=paste0(i, ": all travel vectors, with avg in red"))
  segments(0,0,vecs[,1], vecs[,2])
  mean_vec = apply(vecs,2,mean)
  points(mean_vec[1], mean_vec[2], bg="red", col="black", cex=1.5,pch=21)
  segments(0,0,mean_vec[1], mean_vec[2], col="red", lwd=2)
  
  #------------
  #make density plots comparing the density of the start point to the density of the end points
  first_ppp = as.ppp(dats[[i-1]][,c("x", "y")], owin(x_range, y_range))
  first_dens = spatstat::density.ppp(first_ppp, sigma=density_bw,edge=FALSE)
  
  last_ppp = as.ppp(dats[[i]][,c("x", "y")], owin(x_range, y_range))
  last_dens = spatstat::density.ppp(last_ppp, sigma=density_bw, edge=FALSE)
  
  #we need the color scales to be standardized in order to make a direct comparison between the images
  dens_min = min(c(min(first_dens$v), min(last_dens$v)))
  dens_max = max(c(max(first_dens$v), max(last_dens$v)))
  colmap = colourmap(rev(topo.colors(100)), range=c(dens_min, dens_max))
  plot(first_dens, col=colmap, main=paste0(i, ": density of start points"))
  plot(last_dens, col=colmap, main=paste0(i, ": density of end points"))
  
  #------------
  #make a histogram of distance travelled
  cmb$dist = apply(cmb, 1, function(row_i){
    dist_btw_points(c(row_i[2], row_i[3]), c(row_i[5], row_i[6]))
  })
  hist(cmb$dist, main=paste0(i, ": hist of dist travelled"))
  
  #print(cmb$dist)
  # input = readline("")
  # if(input == "q"){
  #   break;
  # }
  dev.off()
}


last = dats[[length(dats)]]
head(last)


test = movts[movts$iter == 0,]
lines(test[,c("x", "y")])
test
unq_ids = unique(test$id)

x_vals = test %>% pivot_wider(id_cols=step, values_from=x, names_from=id)
y_vals = test %>% pivot_wider(id_cols=step, values_from=y, names_from=id)

matplot(x_vals[,-1],y_vals[,-1], pch=16, type="p", col=rainbow(length(unq_ids)))
matlines(x_vals[,-1], y_vals[,-1], lty=1, col=rainbow(length(unq_ids)))
test2 = lapply(1:length(unq_ids), function(i){
  return(test[test$id == unq_ids[i],])
})
do.call(cbind, test2)
# qtplot(qt, border_col="transparent")
# unq_ids = unique(movts$id)
# cols = rainbow(length(unq_ids))
# cols = sample(cols, length(cols), replace=FALSE)
# lapply(1:length(unq_ids), function(i){
#   movts_i = movts[movts$id == unq_ids[i],]
#   lines(movts_i$x, movts_i$y, col=cols[i])
#   points(movts_i$x, movts_i$y, pch=21, cex=.7, bg=cols[i], col="black")
# })
library(readr)
angles_string = read_file("C:\\Users\\derek\\Documents\\Programming\\cpp\\abm\\output\\rand_angles.txt")
angles = as.numeric(unlist(strsplit(angles_string, ",")))
length(angles)
hist(angles, breaks = seq(0,2*pi, pi/6))

rand = runif(9000,0,2*pi)
hist(rand, breaks = seq(0,2*pi, pi/6))

par(mfrow=c(1,1))
for(i in 1:10){
  print(plot(1,1,main=i))
  # input = readline("")
  # if(input == "q"){
  #   break;
  # }
}
plot(1:10,seq(1,5,length.out=10))
