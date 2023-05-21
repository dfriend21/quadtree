# as foreign objects

# x Quadtree object
# returns a list with two elements:
#   wkt -> character representing the WKT representation of the polygons
#   vals -> numeric vector with the corresponding values
#   crs  -> WKT2019 string with CRS information of WKT polygons
as_wkt_list <- function(x) {
  y <- as_data_frame(x)
  wkt <- sprintf("POLYGON ((%s %s, %s %s, %s %s, %s %s, %s %s))",
          y$xmin, y$ymin, 
          y$xmin, y$ymax,
          y$xmax, y$ymax,
          y$xmax, y$ymin,
          y$xmin, y$ymin)
  vals <- y$value
  return(list(wkt = wkt, vals = vals, crs = projection(x)))
}

#' Convert to other R spatial objects
#'
#' @param x Quadtree object
#'
#' @return an object of class \code{sf} or \code{SpatVector}, or a Well-Known Text (WKT) \code{character} representation
#' 
#' @examplesIf all(sapply(c("sf"), function(x) !inherits(try(requireNamespace(x, quietly=TRUE), silent=TRUE), 'try-error')))
#' @examples
#' library(quadtree)
#' habitat <- rast(system.file("extdata", "habitat.tif", package="quadtree"))
#' 
#' qt <- quadtree(habitat, .1)
#' sf <- as(qt, "sf")
#' sr <- as(qt, "SpatRaster")
#' sv <- as(qt, "SpatVector")
#' ch <- as(qt, "character")
#' @export
#' @rdname as-foreign
as_sf <- function(x) {
  if (!requireNamespace("sf")) {
    stop("package 'sf' is required to convert Quadtree to sf", call. = FALSE)
  }
  lst <- as_wkt_list(x)
  v <- sf::st_as_sf(data.frame(value = lst$vals, 
                               geometry = sf::st_as_sfc(lst$wkt)), 
                    crs = lst$crs)
  return(v)
}

#' @export
#' @rdname as-foreign
as_vect <- function(x) {
  if (!requireNamespace("terra")) {
    stop("package 'terra' is required to convert Quadtree to SpatVector", call. = FALSE)
  }
  lst <- as_wkt_list(x)
  v <- terra::vect(data.frame(value = lst$vals, 
                              geometry = lst$wkt), 
                   geom = "geometry",
                   crs = lst$crs)
  return(v)
}

#' @export
#' @rdname as-foreign
as_character <- function(x) {
  lst <- as_wkt_list(x)
  attr(lst$wkt, 'crs') <- lst$crs
  return(lst$wkt)
}

# create as(x, 'foo') coercion methods
setAs("Quadtree", "vector", function(from) quadtree::as_vector(from))
setAs("Quadtree", "SpatRaster", function(from) quadtree::as_raster(from))
setAs("Quadtree", "data.frame", function(from) quadtree::as_data_frame(from))
setAs("Quadtree", "sf", function(from) quadtree::as_sf(from))
setAs("Quadtree", "SpatVector",  function(from) quadtree::as_vect(from))
setAs("Quadtree", "character", function(from) quadtree::as_character(from))
