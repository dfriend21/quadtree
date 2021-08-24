#' @include classes.R

#if (!isGeneric("plot")) {setGeneric("plot", function(x, y, ...) standardGeneric("plot"))}
setGeneric("plot", function(x, y, ...) standardGeneric("plot"))
setGeneric("as_data_frame", function(x, ...) standardGeneric("as_data_frame"))
setGeneric("as_raster", function(x, ...) standardGeneric("as_raster"))
setGeneric("copy", function(x, ...) standardGeneric("copy"))
setGeneric("quadtree", function(x, ...) standardGeneric("quadtree"))
setGeneric("find_lcp", function(x, y, ...) standardGeneric("find_lcp"))
setGeneric("find_lcps", function(x, ...) standardGeneric("find_lcps"))
setGeneric("get_neighbors", function(x, y, ...) standardGeneric("get_neighbors"))
setGeneric("lcp_finder", function(x, y, ...) standardGeneric("lcp_finder"))
setGeneric("lcp_summary", function(x, ...) standardGeneric("lcp_summary"))
setGeneric("read_quadtree", function(x, ...) standardGeneric("read_quadtree"))
setGeneric("write_quadtree", function(x, y, ...) standardGeneric("write_quadtree"))
setGeneric("set_values", function(x, y, z, ...) standardGeneric("set_values"))
setGeneric("transform_values", function(x, y, ...) standardGeneric("transform_values"))
# setGeneric("projection", function(x, ...) standardGeneric("projection"))
setGeneric("projection<-", function(x, value) standardGeneric("projection<-"))



# if (!isGeneric("as_data_frame")) {setGeneric("as_data_frame", function(x, ...) standardGeneric("as_data_frame"))}
# if (!isGeneric("as_raster")) {setGeneric("as_raster", function(x, ...) standardGeneric("as_raster"))}
# if (!isGeneric("copy")) {setGeneric("copy", function(x, ...) standardGeneric("copy"))}
# if (!isGeneric("quadtree")) {setGeneric("quadtree", function(x, ...) standardGeneric("quadtree"))}
# if (!isGeneric("find_lcp")) {setGeneric("find_lcp", function(x, y, ...) standardGeneric("find_lcp"))}
# if (!isGeneric("find_lcps")) {setGeneric("find_lcps", function(x, ...) standardGeneric("find_lcps"))}
# if (!isGeneric("get_neighbors")) {setGeneric("get_neighbors", function(x, y, ...) standardGeneric("get_neighbors"))}
# if (!isGeneric("lcp_finder")) {setGeneric("lcp_finder", function(x, y, ...) standardGeneric("lcp_finder"))}
# if (!isGeneric("lcp_summary")) {setGeneric("lcp_summary", function(x, ...) standardGeneric("lcp_summary"))}
# if (!isGeneric("read_quadtree")) {setGeneric("read_quadtree", function(x, ...) standardGeneric("read_quadtree"))}
# if (!isGeneric("write_quadtree")) {setGeneric("write_quadtree", function(x, y, ...) standardGeneric("write_quadtree"))}
# if (!isGeneric("set_values")) {setGeneric("set_values", function(x, y, z, ...) standardGeneric("set_values"))}
# if (!isGeneric("transform_values")) {setGeneric("transform_values", function(x, y, ...) standardGeneric("transform_values"))}