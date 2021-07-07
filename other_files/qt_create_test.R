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
qt_plot(qt)

split_fun = function(vals, args){
  #sd = sqrt(sum((vals-mean(vals))^2)/length(vals))
  return(sd(vals) > args$sd)
  #return(sd > args$sd)
}
combine_fun = function(vals, args){
  if(sum(is.na(vals)) != 0){
    return(NA)
  } else if(max(vals) < args$threshold){
    return(args$low_val)
  } else {
    return(args$high_val)
  }
}


combine_fun = function(vals, args){
  mean(vals)
}
#qt_create <- function(x, split_threshold = NULL, split_method = "range", combine_method = "mean", split_fun=NULL, split_args=list(), combine_fun=NULL, combine_args=list(), max_cell_length=NULL, adj_type="expand", resample_n_side=NULL, extent=NULL, proj4string=NULL){
system.time(qt_create(1-l_iv, split_threshold=.2, split_method="range"))

system.time(qt_create(1-l, split_threshold=.1, split_method="sd", combine_method="mean"))
system.time(qt_create(1-l, split_method="custom", split_fun=split_fun, split_args=list(sd=.1), combine_method="mean"))
qt1 = qt_create(1-l_iv, split_threshold=.1, split_method="sd", combine_method="mean")
qt2 = qt_create(1-l_iv, split_method="custom", split_fun=split_fun, split_args=list(sd=.1), combine_method="mean")

qt_plot(qt1)
qt_plot(qt2)


qt1 = qt_create(1-l_iv, split_threshold=.1, split_method="sd", combine_method="mean")
qt2 = qt_create(1-l_iv, split_threshold=.1, split_method="sd", combine_method="custom", combine_fun=combine_fun, combine_args=list(hi_there=1))
qt_plot(qt1, crop=TRUE, na_col="transparent")
qt_plot(qt1, crop=TRUE, na_col=NULL)
qt_plot(qt2, crop=TRUE, na_col=NULL)


combine_fun = function(vals, args){
  return(mean(vals))
}
#combine_fun(c(.1,.2,.3,.1,.6), list(threshold=.5, low_val=.5, high_val=.6))
qt = qt_create(l_iv, split_fun = qt_split_diff, split_args=list(range_limit=.15))
qt_plot(qt, crop=TRUE, na_col=NULL)
qt_plot(qt, na_col=NULL)
system.time(qt_create(l, split_fun=qt_split_diff, split_args=list(range_limit=.15)))

qt = qt_create(1-l, split_fun, args=list(sd=.1))
qt_plot(qt, crop=TRUE, na_col=NULL)
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
