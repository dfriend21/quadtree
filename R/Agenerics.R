

#setGeneric("plot")
#setGeneric("transform")

if (!isGeneric("as_data_frame")) {setGeneric("as_data_frame", function(qt, ...) standardGeneric("as_data_frame"))}
if (!isGeneric("as_raster")) {setGeneric("as_raster", function(qt, ...) standardGeneric("as_raster"))}
if (!isGeneric("copy")) {setGeneric("copy", function(qt, ...) standardGeneric("copy"))}
if (!isGeneric("quadtree")) {setGeneric("quadtree", function(x, ...) standardGeneric("quadtree"))}
if (!isGeneric("extent")) {setGeneric("extent", function(qt, ...) standardGeneric("extent"))}
if (!isGeneric("extract")) {setGeneric("extract", function(qt, pts, ...) standardGeneric("extract"))}
if (!isGeneric("find_lcp")) {setGeneric("find_lcp", function(lcpf, pt, ...) standardGeneric("find_lcp"))}
if (!isGeneric("find_lcps")) {setGeneric("find_lcps", function(lcpf, ...) standardGeneric("find_lcps"))}
if (!isGeneric("get_neighbors")) {setGeneric("get_neighbors", function(qt, pt, ...) standardGeneric("get_neighbors"))}
if (!isGeneric("lcp_finder")) {setGeneric("lcp_finder", function(qt, pt, ...) standardGeneric("lcp_finder"))}
if (!isGeneric("lcp_summary")) {setGeneric("lcp_summary", function(lcpf, ...) standardGeneric("lcp_summary"))}
if (!isGeneric("plot")) {setGeneric("plot", function(x, y, ...) standardGeneric("plot"))}
if (!isGeneric("proj4string")) {setGeneric("proj4string", function(qt, ...) standardGeneric("proj4string"))}
if (!isGeneric("read_quadtree")) {setGeneric("read_quadtree", function(path, ...) standardGeneric("read_quadtree"))}
if (!isGeneric("write_quadtree")) {setGeneric("write_quadtree", function(qt, path, ...) standardGeneric("write_quadtree"))}
if (!isGeneric("set_values")) {setGeneric("set_values", function(qt, pts, vals, ...) standardGeneric("set_values"))}
if (!isGeneric("transform")) {setGeneric("transform", function(qt, fun, ...) standardGeneric("transform"))}