#' @name quadtree-class
#' @aliases Rcpp_quadtree readQuadtree
#' @title \code{quadtree}: C++ quadtree data structure
#' @description 
#'   The \code{Rcpp_quadtree} class is the underlying C++ data structure used
#'   in the \code{quadtree} package. Note that the average user should not need
#'   to use these functions - the functions prefixed with 'qt_' are R wrapper 
#'   functions that provide access to the many of the member functions.
#' @details 
#'   Note that the name of the class as it is defined is actually
#'   'QuadtreeWrapper', but it is exposed to R simply as 'quadtree'. Thus, all
#'   the code is in 'QuadtreeWrapper.h' and QuadtreeWrapper.cpp'. As the name
#'   suggests 'QuadtreeWrapper' is a wrapper for the 'Quadtree' class. The
#'   'Quadtree' class was written to be completely independent of R and Rcpp,
#'   and thus operates as a stand-alone C++ class. 'QuadtreeWrapper' contains an
#'   instance of a 'Quadtree' object and contains the code necessary to
#'   interface between R and C++.
#' @field asList \itemize{
#'   \item Description: outputs a list containing details about each cell
#'   \item Parameters: none
#'   \item Returns: a \code{list} of named numeric vectors. Each numeric vector
#'   provides information on a single cell. The elements returned are:
#'   \itemize{
#'     \item \code{id}: the id of the cell
#'     \item \code{hasChdn}: 1 if the cell has children, 0 otherwise
#'     \item \code{level}: integer; the depth of this cell/node in the quadtree,
#'     where the root of the quadtree is considered to be level 0
#'     \item \code{xMin}, \code{xMax}, \code{yMin}, \code{yMax}: the x and y
#'     limits of the cell
#'     \item \code{value}: the value of the cell
#'     \item \code{smSide}: the smallest cell length among all of this cells
#'     descendants
#'     \item \code{parentID}: the ID of the cell's parent. The root, which has
#'     no parent, has a value of -1 for this element
#'   }
#'   It may be desirable to have this information as a data frame - this can done
#'   with the following line of code: \code{do.call(rbind,qt$asList())}
#' }
#' @field copy \itemize{
#'   \item Description: returns a deep copy of a quadtree. \code{qt_copy} is a
#'   wrapper for this function - see \code{?qt_copy} for more
#'   \item Parameters: none
#'   \item Returns: a quadtree object
#' }
#' @field createTree \itemize{
#'   \item Description: constructs the quadtree from a matrix. \code{qt_create}
#'   is a wrapper for this function and should be used to create quadtrees. The
#'   parameters correspond with the similarly named parameters in
#'   \code{qt_create} - see the documentation of that function for details on
#'   the parameters
#'   \item Parameters: \itemize{
#'     \item \code{mat}: matrix; data to be used to create the quadtree
#'     \item \code{splitMethod}: string
#'     \item \code{splitThreshold}: double
#'     \item \code{splitFun}: function
#'     \item \code{splitArgs}: list
#'     \item \code{combineFun}: function
#'     \item \code{combineArgs}: list
#'     \item \code{templateQuadtree}: quadtree
#'   }
#'   \item Returns: void - no return value
#' }
#' @field extent \itemize{
#'   \item Description: returns the extent of the quadtree. This is equivalent
#'   to \code{qt_extent(qt,original=FALSE)}
#'   \item Parameters: none
#'   \item Returns: 4-element numeric vector, in this order: xMin, xMax, yMin,
#'   yMax
#' }
#' @field getCell \itemize{
#'   \item Description: Given the x and y coordinates of a point, returns the 
#'   cell at that point (as a 'Rcpp_node' object)
#'   \item Parameters: \itemize{
#'     \item \code{x}: double; x coordinate
#'     \item \code{y}: double; y coordinate
#'   }
#'   \item Returns: a 'Rcpp_node' object representing the cell that contains
#'   the point
#' }
#' @field getCellDetails \itemize{
#'   \item Description: Given points defined by their x and y coordinates,
#'   returns a matrix giving details on the cells at each of the points. 
#'   \code{qt_extract(qt,extents=TRUE)} is a wrapper for this function.
#'   \item Parameters: \itemize{
#'     \item \code{x}: numeric vector; the x coordinates
#'     \item \code{y}: numeric vector; the y coordinates; must be the same
#'     length as x
#'   }
#'   \item Returns: A matrix with the cell details. See ?qt_extract for details
#'   about the matrix structure
#' }
#' @field getCells \itemize{
#'   \item Description: Given x and y coordinates of points, returns a list
#'   of the cells at those points (as 'Rcpp_node' objects)
#'   \item Parameters: 
#'   \item Returns:
#' }
#' @field getNbList \itemize{
#'   \item Parameters:
#'   \item Returns:
#' }
#' @field getShortestPathFinder \itemize{
#'   \item Parameters:
#'   \item Returns:
#' }
#' @field getValues \itemize{
#'   \item Parameters:
#'   \item Returns:
#' }
#' @field maxCellDims \itemize{
#'   \item Parameters:
#'   \item Returns:
#' }
#' @field nNodes \itemize{
#'   \item Parameters:
#'   \item Returns:
#' }
#' @field originalDim \itemize{
#'   \item Parameters:
#'   \item Returns:
#' }
#' @field originalExtent \itemize{
#'   \item Parameters:
#'   \item Returns:
#' }
#' @field originalRes \itemize{
#'   \item Parameters:
#'   \item Returns:
#' }
#' @field print \itemize{
#'   \item Parameters:
#'   \item Returns:
#' }
#' @field projection \itemize{
#'   \item Parameters:
#'   \item Returns:
#' }
#' @field root \itemize{
#'   \item Parameters:
#'   \item Returns:
#' }
#' @field setOriginalValues \itemize{
#'   \item Parameters:
#'   \item Returns:
#' }
#' @field setProjection \itemize{
#'   \item Parameters:
#'   \item Returns:
#' }
#' @field setValues \itemize{
#'   \item Parameters:
#'   \item Returns:
#' }
#' @field writeQuadtree \itemize{
#'   \item Parameters:
#'   \item Returns:
#' }
#' @field readQuadtree \itemize{
#'    \item Parameters: \itemize{ 
#'       \item filePath
#'       \item otherthing
#'    }
#'    \item Returns: product of the values
#' }
NULL

#' @name node-class
#' @aliases Rcpp_node
#' @title title here
#' @description describe stuff
#' @field stuff more stuff
NULL

#' @name shortestPathFinder-class
#' @aliases Rcpp_shortestPathFinder
#' @title title here
#' @description describe stuff
#' @field stuff more stuff
NULL