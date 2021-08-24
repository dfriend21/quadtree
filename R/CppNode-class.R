#' @name CppNode-class
#' @aliases CppNode Rcpp_CppNode Rcpp_CppNode-class
#' @title C++ Quadtree Node
#' @description The 'CppNode' is a C++ class represents a single quadtree node.
#' This is used internally - end users should have no need to use any of the 
#' methods listed here.
#' @field asVector \itemize{
#'   \item \strong{Description}: Returns a vector giving info about the node
#'   \item \strong{Parameters}: none
#'   \item \strong{Returns}: a numeric vector with the following named elements:
#'   \itemize{
#'     \item{\code{id}}
#'     \item{\code{hasChdn}}
#'     \item{\code{level}}
#'     \item{\code{xMin}}
#'     \item{\code{xMax}}
#'     \item{\code{yMin}}
#'     \item{\code{yMax}}
#'     \item{\code{smSide}}
#'   }
#'   \code{\link{as_data_frame}} makes use of this function to output info on
#'   each node - see the documentation of that function for details on the
#'   output
#' }
#' @field getChildren \itemize{
#'   \item \strong{Description}: Returns a \code{list} of the child nodes
#'   \item \strong{Parameters}: none
#'   \item \strong{Returns}: a \code{list} of \code{Rcpp_node} objects
#' }
#' @field getNeighborIds \itemize{
#'   \item \strong{Description}: Returns the IDs of the neighboring cells
#'   \item \strong{Parameters}: none
#'   \item \strong{Returns}: a numeric vector
#' }
#' @field getNeighborInfo \itemize{
#'   \item \strong{Description}: Returns a matrix with info on each of the 
#'   neighboring cells
#'   \item \strong{Parameters}: none
#'   \item \strong{Returns}: a matrix. \code{quadtree$getNbList()} makes
#'   use of this function - see documentation of that function (by running
#'   \code{?'quadtree-class'}) for details on the return matrix.
#' }
#' @field getNeighborVals \itemize{
#'   \item \strong{Description}: Returns the values of all neighboring cells
#'   \item \strong{Parameters}: none
#'   \item \strong{Returns}: a numeric vector
#' }
#' @field getNeighbors \itemize{
#'   \item \strong{Description}: Returns a \code{list} of the neighboring nodes
#'   \item \strong{Parameters}: none
#'   \item \strong{Returns}: a \code{list} of \code{Rcpp_node} objects
#' }
#' @field hasChildren \itemize{
#'   \item \strong{Description}: Returns a boolean representing whether the node
#'   has children
#'   \item \strong{Parameters}: none
#'   \item \strong{Returns}: a boolean value - \code{TRUE} if it has children,
#'   \code{FALSE} otherwise
#' }
#' @field id \itemize{
#'   \item \strong{Description}: Returns the ID of this node
#'   \item \strong{Parameters}: none
#'   \item \strong{Returns}: an integer
#' }
#' @field level \itemize{
#'   \item \strong{Description}: Returns the 'level' (i.e. depth in the tree) of
#'   this node
#'   \item \strong{Parameters}: none
#'   \item \strong{Returns}: an integer
#' }
#' @field smallestChildSideLength \itemize{
#'   \item \strong{Description}: Returns the side length of the smallest
#'   descendant node
#'   \item \strong{Parameters}: none
#'   \item \strong{Returns}: a double
#' }
#' @field value \itemize{
#'   \item \strong{Description}: Returns the value of the node
#'   \item \strong{Parameters}: none
#'   \item \strong{Returns}: a double
#' }
#' @field xLims \itemize{
#'   \item \strong{Description}: Returns the x boundaries of the node
#'   \item \strong{Parameters}: none
#'   \item \strong{Returns}: 2-element numeric vector (xMin, xMax)
#' }
#' @field yLims \itemize{
#'   \item \strong{Description}: Returns the y boundaries of the node
#'   \item \strong{Parameters}: none
#'   \item \strong{Returns}: 2-element numeric vector (yMin, yMax)
#' }
NULL