#' @import methods Rcpp
#' @importFrom graphics plot points lines matplot
#' @importFrom stats reshape
# @importFrom raster extract extent projection projection<-

#' @name quadtree-package
#' @docType package
#' @useDynLib quadtree, .registration = TRUE
#' @title Quadtree Representation of Rasters
#' @description
#' This package provides functionality for working with raster-like quadtrees
#' (also called “region quadtrees”), which allow for variable-sized cells. The
#' package allows for flexibility in the quadtree creation process.  Several
#' functions defining how to split and aggregate cells are provided, and custom
#' functions can be written for both of these processes. In addition, quadtrees
#' can be created using other quadtrees as “templates”, so that the new
#' quadtree's structure is identical to the template quadtree. The package also
#' includes functionality for modifying quadtrees, querying values, saving
#' quadtrees to a file, and calculating least-cost paths using the quadtree as a
#' resistance surface.
#'
#' Vignettes are included that demonstrate the functionality contained in the
#' package - these are intended to serve as an introduction to using the
#' \code{quadtree} package. You can see the available vignettes by running
#' \code{vignette(package = "quadtree")} and view individual vignettes using
#' \code{vignette("vignette-name", package = "quadtree")}.
#'
#' I'd recommend reading the vignettes in the following order: \enumerate{
#'   \item \code{"quadtree-creation"}
#'   \item \code{"quadtree-usage"}
#'   \item \code{"quadtree-lcp"}
#' }
#'
#' A fourth vignette called "quadtree-code" is also available. This briefly
#' discusses the structure of the package. It is not necessary for using the
#' package but may be useful for those who want more details about the code.
NULL
