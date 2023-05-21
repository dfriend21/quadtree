#' @include generics.R

#' @name as_vector
#' @aliases as_vector,Quadtree-method
#' @title Get all \code{Quadtree} cell values as a vector
#' @description Returns all cell values  of a \code{\link{Quadtree}} as a
#'   numeric vector.
#' @param x a \code{\link{Quadtree}}
#' @param terminal_only boolean; if \code{TRUE} (the default) only values of
#'   terminal cells are returned. If \code{FALSE}, all cell values are returned.
#' @return a numeric vector
#' @seealso \code{\link{as_data_frame}} creates a data frame from a
#'   \code{\link{Quadtree}} that has all the cell values as well as details
#'   about each cell's size and extent.
#' @examples
#' library(quadtree)
#' habitat <- terra::rast(system.file("extdata", "habitat.tif", package="quadtree"))
#'
#' qt <- quadtree(habitat, .2)
#' head(as_vector(qt), 20)
#' head(as_vector(qt, FALSE), 20)
#' @export
setMethod("as_vector", signature(x = "Quadtree"),
  function(x, terminal_only = TRUE) {
    return(x@ptr$asVector(terminal_only))
  }
)
