# as foreign objects

#' Convert to other R spatial objects
#'
#' @param x Quadtree object
#'
#' @return an object of class `sf` or `SpatVector`, or a Well-Known Text (WKT) `character` representation
#' @export
#'
#' @rdname as-foreign
as_sf <- function(x) {
  if (!requireNamespace("sf")) {
    stop("package 'sf' is required to convert Quadtree to sf", call. = FALSE)
  }
  sf::st_as_sf(data.frame(geometry = sf::st_as_sfc(as_character(x))), crs = projection(x))
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
  y <- as_data_frame(x)
  sprintf("POLYGON ((%s %s, %s %s, %s %s, %s %s, %s %s))",
                    y$xmin, y$ymin, 
                    y$xmin, y$ymax,
                    y$xmax, y$ymax,
                    y$xmax, y$ymin,
                    y$xmin, y$ymin)
}

# create as(x, 'foo') coercion methods
setAs("Quadtree", "sf", function(from) as_sf(from))
setAs("Quadtree", "SpatVector",  function(from) as_vect(from))
setAs("Quadtree", "character", function(from) as_character(from))