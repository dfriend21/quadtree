#' @include generics.R

#' @name set_values
#' @title Change values of quadtree cells
#' @description Given a quadtree, a set of points and a vector of new values,
#'   changes the value of the quadtree cells containing the points to the
#'   corresponding value
#' @param x A \code{\link{Quadtree}} object 
#' @param y A two-column matrix representing point coordinates. First column
#'   contains the x-coordinates, second column contains the y-coordinates
#' @param z A numeric vector the same length as the number of rows of
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
#' @seealso \code{\link{transform_values}()} can be used to transform the existing
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
setMethod("set_values", signature(x = "Quadtree", y="ANY", z="numeric"),
  function(x, y, z){
    if(!is.matrix(y) && !is.data.frame(y)) stop("'y' must be a matrix or a data frame")
    if(ncol(y) != 2) stop("'y' must have two columns")
    if(!is.numeric(y[,1]) || !is.numeric(y[,2])) stop("'y' must be numeric")
    if(!is.numeric(z)) stop("'z' must be numeric")
    if(nrow(y) != length(z)) stop("'z' must have the same number of elements as the number of rows in 'y'")
    x@ptr$setValues(y[,1], y[,2], z)
  }
)