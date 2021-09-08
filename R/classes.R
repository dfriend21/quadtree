#' @name Quadtree-class
#' @aliases Quadtree
#' @title Quadtree class
#' @description
#' This S4 class is a wrapper around a \code{CppQuadtree} C++ object that is
#' made available to R via the 'Rcpp' package. Instances of this class can be
#' created through the \code{\link{quadtree}()} function.
#'
#' The methods of the C++ object (\code{\link{CppQuadtree}}) can be accessed
#' from R, but the typical end-user should have no need of these methods -
#' they are meant for internal use. That being said, descriptions of the
#' available methods can be found on the \code{\link{CppQuadtree}} documentation
#' page.
#' @slot ptr a C++ object of class \code{CppQuadtree}
#' @details
#' Functions for creating a \code{Quadtree} object: \itemize{
#'   \item \code{\link{quadtree}()}
#'   \item \code{\link{read_quadtree}()}
#' }
#' Methods:
#' \itemize{
#'   \item \code{\link{as_data_frame}()}
#'   \item \code{\link{as_raster}()}
#'   \item \code{\link{as_vector}()}
#'   \item \code{\link{copy}()}
#'   \item \code{\link{extent}()}
#'   \item \code{\link{extract}()}
#'   \item \code{\link{get_neighbors}()}
#'   \item \code{\link{lcp_finder}()}
#'   \item \code{\link{n_cells}()}
#'   \item \code{\link{projection}()}
#'   \item \code{\link[=plot.Quadtree]{plot}()}
#'   \item \code{\link{set_values}()}
#'   \item \code{\link[=show.Quadtree]{show}()}
#'   \item \code{\link[=summary.Quadtree]{summary}()}
#'   \item \code{\link{transform_values}()}
#'   \item \code{\link{write_quadtree}()}
#' }
#' @export
setClass("Quadtree",
   slots = c(
     ptr = "C++Object"
   ),
   prototype = list(
     ptr = NULL
   ),
   validity = function(object)	{
     if (is.null(object@ptr) || is(object@ptr, "Rcpp_CppQuadtree")) {
       return(TRUE)
     } else {
       return(FALSE)
     }
   }
)

#' @name LcpFinder-class
#' @aliases LcpFinder
#' @title LcpFinder Class
#' @description
#' This S4 class is a wrapper around a \code{CppShortestPathFinder} C++ object
#' that is made available to R via the 'Rcpp' package. Instances of this class
#' can be created from a \code{\link{Quadtree}} object using the
#' \code{\link{lcp_finder}} function.
#'
#' The methods of the C++ object (\code{\link{CppShortestPathFinder}}) can be
#' accessed from R, but the typical end-user should have no need of these
#' methods - they are meant for internal use. That being said, descriptions of
#' the available methods can be found on the \code{\link{CppShortestPathFinder}}
#' documentation page.
#' @slot ptr a C++ object of class \code{CppShortestPathFinder}
#' @details
#' Functions for creating a \code{LcpFinder} object: \itemize{
#'   \item \code{\link{lcp_finder}()}
#' }
#' Methods: \itemize{
#'   \item \code{\link{find_lcp}()}
#'   \item \code{\link{find_lcps}()}
#'   \item \code{\link[=plot.LcpFinder]{plot}()}
#'   \item \code{\link[=show.LcpFinder]{show}()}
#'   \item \code{\link{summarize_lcps()}}
#'   \item \code{\link[=summary.LcpFinder]{summary}()}
#' }
#' @export
setClass("LcpFinder",
  slots = c(
    ptr = "C++Object"
  ),
  prototype = list(
    ptr = NULL
  ),
  validity = function(object)	{
    if (is.null(object@ptr) || is(object@ptr, "Rcpp_CppShortestPathFinder")) {
      return(TRUE)
    } else {
      return(FALSE)
    }
  }
)
