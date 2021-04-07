#make gitlab picture

library(raster)
library(quadtree)
l = raster("/Users/dfriend/Documents/clark_county_project/data/CC Habitat model 250m/EnsembleModelccBuffered.img")

#==================
#TEST 1
#qt_1 = createQuadtree(1-l_iv, .2, adj_type="expand")
qt_1 = createQuadtree(1-l, .2, adj_type="expand")

plot(l)
pic_ext = drawExtent()
pic_ext = new("Extent", xmin = 626949.152846065, xmax = 630900.027553314, 
              ymin = 4037633.01991249, ymax = 4041828.90854116)
#pic_ext = extent(728846.7, 732195.9, 4078730, 4082079) 

small = crop(l,pic_ext)
plot(small)

/Users/dfriend/Documents/r_packages/quadtree/man
qt = createQuadtree(small,.2)

png("/Users/dfriend/Documents/r_packages/quadtree/other_files/output/gitlab_pic.png", width = 100, height = 100)
par(mar = c(0,0,0,0))
qtplot(qt,col="white", axes=FALSE, xlab="", ylab = "")
dev.off()
