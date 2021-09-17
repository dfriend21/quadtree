#' @include generics.R

#' @name set_values
#' @aliases set_values,Quadtree,ANY,numeric-method
#' @title Change values of \code{Quadtree} cells
#' @description Given a \code{\link{Quadtree}}, a set of points, and a vector of
#'   new values, changes the value of the quadtree cells containing the points
#'   to the corresponding value.
#' @param x A \code{\link{Quadtree}}
#' @param y A two-column matrix representing point coordinates. First column
#'   contains the x-coordinates, second column contains the y-coordinates.
#' @param z A numeric vector the same length as the number of rows of
#'   \code{y}. The values of the cells containing \code{y} will be changed
#'   to the corresponding value in \code{z}.
#' @details
#' Note that it is entirely possible for \code{y} to contain multiple points
#' that all fall within the same cell. The values are changed in the order
#' given, so the cell will take on the \emph{last} value given for that cell.
#'
#' It's important to note that this modifies the original quadtree. If you wish
#' to maintain a version of the original quadtree, use \code{\link{copy}}
#' beforehand to make a copy of the quadtree.
#' @return
#' no return value
#' @seealso \code{\link{transform_values}()} can be used to transform the
#'   existing values of all cells using a function.
#' @examples
#' library(quadtree)
#' data(habitat)
#'
#' # create a quadtree
#' qt <- quadtree(habitat, split_threshold = .1)
#'
#' # generate some random points, then change the values at those points
#' ext <- extent(qt)
#' pts <- cbind(runif(100, ext[1], ext[2]), runif(100, ext[3], ext[4]))
#' set_values(qt, pts, rep(10, 100))
#'
#' # plot it out to see what happened
#' old_par <- par(mfrow = c(1, 2))
#' plot(qt, main = "original")
#' plot(qt, main = "after modification")
#' par(old_par)
#' @export
setMethod("set_values", signature(x = "Quadtree", y = "ANY", z = "numeric"),
  function(x, y, z) {
    # validate inputs
    if (!is.matrix(y) && !is.data.frame(y)) stop("'y' must be a matrix or a data frame")
    if (ncol(y) != 2) stop("'y' must have two columns")
    if (!is.numeric(y[, 1]) || !is.numeric(y[, 2])) stop("'y' must be numeric")
    if (!is.numeric(z)) stop("'z' must be numeric")
    if (nrow(y) != length(z)) stop("'z' must have the same number of elements as the number of rows in 'y'")

    x@ptr$setValues(y[, 1], y[, 2], z)
  }
)
