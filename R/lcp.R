#' @include generics.R

#' @name lcp_finder
#' @aliases lcp_finder,Quadtree,numeric-method
#' @title Create an object for finding LCPs on a quadtree
#' @description This function creates an LcpFinder object that can then be used
#'   by \code{\link{find_lcp}} and \code{\link{find_lcps}} to find
#'   least-cost paths (LCPs).
#' @param x a \code{\link{Quadtree}} object to be used as a resistance surface
#' @param y numeric vector with 2 elements - the x and y coordinates
#'   of the starting point of the path(s)
#' @param xlim numeric vector with 2 elements - constrains the nodes included
#'   in the network to those whose extent overlaps with the range specified in
#'   \code{xlim}. If \code{NULL} the x limits of \code{x} are used
#' @param ylim same as \code{xlim}, but for y
#' @param search_by_centroid boolean; determines which cells are considered to
#'   be "in" the box specified by \code{xlim} and \code{ylim}. If \code{FALSE}
#'   (the default) any cell that overlaps with the box is included. If
#'   \code{TRUE}, a cell is only included if its *centroid* falls inside the
#'   box. See 'Details' for more.
#' @details This function creates an object that can then be used by
#'   \code{\link{find_lcp}} or \code{\link{find_lcps}} to calculate
#'   least-cost paths on the quadtree.
#'   
#'   See the vignette 'quadtree-lcp' for more details.
#'   
#'   \code{search_by_centroid} is important because it defines what it means for
#'   a cell to "in" the box defined by \code{xlim} and \code{ylim}. If
#'   \code{search_by_centroid} is \code{FALSE}, it is possible for least-cost
#'   paths to travel outside the specified box (since a cell may overlap with
#'   the box but have its centroid outside the box.) If \code{TRUE}, all LCPs
#'   are guaranteed to be fully contained within the box since cells are only
#'   included if the centroid falls in the box.
#'   
#'   Dijkstra's algorithm is used to find least-cost-paths (LCPs) on a network.
#'   The network used in this case consists of the cell centroids (nodes) and
#'   the neighbor connections (edges). The cost of each edge is taken as the
#'   length of the edge times the weight - because the edge travels between two
#'   cells, the cost of the edge is weighted by the distance that falls within
#'   each cell.
#'
#'   Dijkstra's algorithm essentially builds a tree data structure, where the
#'   starting node is the root of the tree. It iteratively builds the tree
#'   structure, and in each iteration it adds the node that is "closest" to the
#'   current tree - that is, it chooses the node which is easiest to get to. The
#'   result is that even if only one LCP is desired, LCPs to other nodes are
#'   also calculated in the process.
#'
#'   The LCP finder object internally stores the results as a tree-like
#'   structure. Finding the LCP to a given point can be seen as a two-step
#'   process. First, construct the tree structure as described above. Second,
#'   starting from the destination node, travel up the tree, keeping track of
#'   the sequence of nodes passed through, until the root (the starting node) is
#'   reached. This sequence of nodes (in reverse, since we started from the
#'   destination node) is the LCP to that point.
#'
#'   Once the tree has been constructed, LCPs can be found to any of the of the
#'   child nodes without further computation. This allows for efficient
#'   computation of multiple LCPs. The LCP finder saves state - whenever an LCP
#'   is asked to be calculated, it first checks whether or not a path has been
#'   found to that node already - if so, it simply returns the path using the
#'   process described above. If not, it builds out the existing tree until the
#'   desired node has been reached.
#'
#'   Two slightly different ways of calculating LCPs are provided that differ in
#'   their stop criteria - that is, the condition on which the tree stops being
#'   built. \code{\link{find_lcp}()} finds a path to a specific point. As soon
#'   as that node has been added to the tree, the algorithm stops and the LCP is
#'   returned. \code{\link{find_lcps}()} doesn't use a destination point -
#'   instead, the tree continues to be built until the paths exceed a given
#'   cost-distance, depending on which one the user selects. In addition, this
#'   constraint can be ignored in order to find all LCPs within the given set of
#'   nodes. See the documentation of those two functions for more details.
#'
#'   An important note is that because of the heterogeneous nature of a
#'   quadtree, the paths found likely won't reflect the 'true' least cost path.
#'   This is because treating the centroids of the cells as the nodes introduces
#'   some distortion, especially with large cells.
#'
#'   Also note that the \code{xlim} and \code{ylim} arguments in
#'   \code{\link{lcp_finder}()} can be used to restrict the search space to the
#'   rectangle defined by xlim and ylim. This speeds up the computation of the
#'   LCP by limiting the number of cells considered.
#'
#'   Another note is that an LcpFinder object is specific to a given
#'   starting point. If a new starting point is used, a new LCP finder is
#'   needed.
#' @return returns an LCP finder object. If \code{start_point} falls outside of
#'   the quadtree extent, \code{NULL} is returned.
#' @seealso \code{\link{find_lcp}()} returns the LCP between two points.
#'   \code{\link{find_lcps}()} finds all LCPs whose cost-distance is less
#'   than some value. \code{\link{summarize_lcps}()} outputs a summary matrix of
#'   all LCPs that have been calculated so far.
#' @examples
#' library(raster)
#'
#' #####################################
#' # create a quadtree
#' #####################################
#'
#' data(habitat)
#' rast <- habitat
#' qt <- quadtree(rast, split_threshold = .1, adj_type = "expand")
#' plot(qt, crop = TRUE, na_col = NULL, border_lwd = .4)
#'
#' #####################################
#' # basic usage
#' #####################################
#'
#' # --------------------
#' # find the LCP to a single point
#' # --------------------
#' start_pt1 <- c(6989, 34007)
#' end_pt1 <- c(33015, 38162)
#'
#' # create the LCP finder object and find the LCP
#' lcpf1 <- lcp_finder(qt, start_pt1)
#' path1 <- find_lcp(lcpf1, end_pt1)
#'
#' # plot the LCP
#' plot(qt, crop = TRUE, na_col = NULL, border_col = "gray30", border_lwd = .4)
#' points(rbind(start_pt1, end_pt1), pch = 16, col = "red")
#' lines(path1[, 1:2], col = "black")
#'
#' # --------------------
#' # find all LCPs
#' # --------------------
#' # calculate all LCPs
#' paths_summary1 <- find_lcps(lcpf1, limit_type = "none")
#' # retrieve each individual LCP
#' all_paths1 <- lapply(1:nrow(paths_summary1), function(i) {
#'   row_i <- paths_summary1[i, ]
#'   pt_i <- with(row_i, c((xmin + xmax) / 2, (ymin + ymax) / 2))
#'   return(find_lcp(lcpf1, pt_i))
#' })
#'
#' # plot all the LCPs
#' plot(qt, crop = TRUE, na_col = NULL, border_col = "gray30", border_lwd = .4)
#' invisible(lapply(all_paths1, lines))
#' points(start_pt1[1], start_pt1[2], bg="red", col="black", pch=21, cex=1.2)
#'
#' # --------------------
#' # find all cells reachable under a given threshold
#' # --------------------
#' start_pt2 <- c(19000, 25000)
#' limit <- 5000
#'
#' # create the LCP finder object and find all the valid LCPs
#' lcpf2 <- lcp_finder(qt, start_pt2)
#' # we could use limit_type = "none" if we wanted to find LCPs to ALL cells
#' paths_summary2 <- find_lcps(lcpf2, limit_type = "cd", limit = limit)
#'
#' # plot the centroids of the reachable cells
#' plot(qt, main = paste0("reachable cells; cost + distance < ", limit),
#'      crop = TRUE, na_col = NULL, border_col = "gray60")
#' with(paths_summary2,
#'      points((xmin + xmax) / 2, (ymin + ymax) / 2,
#'             pch = 16, col = "black", cex = .4))
#' points(start_pt2[1], start_pt2[2], col = "red", pch = 16)
#'
#' # --------------------
#' # limiting the search area
#' # --------------------
#' # define the search area
#' box_length <- 7000
#' xlim <- c(start_pt2[1] - box_length / 2, start_pt2[1] + box_length / 2)
#' ylim <- c(start_pt2[2] - box_length / 2, start_pt2[2] + box_length / 2)
#'
#' # find the LCPs to all the cells inside the search area
#' lcpf3 <- lcp_finder(qt, start_pt2, xlim = xlim, ylim = ylim)
#' paths_summary3 <- find_lcps(lcpf3, limit_type = "none")
#'
#' # retrive each LCP
#' all_paths3 <- lapply(1:nrow(paths_summary3), function(i) {
#'   row_i <- paths_summary3[i, ]
#'   pt_i <- with(row_i, c((xmin + xmax) / 2, (ymin + ymax) / 2))
#'   return(find_lcp(lcpf3, pt_i))
#' })
#'
#' # plot the results
#' plot(qt, crop = TRUE, na_col = NULL, border_col = "gray60")
#' with(paths_summary3,
#'      points((xmin + xmax) / 2, (ymin + ymax) / 2,
#'             pch = 16, col = "black", cex = .4))
#' invisible(lapply(all_paths3, lines))
#' rect(xlim[1], ylim[1], xlim[2], ylim[2], border = "red", lwd = 2)
#' points(start_pt2[1], start_pt2[2], col = "red", pch = 16)
#'
#'
#' #####################################
#' # a larger example to demonstrate run time
#' #####################################
#'
#' #generate a large matrix of random values between 0 and 1
#' nrow <- 570
#' ncol <- 750
#' rast <- raster(matrix(runif(nrow * ncol), nrow = nrow, ncol = ncol),
#'               xmn = 0, xmx = ncol, ymn = 0, ymx = nrow)
#'
#' #make the quadtree
#' qt1 <- quadtree(rast, split_threshold = .9, adj_type = "expand")
#'
#' #get the LCP finder
#' lcpf <- lcp_finder(qt1, c(1, 1))
#'
#' # the LCP finder saves state. So finding the path the first time requires
#' # computation, and takes longer, but running it again is nearly instantaneous
#' system.time(find_lcp(lcpf, c(740, 560))) #takes longer
#' system.time(find_lcp(lcpf, c(740, 560))) #runs MUCH faster
#'
#' # in addition, because of how Dijkstra's algorithm works, the LCP finder also
#' # found many other LCPs in the course of finding the first LCP, meaning that
#' # subsequent LCP queries for different destination points will be much faster
#' # (since the LCP finder saves state)
#' system.time(find_lcp(lcpf, c(740, 1)))
#' system.time(find_lcp(lcpf, c(1, 560)))
#'
#' # now save the paths so we can plot them
#' path1 <- find_lcp(lcpf, c(740, 560))
#' path2 <- find_lcp(lcpf, c(740, 1))
#' path3 <- find_lcp(lcpf, c(1, 560))
#'
#' # plot the paths
#' plot(qt1, crop = TRUE, border_col = "transparent", na_col = NULL)
#' lines(path1[, 1:2])
#' lines(path2[, 1:2], col = "red")
#' lines(path3[, 1:2], col = "blue")
#' @export
setMethod("lcp_finder", signature(x = "Quadtree", y = "numeric"),
  function(x, y, xlim = NULL, ylim = NULL, search_by_centroid = FALSE) {
    if (!is.numeric(y) || length(y) != 2)
      stop("'y' must be a numeric vector with length 2")
    if (any(is.na(y)))
      stop("'y' contains NA values")
    if (!is.null(xlim) && (!is.numeric(xlim) || length(xlim) != 2))
      stop("'xlim' must be a numeric vector with length 2")
    if (!is.null(xlim) && any(is.na(xlim)))
      stop("'xlim' contains NA values")
    if (!is.null(ylim) && (!is.numeric(ylim) || length(ylim) != 2))
      stop("'ylim' must be a numeric vector with length 2")
    if (!is.null(ylim) && any(is.na(ylim)))
      stop("'ylim' contains NA values")

    ext <- x@ptr$extent()
    if (is.null(xlim)) xlim <- ext[1:2]
    if (is.null(ylim)) ylim <- ext[3:4]

    if (xlim[1] > xlim[2])
      stop("'xlim[1]' must be less than 'xlim[2]'")
    if (ylim[1] > ylim[2])
      stop("'ylim[1]' must be less than 'ylim[2]'")
    if (xlim[2] < ext[1] ||
        xlim[1] > ext[2] ||
        ylim[2] < ext[3] ||
        ylim[1] > ext[4]) {
      warning("the search area defined by 'xlim' and 'ylim' does not overlap with the quadtree extent. No LCPs will be found.")
    }
    if (y[1] < xlim[1] ||
        y[1] > xlim[2] ||
        y[2] < ylim[1] ||
        y[2] > ylim[2]) {
      warning(paste0("starting point (", y[1], ",", y[2], ") not valid (falls outside the search area). No LCPs will be found."))
    }
    spf <- new("LcpFinder")
    spf@ptr <- x@ptr$getShortestPathFinder(y, xlim, ylim, search_by_centroid)

    return(spf)
  }
)

