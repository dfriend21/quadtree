#' @title Change values of quadtree cells
#' @description Given a set of points and a vector of new values, changes the
#'   value of the quadtree cells containing the points to the corresponding
#'   value
#' @param quadtree The \code{quadtree} object to copy
#' @param pts A two-column matrix representing point coordinates. First column
#'   contains the x-coordinates, second column contains the y-coordinates
#' @param vals A numeric vector the same length as the number of rows of
#'   \code{pts}. The values of the cells containing \code{pts} will be changed
#'   to the corresponding number in \code{vals}.
#' @details
#' Note that it is entirely possible for \code{pts} to contain multiple points
#' that all fall within the same cell. The values are changed in the order
#' given, so in this case the cell will take on the \emph{last} value given for
#' that cell.
#' 
#' Also note that the structure of the quadtree will not be changed - only the 
#' cell values will change.
#' @return 
#' No return value
#' @examples
#' library(raster)
#' 
#' # create raster of random values
#' nrow = 64
#' ncol = 64
#' rast = raster(matrix(runif(nrow*ncol), nrow=nrow, ncol=ncol), xmn=0, xmx=ncol, ymn=0, ymx=nrow)
#' 
#' # create quadtree - then create a shallow copy and a deep copy for demonstration
#' qt1 = qt_create(rast, split_threshold = .9, split_method="range", adj_type="expand")
#' 
#' par(mfrow=c(1,2))
#' qt_plot(qt1, main="original")
#' 
#' ext = qt_extent(qt1)
#' pts = cbind(runif(100,ext[1], ext[2]), runif(100,ext[3], ext[4]))
#' qt_set_values(qt1, pts, rep(10,100))
#' 
#' # plot it out to see what happened
#' qt_plot(qt1, main="after modification")
qt_set_values = function(quadtree, pts, vals){
  quadtree$setValues(pts[,1], pts[,2], vals)
}