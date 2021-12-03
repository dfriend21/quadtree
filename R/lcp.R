#' @include generics.R

#' @name lcp_finder
#' @aliases lcp_finder,Quadtree-method
#' @title Create a \code{LcpFinder}
#' @description Creates a \code{\link{LcpFinder}} object that can then be used
#'   by \code{\link{find_lcp}} and \code{\link{find_lcps}} to find least-cost
#'   paths (LCPs) using a \code{\link{Quadtree}} as a resistance surface.
#' @param x a \code{\link{Quadtree}} to be used as a resistance surface
#' @param y two-element numeric vector (x, y) - the x and y coordinates of the
#'   starting point
#' @param xlim two-element numeric vector (xmin, xmax) - constrains the nodes
#'   included in the network to those whose x limits fall in the range specified
#'   in \code{xlim}. If \code{NULL} the x limits of \code{x} are used
#' @param ylim same as \code{xlim}, but for y
#' @param new_points a two-column matrix representing point coordinates. First
#'   column contains the x-coordinates, second column contains the
#'   y-coordinates. This matrix specifies point locations to use instead of the
#'   node centroids. See 'Details' for more.
#' @param search_by_centroid boolean; determines which cells are considered to
#'   be "in" the box specified by \code{xlim} and \code{ylim}. If \code{FALSE}
#'   (the default) any cell that overlaps with the box is included. If
#'   \code{TRUE}, a cell is only included if its \strong{centroid} falls inside
#'   the box.
#' @details
#'   To find a least-cost path, the cells are treated as points - by default,
#'   the cell centroids are used. This results in some degree of error,
#'   especially for large cells. The \code{new_points} parameter can be used to
#'   specify the points used to represent the cells. Each
#'   point in the matrix will be used as the point for the cell it falls in.
#'   Note that if two points fall in the same cell, the first point is used.
#'   This is most useful for specifying the points to be used for the start cell
#'   as well as the end cell (if the \code{LcpFinder} is being used to find a
#'   path to one specific point).
#'   
#'   An \code{LcpFinder} saves state, so once the LCP tree is calculated,
#'   individual LCPs can be retrieved without further computation. This makes it
#'   efficient at calculating multiple LCPs from a single starting point.
#'   However, in the case where only a single LCP is needed,
#'   \code{\link{find_lcp()}} offers an interface for finding an LCP without
#'   needing to use \code{lcp_finder()} to create the \code{LcpFinder} object
#'   first.
#'   
#'   See the vignette 'quadtree-lcp' for more details and examples (i.e. run
#'   \code{vignette("quadtree-lcp", package = "quadtree")})
#' @return a \code{\link{LcpFinder}}
#' @seealso \code{\link{find_lcp}()} returns the LCP between the start point and
#'   another point. \code{\link{find_lcps}()} finds all LCPs whose cost-distance
#'   is less than some value. \code{\link{summarize_lcps}()} outputs a summary
#'   matrix of all LCPs that have been calculated so far.
#'   \code{\link[=plot.LcpFinder]{points}()} and
#'   \code{\link[=plot.LcpFinder]{lines}()} can be used to plot a
#'   \code{\link{LcpFinder}}.
#' @examples
#' ####### NOTE #######
#' # see the "quadtree-lcp" vignette for more details and examples:
#' # vignette("quadtree-lcp", package = "quadtree")
#' ####################
#'
#' library(quadtree)
#'
#' data(habitat)
#' qt <- quadtree(habitat, split_threshold = .1, adj_type = "expand")
#'
#' # find the LCP between two points
#' start_pt <- c(6989, 34007)
#' end_pt <- c(33015, 38162)
#'
#' # create the LCP finder object and find the LCP
#' lcpf <- lcp_finder(qt, start_pt)
#' path <- find_lcp(lcpf, end_pt)
#'
#' # plot the LCP
#' plot(qt, crop = TRUE, na_col = NULL, border_lwd = .3)
#' points(rbind(start_pt, end_pt), pch = 16, col = "red")
#' lines(path[, 1:2], col = "black")
#' @export
setMethod("lcp_finder", signature(x = "Quadtree"),
  function(x, start_point, xlim = NULL, ylim = NULL, new_points = matrix(nrow = 0, ncol = 2), search_by_centroid = FALSE) {
    if (!is.numeric(start_point) || length(start_point) != 2)
      stop("'start_point' must be a numeric vector with length 2")
    if (any(is.na(start_point)))
      stop("'start_point' contains NA values")
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
    if (start_point[1] < xlim[1] ||
        start_point[1] > xlim[2] ||
        start_point[2] < ylim[1] ||
        start_point[2] > ylim[2]) {
      warning(paste0("starting point (", start_point[1], ",", start_point[2], ") not valid (falls outside the search area). No LCPs will be found."))
    }
    spf <- new("LcpFinder")
    spf@ptr <- x@ptr$getLcpFinder(start_point, xlim, ylim, new_points, search_by_centroid)
    # spf@ptr <- x@ptr$getLcpFinder(y, xlim, ylim, search_by_centroid)

    return(spf)
  }
)

