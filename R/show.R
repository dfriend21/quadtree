setMethod("show", signature(object = "Quadtree"),
  function(object){
    e = extent(object)
    proj = projection(object)
    if(proj == "") proj = "none"
    cat("class         : Quadtree\n",
        "# of cells    : ", object@ptr$nNodes(), "\n",
        "min cell size : ", object@ptr$root()$smallestChildSideLength(),"\n",
        "extent        : ", e[1], ", ", e[2], ", ", e[3], ", ", e[4], " (xmin, xmax, ymin, ymax)\n", 
        "projection    : ", projection(object), sep="")    
  }
)