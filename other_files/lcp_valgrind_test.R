# ----- create a quadtree
# create raster of random values
nrow = 57
ncol = 75
set.seed(4)
rast = raster(matrix(runif(nrow*ncol), nrow=nrow, ncol=ncol), xmn=0, xmx=ncol, ymn=0, ymx=nrow)

# create quadtree
#old = qt_extract(qt, pts)

lcpf2 = qt_lcp_finder(qt, start_pt)
paths2 = qt_find_lcps(lcpf2, limit_type="d", limit=40)
paths2_old = paths2

qt = qt_create(rast, range_limit = .9, adj_type="expand")
cells = data.frame(do.call(rbind, qt$asList()))
cells = cells[cells$hasChdn == 0,]
cells$x = (cells$xMin + cells$xMax)/2
cells$y = (cells$yMin + cells$yMax)/2
qt_plot(qt)
points(cells$x, cells$y)
#filepath = "/Users/dfriend/Desktop/test_folder/file.qtree"
#qt_write(qt, filepath)

#qt = qt_read(filepath)
#qt_plot(qt, crop=TRUE, na_col=NULL)
start_pt = c(ncol/2,nrow/2)

lcpf2 = qt_lcp_finder(qt, start_pt)
paths2 = qt_find_lcps(lcpf2, limit_type="cd", limit=18)

qt_plot(qt, crop=TRUE, na_col=NULL)
pts = cbind((paths2$xmin + paths2$xmax)/2, (paths2$ymin + paths2$ymax)/2)
points(pts, pch=16)



m = merge(paths2_old[,c("id", "cost_tot")], paths2[,c("id", "cost_tot")], by="id")
m$cost_tot.x - m$cost_tot.y
table(m$cost_tot.x - m$cost_tot.y)

dif_ids = setdiff(paths2_old$id, paths2$id)
paths2_old[paths2_old$id %in% dif_ids,]


qt_plot(qt, crop=TRUE, na_col=NULL)
pts = cbind((paths2$xmin + paths2$xmax)/2, (paths2$ymin + paths2$ymax)/2)
points(pts, pch=16)












qt = qt_create(rast, range_limit = .9, adj_type="expand")
#qt_plot(qt, crop=TRUE, na_col=NULL)
start_pt = c(ncol/2,nrow/2)

lcpf2 = qt_lcp_finder(qt, start_pt)
paths2 = qt_find_lcps(lcpf2, limit_type="d", limit=40)
#paths2 = qt_find_lcps(lcpf2, limit_type="none", limit=18)

#summary(paths2)
#pts = cbind((paths2$xmin + paths2$xmax)/2, (paths2$ymin + paths2$ymax)/2)
#points(pts, pch=16)

#new = qt_extract(qt, pts)
#summary(old)
#summary(new)
#summary(old-new)
