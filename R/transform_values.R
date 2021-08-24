#' @include generics.R

#' @name transform_values
#' @title Transform the Values of All Cells
#' @description Uses a function to change all cell values
#' @param x A \code{\link{Quadtree}} object
#' @param y function; function used on each cell to transform the 
#'   value. Must accept a single numeric value and return a single numeric
#'   value. The function must also be able to handle NA values.
#' @details
#' This function applies a function to every single cell, which allows the user
#' to do things like multiply by a scalar, invert the values, etc.
#' 
#' Since a quadtree may contain \code{NA} values, \code{y} must
#' be able to handle \code{NA}s without throwing an error. For example, if
#' \code{y} contains some control statement such as \code{if(x <
#' .7)}, the function must have a separate statement before this to catch
#' \code{NA} values, since having an \code{NA} in an if statement is not
#' allowed. See 'Examples' for an example of this.
#' 
#' It's important to note that this modifies the original quadtree. If you wish
#' to maintain a version of the original quadtree, use \code{\link{copy}} 
#' beforehand to make a copy of the quadtree (see 'Examples').
#' @return 
#' No return value
#' @seealso \code{\link{qt_set_values}()} can be used to set the values of cells 
#' to specified values (rather than transforming the existing values)
#' @examples
#' data(habitat)
#' rast = habitat
#' 
#' # create a quadtree
#' qt1 = quadtree(rast, split_threshold = .1)
#' 
#' # copy the quadtree so that we have a copy of the original (since using 
#' #'transform_values' modifies the quadtree object)
#' qt2 = copy(qt1)
#' qt3 = copy(qt1)
#' qt4 = copy(qt1)
#' 
#' transform_values(qt2, function(x) 1-x)
#' transform_values(qt3, function(x) x^3 ) 
#' transform_values(qt4, function(x){
#'   if(is.na(x)) return(NA) # make sure to handle NA's
#'   if(x < .7) return(0)
#'   else return(1)
#' })
#' 
#' par(mfrow=c(2,2))
#' qt_plot(qt1, main="original", crop=TRUE, na_col=NULL, border_lwd=.3, zlim=c(0,1))
#' qt_plot(qt2, main="1 - value", crop=TRUE, na_col=NULL, border_lwd=.3, zlim=c(0,1))
#' qt_plot(qt3, main="values cubed", crop=TRUE, na_col=NULL, border_lwd=.3, zlim=c(0,1))
#' qt_plot(qt4, main="values converted to 0/1", crop=TRUE, na_col=NULL, border_lwd=.3, zlim=c(0,1))
setMethod("transform_values", signature(x = "Quadtree", y = "function"),
  function(x, y){
    x@ptr$transformValues(y)
  }
)