#' @name find_lcp
#' @aliases find_lcp,LcpFinder,numeric-method
#' @title Find the LCP between two points on a quadtree
#' @description Finds the least cost path (LCP) between two points, using a
#'   quadtree as a resistance surface
#' @param x the \code{\link{LcpFinder}} object returned from
#'   \code{lcp_finder}
#' @param y numeric vector with two elements - the x and y coordinates
#'   of the the destination point
#' @param use_original_end_points boolean; by default the start and end points
#'   of the returned path are not the points given by the user but instead the
#'   centroids of the cells that those points fall in. If this parameter is set
#'   to \code{TRUE} the start and end points (representing the cell centroids)
#'   are replaced with the actual points specified by the user. Note that this
#'   is done after the calculation and has no effect on the path found by the
#'   algorithm.
#' @details See \code{\link{lcp_finder}} for more information on how the LCP
#'   is found
#' @return \code{find_lcp} returns a five column matrix representing the
#'   least cost path. It has the following columns:
#'   \itemize{
#'      \item{\code{x}: }{x coordinate of this point}
#'      \item{\code{y}: }{y coordinate of this point}
#'      \item{\code{cost_tot}: }{the cumulative cost up to this point}
#'      \item{\code{dist_tot}: }{the cumulative distance up to this point - note
#'      that this is not straight-line distance, but instead the distance along
#'      the path}
#'      \item{\code{cost_cell}: }{the cost of the cell that contains this point}
#'    }
#'
#'   If no path is possible between the two points, a 0-row matrix with the
#'   previously described columns is returned. Also, note that when creating the
#'   \code{\link{LcpFinder}} object using \code{lcp_finder}, \code{NULL} will be
#'   returned if \code{start_point} falls outside of the quadtree. If
#'   \code{NULL} is passed to the \code{lcp_finder} parameter, a 0-row matrix is
#'   returned.
#'
#'   IMPORTANT NOTE: the \code{use_original_end_points} options ONLY changes the
#'   x and y coordinates of the first and last points - it doesn't change the
#'   \code{cost_tot} or \code{dist_tot} columns. This means that even though the
#'   start and end points have changed, the \code{cost_tot} and \code{dist_tot}
#'   columns still represent the cost and distance using the cell centroids of
#'   the start and end cells.
#' @seealso \code{\link{lcp_finder}()} creates the LCP finder object used as
#'   input to this function. \code{\link{find_lcps}()} calculates all LCPs
#'   whose cost-distance is less than some value. \code{\link{summarize_lcps}()}
#'   outputs a summary matrix of all LCPs that have been calculated so far.
#' @examples
#' library(raster)
#'
#' # create a quadtree
#' data(habitat)
#' rast <- habitat
#' qt <- quadtree(rast, split_threshold = .1, adj_type = "expand")
#' plot(qt, crop = TRUE, na_col = NULL, border_lwd = .4)
#'
#' # define our start and end points
#' start_pt <- c(6989, 34007)
#' end_pt <- c(33015, 38162)
#'
#' # create the LCP finder object and find the LCP
#' lcpf <- lcp_finder(qt, start_pt)
#' path <- find_lcp(lcpf, end_pt)
#'
#' # plot the LCP
#' plot(qt, crop = TRUE, na_col = NULL, border_col = "gray30", border_lwd = .4)
#' points(rbind(start_pt, end_pt), pch = 16, col = "red")
#' lines(path[, 1:2], col = "black")
#'
#' # NOTE: see "Examples" in ?lcp_finder for more examples
#' @export
setMethod("find_lcp", signature(x = "LcpFinder", y = "numeric"),
  function(x, y, use_original_end_points = FALSE) {
    if (!is.numeric(y) || length(y) != 2)
      stop("'y' must be a numeric vector with length 2")
    if (any(is.na(y)))
      stop("'y' contains NA values")
    if (!is.null(x)) {
      lims <- x@ptr$getSearchLimits()

      mat <- x@ptr$getShortestPath(y)
      if (use_original_end_points && nrow(mat) > 0) {
        mat[1, 1:2] <- x@ptr$getStartPoint()
        mat[nrow(mat), 1:2] <- y
      }
      return(mat)
    } else {
      warning("NULL passed to the 'x' parameter. Returning an empty matrix.")
      mat <- matrix(nrow = 0,
                    ncol = 5,
                    dimnames = list(NULL, c("x", "y", "cost_tot", "dist_tot",
                                            "cost_cell")))
      return(mat)
    }
  }
)

