
# adj_type - the type of adjustment to make the raster be square and have the
        # number of cells of each dimension be a power of 2. Valid values are
        # 'expand', 'resample', or 'none'. If 'resample', then 'resample_res' 
        # must be specified.
createQuadtree <- function(rast, range_limit, adj_type="expand", resample_n_side=NA){
  ext = raster::extent(rast)
  dim = c(ncol(rast), nrow(rast))
  
  if(adj_type == "expand"){
    nXLog2 = log2(raster::ncol(rast))
    nYLog2 = log2(raster::nrow(rast))
    if(((nXLog2 %% 1) != 0) || (nYLog2 %% 1 != 0) || (raster::nrow(rast) != raster::ncol(rast))){  #check if the dimensions are a power of 2 or if the dimensions aren't the same (i.e. it's not square)
      newN = max(c(2^ceiling(nXLog2), 2^ceiling(nYLog2)))
      newExt = raster::extent(rast)
      newExt[2] = newExt[1] + raster::res(rast)[1] * newN
      newExt[4] = newExt[3] + raster::res(rast)[2] * newN
      
      rast = raster::extend(rast,newExt)
    }
  } else if(adj_type == "resample"){
    if(is.na(resample_n_side)) { stop("adj_type is 'resample', but 'resample_n_side' is not specified. Please provide a value for 'resample_n_side'.")}
    if(log2(resample_n_side) %% 1 != 0) { warning(paste0("resample_n_side was given as ", resample_n_side, ", which is not a power of 2. Are you sure these are the dimensions you want? This could result in the smallest possible resoltion of the quadtree being much larger than the resolution of the raster"))}
    
    #first we need to make it square
    newN = max(c(raster::nrow(rast), raster::ncol(rast)))
    newExt = raster::extent(rast)
    newExt[2] = newExt[1] + raster::res(rast)[1] * newN
    newExt[4] = newExt[3] + raster::res(rast)[2] * newN
    rast = raster::extend(rast,newExt)
    
    #now we can resample
    rastTemplate = raster::raster(newExt, nrow=resample_n_side, ncol=resample_n_side, crs=raster::crs(rast))
    rast = raster::resample(rast, rastTemplate, method = "ngb")
  }
  
  qt <- new(quadtree, raster::as.matrix(rast), raster::extent(rast)[1:2], raster::extent(rast)[3:4], range_limit)
  qt$setOriginalValues(ext[1], ext[2], ext[3], ext[4], dim[1], dim[2])
  qt$setProjection(projection(rast))
  return(qt)
}
