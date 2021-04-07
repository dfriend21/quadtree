#' Retrieve the proj4string of a quadtree
#' @param quadtree a quadtree object
#' @return A character containing the proj4string
qt_proj4string <- function(quadtree){
  return(quadtree$projection())
}