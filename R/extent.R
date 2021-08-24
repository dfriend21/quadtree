#' @include generics.R

#' @name extent
#' @title Get the extent of a quadtree
#' @description Gets the extent of the quadtree as an 'extent' object (from the 
#' raster package)
#' @param x \link{\code{Quadtree}} object
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
#' qt = quadtree(rast, split_threshold=.1, adj_type="expand")
#' 
#' # retrieve the extent and the original extent
#' ext = extent(qt)
#' ext_orig = extent(qt,original=TRUE)
#' 
#' ext
#' ext_orig
#' 
#' # plot them
#' plot(qt)
#' rect(ext[1],ext[3],ext[2],ext[4],border="blue",lwd=4)
#' rect(ext_orig[1],ext_orig[3],ext_orig[2],ext_orig[4],border="red",lwd=4)
#' @export
setMethod("extent", signature(x = "Quadtree"),
  function(x, original=FALSE){
    if(original){
      return(raster::extent(x@ptr$originalExtent()))
    } else {
      return(raster::extent(x@ptr$extent()))
    }
  }
)