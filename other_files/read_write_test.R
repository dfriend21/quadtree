library(raster)
library(quadtree)
l = raster("/Users/dfriend/Documents/clark_county_project/data/CC Habitat model 250m/EnsembleModelccBuffered.img")

#==================
#TEST 1
path = "/Users/dfriend/Documents/r_packages/quadtree/other_files/output/habQT_test.qtree"
qt = qt_create(1-l, .3, adj_type="expand")
qt_write(qt, path)
qt2 = qt_read(path)
qt_plot(qt2, border_col = "transparent")

pt1 = c(600000,4000000)
pt2 = c(750000,4100000)
spf = qt_lcp_finder(qt, pt1)
lcp = qt_find_lcp(spf, pt2)
points(rbind(pt1,pt2))
qt_extract(qt, rbind(pt1,pt2))
lines(lcp)
lcp