#' @name find_lcps
#' @aliases find_lcps,LcpFinder-method
#' @title Find LCPs to surrounding points
#' @description Calculates the LCPs to surrounding points. A constraint can be
#'   placed on the LCPs, so that only LCPs that are less than some specified
#'   cost-distance are returned. 
#' @param x the \code{LcpFinder} object returned from \code{\link{lcp_finder}}
#' @param limit numeric; the maximum cost-distance for the LCPs. If \code{NULL},
#'   no limit is applied and all possible LCPs (within the \code{LcpFinder}'s 
#'   serach area) are found
#' @details
#' A very important note to make is that once the LCP tree is calculated, it
#' never gets smaller. The implication of this is that great care is needed if
#' using a \code{\link{LcpFinder}} more than once. For example, I could use
#' \code{find_lcps(lcp_finder, limit=10)} to find all LCPs that have a
#' cost-distance less than 10. I could then use \code{summarize_lcps} to view
#' all cells that are reachable within 10 cost units. However, if I then run
#' \code{find_lcps(lcp_finder, limit=5)} to find all LCPs that have a
#' cost-distance less than 5, the underlying LCP network \strong{will remain
#' unchanged}. That is, if I run \code{summarize_lcps} on \code{lcp_finder}, it
#' will \strong{return paths with a cost-distance greater than 5}, since we had
#' previously used \code{lcp_finder} to find paths less than 10. As mentioned
#' before, this happens because the underlying data structure only ever adds
#' nodes, and never removes nodes.
#' @return Returns a matrix summarizing each LCP found.
#'   \code{\link{summarize_lcps}} is used to generate this matrix - see the help
#'   for that function for details on the return matrix. Note that this function
#'   does \strong{not} return the full paths to each point - however, each of
#'   the paths summarized in the output matrix has already been calculated, and
#'   can be retrieved using \code{find_lcp()} (without having to recalculate
#'   the path, since it's already been calculated).
#' @seealso \code{\link{lcp_finder}()} creates the \code{\link{LcpFinder}}
#'   object used as input to this function. \code{\link{find_lcp}()} returns the
#'   LCP between two points. \code{\link{summarize_lcps}()} outputs a summary
#'   matrix of all LCPs that have been calculated so far.
#' @examples
#' library(raster)
#' 
#' # create a quadtree
#' data(habitat)
#' rast <- habitat
#' qt <- quadtree(rast, split_threshold = .1, adj_type = "expand")
#' 
#' start_pt <- c(19000, 25000)
#' 
#' # finds LCPs to all cells
#' lcpf1 <- lcp_finder(qt, start_pt)
#' paths1 <- find_lcps(lcpf1, limit = NULL)
#' 
#' # limit LCPs by cost-distance
#' lcpf2 <- lcp_finder(qt, start_pt)
#' paths2 <- find_lcps(lcpf2, limit = 5000)
#' 
#' # Now plot the reachable cells
#' plot(qt, crop = TRUE, na_col = NULL, border_lwd = .3)
#' points(lcpf1, col = "black", pch = 16, cex = 1)
#' points(lcpf2, col = "red", pch = 16, cex = .7)
#' points(start_pt[1], start_pt[2], bg = "skyblue", col = "black", pch = 24,
#'        cex = 1.5)
#' @export
setMethod("find_lcps", signature(x = "LcpFinder"),
  function(x, limit = NULL) {
    if (is.null(limit)) {
      x@ptr$makeNetworkAll()
    } else {
      x@ptr$makeNetworkCostDist(limit)
    }
    return(summarize_lcps(x))
  }
)

