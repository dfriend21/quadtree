#' @name CppQuadtree-class
#' @aliases Rcpp_CppQuadtree Rcpp_CppQuadtree-class CppQuadtree
#' @title \code{CppQuadtree}: C++ quadtree data structure
#' @description
#'   The \code{CppQuadtree} class is the underlying C++ data structure used
#'   in the \code{quadtree} package. Note that the average user should not need
#'   to use these functions - there are R wrapper functions that provide access
#'   to the many of the member functions.
#' @details 
#'   Note that the name of the class as it is defined is actually
#'   'QuadtreeWrapper', but it is exposed to R as 'CppQuadtree'. Thus, this
#'   class is defined in the 'QuadtreeWrapper.h' and QuadtreeWrapper.cpp' files.
#'   As the name suggests 'QuadtreeWrapper' is a wrapper for the C++ 'Quadtree'
#'   class. The 'Quadtree' class was written to be completely independent of R
#'   and Rcpp, and thus operates as a stand-alone C++ class. 'QuadtreeWrapper'
#'   contains an instance of a C++ 'Quadtree' object and contains the code
#'   necessary to interface between R and C++.
#'   
#'   Each member function exposed to R is described below. Note that when a
#'   function directly corresponds with an R function, the user is referred to
#'   the documentation for that function for more details (in order to avoid
#'   replication of documentation)
#' @field constructor \itemize{
#'   \item \strong{Description}: default constructor. Can be used as follows:
#'   \code{qt = new(CppQuadtree)}
#'   \item \strong{Parameters}: none
#'   \item \strong{Returns}: an empty CppQuadtree object
#' }
#' @field constructor \itemize{
#'   \item \strong{Description}: constructor. Can be used as follows: \code{qt =
#'   new(CppQuadtree, xlims, ylims, maxCellLength, minCellLength, splitAllNAs,
#'   splitAnyNAs)}. Used in \code{\link{quadtree}()}. The parameters for this
#'   constructor correspond with the similarly named parameters in
#'   \code{\link{quadtree}()} - see its documentation for more details on what
#'   the parameters signify. Note that the constructor does not "build" the
#'   quadtree structure - that is done by \code{createTree()}.
#'   \item \strong{Parameters}: \itemize{
#'     \item \code{xlims}: 2-element numeric vector
#'     \item \code{ylims}: 2-element numeric vector
#'     \item \code{maxCellLength}: 2-element numeric vector - first element is
#'     for the x dimension, second is for the y dimension
#'     \item \code{minCellLength}: 2-element numeric vector - first element is
#'     for the x dimension, second is for the y dimension
#'     \item \code{splitAllNAs}: boolean
#'     \item \code{splitAnyNAs}: boolean
#'   }
#' }
#' @field readQuadtree \itemize{
#'   \item \strong{Description}: Reads a quadtree from a file. Note that this is
#'   a static function, so does not require an instance of \code{CppQuadtree}
#'   to be called. \code{\link{read_quadtree}()} is a wrapper for this function - see
#'   its documentation for more details.
#'   \item \strong{Parameters}: \itemize{ 
#'     \item \code{filePath}: string; the file to read from
#'   }
#'   \item \strong{Returns}: a \code{CppQuadtree} object
#' }
#' @field asList \itemize{
#'   \item \strong{Description}: outputs a list containing details about each
#'   cell. \code{\link{as_data_frame}()} is a wrapper for this function that
#'   rbinds the individual list elements into a data frame.
#'   \item \strong{Parameters}: none
#'   \item \strong{Returns}: a \code{list} of named numeric vectors. Each
#'   numeric vector provides information on a single cell. The elements returned
#'   are the same as the columns described in the documentation for
#'   \code{\link{as_data_frame}()} - see that help page for details.
#' }
#' @field copy \itemize{
#'   \item \strong{Description}: returns a deep copy of a quadtree.
#'   \code{\link{copy}()} is a wrapper for this function - see the
#'   documentation for that function for more details.
#'   \item \strong{Parameters}: none
#'   \item \strong{Returns}: a CppQuadtree object
#' }
#' @field createTree \itemize{
#'   \item \strong{Description}: constructs a quadtree from a matrix.
#'   \code{\link{quadtree}()} is a wrapper for this function and should be used
#'   to create quadtrees. The parameters correspond with the similarly
#'   named parameters in \code{\link{quadtree}} - see the
#'   documentation of that function for details on the parameters
#'   \item \strong{Parameters}: \itemize{
#'     \item \code{mat}: matrix; data to be used to create the quadtree
#'     \item \code{splitMethod}: string
#'     \item \code{splitThreshold}: double
#'     \item \code{splitFun}: function
#'     \item \code{splitArgs}: list
#'     \item \code{combineFun}: function
#'     \item \code{combineArgs}: list
#'     \item \code{templateQuadtree}: CppQuadtree object
#'   }
#'   \item \strong{Returns}: void - no return value
#' }
#' @field extent \itemize{
#'   \item \strong{Description}: returns the extent of the quadtree. This is
#'   equivalent to \code{\link{extent}(qt,original=FALSE)}
#'   \item \strong{Parameters}: none
#'   \item \strong{Returns}: 4-element numeric vector, in this order: xMin,
#'   xMax, yMin, yMax
#' }
#' @field getCell \itemize{
#'   \item \strong{Description}: Given the x and y coordinates of a point,
#'   returns the cell at that point (as a \code{\link{CppNode}} object)
#'   \item \strong{Parameters}: \itemize{
#'     \item \code{x}: double; x coordinate
#'     \item \code{y}: double; y coordinate
#'   }
#'   \item \strong{Returns}: a 'CppNode' object representing the cell that
#'   contains the point
#' }
#' @field getCellDetails \itemize{
#'   \item \strong{Description}: Given points defined by their x and y
#'   coordinates, returns a matrix giving details on the cells at each of the
#'   points.
#'   \code{\link{extract}(qt,extents=TRUE)} is a wrapper for this function.
#'   \item \strong{Parameters}: \itemize{
#'     \item \code{x}: numeric vector; the x coordinates
#'     \item \code{y}: numeric vector; the y coordinates; must be the same
#'     length as x
#'   }
#'   \item \strong{Returns}: A matrix with the cell details. See
#'   \code{\link{extract}()} for details about the matrix columns
#' }
#' @field getCells \itemize{
#'   \item \strong{Description}: Given x and y coordinates of points, returns a
#'   list of the cells at those points (as \code{\link{CppNode objects}}). It is
#'   the same as \code{getCell}, except that it allows users to get multiple
#'   cells at once instead of one at a time.
#'   \item \strong{Parameters}: \itemize{
#'     \item \code{x}: numeric vector; the x coordinates
#'     \item \code{y}: numeric vector; the y coordinates; must be the same
#'     length as x
#'   }
#'   \item \strong{Returns}: a \code{list} of \code{\link{CppNode}} objects
#'   corresponding to the x and y coordinates passed to the function
#' }
#' @field getNbList \itemize{
#'   \item \strong{Description}: Returns the neighbor relationships between all
#'   cells
#'   \item \strong{Parameters}: none
#'   \item \strong{Returns}: \code{list} of matrices. Each matrix corresponds to
#'   a single cell and has one line for each neighboring cell. "neighbor"
#'   includes diagonal adjacency. Each matrix has the following columns:
#'   \itemize{
#'     \item \code{id0}, \code{x0}, \code{y0}, \code{val0}: the ID, x and y
#'     coordinates of the centroid, and cell value for the cell of interest.
#'     Note that all of these values of these columns will be same across all
#'     rows because they refer to the same cell.
#'     \item \code{id1}, \code{x1}, \code{y1}, \code{val1}: the ID, x and y
#'     coordinates of the centroid, and cell value for each cell that neighbors
#'     the cell of interest (i.e. the cell represented by the columns suffixed
#'     with '0').
#'     \item \code{isLowest}: 1 or 0 - whether or not the cell of interest (i.e.
#'     the cell represented by the columns suffixed with '0') is a terminal
#'     node, where 1 means it is a terminal node (no children) and 0 means it is
#'     not a terminal node (has children).
#'   }
#' }
#' @field getNeighbors \itemize{
#'   \item \strong{Description}: Given a point, returns a matrix with info on
#'   the cells that neighbor the cell that the point falls in.
#'   \code{\link{get_neighbor}} is a wrapper for this function.
#'   \item \strong{Parameters}: \itemize{
#'     \item \code{pt}: numeric vector of length two giving the x and y
#'     coordinates of a point
#'   }
#'   \item \strong{Returns}: a 6-column matrix with one row per neighboring cell.
#'   It has the following columns: \itemize{
#'     \item \code{id} 
#'     \item \code{xmin}
#'     \item \code{xmax}
#'     \item \code{ymin}
#'     \item \code{ymax}
#'     \item \code{value}
#'   }
#' }
#' @field getShortestPathFinder \itemize{
#'   \item \strong{Description}: Returns a CppShortestPathFinder object that can
#'   be used to find least-cost paths on the quadtree.
#'   \code{\link{lcp_finder}()} is a wrapper for this function. For details on
#'   the parameters see the \strong{Description} of the similarly named
#'   parameters in \code{\link{lcp_finder}()}
#'   \item \strong{Parameters}: \itemize{
#'     \item \code{startPoint}: two element numeric vector
#'     \item \code{xlims}: two element numeric vector
#'     \item \code{ylims}: two element numeric vector
#'   }
#'   \item \strong{Returns}: an object with class \code{CppShortestPathFinder}
#' }
#' @field getValues \itemize{
#'   \item \strong{Description}: Given points defined by their x and y
#'   coordinates, returns a numeric vector of the values of the cells at each of
#'   the points.
#'   \code{\link{extract}(qt,extents=FALSE)} is a wrapper for this function.
#'   \item \strong{Parameters}: \itemize{
#'     \item \code{x}: numeric vector; the x coordinates
#'     \item \code{y}: numeric vector; the y coordinates; must be the same
#'     length as x
#'   }
#'   \item \strong{Returns}: a numeric vector of cell values corresponding with
#'   the x and y coordinates passed to the function
#' }
#' @field maxCellDims \itemize{
#'   \item \strong{Description}: Returns the maximum allowable cell length used
#'   when constructing the quadtree (i.e. the value passed to the
#'   \code{max_cell_length}) parameter of \code{\link{quadtree}()}). Note that
#'   this does \strong{not} return the maximum cell size in the quadtree - it
#'   returns the maximum \emph{allowable} cell size. Note that if no value was
#'   provided for \code{max_cell_length}, the max allowable cell length is set
#'   to the length and width of the total extent.
#'   \item \strong{Parameters}: none
#'   \item \strong{Returns}: A two-element numeric vector giving the maximum
#'   allowable
#'   side length in the x and y dimensions.
#' }
#' @field minCellDims \itemize{
#'   \item \strong{Description}: Returns the minimum allowable cell length used
#'   when constructing the quadtree (i.e. the value passed to the
#'   \code{min_cell_length}) parameter of \code{\link{quadtree}()}). Note that
#'   this does \strong{not} return the minimum cell size in the quadtree - it
#'   returns the minimum \emph{allowable} cell size. Note that if no value was
#'   provided for \code{min_cell_length}, the min allowable cell length is set
#'   to -1.
#'   \item \strong{Parameters}: none
#'   \item \strong{Returns}: A two-element numeric vector giving the minimum
#'   allowable side length in the x and y dimensions.
#' }
#' @field nNodes \itemize{
#'   \item \strong{Description}: Returns the total number of nodes in the
#'   quadtree. Note that this includes \emph{all} nodes, not just terminal
#'   nodes.
#'   \item \strong{Parameters}: none
#'   \item \strong{Returns}: integer
#' }
#' @field originalDim \itemize{
#'   \item \strong{Description}: Returns the dimensions of the raster used to
#'   create the quadtree \emph{before} its dimensions were adjusted.
#'   \item \strong{Parameters}: none
#'   \item \strong{Returns}: 2-element numeric vector that given the number of
#'   cells along the x and y dimensions.
#' }
#' @field originalExtent \itemize{
#'   \item \strong{Description}: Returns the extent of the raster used to create
#'   the quadtree \emph{before} its dimensions/extent were adjusted. This is
#'   equivalent to \code{\link{extent}(qt,original=TRUE)}
#'   \item \strong{Parameters}: none
#'   \item \strong{Returns}: 4-element numeric vector, in this order: xMin,
#'   xMax, yMin, yMax
#' }
#' @field originalRes \itemize{
#'   \item \strong{Description}: Returns the resolution of the raster used to
#'   create the quadtree \emph{before} its dimensions/extent were adjusted.
#'   \item \strong{Parameters}: none
#'   \item \strong{Returns}: 2-element numeric vector
#' }
#' @field print \itemize{
#'   \item \strong{Description}: Returns a string that represents the quadtree
#'   \item \strong{Parameters}: none
#'   \item \strong{Returns}: a string
#' }
#' @field projection \itemize{
#'   \item \strong{Description}: Returns the proj4string of the quadtree
#'   \item \strong{Parameters}: none
#'   \item \strong{Returns}: a string
#' }
#' @field root \itemize{
#'   \item \strong{Description}: Returns the root node of the quadree
#'   \item \strong{Parameters}: none
#'   \item \strong{Returns}: a \code{CppNode} object
#' }
#' @field setOriginalValues \itemize{
#'   \item \strong{Description}: Sets the properties that record the extent and
#'   dimensions of the original raster used to create the quadtree
#'   \item \strong{Parameters}: \itemize{
#'     \item \code{xMin}: double
#'     \item \code{xMax}: double
#'     \item \code{yMin}: double
#'     \item \code{yMax}: double
#'     \item \code{nX}: integer - number of cells along the x dimension
#'     \item \code{nY}: integer - number of cells along the y dimension
#'   }
#'   \item \strong{Returns}: void - no return value
#' }
#' @field setProjection \itemize{
#'   \item \strong{Description}: Sets the property that records the proj4string
#'   of the quadtree
#'   \item \strong{Parameters}: \itemize{
#'     \item \code{proj4string}: string
#'   }
#'   \item \strong{Returns}: void - no return value
#' }
#' @field setValues \itemize{
#'   \item \strong{Description}: Given points defined by their x and y
#'   coordinates and a vector of values, sets the values of the quadtree cells
#'   at each of the points. \code{\link{set_values}()} is a wrapper for this
#'   function - see its documentation page for more details.
#'   \code{\link{extract}(qt,extents=FALSE)} is a wrapper for this function.
#'   \item \strong{Parameters}: \itemize{
#'     \item \code{x}: numeric vector; the x coordinates
#'     \item \code{y}: numeric vector; the y coordinates; must be the same
#'     length as x
#'     \item \code{newVals}: numeric vector; must be the same length as x and y
#'   }
#'   \item \strong{Returns}: void - no return value
#' }
#' @field transformValues \itemize{
#'   \item \strong{Description}: Uses a function to transform the values of
#'   all cells. \code{\link{transform_values}()} is a wrapper for this function - 
#'   see its documentation page for more details.
#'   \item \strong{Parameters}: \itemize{
#'     \item \code{trasform_fun}: function
#'   }
#'   \item \strong{Returns}: void - no return value
#' }
#' @field writeQuadtree \itemize{
#'   \item \strong{Description}: Writes a quadtree to a file.
#'   \code{\link{write_quadtree}()} is a wrapper for this function - see its
#'   documentation page for more details.
#'   \item \strong{Parameters}: \itemize{
#'     \item \code{filePath}: string; the file to save the quadtree to
#'   }
#'   \item \strong{Returns}: void - no return value
#' }
NULL