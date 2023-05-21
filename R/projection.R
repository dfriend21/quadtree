#' @include generics.R

#' @name projection
#' @aliases projection,Quadtree-method projection<-
#'   projection<-,Quadtree,ANY-method
#' @title Retrieve the proj4string of a \code{Quadtree}
#' @description Retrieves the proj4string of a \code{\link{Quadtree}}.
#' @param x a \code{\link{Quadtree}}
#' @return a string
#' @examples
#' library(quadtree)
#' habitat <- terra::rast(system.file("extdata", "habitat.tif", package="quadtree"))
#'
#' qt <- quadtree(habitat, .1)
#' quadtree::projection(qt) <- "+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs"
#' quadtree::projection(qt)
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
