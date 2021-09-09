#' @name CppNode-class
#' @aliases CppNode Rcpp_CppNode Rcpp_CppNode-class
#' @title \code{CppNode}: C++ quadtree node
#' @description The \code{CppNode} class defines objects that represent a single
#'   node of a quadtree. This is used internally - end users should have no need
#'   to use any of the methods listed here.
#' @details This class is defined in 'src/NodeWrapper.h' and
#'   'src/NodeWrapper.cpp'. When made available to R, it is exposed as
#'   \code{CppNode} instead of \code{NodeWrapper}. \code{NodeWrapper} contains a
#'   pointer to a \code{Node} object (defined in 'src/Node.h' and
#'   'src/Node.cpp'). All of the core functionality is in the \code{Node} class
#'   - \code{NodeWrapper} is a wrapper class that adds the Rcpp code required
#'   for it to be accessible from R.
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
#'   each node - see the documentation of that function for details on what each
#'   column represents
#' }
#' @field getChildren \itemize{
#'   \item \strong{Description}: Returns a \code{list} of the child nodes
#'   \item \strong{Parameters}: none
#'   \item \strong{Returns}: a \code{list} of \code{CppNode} objects
#' }
#' @field getNeighborIds \itemize{
#'   \item \strong{Description}: Returns the IDs of the neighboring cells
#'   \item \strong{Parameters}: none
#'   \item \strong{Returns}: a numeric vector containing the neighbor IDs
#' }
#' @field getNeighborInfo \itemize{
#'   \item \strong{Description}: Returns a matrix with info on each of the
#'   neighboring cells
#'   \item \strong{Parameters}: none
#'   \item \strong{Returns}: a matrix. The \code{getNbList()} member function
#'   of \code{\link{CppQuadtree}} makes use of this function - see documentation
#'   of that function for details on the return matrix.
#' }
#' @field getNeighborVals \itemize{
#'   \item \strong{Description}: Returns the values of all neighboring cells
#'   \item \strong{Parameters}: none
#'   \item \strong{Returns}: a numeric vector
#' }
#' @field getNeighbors \itemize{
#'   \item \strong{Description}: Returns a \code{list} of the neighboring nodes
#'   \item \strong{Parameters}: none
#'   \item \strong{Returns}: a \code{list} of \code{CppNode} objects
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
