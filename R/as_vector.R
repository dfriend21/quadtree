#' @include generics.R

#' @name as_vector
#' @aliases as_vector,Quadtree-method
#' @title Get All Cell Values in a Vector
#' @description Returns all cell values as a numeric vector
#' @param x a \code{\link{Quadtree}} object
#' @param terminal_only boolean; if TRUE (the default) only values of terminal
#'   cells are returned. If FALSE, all cell values are returned.
#' @seealso \code{\link{as_data_frame}} creates a data frame from a quadtree
#'   that has all the cell values as well as details about each cell's size and
#'   extent.
#' @examples
#' data(habitat)
#' qt <- quadtree(habitat, .2)
#' as_vector(qt)
#' @export
setMethod("as_vector", signature(x = "Quadtree"),
  function(x, terminal_only = TRUE) {
    return(x@ptr$asVector(terminal_only))
  }
)
