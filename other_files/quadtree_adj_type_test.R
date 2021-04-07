library(raster)
library(quadtreeNew)
l = raster("/Users/dfriend/Documents/clark_county_project/data/CC Habitat model 250m/EnsembleModelccBuffered.img")
l
#==================
#TEST 1
q1_1 = createQuadtree(l, .2, adj_type="expand")
qtplot(q1_1,colors=hcl.colors(100), border_col="transparent")
qtplot(q1_1,colors=hcl.colors(100), border_col="transparent", crop=TRUE)
q1_1$nNodes()

q1_2 = createQuadtree(l, .2, adj_type="resample", resample_n_side = 1024)
qtplot(q1_2, na_col="lightgray")
q1_2$nNodes()

#==================
#TEST 2
plot(l)
#ext2 = drawExtent()
ext2 = extent(58503.2,643679.8,3892624,4078649)
l2 = crop(l, ext2)
plot(l2)
l2
q2_1 = createQuadtree(l2, .2, adj_type = "expand")
qtplot(q2_1)
qtplot(q2_1, crop=TRUE)

q2_2 = createQuadtree(l2, .2, adj_type = "resample", resample_n_side=512)
qtplot(q2_2)
qtplot(q2_2,crop=TRUE)
q2_2$nNodes()
test = q2_2$getNbList()

q2_1$nNodes()
q2_2$nNodes()

testFolder = "/Users/dfriend/Desktop/qt_testing_output"

q2_1_file = paste0(testFolder, "/q2_1.quadtree")
q2_2_file = paste0(testFolder, "/q2_2.quadtree")

q2_1$writeQuadtree(q2_1_file)
q2_2$writeQuadtree(q2_2_file)

q2_1i = readQuadtree(q2_1_file)
q2_2i = readQuadtree(q2_2_file)

q2_2i$extent()
q2_2i$originalExtent()
qtplot(q2_1i)
qtplot(q2_2i)

qtplot(q2_1i, crop=TRUE)
qtplot(q2_2i, crop=TRUE)

qtplot(q2_1i, crop=TRUE, border_col="transparent")
qtplot(q2_2i, crop=TRUE, border_col="transparent")

thing = do.call(rbind,test)
head(thing)
class(thing)
names(thing)
edges = data.frame(do.call(rbind,q2_2$getNbList()))
edges = edges[edges$isLowest == 1,]
edges
segments(edges$x0, edges$y0, edges$x1, edges$y1)