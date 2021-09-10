#' @include generics.R

#' @name projection
#' @aliases projection,Quadtree-method projection<-
#'   projection<-,Quadtree,ANY-method
#' @title Retrieve the proj4string of a \code{\link{Quadtree}}
#' @description Retrieves the proj4string of a \code{\link{Quadtree}}
#' @param x a \code{\link{Quadtree}}
#' @return a string
#' @examples 
#' library(quadtree)
#' data(habitat)
#' 
#' qt <- quadtree(habitat, .1)
#' projection(qt) <- "+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs"
#' projection(qt) 
#' @export
setMethod("projection", signature(x = "Quadtree"),
  function(x) {
    return(x@ptr$projection())
  }
)

#' @rdname projection
#' @param value character; the projection to assign to the
#'   \code{\link{Quadtree}}
#' @export
setMethod("projection<-", signature(x = "Quadtree", value = "ANY"),
  function(x, value) {
    x@ptr$setProjection(value)
    return(x)
  }
)
