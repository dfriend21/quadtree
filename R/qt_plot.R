#' Plot a quadtree object
#'
#' @param qt a \code{quadtree} object
#' @param colors character vector; the colors that will be used to create the color ramp used in the plot. If no argument is provided, \code{terrain.colors(100,rev=TRUE)} is used.
#' @param nb boolean; whether or not to include lines connecting neighboring cells
#' @param border_col character; the color to use for the cell borders. Use 'transparent' if you don't want borders to be shown
#' @param xlim two element numeric vector; defines the minimum and maximum values of the x axis
#' @param ylim two element numeric vector; defines the minimum and maximum values of the y axis
#' @param crop boolean; if \code{TRUE}, only displays the extent of the original raster, thus ignoring any of the NA cells that were added to pad the raster before making the quadtree. If \code{TRUE}, \code{xlim} and \code{ylim} are ignored
#' @param na_col character; the color to use for NA cells
#' @param ... arguments passed to the default \code{plot} function
#' @examples 
#' # create raster of random values
#' nrow = 57
#' ncol = 75
#' rast = raster(matrix(runif(nrow*ncol), nrow=nrow, ncol=ncol), xmn=0, xmx=ncol, ymn=0, ymx=nrow)
#' 
#' # create quadtree
#' qt1 = qt_create(rast, range_limit = .9, adj_type="expand")
#' 
#' # -----------
#' # DEFAULT
#' # -----------
#' qt_plot(qt1) #default - no additional parameters provided
#' 
#' # -----------
#' # CHANGE PLOT EXTENT
#' # -----------
#' # note that additional parameters like 'main', 'xlab', 'ylab', etc. will be
#' # passed to the default 'plot()' function
#' qt_plot(qt1, crop=TRUE, main="cropped") #crop extent to the original extent of the raster
#' qt_plot(qt1, xlim = c(30,50), ylim = c(10,20), main="zoomed in") 
#' 
#' # -----------
#' # COLORS
#' # -----------
#' # change border color
#' qt_plot(qt1, border_col="transparent") #no borders
#' qt_plot(qt1, border_col="gray60")
#' 
#' # change color palette
#' qt_plot(qt1, colors=c("blue", "yellow", "red"))
#' qt_plot(qt1, colors=hcl.colors(100))
#' qt_plot(qt1, colors=c("black", "white"))
#' 
#' # change color of NA cells
#' qt_plot(qt1, na_col="pink")
#' 
#' # -----------
#' # SHOW NEIGHBOR CONNECTIONS
#' # -----------
#' qt_plot(qt1, nb=TRUE, border_col="gray60")
qt_plot = function(qt, colors = NULL, nb=FALSE, border_col="black", xlim=NULL, ylim=NULL, crop=FALSE, na_col="white", ...) {
  args = list(...)
  #if the user hasn't provided custom axis labels, assign values for the labels
  if(is.null(args[["xlab"]])) args[["xlab"]] = "x"
  if(is.null(args[["ylab"]])) args[["ylab"]] = "y"
  
  nodes = dplyr::bind_rows(qt$asList())
  if(is.null(colors)){
    colors = terrain.colors(100,rev=TRUE)
  }
  colRamp = colorRamp(colors = colors)
  if(min(nodes$value, na.rm=TRUE) != max(nodes$value, na.rm=TRUE)){
    nodes$val_adj = (nodes$value-min(nodes$value, na.rm=TRUE))/(max(nodes$value,na.rm=TRUE)-min(nodes$value,na.rm=TRUE))
  } else {
    nodes$val_adj = .5
  }
  col_nums = colRamp(nodes$val_adj)
  nodes$col = apply(col_nums, MARGIN=1, function(row_i){
    if(any(is.na(row_i))){
      return(na_col)
    } 
    return(rgb(row_i[1], row_i[2], row_i[3], 255, maxColorValue = 255))
  })
  if(is.null(xlim)){ xlim = qt$root()$xLims() }
  if(is.null(ylim)){ ylim = qt$root()$yLims() }
  if(crop){
    orig_ext = qt$originalExtent()
    xlim = orig_ext[1:2]
    ylim = orig_ext[3:4]
  }
  
  #all_args = c(list(x=1,y=1, xlim=xlim, ylim=ylim, type="n", asp=1),args)
  do.call(plot,c(list(x=1,y=1, xlim=xlim, ylim=ylim, type="n", asp=1),args))
  rect(nodes$xMin, nodes$yMin, nodes$xMax, nodes$yMax, col=nodes$col, border=border_col)
  
  if(nb){
    edges = data.frame(do.call(rbind,qt$getNbList()))
    edges = edges[edges$isLowest == 1,]
    segments(edges$x0, edges$y0, edges$x1, edges$y1)
  }
}
