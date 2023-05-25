#' @name habitat
#' @aliases habitat_roads
#' @docType data
#' @title Sample raster data for the \code{quadtree} package
#' @description
#' \code{habitat.tif} is a raster containing habitat suitability values where each cell
#' takes on a value between 0 and 1.
#'
#' \code{habitat_roads.tif} is a raster with the exact same footprint as 'habitat.tif',
#' but the values represent the presence/absence of roads in that cell. 1 indicates
#' presence, while 0 indicates absence.
#' @format GeoTIFF
#' @details
#' These rasters are included for two reasons. First, they provide the datasets
#' that are used for the code examples in the help files and the vignettes.
#' Second, they provide easy-to-access datasets for users to experiment with
#' when learning how to use the \code{quadtree} package.
#' @examples
#' library(quadtree)
#' habitat <- terra::rast(system.file("extdata", "habitat.tif", package="quadtree"))
#' habitat_roads <- terra::rast(system.file("extdata", "habitat_roads.tif", package="quadtree"))
#'
#' old_par <- par(mfrow = c(1, 2))
#' plot(habitat)
#' plot(habitat_roads)
#'
#' qt1 <- quadtree(habitat, .1)
#' qt2 <- quadtree(habitat_roads, .1)
#'
#' plot(qt1, crop = TRUE, na_col = NULL, border_lwd = .3)
#' plot(qt2, crop = TRUE, na_col = NULL, border_lwd = .3)
#' 
#' par(old_par)
NULL
