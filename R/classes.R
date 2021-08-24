#' @export 
setClass("Quadtree",
   slots = c(
     ptr = "C++Object"
   ),
   prototype = list(
     ptr = NULL
   ),
   validity = function(object)	{
     if (is.null(object@ptr) || is(object@ptr, "Rcpp_CppQuadtree")){
       return(TRUE)
     } else {
       return(FALSE)
     }
   }
)

#' @export
setClass("LcpFinder",
  slots = c(
    ptr = "C++Object"
  ),
  prototype = list(
    ptr = NULL
  ),
  validity = function(object)	{
    if (is.null(object@ptr) || is(object@ptr, "Rcpp_CppShortestPathFinder")){
      return(TRUE)
    } else {
      return(FALSE)
    }
  }
)