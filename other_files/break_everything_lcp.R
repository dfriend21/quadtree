library(quadtree)
library(raster)

#BREAK EVERYTHING!!!

data(habitat)
r = habitat
qt = qt_create(r, .1)
#qt_plot(qt)

start_pt = c(8001,20001)
end_pt = c(36001,21001)

lcpf = qt_lcp_finder(qt, start_pt)
lcp = qt_find_lcp(lcpf, end_pt)
#lcp = qt_find_lcp(lcpf, c(-1,-1))
qt_lcp_summary(lcpf) 
qt_plot(qt, border_lwd=.2)
lines(lcp)

#-------- qt

lcpf = qt_lcp_finder(NULL, start_pt)
#lcp = qt_find_lcp(lcpf, end_pt)
#lcp

#-------- start_point
lf = qt_lcp_finder(qt,c(-1,-1))
qt_find_lcp(lf, c(1000,1000))
qt_find_lcps(lf)
qt_lcp_summary(lf)

qt_lcp_finder(qt, "c")
qt_lcp_finder(qt, list(4,5))
qt_lcp_finder(qt, c("c",1))
qt_lcp_finder(qt, numeric())
qt_lcp_finder(qt, c(1,NA))



#-------- xlims and ylims
qt_lcp_finder(qt,c(2000,2000),NA,c(1,2))
qt_lcp_finder(qt,c(2000,2000),c(NA,3),c(1,2))
qt_lcp_finder(qt,c(2000,2000),c(1,3),c(1,NA))
qt_lcp_finder(qt,c(2000,2000),c(1,3),list())
qt_lcp_finder(qt,c(2000,2000),c(4,1),c(4,1))


#invalid x and y lims
lf = qt_lcp_finder(qt,c(-75,-75),c(-100,-50),c(-100,-50))
qt_find_lcp(lf, c(-80,-80))
qt_find_lcps(lf)
qt_lcp_summary(lf)

#invalid x and y lims AND point is outside of x and y lims
lf = qt_lcp_finder(qt,c(30000,30000),c(-100,-50),c(-100,-50))
qt_find_lcp(lf, c(-75,-75))
qt_find_lcps(lf)
qt_lcp_summary(lf)

#point is inside the quadtree but outside of x and y lims
lf = qt_lcp_finder(qt,c(20000,20000),c(10000,40000),c(10000,40000))
lcp = qt_find_lcp(lf, c(30000,30000))
lines(lcp)
qt_lcp_summary(lf)
qt_find_lcp(lf, c(5000,5000))
qt_lcp_summary(lf)
qt_find_lcps(lf)

#valid point
qt_lcp_summary(lf)
lf = qt_lcp_finder(qt,c(30000,30000),c(0,40000),c(0,40000))
lf = qt_lcp_finder(qt,c(30000,30000),c(-100,-50),c(0,10000))
qt_lcp_finder(qt,c(30000,30000),c(-100,-50),c(-100))
qt_lcp_finder(qt,c(30000,30000),c(10000,20000),c(10000,20000))
qt_lcp_finder(qt,c(30000,30000),"a","b")

#valid point, but try using invalid points as end points
lf = qt_lcp_finder(qt,c(20000,20000))
qt_find_lcp(lf,c(-1,-1))

start_pt = c(20000,20000)
xlims = c(10000,30000)
ylims = c(10000,30000)
end_pt = c(20000,40000)

qt_plot(qt, border_lwd=.2)
rect(xlims[1],ylims[1],xlims[2],ylims[2])
points(rbind(start_pt,end_pt),bg=c("blue", "red"),pch=21,col="black")
lf = qt_lcp_finder(qt,start_pt,xlims,ylims)
qt_lcp_summary(lf)
lcp = qt_find_lcp(lf,end_pt)
lcp
qt_lcp_summary(lf)
lines(lcp[,1:2])


lf = qt_lcp_finder(qt,c(20000,20000),c(40000,10000),c(40000,10000))
qt_find_lcp(lf, c(30000,30000))

