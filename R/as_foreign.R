# as foreign objects

#' Convert to other R spatial objects
#'
#' @param x Quadtree object
#' @param ... not used
#'
#' @return an object of class `sf` or `SpatVector`
#' @export
#'
#' @rdname as-foreign
as_sf <- function(x) {
  if (!requireNamespace("sf")) {
    stop("package 'sf' is required to convert Quadtree to sf", call. = FALSE)
  }
  sf::st_as_sf(as_character(x), crs = projection(x))
}

#' @export
#' @rdname as-foreign
as_vect <- function(x) {
  if (!requireNamespace("terra")) {
    stop("package 'terra' is required to convert Quadtree to SpatVector", call. = FALSE)
  }
  terra::vect(as_character(x), crs = projection(x))
}

#' @export
#' @rdname as-foreign
as_character <- function(x) {
  dt <- as_data_frame(x)
  sprintf("POLYGON ((%s %s, %s %s, %s %s, %s %s, %s %s))",
                      dt$xmin, dt$ymin, 
                      dt$xmin, dt$ymax,
                      dt$xmax, dt$ymax,
                      dt$xmax, dt$ymin,
                      dt$xmin, dt$ymin,
              crs = projection(qt))
}

# create as(x, 'foo') coercion methods
setAs("Quadtree", "sf",  as_sf)
setAs("Quadtree", "SpatVector",  as_vect)
setAs("Quadtree", "character", as_character)