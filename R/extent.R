#' @include generics.R

#' @name extent
#' @aliases extent,Quadtree-method extent.Quadtree
#' @title Get the extent of a \code{Quadtree}
#' @description Gets the extent of the \code{\link{Quadtree}} as an
#'   \code{\link[raster:Extent-class]{Extent}} object (from the raster package).
#' @param x a \code{\link{Quadtree}}
#' @param original boolean; if \code{FALSE} (the default), it returns the total
#'   extent covered by the quadtree. If \code{TRUE}, the function returns the
#'   extent of the original raster used to create the quadtree, before the
#'   dimensions were adjusted by padding with \code{NA}s and/or the raster was
#'   resampled.
#' @return an \code{\link[raster:Extent-class]{Extent}} object
#' @examples
#' library(quadtree)
#' data(habitat)
#'
#' # create a quadtree
#' qt <- quadtree(habitat, split_threshold = .1, adj_type = "expand")
#'
#' # retrieve the extent and the original extent
#' ext <- extent(qt)
#' ext_orig <- extent(qt, original = TRUE)
#'
#' ext
#' ext_orig
#'
#' # plot them
#' plot(qt)
#' rect(ext[1], ext[3], ext[2], ext[4], border = "blue", lwd = 4)
#' rect(ext_orig[1], ext_orig[3], ext_orig[2], ext_orig[4],
#'      border = "red", lwd = 4)
#' @export
setMethod("extent", signature(x = "Quadtree"),
  function(x, original = FALSE) {
    if (original) {
      return(terra::ext(x@ptr$originalExtent()))
    } else {
      return(terra::ext(x@ptr$extent()))
    }
  }
)
