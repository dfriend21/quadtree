#' Extract the values of a quadtree at the given locations
#'
#' @param quadtree A \code{quadtree} object
#' @param pts A two-column matrix representing point coordinates. First column contains the x-coordinates, second column contains the y-coordinates
#' @return 
#' a numeric vector corresponding to the values at the points represented by
#' \code{pts}. If a point falls within the quadtree extent and the corresponding
#' cell is \code{NA}, \code{NA} is returned. If the point falls outside of the
#' quadtree extent, \code{NaN} is returned.
#' @examples 
#' #create raster of random values
#' nrow = 57
#' ncol = 75
#' rast = raster(matrix(runif(nrow*ncol), nrow=nrow, ncol=ncol), xmn=0, xmx=ncol, ymn=0, ymx=nrow)
#' 
#' #create quadtree
#' qt1 = qt_create(rast, range_limit = .9, adj_type="expand")
#' 
#' #create points at which we'll extract values
#' pts = cbind(-5:15, 45:65)
#' 
#' #plot the quadtree and the points
#' qt_plot(qt1, border_col="gray60")
#' points(pts, pch=16,cex=.6)
#' 
#' #extract values
#' qt_extract(qt1,pts)
qt_extract <- function(quadtree, pts){
  return(quadtree$getValues(pts[,1], pts[,2]))
}
