qtplot = function(qt, colors = NULL, nb=FALSE, border_col="black", xlim=NULL, ylim=NULL, crop=FALSE, na_col="white", ...) {
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
  plot(1, xlim=xlim, ylim=ylim, type="n", asp=1,...)
  rect(nodes$xMin, nodes$yMin, nodes$xMax, nodes$yMax, col=nodes$col, border=border_col)
  
  if(nb){
    edges = data.frame(do.call(rbind,qt$getNbList()))
    edges = edges[edges$isLowest == 1,]
    segments(edges$x0, edges$y0, edges$x1, edges$y1)
  }
}