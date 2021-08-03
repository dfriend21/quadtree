library(raster)
library(rgdal)
library(sp)
library(quadtree)
rst = raster("/Users/dfriend/Downloads/CC Habitat model 250m/EnsembleModelccBuffered.img")
roads0 = readOGR("/Users/dfriend/Downloads/Roads/ALLmajorrds.shp")
roads = spTransform(roads0, proj4string(rst))
plot(rst)
plot(roads, add=TRUE)
wshd1_0 = readOGR("/Users/dfriend/Downloads/Shape/WBDHU10.shp")
wshd1 = spTransform(wshd1_0, proj4string(rst))

wshd2_0 = readOGR("/Users/dfriend/Downloads/Shape 2/WBDHU10.shp")
wshd2 = spTransform(wshd2_0, proj4string(rst))

wshd3_0 = readOGR("/Users/dfriend/Downloads/Shape 3/WBDHU10.shp")
wshd3 = spTransform(wshd3_0, proj4string(rst))

wshd4_0 = readOGR("/Users/dfriend/Downloads/Shape 4/WBDHU10.shp")
wshd4 = spTransform(wshd4_0, proj4string(rst))

plot(rst)
plot(wshd1, add=TRUE, border="red")
plot(wshd2, add=TRUE, border="darkgreen")

plot(wshd3, add=TRUE, border="blue")
plot(wshd4, add=TRUE, border="purple")
plot(wshd3[8,], col="black",add=TRUE)

roads = raster::intersect(roads, rst_i)
rst_crop = mask(crop(rst, wshd3[8,]), wshd3[8,])
plot(rst_crop)

qt = qt_create(rst_crop, split_method = "sd", .05)
qt_plot(qt)

sheds_list = list(wshd1, wshd2, wshd3, wshd4)
val=""
for(i in 1:length(sheds_list)){
   for(j in 1:nrow(sheds_list[[i]])){
      print(paste0("i: ", i, " | j: ", j))
      rast_i = mask(crop(rst, sheds_list[[i]][j,]), sheds_list[[i]][j,])
      qt_i = qt_create(rast_i, split_threshold=.05, split_method="sd")
      qt_plot(qt_i)
      val = readline("")
      if(val == "q") break;
   }
   if(val == "q") break;
}

i=2; j=1
i=2; j=2
i=2; j=3
i=2; j=5

roads = raster::intersect(roads, wshd2[5,])


plot(rst)

roads_mod = roads[-2,]
plot(rast_i)
plot(roads_mod, add=TRUE)

qt_plot(qt_i, border_lwd=.2)
plot(roads, add=TRUE, col="red")

?rasterize

test = rasterize(roads, rast_i)
test[!is.na(test)] = 1
test[is.na(test)] = 0
plot(test)
test = mask(test, rast_i)
plot(test)
qt_test = qt_create(test, split_threshold=.1)
qt_plot(qt_test, border_lwd=.2)
