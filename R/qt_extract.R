#' @title Extract the values of a quadtree at the given locations
#' @description Extract the cell values and optionally the cell extents
#' @param quadtree A \code{quadtree} object
#' @param pts A two-column matrix representing point coordinates. First column
#'   contains the x-coordinates, second column contains the y-coordinates
#' @param extents boolean; if \code{FALSE} (the default), a vector containing
#'   cell values is returned. If \code{TRUE}, a matrix is returned providing
#'   each cell's extent in addition to its value
#' @return The return type depends on the value of \code{extents}. 
#' 
#' If \code{extents = FALSE}, the function returns a numeric vector
#' corresponding to the values at the points represented by \code{pts}. If a
#' point falls within the quadtree extent and the corresponding cell is
#' \code{NA}, or if the point falls outside of the extent, \code{NaN} is
#' returned.
#' 
#' If \code{extents = TRUE}, the function returns a 6-column numeric matrix
#' providing the extent of each cell along with the cell's value and ID. The 6
#' columns are, in this order: \code{id}, \code{xmin}, \code{xmax}, \code{ymin},
#' \code{ymax}, \code{value}. If a point falls in a \code{NA} cell, the cell
#' extent is still returned but \code{value} will be \code{NaN}. If a point
#' falls outside of the quadtree, all values will be \code{NaN}.
#' 
#' @examples
#' data(habitat)
#' rast = habitat
#' 
#' # create quadtree
#' qt1 = qt_create(rast, split_threshold=.1, adj_type="expand")
#' qt_plot(qt1)
#' 
#' # create points at which we'll extract values
#' coords = seq(-1000,40010,length.out=10)
#' pts = cbind(coords,coords)
#' 
#' # extract the cell values
#' vals = qt_extract(qt1,pts)
#' 
#' # plot the quadtree and the points
#' qt_plot(qt1, border_col="gray50", border_lwd=.4)
#' points(pts, pch=16,cex=.6)
#' text(pts,labels=round(vals,2),pos=4)
#' 
#' # we can also extract the cell extents in addition to the values
#' qt_extract(qt1,pts,extents=TRUE)
qt_extract <- function(quadtree, pts, extents=FALSE){
  if(!inherits(quadtree, "Rcpp_quadtree")) stop("'quadtree' must be a quadtree object (i.e. have class 'Rcpp_quadtree')")
  if(!is.matrix(pts) && !is.data.frame(pts)) stop("'pts' must be a matrix or a data frame")
  if(ncol(pts) != 2) stop("'pts' must have two columns")
  if(!is.numeric(pts[,1]) || !is.numeric(pts[,2])) stop("'pts' must be numeric")
  if(extents){
    return(quadtree$getCellDetails(pts[,1], pts[,2]))
  } else {
    return(quadtree$getValues(pts[,1], pts[,2]))
  }
}