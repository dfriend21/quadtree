#https://stackoverflow.com/questions/15932585/multiple-functions-in-one-rd-file

#' @name qt_lcp_finder
#' @rdname qt_lcp_finder
#' 
#' @title Find the LCP between two points on a quadtree
#' @description Finds the least cost path (LCP) between two points, using a quadtree as a resistance surface
#' @details 
#' These two functions are intended to be used in conjunction with one another.
#' \code{qt_lcp_finder} creates the object used to find the LCP(s), and
#' \code{qt_find_lcp} uses this object to find the LCP to a given point. See
#' 'Examples' for examples of its usage.
#'
#' The code is structured this way to minimize the computation needed to compute
#' multiple LCPs from a single point. Dijkstra's algorithm iteratively searches
#' for least cost paths, and in the process of finding one LCP it inevitably
#' finds LCPs to other points. Because of this, we can save computation if we
#' use an object that can save its current state rather than having to replicate
#' our work.
#'
#' The LCP finder stops its search once it reaches the desired node. However,
#' because state is saved, if another LCP is requested and the LCP to that point
#' has not yet been calculated, the LCP finder starts where it left off rather
#' than starting over again. If the LCP to that point has been calculated, it
#' returns the path without having to perform the algorithm again.
#'
#' Note, however, that this only applies to the LCPs found using the same
#' starting point. If a different starting point is used, a different LCP finder
#' object is needed.
#'
#' As mentioned before, Dijkstra's algorithm is used to compute the shortest
#' path. Dijkstra's algorithm is a network algorithm. The network used in this
#' case consists of the cell centroids (nodes) and the neighbor connections
#' (edges). The cost of each edge is taken as the length of the edge times the
#' weight - because the edge travels between two cells, the cost of the edge is
#' weighted by the distance that falls within each cell.
#'
#' Because of the heterogeneous nature of a quadtree, the paths found likely
#' won't reflect the 'true' least cost path. This is because treating the
#' centroids of the cells as the nodes introduces some distortion, especially
#' with large cells.
#' 
#' Note that the \code{xlims} and \code{ylims} arguments in
#' \code{qt_lcp_finder} can be used to restrict the search space to the
#' rectangle defined by \code{xlims} and \code{ylims}. This speeds up the
#' computation of the LCP by limiting the number of cells considered.
#' @examples 
#' # create raster of random values
#' nrow = 57
#' ncol = 75
#' set.seed(4)
#' rast = raster(matrix(runif(nrow*ncol), nrow=nrow, ncol=ncol), xmn=0, xmx=ncol, ymn=0, ymx=nrow)
#' 
#' # create quadtree
#' qt1 = qt_create(rast, range_limit = .9, adj_type="expand")
#' qt_plot(qt1,crop=TRUE)
#' start_pt = c(.231,.14)
#' end_pt = c(74.89,56.11)
#' # create the LCP finder object
#' spf = qt_lcp_finder(qt1, start_pt)
#' 
#' # use the LCP finder object to find the LCP to a certain point
#' # this path will have the cell centroids as the start and end points
#' path1 = qt_find_lcp(spf, end_pt) 
#' # this path will be identical to path1 except that the start and end points
#' # will be the user-provided start and end points rather than the cell centroids
#' path2 = qt_find_lcp(spf, end_pt, use_original_end_points = TRUE) 
#' 
#' head(path1)
#' head(path2)
#' 
#' # plot the result
#' qt_plot(qt1, crop=TRUE, border_col="gray60")
#' points(rbind(start_pt, end_pt), pch=16, col="red")
#' lines(path1[,1:2], col="black", lwd=2.5)
#' lines(path2[,1:2], col="red", lwd=1)
#' points(path1, cex=.7, pch=16)
#' 
#' #-------------------
#' # a larger example to demonstrate run time
#' #-------------------
#' nrow = 570
#' ncol = 750
#' rast = raster(matrix(runif(nrow*ncol), nrow=nrow, ncol=ncol), xmn=0, xmx=ncol, ymn=0, ymx=nrow)
#' 
#' qt1 = qt_create(rast, range_limit = .9, adj_type="expand") 
#' spf = qt_lcp_finder(qt1, c(1,1))
#' 
#' # the LCP finder saves state. So finding the path the first time requires
#' # computation, and takes longer, but running it again is nearly instantaneous
#' system.time(qt_find_lcp(spf, c(740,560))) #takes longer
#' system.time(qt_find_lcp(spf, c(740,560))) #runs MUCH faster
#' 
#' # in addition, because of how Dijkstra's algorithm works, the LCP finder also
#' # found many other LCPs in the course of finding the first LCP, meaning that
#' # subsequent LCP queries for different destination points will be much faster
#' # (since the LCP finder saves state)
#' system.time(qt_find_lcp(spf, c(740,1)))
#' system.time(qt_find_lcp(spf, c(1,560)))
#' 
#' # now save the paths so we can plot them
#' path1 = qt_find_lcp(spf, c(740,560))
#' path2 = qt_find_lcp(spf, c(740,1))
#' path3 = qt_find_lcp(spf, c(1,560))
#' 
#' qt_plot(qt1, crop=TRUE, border_col="transparent")
#' lines(path1[,1:2])
#' lines(path2[,1:2], col="red")
#' lines(path3[,1:2], col="blue")
NULL

