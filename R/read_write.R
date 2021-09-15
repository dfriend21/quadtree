#' @include generics.R

#' @name read_quadtree
#' @aliases write_quadtree read_quadtree,character-method
#'   write_quadtree,character-method
#' @title Read/write a \code{Quadtree}
#' @description Reads and writes a \code{\link{Quadtree}}.
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
#' library(quadtree)
#' data(habitat)
#'
#' qt <- quadtree(habitat, .1)
#' 
#' path <- tempfile(fileext = "qtree")
#' write_quadtree(path, qt)
#' qt2 <- read_quadtree(path)
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
