#' @include generics.R

#' @name plot
#' @aliases plot,Quadtree,missing-method plot.Quadtree
#' @title Plot a \code{Quadtree}
#' @description Plots a \code{\link{Quadtree}}.
#' @param x a \code{\link{Quadtree}}
#' @param add boolean; if \code{FALSE} (the default) a new plot is created. If
#'   \code{TRUE}, the plot is added to the existing plot.
#' @param col character vector; the colors that will be used to create the
#'   color ramp used in the plot. If no argument is provided,
#'   \code{terrain.colors(100, rev = TRUE)} is used.
#' @param alpha numeric; transparency of the cell colors. Must be in the range
#'   0-1, where 0 is fully transparent and 1 is fully opaque. If \code{NULL}
#'   (the default) it sets \code{alpha} to 1.
#' @param nb_line_col character; the color of the lines drawn between
#'   neighboring cells. If \code{NULL} (the default), these lines are not
#'   plotted.
#' @param border_col character; the color to use for the cell borders. Use
#'   "transparent" if you don't want borders to be shown. Default is "black".
#' @param border_lwd numeric; the line width of the cell borders. Default is .4.
#' @param xlim two-element numeric vector; defines the minimum and
#'   maximum values of the x axis. Note that this overrides the \code{crop}
#'   parameter.
#' @param ylim two-element numeric vector; defines the minimum and
#'   maximum values of the y axis. Note that this overrides the \code{crop}
#'   parameter.
#' @param zlim two-element numeric vector; defines how the colors are
#'   assigned to the cell values.  The first color in \code{col} will correspond
#'   to \code{zlim[1]} and the last color in \code{col} will correspond to
#'   \code{zlim[2]}. If \code{zlim} does not encompass the entire range of cell
#'   values, cells that have values outside of the range specified by
#'   \code{zlim} will be treated as \code{NA} cells. If this value is
#'   \code{NULL} (the default), it uses the min and max cell values.
#' @param crop boolean; if \code{TRUE}, only displays the extent of the original
#'   raster, thus ignoring any of the \code{NA} cells that were added to pad the
#'   raster before making the quadtree. Ignored if either \code{xlim} or
#'   \code{ylim} are non-\code{NULL}.
#' @param na_col character; the color to use for \code{NA} cells. If
#'   \code{NULL}, \code{NA} cells are not plotted. Default is "white".
#' @param adj_mar_auto numeric; checks the size of the right margin
#'   (\code{par("mar")[4]}) - if it is less than the provided value and
#'   \code{legend} is \code{TRUE}, then it sets it to be the provided value in
#'   order to make room for the legend (after plotting, it resets it to its
#'   original value). If \code{NULL}, the margin is not adjusted. Default is 6.
#' @param legend boolean; if \code{TRUE} (the default) a legend is plotted in
#'   the right margin.
#' @param legend_args named list; contains arguments that are sent to the
#'   \code{\link{add_legend}()} function. See the help page for
#'   \code{\link{add_legend}()} for the parameters. Note that \code{zlim},
#'   \code{cols}, and \code{alpha} are supplied automatically, so if the list
#'   contains elements named \code{zlim}, \code{cols}, or \code{alpha} the
#'   user-provided values will be ignored.
#' @param ... arguments passed to the default
#'   \code{\link[graphics:plot.default]{plot}()} function
#' @details See 'Examples' for demonstrations of how the various options can be
#' used.
#' @return no return value
#' @examples
#' library(quadtree)
#' data(habitat)
#'
#' # create quadtree
#' qt <- quadtree(habitat, split_threshold = .1, adj_type = "expand")
#'
#' #####################################
#' # DEFAULT
#' #####################################
#'
#' # default - no additional parameters provided
#' plot(qt)
#'
#' #####################################
#' # CHANGE PLOT EXTENT
#' #####################################
#'
#' # note that additional parameters like 'main', 'xlab', 'ylab', etc. will be
#' # passed to the default 'plot()' function
#'
#' # crop extent to the original extent of the raster
#' plot(qt, crop = TRUE, main = "cropped")
#'
#' # crop and don't plot NA cells
#' plot(qt, crop = TRUE, na_col = NULL, main = "cropped")
#'
#' # use 'xlim' and 'ylim' to zoom in on an area
#' plot(qt, xlim = c(10000, 20000), ylim = c(20000, 30000), main = "zoomed in")
#'
#' #####################################
#' # COLORS AND BORDERS
#' #####################################
#'
#' # change border color and width
#' plot(qt, border_col = "transparent") # no borders
#' plot(qt, border_col = "gray60") # gray borders
#' plot(qt, border_lwd = .3) # change line thickness of borders
#'
#' # change color palette
#' plot(qt, col = c("blue", "yellow", "red"))
#' plot(qt, col = hcl.colors(100))
#' plot(qt, col = c("black", "white"))
#'
#' # change color transparency
#' plot(qt, alpha = .5)
#' plot(qt, col = c("blue", "yellow", "red"), alpha = .5)
#'
#' # change color of NA cells
#' plot(qt, na_col = "lavender")
#'
#' # don't plot NA cells at all
#' plot(qt, na_col = NULL)
#'
#' # change 'zlim'
#' plot(qt, zlim = c(0, 5))
#' plot(qt, zlim = c(.2, .7))
#'
#' #####################################
#' # SHOW NEIGHBOR CONNECTIONS
#' #####################################
#'
#' # plot all neighbor connections
#' plot(qt, nb_line_col = "black", border_col = "gray60")
#'
#' # don't plot connections to NA cells
#' plot(qt, nb_line_col = "black", border_col = "gray60", na_col = NULL)
#'
#' #####################################
#' # LEGEND
#' #####################################
#'
#' # no legend
#' plot(qt, legend = FALSE)
#'
#' # increase right margin size
#' plot(qt, adj_mar_auto = 10)
#'
#' # use 'legend_args' to customize the legend
#' plot(qt, adj_mar_auto = 10,
#'      legend_args = list(lgd_ht_pct = .8, bar_wd_pct = .4))
#' @export
setMethod("plot", signature(x = "Quadtree", y = "missing"),
  function(x, add = FALSE, col = NULL, alpha = NULL, nb_line_col = NULL,
           border_col = "black", border_lwd = .4, xlim = NULL, ylim = NULL,
           zlim = NULL, crop = FALSE, na_col = "white", adj_mar_auto = 6,
           legend = TRUE, legend_args = list(), ...) {
    args <- list(...)

    if (is.null(args[["xlab"]])) args[["xlab"]] <- "x"
    if (is.null(args[["ylab"]])) args[["ylab"]] <- "y"

    nodes <- as_data_frame(x, terminal_only = TRUE)

    if (is.null(col)) {
      col <- grDevices::terrain.colors(100, rev = TRUE)
    }
    col_ramp <- grDevices::colorRamp(colors = col, alpha = TRUE)

    if (is.null(zlim)) {
      if (all(is.na(nodes$value))) {
        zlim <- c(0, 0)
      } else {
        zlim <- range(nodes$value, na.rm = TRUE)
      }
    }

    # calculate an "adjusted" value - scales the cell values to be between 0 and 1 so they can be used with 'col_ramp'
    if (zlim[1] != zlim[2]) {
      nodes$val_adj <- (nodes$value - zlim[1]) / (zlim[2] - zlim[1])
    } else {
      nodes$val_adj <- ifelse(is.na(nodes$value), NA, .5)
    }
    col_nums <- col_ramp(nodes$val_adj) # returns a matrix with RGB components
    
    # if alpha is set we'll adjust the existing alphas using the provided alpha
    if(!is.null(alpha)) {
      col_nums[,4] <- col_nums[,4] * alpha
    }
    
    # now we'll convert that matrix of RGB colors to hex colors
    col_nums[is.na(nodes$val_adj),] <- 0 # rgb() fails if there are any NAs. So temporarily replace NA's with 0, and then we'll switch them back to NA after we've calculated the colors
    cols <- grDevices::rgb(col_nums[,1], col_nums[,2], col_nums[,3], col_nums[,4],
                           names = is.na(nodes$val_adj), maxColorValue = 255)
    cols[names(cols) == "TRUE"] <- NA
    nodes$col <- cols
    
    # nodes$col <- apply(col_nums, MARGIN = 1, function(row_i) {
    #   if (any(is.na(row_i))) {
    #     return(NA)
    #   }
    #   if(is.null(alpha)) { 
    #     alpha <- row_i[4]
    #   } else {
    #     alpha <- row_i[4] + alpha * 255
    #     alpha <- sapply(alpha, function(x){
    #       if(x > 255) return(255)
    #       return(x)
    #     })
    #   }
    #   return(grDevices::rgb(row_i[1], row_i[2], row_i[3], alpha,
    #                         maxColorValue = 255))
    # })

    # now deal with NA cells and cells whose values fall outside of 'zlim'
    if (is.null(na_col)) { # if na_col is NULL, we won't plot NA cells
      nodes <- nodes[!is.na(nodes$col), ]
    } else {
      nodes$col[is.na(nodes$col)] <- na_col
    }

    if (crop && (!is.null(xlim) || !is.null(ylim))) {
      warning("`crop` is TRUE, and at least one of `xlim` and `ylim` is
              provided; `crop` will therefore be ignored.")
    }

    if (crop && is.null(xlim) && is.null(ylim)) {
      orig_ext <- x@ptr$originalExtent()
      xlim <- orig_ext[1:2]
      ylim <- orig_ext[3:4]
    }

    if (is.null(xlim)) xlim <- x@ptr$root()$xLims()
    if (is.null(ylim)) ylim <- x@ptr$root()$yLims()

    # if 'adj_mar_auto' is not NULL and 'legend' is TRUE, make sure the right margin is big enough for the legend
    if (!is.null(adj_mar_auto) && legend) {
      mar <- graphics::par("mar")
      if (mar[4] < adj_mar_auto) {
        old_mar <- mar
        on.exit(graphics::par(mar = old_mar), add = TRUE) # reset 'par' on function exit  
        mar[4] <- adj_mar_auto
        graphics::par(mar = mar)
      }
    }

    if (!add) {
      do.call(graphics::plot,
              c(list(x = 1, y = 1, xlim = xlim, ylim = ylim, type = "n",
                     asp = 1), args))
    }
    graphics::rect(nodes$xmin, nodes$ymin, nodes$xmax, nodes$ymax,
                   col = nodes$col, border = border_col, lwd = border_lwd)

    if (!is.null(nb_line_col)) {
      edges <- data.frame(do.call(rbind, x@ptr$getNeighborList())) # gets a data frame with one row for each 'connection'
      if (is.null(na_col)) {
        edges <- stats::na.omit(edges)
      }
      edges <- edges[edges$hasChildren0 == 0 & edges$hasChildren1 == 0, ] # only plot connections between terminal nodes
      graphics::segments(edges$x0, edges$y0, edges$x1, edges$y1,
                         col = nb_line_col)
    }

    if (legend) {
      col_rgb <- col_ramp(seq(0, 1, length.out = 300))
      col_hex <- grDevices::rgb(col_rgb[, 1], col_rgb[, 2], col_rgb[, 3],
                                maxColorValue = 255)
      legend_args$zlim <- zlim
      legend_args$col <- col_hex
      legend_args$alpha <- alpha
      do.call(add_legend, legend_args)
    }
  }
)

#' @noRd
#' @name .get_coords
#' @rdname .get_coords
#' @title Get the extent of the figure area in plot units (for one dimension)
#' @description Given the coordinate range of a single dimension in user units
#'   (\code{par("usr")}) and the coordinates of that same coordinate range as a
#'   fraction of the current figure region (\code{par("plt")}), calculates the
#'   extent of the entire figure area in user units.
#' @param usr two-element (\code{.get_coords_axis}) or four-element
#'   (\code{.get_coords}) numeric vector; specifies the user coordinates of the
#'   plot region. Can be retrieved using \code{par("usr")}, and subscripts can
#'   be used to get only one dimension (for \code{.get_coords_axis} - i.e
#'   \code{par("usr")[1:2]})
#' @param plt two-element (\code{.get_coords_axis}) or four-element
#'   (\code{.get_coords}) numeric vector; specifies the coordinates of the plot
#'   region as fractions of the figure region. Can be retrieved using
#'   \code{par("plt")}, and subscripts can be used to get only one dimension
#'   (for \code{.get_coords_axis} - i.e \code{par("plt")[1:2]})
#' @details \code{.get_coords_axis()} is used to find the user coordinates of a
#'   single dimension of the figure area. In this case, \code{usr} and
#'   \code{plt} should both be two-element vectors corresponding to the same
#'   dimension (see examples). Both vectors need to be in the format
#'   \code{c(max,min)}.
#'
#'   \code{.get_coords()} is simply a wrapper for \code{.get_coords_axis} that
#'   does both dimensions at once. In this case the output of \code{par("usr")}
#'   and \code{par("plt")} can be directly supplied to the \code{usr} and
#'   \code{plt} parameters, respectively. Note that for both parameters the
#'   vectors must have length 4 and be in this order:
#'   \code{c(xmin,xmax,ymin,ymax)}.
#'
#'   These functions were written for use in \code{\link{add_legend}}. In order
#'   to properly place the legend, I needed to know the extent of the entire
#'   figure region in user coordinates. However, there's nothing about this
#'   function that is specific to that one application, and could be used in
#'   other situations as well.
#'
#'   Understanding what these functions do (and why they're necessary) requires
#'   an understanding of the graphical parameters, and in particular what
#'   \code{usr} and \code{plt} represent. See \code{?par} for more on these
#'   parameters.
#' @examples
#' p = par() # retrieve the graphical parameters as a list
#' .get_coords_axis(p$usr[1:2], p$plt[1:2]) # x-axis
#' .get_coords_axis(p$usr[3:4], p$plt[3:4]) # y-axis
#'
#' .get_coords(p$usr, p$plt) # both dimensions at once
#' .get_coords(par("usr"), par("plt")) # this also works
#' @seealso Run \code{?par} for more details on the \code{usr} and \code{plt}
#'   parameters
NULL

#' @noRd
#' @rdname .get_coords
.get_coords_axis <- function(usr, plt) {
  b_a <- (usr[2] - usr[1]) / (plt[2] - plt[1])
  a <- usr[1] - plt[1] * b_a
  b <- usr[2] + (1 - plt[2]) * b_a
  return(c(a, b))
}
 
#' @noRd
#' @rdname .get_coords
.get_coords <- function(usr, plt) {
  x <- .get_coords_axis(usr[1:2], plt[1:2])
  y <- .get_coords_axis(usr[3:4], plt[3:4])
  return(c(x, y))
}

#' @title Add a gradient legend to a plot
#' @description Adds a gradient legend to a plot.
#' @param zlim two-element numeric vector; required; the min and max value of z
#' @param col character vector; required; the colors that will be used in the
#'   legend.
#' @param alpha numeric; transparency of the colors. Must be in the range
#'   0-1, where 0 is fully transparent and 1 is fully opaque. Default is 1.
#' @param lgd_box_col character; color of the box to draw around the entire
#'   legend. If \code{NULL} (the default), no box is drawn
#' @param lgd_x_pct numeric; location of the center of the legend in the
#'   x-dimension, as a fraction (0 to 1) of the \emph{right margin area},
#'   \strong{not} the entire width of the figure
#' @param lgd_y_pct numeric; location of the center of the legend in the
#'   y-dimension, as a fraction (0 to 1). Unlike \code{lgd_x_pct}, this
#'   \strong{is} relative to the entire figure height (since the right margin
#'   area spans the entire vertical dimension)
#' @param lgd_wd_pct numeric; width of the entire legend, as a fraction (0 to 1)
#'   of the right margin width
#' @param lgd_ht_pct numeric; height of the entire legend, as a fraction (0 to
#'   1) of the figure height
#' @param bar_box_col character; color of the box to draw around the color bar.
#'   If \code{NULL}, no box is drawn
#' @param bar_wd_pct numeric; width of the color bar, as a fraction (0 to 1) of
#'   the width of the \emph{legend area} (\strong{not} the entire right margin
#'   width)
#' @param bar_ht_pct numeric; height of the color bar, as a fraction (0 to 1) of
#'   the height of the \emph{legend area} (\strong{not} the entire right margin
#'   height)
#' @param text_cex numeric; size of the legend text. Default is 1.
#' @param text_col character; color of the legend text. Default is "black".
#' @param text_font integer; specifies which font to use. See
#'   \code{\link[graphics:par]{par()}} for more details.
#' @param text_x_pct numeric; the x-placement of the legend text as a fraction
#'   (0 to 1) of the width of the legend area. This corresponds to the
#'   \emph{right-most} part of the text - i.e. a value of 1 means the text will
#'   end exactly at the right border of the legend area. Default is 1.
#' @param ticks numeric vector; the z-values at which to place tick marks. If
#'   \code{NULL} (the default), tick placement is automatically calculated
#' @param ticks_n integer; the number of ticks desired - only used if
#'   \code{ticks} is \code{NULL}. Note that this is an \emph{approximate} number
#'   - the \code{\link[base:pretty]{pretty()}} function is used to generate
#'   "nice-looking" values, but it doesn't guarantee a set number of tick marks
#' @details I took an HTML/CSS-like approach to determining the positioning -
#'   that is, each space is treated as \code{<div>}-like space, and the position
#'   of objects within that space happens \emph{relative to that space} rather
#'   than the entire space. The parameters prefixed by \code{lgd} are all
#'   relative to the right margin space and correspond to the box that contains
#'   the entire legend. The parameters prefixed by \code{bar} and \code{ticks}
#'   are relative to the space within the legend box.
#'
#'   This function is used within \code{\link[=plot.Quadtree]{plot}()}, so the
#'   user shouldn't call this function to manually create the legend.
#'   Customizations to the legend can be done via the \code{legend_args}
#'   parameter of \code{\link[=plot.Quadtree]{plot}()}. Using this function to
#'   plot the legend after using \code{\link[=plot.Quadtree]{plot}()} raises the
#'   possibility of the legend not corresponding correctly with the plot, and
#'   thus should be avoided.
#' @return no return value
#' @examples
#' library(quadtree)
#' data(habitat)
#' qt <- quadtree(habitat, .2)
#'
#' old_par <- par(mar = c(5, 4, 4, 5))
#' plot(qt, legend = FALSE)
#' add_legend(raster::cellStats(habitat, "range"), rev(terrain.colors(100)))
#' par(old_par)
#' # this example simply illustrates how it COULD be used, but as stated in the
#' # 'Details' section, it shouldn't be called separately from 'plot()' - if
#' # customizations to the legend are desired, use the 'legend_args' parameter
#' # of 'plot()'.
#' @export
add_legend <- function(zlim, col, alpha = 1, lgd_box_col = NULL, lgd_x_pct = .5,
                      lgd_y_pct = .5, lgd_wd_pct = .5, lgd_ht_pct = .5,
                      bar_box_col = "black", bar_wd_pct = .2, bar_ht_pct = 1,
                      text_cex = 1, text_col = NULL, text_font = NULL, 
                      text_x_pct = 1, ticks = NULL, ticks_n = 5) {
  p <- graphics::par() # get the current graphical parameter settings
  crds <- .get_coords(p$usr, p$plt) # get the x and y limits of the ENTIRE plot area, in the units used in the plot
  mar_crds <- c(p$usr[2], crds[2], crds[3], crds[4]) # get the x and y limits of the right margin area
  wd_crd <- lgd_wd_pct * (diff(mar_crds[1:2])) # get the width of the legend area relative to the right margin width
  ht_crd <- lgd_ht_pct * (mar_crds[4] - mar_crds[3]) # get the height of the legend area relative to the right margin height

  # get the coordinates for the legend area, based on the user-specified width, height, and positioning
  lgd_x0 <- mar_crds[1] + lgd_x_pct * diff(mar_crds[1:2]) - wd_crd * .5
  lgd_x1 <- mar_crds[1] + lgd_x_pct * diff(mar_crds[1:2]) + wd_crd * .5
  lgd_y0 <- mar_crds[3] + lgd_y_pct * diff(mar_crds[3:4]) - ht_crd * .5
  lgd_y1 <- mar_crds[3] + lgd_y_pct * diff(mar_crds[3:4]) + ht_crd * .5

  if (!is.null(lgd_box_col)) { # if specified, plot a box around the whole legend
    graphics::rect(lgd_x0, lgd_y0, lgd_x1, lgd_y1,
                   xpd = TRUE, border = lgd_box_col)
  }

  # get the coordinates where we'll put the color bar
  bar_x0 <- lgd_x0
  bar_x1 <- lgd_x0 + bar_wd_pct * wd_crd
  bar_y0 <- lgd_y0
  bar_y1 <- lgd_y0 + bar_ht_pct * ht_crd

  # make the color bar and add it to the plot
  col <- paste0(col, as.hexmode(round(alpha * 255)))
  rast <- grDevices::as.raster(rev(col))
  graphics::rasterImage(rast, bar_x0, bar_y0, bar_x1, bar_y1, xpd = TRUE)
  if (!is.null(bar_box_col)) { # if specified, add a box around the color bar
    graphics::rect(bar_x0, bar_y0, bar_x1, bar_y1,
                   xpd = TRUE, border = bar_box_col)
  }

  ticks_pct <- .5
  if (is.null(ticks)) { # if the user doesn't provide tick locations, calculate the ticks that we'll show on the color bar
    if (all(is.na(zlim))) { # handle the edge case where both 'zlim' values are NA
      ticks <- 0
    } else if (zlim[1] == zlim[2]) { # handle the edge case where the min and max of 'zlim' are the same
      ticks <- signif(zlim[1], 3)
    }
    else {
      ticks <- pretty(zlim, ticks_n)
      ticks <- ticks[ticks >= zlim[1] & ticks <= zlim[2]] # pretty() can return ticks outside of the specified range, so get rid of any that are outside the range
      ticks_pct <- (ticks - zlim[1]) / diff(zlim) # get the ticks as percent of total
    }
  }

  # get the x and y coordinates where we'll put the ticks
  ticks_x <- rep(lgd_x0 + text_x_pct * wd_crd, length(ticks))
  ticks_y <- lgd_y0 + ticks_pct * ht_crd
  graphics::text(ticks_x, ticks_y, labels = ticks, xpd = TRUE, adj = 1,
                 cex = text_cex, col = text_col, font = text_font) # add the ticks

  # add horizontal lines between the color bar and the numbers
  txt_bar_gap <- (ticks_x - max(graphics::strwidth(ticks))) - bar_x1 # get the distances between the right side of the color bar and the left side of the text
  seg_x0 <- rep(bar_x1, length(ticks))
  seg_x1 <- seg_x0 + txt_bar_gap * .5
  seg_y0 <- ticks_y
  seg_y1 <- seg_y0
  graphics::segments(seg_x0, seg_y0, seg_x1, seg_y1, xpd = TRUE)
}
