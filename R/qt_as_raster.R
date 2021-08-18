#' @title Create a Raster from a Quadtree
#' @description Creates a raster from a quadtree
#' @param quadtree The \code{quadtree} object to create the raster from
#' @param rast A \code{RasterLayer} object; optional; this will be used as a
#' template - the output raster will have the same extent and dimensions as this
#' raster. If \code{NULL} (the default), a raster is automatically created, where
#' the quadtree extent is used as the raster extent, and the smallest cell in the
#' quadtree is used to determine the resolution of the raster.
#' @details
#' Note that the value of a raster cell is determined by the value of the
#' quadtree cell located at the centroid of the raster cell - thus, if a raster
#' cell overlaps several quadtree cells, whichever quadtree cell the centroid of
#' the raster cell falls in will determine the raster cell's value. If no value
#' is provided for the \code{rast} parameter, the raster's dimensions are
#' automatically determined from the quadtree in such a way that the cells are
#' guaranteed to line up with the quadtree cells with no overlap, thus avoiding 
#' the issue.
#' @return a \code{RasterLayer} object
#' @examples
#' library(raster)
#' data(habitat)
#' rast = habitat
#' 
#' # create a quadtree
#' qt = qt_create(rast, split_threshold = .1, split_method = "sd")
#' 
#' rst1 = qt_as_raster(qt) #use the default raster
#' rst2 = qt_as_raster(qt, habitat) #use another raster as a template
#' 
#' par(mfrow=c(2,2))
#' plot(habitat, main="original raster")
#' qt_plot(qt, main="quadtree")
#' plot(rst1, main="raster from quadtree")
#' plot(rst2, main="raster from quadtree")
qt_as_raster = function(quadtree, rast=NULL){
  if(is.null(rast)){
    res = quadtree$root()$smallestChildSideLength()
    rast = raster::raster(qt_extent(quadtree), resolution=res, crs=qt_proj4string(quadtree))
  } else {
    rast = raster::raster(rast)
  }
  pts = raster::rasterToPoints(rast,spatial=FALSE)
  vals = qt_extract(quadtree, pts[,1:2])
  rast[] = vals
  return(rast)
}