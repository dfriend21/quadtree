#' @include generics.R

#' @name read_quadtree
#' @aliases write_quadtree read_quadtree,character-method
#'   write_quadtree,character-method
#' @title Read/write a \code{\link{Quadtree}}
#' @description Read/write a \code{\link{Quadtree}}
#' @param x character; the filepath to read from or write to
#' @param y a \code{\link{Quadtree}}
#' @details
#' To read/write a quadtree object, the C++ library \code{cereal} is used to
#' serialize the quadtree and save it to a file. The file extension is
#' unimportant - it can be anything (I've been using the extension '.qtree').
#' @return 
#' \code{read_quadtree()} - returns a \code{\link{Quadtree}}
#' 
#' \code{write_quadtree()} - no return value
#' @examples
#' \dontrun{
#' library(quadtree)
#' data(habitat)
#'
#' qt1 <- quadtree(habitat, .1)
#' write_quadtree(qt1, "path/to/quadtree.qtree")
#' qt2 <- read_quadtree("path/to/quadtree.qtree")
#' }
NULL

#' @rdname read_quadtree
#' @export
setMethod("read_quadtree", signature(x = "character"),
  function(x) {
    qt <- new("Quadtree")
    qt@ptr <- readQuadtreeCpp(x)
    return(qt)
  }
)

#' @rdname read_quadtree
#' @export
setMethod("write_quadtree", signature(x = "character", y = "Quadtree"),
  function(x, y) {
    writeQuadtreeCpp(y@ptr, x)
  }
)