#' @name find_lcp
#' @aliases find_lcp,Quadtree-method find_lcp.Quadtree
#' @param x a \code{\link{LcpFinder}} or a \code{\link{Quadtree}}
#' @param start_point two-element numeric vector; the x and y coordinates of the
#'   starting point. Not used if \code{x} is a \code{\link{LcpFinder}} since the
#'   start point is determined when the \code{\link{LcpFinder}} is created
#'   (using \code{\link{lcp_finder}()}).
#' @param end_point two-element numeric vector; the x and y coordinates of the
#'   destination point
#' @param use_orig_points boolean; if \code{TRUE} (the default), the path is
#'   calculated between \code{start_point} and \code{end_point}. If
#'   \code{FALSE}, the path is calculated between the centroids of the cells the
#'   points fall in.
#' @param xlim two-element numeric vector (xmin, xmax); passed to
#'   \code{\link{lcp_finder}()}; constrains the nodes included in the network to
#'   those whose x limits fall in the range specified in \code{xlim}. If
#'   \code{NULL} the x limits of \code{x} are used
#' @param ylim same as \code{xlim}, but for y
#' @param search_by_centroid boolean; passed to \code{\link{lcp_finder}()};
#'   determines which cells are considered to be "in" the box specified by
#'   \code{xlim} and \code{ylim}. If \code{FALSE} (the default) any cell that
#'   overlaps with the box is included. If \code{TRUE}, a cell is only included
#'   if its \strong{centroid} falls inside the box.
#' @export
setMethod("find_lcp", signature(x = "Quadtree"),
  function(x, start_point, end_point, use_orig_points = TRUE, xlim = NULL, ylim = NULL, search_by_centroid = FALSE) {
    if (!is.numeric(start_point) || length(start_point) != 2 ||
        !is.numeric(end_point) || length(end_point) != 2)
      stop("'start_point' and 'end_point' must be numeric vectors with length 2")
    if (any(is.na(start_point)) || any(is.na(end_point)))
      stop("'start_point' and 'end_point' must not contain NA values")
    if(use_orig_points){
      new_points <- rbind(start_point, end_point)
    } else {
      new_points <- matrix(nrow = 0, ncol = 2)
    }
    lcpf <- lcp_finder(x, start_point, xlim, ylim, new_points, search_by_centroid)
    mat <- lcpf@ptr$getLcp(end_point, use_orig_points)
    return(mat)
  }
)

#' @name find_lcp
#' @aliases find_lcp,LcpFinder-method find_lcp.LcpFinder
#' @title Find the LCP between two points on a \code{Quadtree}
#' @description Finds the least-cost path (LCP) from the start point (the point
#'   used to create the \code{\link{LcpFinder}}) to another point, using a
#'   \code{\link{Quadtree}} as a resistance surface.
#' @param allow_same_cell_path boolean; default is FALSE; if TRUE, allows
#'   paths to be found between two points that fall in the same cell. See
#'   'Details' for more.
#' @details
#'   See the vignette 'quadtree-lcp' for more details and examples (i.e. run
#'   \code{vignette("quadtree-lcp", package = "quadtree")})
#'   
#'   By default, if the end point falls in the same cell as the start point, the
#'   path will consist only of the point associated with the cell. When using
#'   \code{find_lcp} with a \code{\link{LcpFinder}}, setting
#'   \code{allow_same_cell_path} to \code{TRUE} allows for paths to be found
#'   within a single cell. In this case, if the start and end points fall in the
#'   same cell, the path will consist of two points - the point associated with
#'   the cell and \code{end_point}. If using \code{find_lcp} with a
#'   \code{\link{Quadtree}}, this will automatically be allowed if
#'   \code{use_orig_points} is \code{TRUE}.
#' @return Returns a five column matrix representing the LCP. It has the
#'   following columns:
#'   \itemize{
#'      \item{\code{x}: }{x coordinate of this point (centroid of the cell)}
#'      \item{\code{y}: }{y coordinate of this point (centroid of the cell)}
#'      \item{\code{cost_tot}: }{the cumulative cost up to this point}
#'      \item{\code{dist_tot}: }{the cumulative distance up to this point - note
#'      that this is not straight-line distance, but instead the distance along
#'      the path}
#'      \item{\code{cost_cell}: }{the cost of the cell that contains this point}
#'      \item{\code{id}:}{ the ID of the cell that contains this point}
#'    }
#'
#'   If no path is possible between the two points, a zero-row matrix with the
#'   previously described columns is returned.
#' @seealso \code{\link{lcp_finder}()} creates the LCP finder object used as
#'   input to this function. \code{\link{find_lcps}()} calculates all LCPs
#'   whose cost-distance is less than some value. \code{\link{summarize_lcps}()}
#'   outputs a summary matrix of all LCPs that have been calculated so far.
#' @examples
#' ####### NOTE #######
#' # see the "quadtree-lcp" vignette for more details and examples:
#' # vignette("quadtree-lcp", package = "quadtree")
#' ####################
#'
#' library(quadtree)
#' data(habitat)
#'
#' # create a quadtree
#' qt <- quadtree(habitat, split_threshold = .1, adj_type = "expand")
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
#' @export
setMethod("find_lcp", signature(x = "LcpFinder"),
  function(x, end_point, allow_same_cell_path = FALSE) {
    if (!is.numeric(end_point) || length(end_point) != 2)
      stop("'start_pt' must be a numeric vector with length 2")
    if (any(is.na(end_point)))
      stop("'start_pt' contains NA values")

    mat <- x@ptr$getLcp(end_point, allow_same_cell_path)
    return(mat)
  }
)

