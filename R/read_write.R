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

#' @name write_quadtree_ptr
#' @aliases write_quadtree_ptr,character,Quadtree-method
#' @title Read/write a \code{Quadtree}
#' @description This is for debugging only, and users should never need to use
#'   this function - use \code{\link{write_quadtree}()} instead.
#'   \code{\link{write_quadtree}()} serializes the \code{CppQuadtree} object
#'   (note that the underlying C++ object is actually called
#'   \code{QuadtreeWrapper}, but it is exposed to R as \code{CppQuadtree}) stored
#'   in the \code{ptr} slot of \code{\link{Quadtree}}.
#'
#'   This function, however, serializes only the \code{Quadtree} object contained by the
#'   \code{QuadtreeWrapper}.
#' @param x character; the filepath to read from or write to
#' @param y a \code{\link{Quadtree}}
#' @return
#' no return value
#' @examples
#' library(quadtree)
#' data(habitat)
#'
#' qt <- quadtree(habitat, .1)
#'
#' path <- tempfile(fileext = "qtree")
#' write_quadtree_ptr(path, qt)
#' @export
setMethod("write_quadtree_ptr", signature(x = "character", y = "Quadtree"),
  function(x, y) {
    writeQuadtreePtr(y@ptr, x)
  }
)
