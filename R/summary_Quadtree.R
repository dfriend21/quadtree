#' @include generics.R

#' @name summary.Quadtree
#' @aliases summary,Quadtree-method show.Quadtree show,Quadtree-method
#' @title Show a summary of a \code{Quadtree}
#' @param object a \code{\link{Quadtree}} object
#' @description Prints out information about a \code{\link{Quadtree}}.
#'   Information shown is:
#' \itemize{
#'   \item class of object
#'   \item number of cells
#'   \item minimum cell size
#'   \item extent
#'   \item projection
#'   \item minimum and maximum values
#' }
#' @return no return value
#' @examples
#' library(quadtree)
#' habitat <- terra::rast(system.file("extdata", "habitat.tif", package="quadtree"))
#'
#' qt <- quadtree(habitat, .1)
#' summary(qt)
#' @export
setMethod("summary", signature(object = "Quadtree"),
  function(object) {
    e <- extent(object)
    proj <- projection(object)
    vals <- as_vector(object)
    if (proj == "") proj <- "NA"
    cat("class         : Quadtree\n",
        "# of cells    : ", n_cells(object, terminal_only = TRUE), "\n",
        "min cell size : ", object@ptr$root()$smallestChildSideLength(), "\n",
        "extent        : ", e[1], ", ", e[2], ", ", e[3], ", ", e[4], " (xmin, xmax, ymin, ymax)\n",
        "crs           : ", proj, "\n",
        "values        : ", min(vals, na.rm = TRUE), ", ", max(vals, na.rm = TRUE), " (min, max)", sep = "")
  }
)

#' @rdname summary.Quadtree
#' @export
setMethod("show", signature(object = "Quadtree"),
  function(object) {
    summary(object)
  }
)
