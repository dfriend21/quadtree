#' @include generics.R

#' @name copy
#' @aliases copy,Quadtree-method
#' @title Create a deep copy of a quadtree object
#' @description Creates a \emph{deep} copy of a quadtree object
#' @param x The \code{\link{Quadtree}} object to copy
#' @details This function creates  \emph{deep} copy of a quadtree object. The
#'   quadtree class accessible from R uses pointers to a CppQuadtree C++ object.
#'   Thus, if a copy is attempted by simply assigning the quadtree to a new
#'   variable, it will only make a \emph{shallow} copy, and both variables will
#'   refer to the same object. Thus, changes made to one will also change the
#'   other. For example, take the following code - assume that we already have a
#'   quadtree object in memory called \code{qt}, and that we have a matrix of
#'   points (\code{pts}) and values (\code{vals}):
#'
#'   \code{qt_copy = qt} \cr \code{set_values(qt, pts, vals)}
#'
#'   Both \code{qt} \strong{and} \code{qt_copy} will be changed by this
#'   operation.
#'
#'   This function creates a deep copy by copying the entire quadtree, and
#'   should be used whenever a copy of a quadtree is desired.
#' @return
#' A Quadtree object
#' @examples
#' data(habitat)
#'
#' # create quadtree, then create a shallow copy and a deep copy for
#' # demonstration
#' qt1 <- quadtree(habitat, split_threshold = .1)
#' plot(qt1)
#'
#' qt2 <- qt1 # SHALLOW copy
#' qt3 <- copy(qt1) # DEEP copy
#'
#' # change the values of qt1 so we can observe how this affects qt2 and qt3
#' ext <- extent(qt1)
#' pts <- cbind(runif(100, ext[1], ext[2]), runif(100, ext[3], ext[4]))
#' set_values(qt1, pts, rep(10, 100))
#'
#' # plot it out to see what happened
#' par(mfrow = c(1,3))
#' plot(qt1, main = "qt1")
#' plot(qt2, main = "qt2")
#' plot(qt3, main = "qt3")
#' # qt2 was modified but qt3 was not
#' @export
setMethod("copy", signature(x = "Quadtree"),
  function(x) {
    qt_new <- new("Quadtree")
    qt_new@ptr <- x@ptr$copy()
    return(qt_new)
  }
)
