#' @include generics.R

#' @name as_data_frame
#' @aliases as_data_frame,Quadtree-method
#' @title Convert a \code{Quadtree} to a data frame
#' @description Creates a data frame with information on each quadtree cell.
#' @param x a \code{\link{Quadtree}}
#' @param terminal_only boolean; if \code{TRUE} (the default) only information
#'   on terminal cells is returned. If \code{FALSE}, information on all cells is
#'   returned.
#' @return A data frame with one row for each quadtree cell. The columns are as
#'   follows:
#'   \itemize{
#'     \item \code{id}: the id of the cell
#'     \item \code{hasChildren}: 1 if the cell has children, 0 otherwise
#'     \item \code{level}: integer; the depth of this cell/node in the quadtree,
#'     where the root of the quadtree is considered to be level 0
#'     \item \code{xmin}, \code{xmax}, \code{ymin}, \code{ymax}: the x and y
#'     limits of the cell
#'     \item \code{value}: the value of the cell
#'     \item \code{smallestChildLength}: the smallest cell length among all of this cell's
#'     descendants
#'     \item \code{parentID}: the ID of the cell's parent. The root, which has
#'     no parent, has a value of -1 for this column
#'   }
#' @seealso \code{\link{as_vector}()} returns all the cell values as a numeric
#' vector.
#' @examples
#' library(quadtree)
#' 
#' mat <- rbind(c(1, 1, 0, 1),
#'              c(1, 1, 1, 0),
#'              c(1, 0, 1, 1),
#'              c(0, 1, 1, 1))
#' qt <- quadtree(mat, .1)
#' plot(qt)
#' as_data_frame(qt)
#' @export
setMethod("as_data_frame", signature(x = "Quadtree"),
  function(x, terminal_only = TRUE) {
    df <- data.frame(do.call(rbind, x@ptr$asList()))
    if (terminal_only) {
      df <- df[df$hasChildren == 0, ]
    }
    return(df)
  }
)
