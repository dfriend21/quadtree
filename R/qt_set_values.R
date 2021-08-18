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
#' @seealso \code{\link{qt_transform}()} can be used to transform the existing
#'   values of all cells
#' @examples
#' data(habitat)
#' rast = habitat
#' 
#' # create a quadtree
#' qt = qt_create(rast, split_threshold = .1)
#' 
#' par(mfrow=c(1,2))
#' qt_plot(qt, main="original")
#' 
#' # generate some random points, then change the values at those points
#' ext = qt_extent(qt)
#' pts = cbind(runif(100,ext[1], ext[2]), runif(100,ext[3], ext[4]))
#' qt_set_values(qt, pts, rep(10,100))
#' 
#' # plot it out to see what happened
#' qt_plot(qt, main="after modification")
qt_set_values = function(quadtree, pts, vals){
  if(!inherits(quadtree, "Rcpp_quadtree")) stop("'quadtree' must be a quadtree object (i.e. have class 'Rcpp_quadtree')")
  if(!is.matrix(pts) && !is.data.frame(pts)) stop("'pts' must be a matrix or a data frame")
  if(ncol(pts) != 2) stop("'pts' must have two columns")
  if(!is.numeric(pts[,1]) || !is.numeric(pts[,2])) stop("'pts' must be numeric")
  if(!is.numeric(vals)) stop("'vals' must be numeric")
  if(nrow(pts) != length(vals)) stop("'vals' must have the same number of elements as the number of rows in 'pts'")
  quadtree$setValues(pts[,1], pts[,2], vals)
}