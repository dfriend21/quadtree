#' @name qt_extent
#' @rdname qt_extent
#' 
#' @title Get the extent of a quadtree
#' @description Gets the extent of the quadtree as an 'extent' object (from the 
#' raster package)
#' @param quadtree quadtree object
#' @details
#' \code{qt_extent} returns the total extent covered by the quadtree.
#' 
#' \code{qt_extent_orig} returns the extent of the original raster used to
#' create the quadtree, before NA rows/columns were added to pad the dimensions.
#' This essentially represents the extent in which the non-NA data occurs.
#' @return 
#' Returns an 'extent' object
#' @examples
#' #create raster of random values
#' nrow = 57
#' ncol = 75
#' rast = raster(matrix(runif(nrow*ncol), nrow=nrow, ncol=ncol), xmn=0, xmx=ncol, ymn=0, ymx=nrow)
#' qt = qt_create(rast, .9, adj_type="expand")
#' 
#' qt_extent(qt)
#' qt_extent_orig(qt)

NULL

#' @rdname qt_extent
#' @export
qt_extent = function(quadtree){
  return(raster::extent(quadtree$extent()))
}

#' @rdname qt_extent
#' @export
qt_extent_orig = function(quadtree){
  return(raster::extent(quadtree$originalExtent()))
}