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
