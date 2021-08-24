#' @include generics.R

#' @name as_data_frame
#' @title convert a quadtree to a data frame
#' @description creates a data frame with information on each quadtree cell.
#' @param x a \link{\code{Quadtree}} object
#' @return a data frame with one row for each quadtree cell. The columns are as
#'   follows:
#'   \itemize{
#'     \item \code{id}: the id of the cell
#'     \item \code{hasChdn}: 1 if the cell has children, 0 otherwise
#'     \item \code{level}: integer; the depth of this cell/node in the quadtree,
#'     where the root of the quadtree is considered to be level 0
#'     \item \code{xMin}, \code{xMax}, \code{yMin}, \code{yMax}: the x and y
#'     limits of the cell
#'     \item \code{value}: the value of the cell
#'     \item \code{smSide}: the smallest cell length among all of this cells
#'     descendants
#'     \item \code{parentID}: the ID of the cell's parent. The root, which has
#'     no parent, has a value of -1 for this element
#'   }
#' @examples 
#' mat = rbind(c(1,1,0,1),c(1,1,1,0),c(1,0,1,1),c(0,1,1,1))
#' qt = quadtree(mat,.1)
#' plot(qt)
#' as_data_frame(qt)
#' @export
setMethod("as_data_frame", signature(x = "Quadtree"),
  function(x){
    return(data.frame(do.call(rbind,x@ptr$asList())))
  }
)