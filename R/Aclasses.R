setClass("quadtree",
   slots = c(
     ptr = "C++Object"
   ),
   prototype = list(
     ptr = NULL
   ),
   validity = function(object)	{
     if (is.null(object@ptr) || is(object@ptr, "Rcpp_quadtree")){
       return(TRUE)
     } else {
       return(FALSE)
     }
   }
)

setClass("lcp_finder",
  slots = c(
    ptr = "C++Object"
  ),
  prototype = list(
    ptr = NULL
  ),
  validity = function(object)	{
    if (is.null(object@ptr) || is(object@ptr, "Rcpp_shortestPathFinder")){
      return(TRUE)
    } else {
      return(FALSE)
    }
  }
)