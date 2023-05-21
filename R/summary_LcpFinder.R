#' @include generics.R

#' @name summary.LcpFinder
#' @aliases summary,LcpFinder-method show.LcpFinder show,LcpFinder-method
#' @title Show a summary of a \code{LcpFinder}
#' @param object a \code{\link{LcpFinder}}
#' @description Prints out information about the \code{\link{LcpFinder}}.
#'   Information shown is:
#' \itemize{
#'   \item class of object
#'   \item start point
#'   \item search limits
#'   \item number of paths found
#' }
#' @return no return value
#' @examples
#' library(quadtree)
#' habitat <- terra::rast(system.file("extdata", "habitat.tif", package="quadtree"))
#'
#' qt <- quadtree(habitat, .1)
#'
#' start_point <- c(6989, 34007)
#' end_point <- c(33015, 38162)
#'
#' lcpf <- lcp_finder(qt, start_point)
#' lcp <- find_lcp(lcpf, end_point)
#'
#' summary(lcpf)
#' @export
setMethod("summary", signature(object = "LcpFinder"),
  function(object) {
    lcp_sum <- summarize_lcps(object)
    ext <- object@ptr$getSearchLimits()
    sp <- object@ptr$getStartPoint()
    cat("class            : LcpFinder\n",
        "start point      : (", sp[1], ", ", sp[2], ")\n",
        "search limits    : ", ext[1], ", ", ext[2], ", ", ext[3], ", ", ext[4], " (xmin, xmax, ymin, ymax)\n",
        "# of paths found : ", nrow(lcp_sum), sep = "")
  }
)

#' @rdname summary.LcpFinder
#' @export
setMethod("show", signature(object = "LcpFinder"),
  function(object) {
    summary(object)
  }
)
