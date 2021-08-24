#' @include generics.R

#' @name read_quadtree
#' @aliases write_quadtree read_quadtree,character-method
#'   write_quadtree,character-method
#' @title Read/write a quadtree
#' @description Read/write a quadtree
#' @param x character; the filepath to read from or write to
#' @param y quadtree object; the quadtree to write
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
#' qt = read_quadtree("path/to/quadtree.qtree")
#' write_quadtree(qt, "path/to/newQuadtree.qtree")
#' }
NULL

#' @rdname read_quadtree
#' @export
setMethod("read_quadtree", signature(x = "character"),
  function(x){
    qt = new("Quadtree")
    qt@ptr = readQuadtreeCpp(x)
    return(qt)
  }
)

#' @rdname read_quadtree
#' @export
setMethod("write_quadtree", signature(x = "character", y = "Quadtree"),
  function(x, y){
    writeQuadtreeCpp(y@ptr,x)
  }
)