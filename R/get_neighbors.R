#' @title Get the Neighbors of a Quadtree Cell
#' @description Returns a matrix with information about the neighbors of a 
#' quadtree cell
#' @param qt quadtree object
#' @param pt numeric vector of length 2; the x and y coordinates of a point - 
#' this is used to identify which quadtree cell to find neighbors for.
#' @return 
#' A 6-column matrix with one row per neighboring cell. It has the following
#' columns: \itemize{
#'     \item \code{id}: the ID of the cell
#'     \item \code{xmin}, \code{xmax}, \code{ymin}, \code{ymax}: the x and y
#'     limits of the cell
#'     \item \code{value}: the value of the cell
#'   }
#'   
#' Note that this return matrix only includes terminal nodes/cells - that is,
#' cells that have no children. 
#' @examples
#' data(habitat)
#' rast = habitat
#' 
#' # create a quadtree
#' qt = qt_create(rast, split_threshold=.1, adj_type="expand")
#' 
#' # get the cell's neighbors
#' pt = c(27000,10000)
#' nbs = qt_get_neighbors(qt,pt)
#' 
#' # plot the neighbors
#' qt_plot(qt,border_lwd=.3)
#' points(pt[1],pt[2],col="black",bg="lightblue",pch=21)
#' with(data.frame(nbs),rect(xmin,ymin,xmax,ymax,col="red",border="black",lwd=2))
setMethod("get_neighbors", signature(qt = "quadtree", pt = "numeric"),
  function(qt, pt){
    return(qt@ptr$getNeighbors(pt))
  }
)
