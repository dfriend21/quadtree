library(raster)
library(rgdal)
library(quadtree)

pythag = function(a,b){ sqrt(a^2 + b^2) }
dist_btw_points = function(pts1, pts2){ pythag(pts1[,1]-pts2[,1], pts1[,2]-pts2[,2]) } #gets the distance between two points

l = raster("/Users/dfriend/Documents/clark_county_project/data/CC Habitat model 250m/EnsembleModelccBuffered.img")

iv = readOGR("/Users/dfriend/Documents/cpp/abm/input/IvanpahValleyWatershed/IvanpahValleyWatershed.shp")
iv = spTransform(iv, crs(l))
l_iv = mask(crop(l,iv),iv)

l_iv
qt = qt_create(1-l_iv, .8, adj_type="expand")
qt = qt_create(1-l_iv, .2, adj_type="expand")
qt = qt_create(l_iv, .2, adj_type="expand")
qt2 = qt_create(l_iv+100, .2, adj_type="expand")
#qt = qt_create(1-l_iv, .8, max_cell_length = 10000, adj_type="resample", resample_n_side = 256)
#plot(1-l_iv)
qt_plot(qt, crop=TRUE, border_col="gray60", xlab='hi there')
qt_plot(qt, crop=TRUE, main="title", na_col=NULL, adj_mar_auto=6)
qt_plot(qt)
qt_plot(qt2, legend_args=list(bar_wd_pct=.15))
qt_plot(qt, nb_line_col="black", na_col=NULL, crop=TRUE, border_col="transparent")
qt_plot(qt, nb_line_col="black", na_col=NULL, crop=TRUE, border_col="gray60", xlim=c(640000,660000), ylim=c(3920000,3940000))
plot(1,1)

add_legend()
qt$maxCellDims()
#qt_plot(qt, crop=TRUE,border_col="transparent")

qext = qt_extent_orig(qt)
pts = cbind(runif(100,qext[1], qext[2]), runif(100,qext[3],qext[4]))
qt_extract(qt, pts)
qt_plot(qt,crop=TRUE, border_col="gray60")
points(pts)

pt1 = c(644571,3910000)
pt2 = c(650000, 3940000)
qt_plot(qt, border_col="gray50",crop=TRUE)
points(rbind(pt1,pt2))
spf = qt_lcp_finder(qt, pt1)
lcp = qt_find_lcp(spf, pt2)
lcp
