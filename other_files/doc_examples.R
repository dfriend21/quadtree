#=============================================
#qt_create example
#=============================================
#create raster of random values
nrow = 57
ncol = 75
rast = raster(matrix(runif(nrow*ncol), nrow=nrow, ncol=ncol), xmn=0, xmx=ncol, ymn=0, ymx=nrow)

#create quadtree using the 'expand' method
qt1 = qt_create(rast, range_limit = .9, adj_type="expand") #automatically adds NA cells to bring the dimensions to 128 x 128 before creating the quadtree
qt_plot(qt1) #plot the quadtree
qt_plot(qt1, crop=TRUE) #we can use 'crop=TRUE' if we don't want to see the padded NA's

#create quadtree using the 'resample' method
qt2 = qt_create(rast, range_limit = .9, adj_type="resample", resample_n_side = 128) #resample to 128 since it's a power of 2
qt_plot(qt2)
qt_plot(qt2, crop=TRUE)

qt_extract(qt2,cbind(-10:9,51:70))


#=============================================
#qt_extract example
#=============================================
#create raster of random values
nrow = 57
ncol = 75
rast = raster(matrix(runif(nrow*ncol), nrow=nrow, ncol=ncol), xmn=0, xmx=ncol, ymn=0, ymx=nrow)

#create quadtree
qt1 = qt_create(rast, range_limit = .9, adj_type="expand") #automatically adds NA cells to bring the dimensions to 128 x 128 before creating the quadtree

#create points at which we'll extract values
pts = cbind(-5:15, 45:65)

#plot the quadtree and the points
qt_plot(qt1, border_col="gray60")
points(pts, pch=16,cex=.6)

#extract values
qt_extract(qt1,pts)


#=============================================
#qt_plot example
#=============================================
#create raster of random values
nrow = 57
ncol = 75
rast = raster(matrix(runif(nrow*ncol), nrow=nrow, ncol=ncol), xmn=0, xmx=ncol, ymn=0, ymx=nrow)

#create quadtree
qt1 = qt_create(rast, range_limit = .9, adj_type="expand") #automatically adds NA cells to bring the dimensions to 128 x 128 before creating the quadtree

#-----------
#DEFAULT
#-----------
qt_plot(qt1) #default - no additional parameters provided

#-----------
#CHANGE PLOT EXTENT
#-----------
#note that additional parameters like 'main', 'xlab', 'ylab', etc. can be passed to qt_plot
qt_plot(qt1, crop=TRUE, main="cropped") #crop extent to the original extent of the raster
qt_plot(qt1, xlim = c(30,50), ylim = c(10,20), main="zoomed in") 

#-----------
#COLORS
#-----------
#change border color
qt_plot(qt1, border_col="transparent",crop=TRUE) #no borders
qt_plot(qt1, border_col="gray60",crop=TRUE)

#change color palette
qt_plot(qt1, colors = c("blue", "yellow", "red"))
qt_plot(qt1, colors=hcl.colors(100))
qt_plot(qt1, colors=c("black", "white"))

#change color of NA cells
qt_plot(qt1, na_col="pink")

#-----------
#SHOW NEIGHBOR CONNECTIONS
#-----------
qt_plot(qt1, nb=TRUE, border_col="gray60")


#=============================================
#qt_lcp_finder example
#=============================================
#create raster of random values
nrow = 57
ncol = 75
set.seed(4)
rast = raster(matrix(runif(nrow*ncol), nrow=nrow, ncol=ncol), xmn=0, xmx=ncol, ymn=0, ymx=nrow)

#create quadtree
qt1 = qt_create(rast, range_limit = .9, adj_type="expand") #automatically adds NA cells to bring the dimensions to 128 x 128 before creating the quadtree
qt_plot(qt1,crop=TRUE)
start_pt = c(.231,.14)
end_pt = c(74.89,56.11)
#create the LCP finder object
spf = qt_lcp_finder(qt1, start_pt)

#use the LCP finder object to find the LCP to a certain point
path1 = qt_find_lcp(spf, end_pt) #this path will have the cell centroids as the start and end points
path2 = qt_find_lcp(spf, end_pt, use_original_end_points = TRUE) #this path will be identical to path1 except that the start and end points will be the user-provided start and end points rather than the cell centroids

#plot the result
qt_plot(qt1, crop=TRUE, border_col="gray60")
points(rbind(start_pt, end_pt), pch=16, col="red")
lines(path1, col="black", lwd=2.5)
lines(path2, col="red", lwd=1)
points(path1, cex=.7, pch=16)

#-------------------
# a larger example to demonstrate run time
#-------------------
nrow = 570
ncol = 750
rast = raster(matrix(runif(nrow*ncol), nrow=nrow, ncol=ncol), xmn=0, xmx=ncol, ymn=0, ymx=nrow)

qt1 = qt_create(rast, range_limit = .9, adj_type="expand") #automatically adds NA cells to bring the dimensions to 128 x 128 before creating the quadtree
spf = qt_lcp_finder(qt1, c(1,1))

#the LCP finder saves state. So finding the path the first time requires computation, and takes longer, but running it again is nearly instantaneous
system.time(qt_find_lcp(spf, c(740,560))) #takes longer
system.time(qt_find_lcp(spf, c(740,560))) #runs MUCH faster

#in addition, because of how Dijkstra's algorithm works, the LCP finder also found many other LCPs in the course of finding the first LCP, meaning that subsequent LCP queries for different destination points will be much faster (since the LCP finder saves state)
system.time(qt_find_lcp(spf, c(740,1)))
system.time(qt_find_lcp(spf, c(1,560)))

#now save the paths so we can plot them
path1 = qt_find_lcp(spf, c(740,560))
path2 = qt_find_lcp(spf, c(740,1))
path3 = qt_find_lcp(spf, c(1,560))

qt_plot(qt1, crop=TRUE, border_col="transparent")
lines(path1)
lines(path2, col="red")
lines(path3, col="blue")
