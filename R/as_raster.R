#' @include generics.R

#' @name as_raster
#' @aliases as_raster,Quadtree-method
#' @title Create a raster from a \code{Quadtree}
#' @description Creates a \code{\link[raster:RasterLayer-class]{RasterLayer}}
#'   from a \code{\link{Quadtree}}.
#' @param x a \code{\link{Quadtree}}
#' @param rast a \code{\link[raster:RasterLayer-class]{RasterLayer}}; optional;
#'   this will be used as a template - the output raster will have the same
#'   extent and dimensions as this raster. If \code{NULL} (the default), a
#'   raster is automatically created, where the quadtree extent is used as the
#'   raster extent, and the size of smallest cell in the quadtree is used as
#'   the resolution of the raster.
#' @details
#' Note that the value of a raster cell is determined by the value of the
#' quadtree cell located at the centroid of the raster cell - thus, if a raster
#' cell overlaps several quadtree cells, whichever quadtree cell the centroid of
#' the raster cell falls in will determine the raster cell's value. If no value
#' is provided for the \code{rast} parameter, the raster's dimensions are
#' automatically determined from the quadtree in such a way that the cells are
#' guaranteed to line up with the quadtree cells with no overlap, thus avoiding
#' the issue.
#' @return a \code{\link[raster:RasterLayer-class]{RasterLayer}}
#' @examples
#' library(raster)
#' library(quadtree)
#' data(habitat)
#' 
#' # create a quadtree
#' qt <- quadtree(habitat, split_threshold = .1, split_method = "sd")
#'
#' rst1 <- as_raster(qt) # use the default raster
#' rst2 <- as_raster(qt, habitat) # use another raster as a template
#'
#' par(mfrow = c(2, 2))
#' plot(habitat, main = "original raster")
#' plot(qt, main = "quadtree")
#' plot(rst1, main = "raster from quadtree")
#' plot(rst2, main = "raster from quadtree")
#' @export
setMethod("as_raster", signature(x = "Quadtree"),
  function(x, rast=NULL) {
    if (is.null(rast)) {
      res <- x@ptr$root()$smallestChildSideLength()
      rast <- raster::raster(extent(x), resolution = res, crs = projection(x))
    } else {
      rast <- raster::raster(rast)
    }
    pts <- raster::rasterToPoints(rast, spatial = FALSE)
    vals <- extract(x, pts[, 1:2])
    rast[] <- vals
    return(rast)
  }
)