#' @rdname qt_lcp_finder
#' @param quadtree a quadtree object to be used as a resistance surface
#' @param start_point numeric vector with 2 elements - the x and y coordinates of the starting point of the path(s)
#' @param xlims numeric vector with 2 elements - paths will be constrained so that all points fall within the min and max x coordinates specified in \code{xlims}. If \code{NULL} the x limits of \code{quadtree} are used
#' @param ylims same as \code{xlims}, but for y
#' @return
#' \code{qt_lcp_finder} returns an LCP finder object
#' @export
qt_lcp_finder = function(quadtree, start_point, xlims=NULL, ylims=NULL){
  if(is.null(xlims)) xlims = quadtree$extent()[1:2]
  if(is.null(ylims)) ylims = quadtree$extent()[3:4]
  spf = quadtree$getShortestPathFinder(start_point, xlims, ylims)
  if(spf$isValid()){
    return(spf)
  } else {
    warning(paste0("warning in qt_lcp_finder(): starting point (",start_point[1], ",", start_point[2], ") not valid (falls outside the quadtree). Returning NULL."))
    return(NULL)
  }
}

#' @rdname qt_lcp_finder
#' @param lcp_finder the LCP finder object returned from \code{qt_lcp_finder}
#' @param end_point numeric vector with two elements - the x and y coordinates of the the destination point
#' @param use_original_end_points boolean; by default the start and end points of the returned path are not the points given by the user but instead the centroids of the cells that those points fall in. If this parameter is set to \code{TRUE} the start and end points (representing the cell centroids) are replaced with the actual points specified by the user. Note that this is done after the calculation and has no effect on the path found by the algorithm.
#' @return
#' \code{qt_find_lcp} returns a five column matrix representing the least cost path. It has the following columns:
#' \itemize{
#'  \item{\code{x}: }{x coordinate of this point}
#'  \item{\code{y}: }{y coordinate of this point}
#'  \item{\code{cost_tot}: }{the cumulative cost up to this point}
#'  \item{\code{dist_tot}: }{the cumulative distance up to this point - note that this is not straight-line distance, but instead the distance along the path}
#'  \item{\code{cost_cell}: }{the cost of the cell that contains this point}
#' }
#' 
#' IMPORTANT NOTE: the \code{use_original_end_points} options ONLY changes the x and y coordinates of the first
#' and last points - it doesn't change the \code{cost_tot} or \code{dist_tot} columns. This means that even 
#' though the start and end points have changed, the \code{cost_tot} and \code{dist_tot} columns still represent
#' the cost and distance using the cell centroids of the start and end cells.
#' @export
qt_find_lcp = function(lcp_finder, end_point, use_original_end_points=FALSE){
  if(!is.null(lcp_finder)){
    mat = lcp_finder$getShortestPath(end_point)
    if(use_original_end_points && nrow(mat) > 0){
      mat[1,1:2] = lcp_finder$getStartPoint()
      mat[nrow(mat),1:2] = end_point
    }
    return(mat)
  } else {
    warning("warning in qt_find_lcp(): NULL passed to the 'lcp_finder' parameter. Returning an empty matrix.")
    mat = matrix(nrow=0,ncol=5, dimnames=list(NULL,c("x","y","cost_tot","dist_tot","cost_cell")))
    return(mat)
  }
  
}