#' @title Get the extent of a quadtree
#' @description Gets the extent of the quadtree as an 'extent' object (from the 
#' raster package)
#' @param qt quadtree object
#' @param original boolean; if \code{FALSE} (the default), it returns the total
#'   extent covered by the quadtree. If \code{TRUE}, the function returns the
#'   extent of the original raster used to create the quadtree, before NA
#'   rows/columns were added to pad the dimensions.
#' @return 
#' Returns an 'extent' object (from the 'raster' package)
#' @examples
#' data(habitat)
#' rast = habitat
#' 
#' # create a quadtree
#' qt = qt_create(rast, split_threshold=.1, adj_type="expand")
#' 
#' # retrieve the extent and the original extent
#' ext = qt_extent(qt)
#' ext_orig = qt_extent(qt,original=TRUE)
#' 
#' ext
#' ext_orig
#' 
#' # plot them
#' qt_plot(qt)
#' rect(ext[1],ext[3],ext[2],ext[4],border="blue",lwd=4)
#' rect(ext_orig[1],ext_orig[3],ext_orig[2],ext_orig[4],border="red",lwd=4)
setMethod("extent", signature(qt = "quadtree"),
  function(qt, original=FALSE){
    if(original){
      return(raster::extent(qt@ptr$originalExtent()))
    } else {
      return(raster::extent(qt@ptr$extent()))
    }
  }
)