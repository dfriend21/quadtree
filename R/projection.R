#' @include generics.R

#' @name projection
#' @aliases projection,Quadtree-method projection<-
#'   projection<-,Quadtree,ANY-method
#' @title Retrieve the proj4string of a quadtree
#' @param x a \code{\link{Quadtree}} object
#' @return A character containing the proj4string
#' @export
setMethod("projection", signature(x = "Quadtree"),
  function(x) {
    return(x@ptr$projection())
  }
)

#' @rdname projection
#' @param value character; the projection to assign to the quadtree
#' @export
setMethod("projection<-", signature(x = "Quadtree", value = "ANY"),
  function(x, value) {
    x@ptr$setProjection(value)
    return(x)
  }
)
