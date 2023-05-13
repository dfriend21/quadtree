# as foreign objects

# returns a list with two elements:
#   wkt -> character representing the WKT representation of the polygons
#   vals -> numeric vector with the corresponding values
as_wkt_list <- function(x){
  y <- as_data_frame(x)
  wkt <- sprintf("POLYGON ((%s %s, %s %s, %s %s, %s %s, %s %s))",
          y$xmin, y$ymin, 
          y$xmin, y$ymax,
          y$xmax, y$ymax,
          y$xmax, y$ymin,
          y$xmin, y$ymin)
  vals <- y$value
  return(list(wkt = wkt, vals = vals))
}

#' Convert to other R spatial objects
#'
#' @param x Quadtree object
#'
#' @return an object of class \code{sf} or \code{SpatVector}, or a Well-Known Text (WKT)
#'   \code{character} representation
#' @examples
#' library(quadtree)
#' data(habitat)
#' 
#' qt <- quadtree(habitat, .1)
#' sf <- as(qt, "sf")
#' v <- as(qt, "SpatVector")
#' ch <- as(qt, "character")
#' @export
#' @rdname as-foreign
as_sf <- function(x) {
  if (!requireNamespace("sf")) {
    stop("package 'sf' is required to convert Quadtree to sf", call. = FALSE)
  }
  lst <- as_wkt_list(x)
  v <- sf::st_as_sf(data.frame(value = lst$vals, geometry = sf::st_as_sfc(lst$wkt)), crs = projection(x))
  return(v)
}

#' @export
#' @rdname as-foreign
as_vect <- function(x) {
  if (!requireNamespace("terra")) {
    stop("package 'terra' is required to convert Quadtree to SpatVector", call. = FALSE)
  }
  lst <- as_wkt_list(x)
  v <- terra::vect(lst$wkt, crs = projection(x))
  values(v) <- data.frame(value = lst$vals)
  return(v)
}

#' @export
#' @rdname as-foreign
as_character <- function(x) {
  lst <- as_wkt_list(x)
  return(lst$wkt)
}

# create as(x, 'foo') coercion methods
setAs("Quadtree", "sf", function(from) as_sf(from))
setAs("Quadtree", "SpatVector",  function(from) as_vect(from))
setAs("Quadtree", "character", function(from) as_character(from))