#' @name summarize_lcps
#' @aliases summarize_lcps,LcpFinder-method
#' @title Show a summary matrix of all LCPs currently calculated
#' @description Given an \code{\link{LcpFinder}} object, returns a matrix that
#'   summarizes all of the LCPs that have already been calculated by the LCP
#'   finder.
#' @param x an LCP finder object created using \code{\link{lcp_finder}()}
#' @details Note that this function returns \strong{all} of the paths that have
#'   been calculated. As explained in the documentation for
#'   \code{\link{lcp_finder}()}, finding one LCP likely involves finding other
#'   LCPs as well. Thus, even if the LCP finder has been used to find one LCP,
#'   others have most likely been calculated. This function returns all of the
#'   LCPs that have been calculated so far.
#' @return Returns a 9-column matrix with one row for each LCP (and therefore
#'   one row per cell). The columns are as follows:
#'   \itemize{
#'      \item{\code{id}: }{the ID of the destination cell}
#'      \item{\code{xmin, xmax, ymin, ymax}: }{the extent of the destination
#'      cell}
#'      \item{\code{value}: }{the value of the destination cell}
#'      \item{\code{area}: }{the area of the destination cell}
#'      \item{\code{lcp_cost}: }{the cumulative cost of the LCP to this cell}
#'      \item{\code{lcp_dist}: }{the cumulative distance of the LCP to this cell
#'      - note that this is not straight-line distance, but instead the distance
#'      along the path} }
#' @seealso \code{\link{lcp_finder}()} creates the \code{\link{LcpFinder}}
#'   object used as input to this function. \code{\link{find_lcp}()} returns the
#'   LCP between two points. \code{\link{find_lcps}()} calculates all LCPs whose
#'   cost-distance is less than some value.
#' @examples
#' library(raster)
#'
#' # create a quadtree
#' data(habitat)
#' rast <- habitat
#' qt <- quadtree(rast, split_threshold = .1, adj_type = "expand")
#'
#' start_pt <- c(19000, 25000)
#' end_pt <- c(33015, 38162)
#'
#' # find LCP from 'start_pt' to 'end_pt'
#' lcpf <- lcp_finder(qt, start_pt)
#' lcp <- find_lcp(lcpf, end_pt)
#'
#' # retrieve ALL the paths that have been calculated
#' paths <- summarize_lcps(lcpf)
#'
#' # plot - put points in each of the cells to which an LCP has been calculated
#' plot(qt, crop = TRUE, na_col = NULL, border_col = "gray60")
#' points((paths$xmin + paths$xmax) / 2, (paths$ymin + paths$ymax) / 2,
#'    pch = 16, col = "black", cex = .4)
#' points(rbind(start_pt, end_pt), col = c("red", "blue"), pch = 16)
#' @export
setMethod("summarize_lcps", signature(x = "LcpFinder"),
  function(x) {
    return(data.frame(x@ptr$getAllPathsSummary()))
  }
)