#' @name find_lcps
#' @aliases find_lcps,LcpFinder-method
#' @title Find LCPs to surrounding points
#' @description Calculates least-cost paths (LCPs) from the start point (the
#'   point used to create the \code{\link{LcpFinder}}) to surrounding points. A
#'   constraint can be placed on the LCPs so that only LCPs that are less than
#'   some specified cost-distance are returned.
#' @param x a \code{\link{LcpFinder}}
#' @param limit numeric; the maximum cost-distance for the LCPs. If \code{NULL}
#'   (the default), no limit is applied and all possible LCPs (within the
#'   \code{LcpFinder}'s search area) are found
#' @param return_summary boolean; if \code{TRUE} (the default),
#'   \code{\link{summarize_lcps}()} is used to return a summary matrix of all
#'   paths found. If \code{FALSE}, no value is returned.
#' @details Once the LCPs have been calculated, \code{\link{find_lcp}()} can be
#'   used to extract paths to individual points. No further calculation will be
#'   required to retrieve these paths so long as they were calculated when
#'   \code{find_lcps()} was run.
#'
#'   A very important note to make is that once the LCP tree is calculated, it
#'   never gets smaller. For example, we could use \code{\link{find_lcps}()}
#'   with \code{limit = NULL} to calculate all LCPs. If we then used
#'   \code{\link{find_lcps}()} on the same \code{LcpFinder} but this time used a
#'   limit, it would still return \emph{all} of the LCPs, even those that are
#'   greater than the specified limit, since the tree never shrinks.
#' @return If \code{return_summary} is \code{TRUE},
#'   \code{\link{summarize_lcps}()} is used to return a matrix summarizing each
#'   LCP found. See the help page of that function for details on the return
#'   matrix. If \code{return_summary} is \code{FALSE}, no value is returned.
#' @seealso \code{\link{lcp_finder}()} creates the \code{\link{LcpFinder}}
#'   object used as input to this function. \code{\link{find_lcp}()} returns the
#'   LCP between the start point and another point.
#'   \code{\link{summarize_lcps}()} outputs a summary matrix of all LCPs that
#'   have been calculated so far.
#' @examples
#' ####### NOTE #######
#' # see the "quadtree-lcp" vignette  for more details and examples:
#' # vignette("quadtree-lcp", package = "quadtree")
#' ####################
#'
#' library(quadtree)
#' data(habitat)
#'
#' qt <- quadtree(habitat, split_threshold = .1, adj_type = "expand")
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
  function(x, limit = NULL, return_summary = TRUE) {
    if (is.null(limit)) {
      x@ptr$makeNetworkAll()
    } else {
      x@ptr$makeNetworkCostDist(limit)
    }
    if (return_summary) {
      return(summarize_lcps(x))
    }
  }
)

#' @name summarize_lcps
#' @aliases summarize_lcps,LcpFinder-method
#' @title Get a matrix summarizing all LCPs found by a \code{LcpFinder}
#' @description Given a \code{\link{LcpFinder}}, returns a matrix that
#'   summarizes all of the LCPs that have been calculated by the
#'   \code{\link{LcpFinder}}.
#' @param x a \code{\link{LcpFinder}}
#' @details Note that this function returns \strong{all} of the paths that have
#'   been calculated. Finding one LCP likely involves finding other LCPs as
#'   well. Thus, even if the \code{\link{LcpFinder}} has been used to find one
#'   LCP, others have most likely been calculated. This function returns all of
#'   the LCPs that have been calculated so far.
#' @return Returns a nine-column matrix with one row for each LCP (and therefore
#'   one row per destination cell). The columns are as follows:
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
#'   LCP between the start point and another point. \code{\link{find_lcps}()}
#'   calculates all LCPs whose cost-distance is less than some value.
#' @examples
#' library(quadtree)
#' data(habitat)
#'
#' qt <- quadtree(habitat, split_threshold = .1, adj_type = "expand")
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
#' head(paths)
#' @export
setMethod("summarize_lcps", signature(x = "LcpFinder"),
  function(x) {
    return(data.frame(x@ptr$getAllPathsSummary()))
  }
)
