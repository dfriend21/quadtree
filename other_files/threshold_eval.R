library(raster)
library(rgdal)
library(quadtree)

pythag = function(a,b){ sqrt(a^2 + b^2) }
dist_btw_points = function(pts1, pts2){ pythag(pts1[,1]-pts2[,1], pts1[,2]-pts2[,2]) } #gets the distance between two points

l = raster("/Users/dfriend/Documents/clark_county_project/data/CC Habitat model 250m/EnsembleModelccBuffered.img")

iv = readOGR("/Users/dfriend/Documents/cpp/abm/input/IvanpahValleyWatershed/IvanpahValleyWatershed.shp")
iv = spTransform(iv, crs(l))
l_iv = mask(crop(l,iv),iv)


rast = l_iv
thresholds = seq(0,1,length.out=20)
split_methods = c("range", "sd")
combine_methods = c("mean", "median")
params = expand.grid(trld = thresholds, splt = split_methods, cmb = combine_methods, stringsAsFactors = FALSE)
params
rast_pts = rasterToPoints(l_iv)
eval_list = lapply(1:nrow(params), function(i){
  qt = qt_create(rast, split_threshold=params$trld[i], split_method=params$splt[i], combine_method=params$cmb[i])
  vals = cbind(rast_pts, qt_extract(qt, rast_pts[,1:2]))
  mse = mean((vals[,3] - vals[,4])^2)
  n_nodes = qt$nNodes()
  return(data.frame(trld = params$trld[i], splt = params$splt[i], cmb = params$cmb[i], mse = mse, n_nodes = n_nodes))
})
eval_df = do.call(rbind, eval_list)
eval_df
plot(eval_df$trld, eval_df$mse, type="b")
plot(eval_df$trld, eval_df$n_nodes)
plot(eval_df$n_nodes, eval_df$mse)

eval_df$trial = paste0(eval_df$splt, " ", eval_df$cmb)
library(ggplot2)
ggplot(eval_df, aes(x=trld, y=mse, col=trial)) + 
  geom_point() + 
  geom_line()


ggplot(eval_df, aes(x=n_nodes, y=mse, col=trial)) + 
  geom_point() + 
  geom_line()
