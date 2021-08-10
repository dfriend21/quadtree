#' Retrieve the proj4string of a quadtree
#' @param quadtree a quadtree object
#' @return A character containing the proj4string
qt_proj4string <- function(quadtree){
  if(!inherits(quadtree, "Rcpp_quadtree")) stop("'quadtree' must be a quadtree object (i.e. have class 'Rcpp_quadtree')")
  return(quadtree$projection())
}