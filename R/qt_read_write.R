#' @name qt_read
#' @rdname qt_read
#' 
#' @title Read/write a quadtree
#' @description Read/write a quadtree
#' @param filepath character; the filepath to read from or write to
#' @param quadtree quadtree object; the quadtree to write
#' @details
#' To read/write a quadtree object, the C++ library \code{cereal} is used to
#' serialize the quadtree and save it to a file. The file extension is
#' unimportant - it can be anything (I've been using the extension '.qtree').
#' 
#' Note that typically the quadtree isn't particularly space-efficient - it's
#' not uncommon for a quadtree file to be larger than the original raster file
#' (although, of course, this depends on how 'coarse' the quadtree is in
#' relation to the original raster). This is likely because the quadtree has to
#' store much more information about each cell (the x and y limits, its value,
#' pointers to its neighbors, among other things) while a raster can store only
#' the value since the coordinates of the cell can be determined from the
#' knowledge of the extent and the dimensions of the raster.
#' 
#' It's entirely possible that a quadtree implemention could be written that
#' is MUCH more space efficient. However, this was not the primary goal when 
#' creating this package.
#' @examples 
#' \dontrun{
#' qt = qt_read("path/to/quadtree.qtree")
#' qt_write(qt, "path/to/newQuadtree.qtree")
#' }
NULL

#' @rdname qt_read
#' @export
qt_read = function(filepath){
  return(readQuadtree(filepath))
}

#' @rdname qt_read
#' @export
qt_write = function(quadtree, filepath){
  if(!inherits(quadtree, "Rcpp_quadtree")) stop("'quadtree' must be a quadtree object (i.e. have class 'Rcpp_quadtree')")
  quadtree$writeQuadtree(filepath)
}