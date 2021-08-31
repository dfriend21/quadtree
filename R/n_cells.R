#' @include generics.R

#' @name n_cells
#' @aliases n_cells,Quadtree-method
#' @title Get the Number of Cells in a Quadtree
#' @description Returns the total number of nodes/cells in the tree.
#' @param x a \code{\link{Quadtree}} object
#' @param terminal_only boolean; if \code{TRUE} (the default) only the terminal
#' nodes are counted. If \code{FALSE}, all nodes are counted, thereby giving the
#' total number of nodes in the tree.
#' @examples
#' data(habitat)
#' qt <- quadtree(habitat, .1)
#' n_cells(qt)
#' n_cells(qt, terminal_only = FALSE)
#' @export
setMethod("n_cells", signature(x = "Quadtree"),
  function(x, terminal_only = TRUE) {
    n <- x@ptr$nNodes()
    if (!terminal_only) return(n)
    return((floor(n / 4) * 3) + 1)
  }
)
