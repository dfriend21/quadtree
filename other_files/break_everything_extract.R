library(quadtree)
library(raster)

#BREAK EVERYTHING!!!

data(habitat)
r = habitat
qt = qt_create(r, .1)

qt_plot(qt)
qt_extract(qt, cbind(NA,NA),extents=TRUE)
qt_extract(qt, cbind(NA,1),extents=TRUE)
qt_extract(qt, cbind(-1,-1),extents=TRUE)
qt_extract(qt, cbind(10,10),extents=TRUE)
qt_extract(qt, cbind(c(NA,-1,10), c(NA,-1,10)),extents=TRUE)
qt_extract(qt, cbind(c(NA,-1,10,30000), c(NA,-1,10,30000)))
qt_extract(qt, cbind(c(NA,-1,10,30000), c(NA,-1,10,30000)),extents=TRUE)

qt_extract("hi there")
qt_extract(qt,"hi")
df = data.frame(f1=c("a","b","c","d","e"), f2=c(1,2,3,4,5))
sapply(df,class)
qt_extract(qt, df)

qt_extract(qt,cbind(c("a","b","c"),c("d","e","f")))
qt_extract(qt,cbind(1:3,1:3,1:3))

qt_extract(qt,cbind(1:3,1:3),"a")
