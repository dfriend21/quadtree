# ----- create a quadtree
# create raster of random values
nrow = 57
ncol = 75
set.seed(4)
k=1
rast = raster(matrix(runif(nrow*ncol,0,k), nrow=nrow, ncol=ncol), xmn=0, xmx=ncol, ymn=0, ymx=nrow)

all_paths_old = all_paths
qt = qt_create(rast, range_limit = .9*k, adj_type="expand")
cells = data.frame(do.call(rbind, qt$asList()))
cells = cells[cells$hasChdn == 0,]
cells$x = (cells$xMin + cells$xMax)/2
cells$y = (cells$yMin + cells$yMax)/2
#qt_plot(qt)
#points(cells$x, cells$y)


# create quadtree
#old = qt_extract(qt, pts)

#check to see if the paths found vary from run to run
start_pt = c(ncol/2,nrow/2)
lcpf = qt_lcp_finder(qt, start_pt)

paths = qt_find_lcps(lcpf, limit_type="cd", limit=15)
qt_plot(qt, crop=TRUE, border_col="gray60", na_col=NULL, col=c("gray50", "white"))
points((paths$xmin+paths$xmax)/2, (paths$ymin+paths$ymax)/2)

paths = qt_find_lcps(lcpf, limit_type="none", limit=40)
summary(paths)

qt_extract(qt, rbind(start_pt), extents=TRUE)
all_paths = lapply(1:nrow(cells), function(i){
  path = data.frame(qt_find_lcp(lcpf, c(cells$x[i], cells$y[i])))
  if(nrow(path) > 0){
    path$end_pt = cells$id[i] 
  }
  return(path)
})




qt_plot(qt, crop=TRUE, border_col="gray60", na_col=NULL, col=c("gray50", "white"))
is_good = sapply(1:length(all_paths), function(i){
  isGood = TRUE
  if(nrow(all_paths[[i]]) != nrow(all_paths_old[[i]])){
    row_dif = nrow(all_paths[[i]]) - nrow(all_paths_old[[i]])
    print(paste0(i, ": dif # of rows (", row_dif, ")"))
    isGood = FALSE
  } else {
    x_dif = all_paths[[i]]$x - all_paths_old[[i]]$x
    y_dif = all_paths[[i]]$y - all_paths_old[[i]]$y
    cost_tot_dif = all_paths[[i]]$cost_tot - all_paths_old[[i]]$cost_tot
    dist_tot_dif = all_paths[[i]]$dist_tot - all_paths_old[[i]]$dist_tot
    cost_cell_dif = all_paths[[i]]$cost_cell - all_paths_old[[i]]$cost_cell
    if(!all(x_dif == 0)){
      print(paste0(i, ": x coords differ"))
      isGood=FALSE
    }
    if(!all(y_dif == 0)){
      print(paste0(i, ": y coords differ"))
      isGood=FALSE
    }
    if(!all(cost_tot_dif == 0)){
      dif_cost_final = all_paths[[i]]$cost_tot[nrow(all_paths[[i]])] - all_paths_old[[i]]$cost_tot[nrow(all_paths_old[[i]])]
      print(paste0(i, ": cost_tot differs (", dif_cost_final, ")"))
      isGood=FALSE
    }
    if(!all(dist_tot_dif == 0)){
      dif_dist_final = all_paths[[i]]$dist_tot[nrow(all_paths[[i]])] - all_paths_old[[i]]$dist_tot[nrow(all_paths_old[[i]])]
      print(paste0(i, ": dist_tot differs (", dif_dist_final, ")"))
      isGood=FALSE
    }
    if(!all(cost_cell_dif == 0)){
      print(paste0(i, ": cost_cell differs"))
      isGood=FALSE
    }
    
  }
  if(!isGood) print("=================================")
  if(!isGood){
    lines(all_paths_old[[i]][,c("x", "y")], col="green", lwd=1.4)
    lines(all_paths[[i]][,c("x", "y")], col="red", lwd=.8)
    points(all_paths_old[[i]][nrow(all_paths_old[[i]]), c("x", "y")], col="green", pch=16)
    points(all_paths[[i]][nrow(all_paths[[i]]), c("x", "y")], col="red", pch=16)
  }
  return(isGood)
})


cost_difs = sapply(1:length(all_paths), function(i){
  isGood = TRUE
  o = all_paths_old[[i]]
  n = all_paths[[i]]
  if(nrow(o) == 0){
    return(NA)
  }
  #all_paths[[i]]$cost_tot[nrow(all_paths[[i]])] - all_paths_old[[i]]$cost_tot[nrow(all_paths_old[[i]])]
  dif = n$cost_tot[nrow(n)] - o$cost_tot[nrow(o)]
  
  return(dif)
  #return(dif/o$cost_tot[nrow(o)])
  #return(dif/n$cost_tot[nrow(n)])
})
cost_difs
summary(cost_difs)
cost_difs[!is_good]
hist(cost_difs[!is_good])

bad_inds = which(!is_good)
i=1
qt_plot(qt, crop=TRUE, border_col="gray60", na_col=NULL, col=c("gray50", "white"))
lines(all_paths_old[[bad_inds[i]]][,c("x", "y")], col="green", lwd=1.4)
lines(all_paths[[bad_inds[i]]][,c("x", "y")], col="red", lwd=.8)
points(all_paths_old[[bad_inds[i]]][nrow(all_paths_old[[bad_inds[i]]]), c("x", "y")], col="green", pch=16)
points(all_paths[[bad_inds[i]]][nrow(all_paths[[bad_inds[i]]]), c("x", "y")], col="red", pch=16)
i = i+1



qt_plot(qt, crop=TRUE, border_col="gray60", na_col=NULL, col=c("gray50", "white"))
sapply(1:length(all_paths), function(i){
  ap = all_paths[[i]]
  if(nrow(ap) > 0){
    lines(ap$x, ap$y, col="red")
    points(ap$x, ap$y, col="red",pch=16, cex=.5)
  }
})

qt_plot(qt, crop=TRUE, border_col="gray60", na_col=NULL, col=c("gray50", "white"))
sapply(1:length(all_paths_old), function(i){
  ap = all_paths_old[[i]]
  if(nrow(ap) > 0){
    lines(ap$x, ap$y, col="red")
    points(ap$x, ap$y, col="red",pch=16, cex=.5)
  }
})

