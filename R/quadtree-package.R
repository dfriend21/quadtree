#' @import methods Rcpp
#' @importFrom graphics plot points lines matplot
#' @importFrom stats reshape
#' @importFrom raster extract extent projection projection<-

#' @name quadtree-package
#' @docType package
#' @useDynLib quadtree, .registration = TRUE
#' @title Quadtree Representation of Rasters
#' @description
#'  Provides a C++ implementation of a quadtree data
#'  structure. Functions are provided for creating a quadtree
#'  from a raster, with the level of "coarseness" of the
#'  quadtree being determined by a user-supplied parameter. In
#'  addition, functions are provided to extract values of the
#'  quadtree at point locations. Functions for calculating
#'  least-cost paths between two points are also provided.
#' @details
#'  To get an understanding of the most important aspects of the package, read
#'  the following:
#'    \enumerate{
#'      \item For details on how a quadtree is constructed, see
#'      \code{\link{quadtree}}.
#'      \item  For details on the least-cost path functionality, see
#'      \code{\link{lcp_finder}}.
#'    }
NULL

#  Function summary:
#
#  \code{\link{quadtree}}: create a quadtree from a raster
#
#  \code{\link{extent}}: get the extent of a quadtree
#
#  \code{\link{extract}}: extract values from the quadtree at point locations
#
#  \code{\link{lcp_finder}}, \code{\link{qt_find_lcp}}: find the LCP between two points using the quadtree as a cost surface
#
#  \code{\link{qt_plot}}: plot a quadtree
#
#  \code{\link{qt_proj4string}}: get the proj4string of a quadtree
#
#  \code{\link{qt_read}}, \code{\link{qt_write}}: read and write a quadtree object to a file
