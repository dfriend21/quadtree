#' @include generics.R

#' @name copy
#' @aliases copy,Quadtree-method copy.Quadtree
#' @title Create a deep copy of a \code{\link{Quadtree}}
#' @description Creates a \emph{deep} copy of a \code{\link{Quadtree}}.
#' @param x a \code{\link{Quadtree}}
#' @details This function creates a \emph{deep} copy of a \code{\link{Quadtree}}
#'   object. The \code{\link{Quadtree}} class contains a pointer to a
#'   \code{\link{CppQuadtree}} C++ object. If a copy is attempted by simply
#'   assigning the quadtree to a new variable, it will simply make a copy of the
#'   \emph{pointer} - both variables will point to the same
#'   \code{\link{CppQuadtree}}. Thus, changes made to one will also change the
#'   other. See "Examples" for a demonstration of this.
#'
#'   This function creates a deep copy by copying the entire quadtree, and
#'   should be used whenever a copy of a quadtree is desired.
#' @return A \code{\link{Quadtree}} object
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
#' transform_values(qt1, function(x) 1-x)
#'
#' # plot it out to see what happened
#' par(mfrow = c(1,3))
#' plot(qt1, main = "qt1", border_col = "transparent")
#' plot(qt2, main = "qt2", border_col = "transparent")
#' plot(qt3, main = "qt3", border_col = "transparent")
#' # qt2 was modified but qt3 was not
#' @export
setMethod("copy", signature(x = "Quadtree"),
  function(x) {
    qt_new <- new("Quadtree")
    qt_new@ptr <- x@ptr$copy()
    return(qt_new)
  }
)
