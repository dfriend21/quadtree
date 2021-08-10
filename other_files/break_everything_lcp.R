library(quadtree)
library(raster)

#BREAK EVERYTHING!!!

data(habitat)
r = habitat
qt = qt_create(r, .1)
#qt_plot(qt)

start_pt = c(8001,20001)
end_pt = c(36001,21001)

#lcpf = qt_lcp_finder(qt, start_pt)
#lcp = qt_find_lcp(lcpf, end_pt)
#qt_plot(qt, border_lwd=.2)
#lines(lcp)


#-------- qt

lcpf = qt_lcp_finder(NULL, start_pt)
lcp = qt_find_lcp(lcpf, end_pt)


#-------- start_point
test = qt_lcp_finder(qt,c(-1,-1))
test
qt_lcp_finder(qt, "c")
qt_lcp_finder(qt, list(4,5))
qt_lcp_finder(qt, c("c",1))
qt_lcp_finder(qt, numeric())
lf = qt_lcp_finder(qt, c(1,NA))
lf$isValid()
qt_find_lcp(lf,end_pt)

#=============================
# qt_extract()
#=============================
qt_plot(qt)
qt_extract(qt, cbind(NA,NA),extents=TRUE)
qt_extract(qt, cbind(-1,-1),extents=TRUE)
qt_extract(qt, cbind(10,10),extents=TRUE)
qt_extract(qt, cbind(c(NA,-1,10), c(NA,-1,10)),extents=TRUE)
qt_extract(qt, cbind(c(NA,-1,10,30000), c(NA,-1,10,30000)))
qt_extract(qt, cbind(c(NA,-1,10,30000), c(NA,-1,10,30000)),extents=TRUE)
