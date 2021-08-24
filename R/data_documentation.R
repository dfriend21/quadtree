#' @name habitat
#' @aliases habitat_roads
#' @docType data
#' @title Sample raster data for the 'quadtree' package
#' @description
#' \code{habitat} is a raster containing habitat suitability values where each cell
#' takes on a value between 0 and 1. 
#' 
#' \code{habitat_roads} has the exact same footprint as 'habitat', but the values
#' represent the presence/absence of roads in that cell. 1 indicates presence,
#' while 0 indicates absence.
#' @usage 
#' data("habitat")
#' data("habitat_roads")
#' @format \code{RasterLayer} (from the 'raster' package)
#' @details
#' These rasters are included for two reasons. First, they provide the datasets
#' that are used for the code examples in the help files. Second, they provide
#' easy-to-access datasets for users to experiment with when learning how to use
#' the 'quadtree' package.
#' @examples
#' library(raster)
#' 
#' data("habitat")
#' data("habitat_roads")
#' 
#' par(mfrow=c(1,2))
#' plot(habitat)
#' plot(habitat_roads)
#' 
#' #use them to make quadtrees
#' qt1 = quadtree(habitat, .1)
#' qt2 = quadtree(habitat_roads, .1)
#' 
#' par(mfrow=c(1,2))
#' plot(qt1,crop=TRUE,na_col=NULL,border_lwd=.3)
#' plot(qt2,crop=TRUE,na_col=NULL,border_lwd=.3)
NULL