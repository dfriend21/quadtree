#' Retrieve the proj4string of a quadtree
#' @param qt a quadtree object
#' @return A character containing the proj4string
setMethod("proj4string", signature(qt = "quadtree"),
  function(qt){
    return(qt@ptr$projection())
  }
)