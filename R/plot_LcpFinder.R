#' @include generics.R

#' @name plot.LcpFinder
#' @aliases points.LcpFinder points,LcpFinder-method lines.LcpFinder
#'   lines,LcpFinder-method
#' @title Plot a LcpFinder object
#' @description Plots a LcpFinder object
#' @param x a \code{\link{LcpFinder}} object
#' @param add boolean; if \code{TRUE}, the LcpFinder plot is added to the
#'   existing plot
#' @param ... arguments passed to the default plotting functions
#' @details \code{points()} plots points at the centroids of the cells to which a
#'   path has been found. \code{lines()} plots all of the LCPs found so far by the
#'   LcpFinder object.
#' @return no return value
#' @examples
#' data(habitat)
#' qt <- quadtree(habitat, .1)
#'
#' start_point <- c(6989, 34007)
#' end_point <- c(12558, 27602)
#' lcpf <- lcp_finder(qt, start_point)
#' lcp <- find_lcp(lcpf, end_point)
#'
#' plot(qt, crop = TRUE, border_lwd = .3, na_col = NULL)
#' points(lcpf, col = "red", pch = 16, cex = .4)
#' lines(lcpf)
NULL

#' @rdname plot.LcpFinder
#' @export
setMethod("points", signature(x = "LcpFinder"),
  function(x, add = TRUE, ...) {
    args <- list(...)
    args[["type"]] <- NULL

    if (is.null(args[["xlab"]])) args[["xlab"]] <- "x"
    if (is.null(args[["ylab"]])) args[["ylab"]] <- "y"

    lcp_sum <- summarize_lcps(x)
    lcp_sum$x <- (lcp_sum$xmin + lcp_sum$xmax) / 2
    lcp_sum$y <- (lcp_sum$ymin + lcp_sum$ymax) / 2
    if (!add) {
      do.call(graphics::plot, c(list(x = lcp_sum$x, y = lcp_sum$y, type = "p"),
                                args))
    } else {
      do.call(graphics::points, c(list(x = lcp_sum$x, y = lcp_sum$y), args))
    }
  }
)

#' @rdname plot.LcpFinder
#' @export
setMethod("lines", signature(x = "LcpFinder"),
  function(x, add = TRUE, ...) {
    args <- list(...)
    args[["type"]] <- NULL

    if (is.null(args[["xlab"]])) args[["xlab"]] <- "x"
    if (is.null(args[["ylab"]])) args[["ylab"]] <- "y"
    if (is.null(args[["lty"]])) args[["lty"]] <- 1
    if (is.null(args[["col"]])) args[["col"]] <- "black"

    lcp_sum <- summarize_lcps(x)
    lcp_sum$x <- (lcp_sum$xmin + lcp_sum$xmax) / 2
    lcp_sum$y <- (lcp_sum$ymin + lcp_sum$ymax) / 2

    # retrieve each individual LCP
    paths_list <- lapply(seq_len(nrow(lcp_sum)), function(i) {
      row_i <- lcp_sum[i, ]
      lcp <- find_lcp(x, as.numeric(row_i[c("x", "y")]))
      return(cbind(lcp[, c("x", "y"), drop = FALSE], id = i,
                   step = seq_len(nrow(lcp))))
    })
    paths <- data.frame(do.call(rbind, paths_list))

    x0 <- stats::reshape(paths[, c("id", "step", "x")], direction = "wide",
                  idvar = "id", timevar = "step")
    y0 <- stats::reshape(paths[, c("id", "step", "y")], direction = "wide",
                  idvar = "id", timevar = "step")

    x1 <- t(x0[, -1])
    y1 <- t(y0[, -1])
    do.call(graphics::matplot, c(list(x = x1, y = y1, add = add, type = "l"),
                                 args))
  }
)
