#' Create a quadtree from gridded data
#'
#' @param x a \code{raster} or a \code{matrix}. If \code{x} is a \code{matrix},
#'   the \code{extent} and \code{proj4string} parameters can be used to set the
#'   extent and projection of the quadtree. If \code{x} is a \code{raster}, the
#'   extent and projection are derived from the raster.
#' @param split_threshold numeric; the threshold value used by the split method
#'   (specified by \code{split_method}) to decided whether or not to split a
#'   cell. If the value for a quadrant is greater than this value, the cell is split.
#'   If \code{split_method} is "custom", this parameter is ignored.
#' @param split_method character; one of \code{"range"}, \code{"sd"} (standard
#'   deviation), or \code{"custom"}. Determines the method used for calculating
#'   the value used to determine whether or not to split a cell (this calculated
#'   value is compared with \code{split_threshold} to decide whether to split a
#'   cell). See 'Details' for more.
#' @param combine_method character; one of \code{"mean"}, \code{"median"},
#'   \code{"min"}, \code{"max"}, or \code{"custom"}. Determines the method used
#'   for aggregating the values of multiple cells into a single value for a
#'   larger, aggregated cell
#' @param split_fun function; function used on each quadrant to decide whether
#'   or not to split the cell. Only used when \code{split_method} is "custom".
#'   Must take two arguments, \code{"vals"} (a numeric vector) and \code{"args"}
#'   (a named list of arguments used within the function), and must output
#'   \code{TRUE} if the quadrant is to be split and \code{FALSE} otherwise.
#' @param split_args list; named list that contains the arguments needed by
#'   \code{split_fun}. This list is given to the \code{args} parameter of
#'   \code{split_fun}
#' @param combine_fun function; function used to calculate the value of a
#'   quadrant that consists of multiple cells. Only used when
#'   \code{combine_method} is "custom"
#' @param combine_args list; named list that contains the arguments needed by
#'   \code{combine_fun}. This list is given to the \code{args} parameter of
#'   \code{combine_fun}
#' @param max_cell_length double; the maximum size allowed for a quadtree cell.
#'   If \code{NULL} no restrictions are placed on the quadtree cell size. See
#'   'Details' for more
#' @param adj_type character; either \code{'expand'} or \code{'resample'}. See
#'   'Details' for more.
#' @param resample_n_side integer; if \code{adj_type} is \code{'resample'}, this
#'   number is used to determine the dimensions to resample the raster to
#' @param extent \code{Extent} object or else a four-element numeric vector
#'   describing the extent of the data (in this order: xmin, xmax, ymin, ymax).
#'   Only used when \code{x} is a matrix - this parameter is ignored if \code{x}
#'   is a raster. If no value is provided and \code{x} is a matrix, the extent
#'   is assumed to be \code{c(0,ncol(x),0,nrow(x))}.
#' @param proj4string character; proj4string describing the projection of the
#'   data. Only used when \code{x} is a matrix - this parameter is ignored if
#'   \code{x} is a raster. If no value is provided and \code{x} is a matrix, the
#'   'proj4string' of the quadtree is set to \code{NA}.
#' @param template_quadtree quadtree object; if provided, the new quadtree will
#'   be created so that it has the exact same 'footprint' as the template
#'   quadtree. Thus, no split function is used because the decision about
#'   whether to split is pre-determined by the template quadtree.
#' @details A quadtree is created from a raster or a matrix by successively
#'   dividing the raster/matrix into smaller and smaller cells, with the
#'   decision on whether to divide a cell determined by a function that checks
#'   the cell values within each quadrant and returns \code{TRUE} if it should
#'   be split, and \code{FALSE} otherwise. Initially, all of the cells in the
#'   raster are considered. If the cell values meet the condition determined by
#'   the splitting function, the raster is divided into four quadrants -
#'   otherwise, the raster is not divided further and the value of this larger
#'   cell is calculated by applying a 'combine function' that aggregates the
#'   cell values into a single value (for example, mean and median). If the
#'   given cell is split, the process is repeated for each of those 'child'
#'   cells, and then for their children, and so on and so forth, until either
#'   the split function returns \code{FALSE} or the smallest possible cell size
#'   has been reached.
#'   
#'   If a quadrant contains both NA cells and non-NA cells, that quadrant is
#'   automatically divided. However, if a quadrant consists entirely of NA
#'   cells, that cell is not divided further (even if the cell is larger than
#'   \code{max_cell_length}).
#'
#'   If \code{max_cell_length} is not \code{NULL}, then the maximum cell size in
#'   the resulting quadtree will be \code{max_cell_length}. This essentially
#'   forces any quadrants larger than \code{max_cell_length} to split. The one
#'   exception is that a quadrant that contains entirely \code{NA} values will
#'   not be split.
#'
#'   If a given quadrant has dimensions that are not divisible by 2 (for
#'   example, 5x5), then the process stops. Because of this, only rasters that
#'   have dimensions that are a power of 2 can be divided down to their smallest
#'   cell size. In addition, the rasters should be square. To create quadtrees
#'   from rasters that have dimensions that are not a power of two and are not
#'   square, two options are provided. The choice of method is determined by the
#'   \code{adj_type} parameter.
#'
#'   In the 'expand' method, NA cells are added to the raster in order to create
#'   an expanded raster whose dimensions are a power of 2. The smallest number
#'   that is a power of two but greater than the larger dimension is used as the
#'   dimensions of the expanded raster. For example, if a raster has dimensions
#'   546 x 978, NA cells are added to the top and right of the raster in order
#'   to create a raster with dimensions 1024 x 1024 (as 1024 is the smallest
#'   power of 2 that is also greater than 978).
#'
#'   In the 'resample' method, the raster is resampled in order to create a
#'   square matrix with dimensions that are a power of two. There are two steps.
#'   First, the raster must be made square. This is done in a way similar to the
#'   method described above. The smaller dimension is padded with NA cells in
#'   order to equal the larger dimension. For example, if the raster has
#'   dimensions 546 x 978, NA rows are added in order to create a raster with
#'   dimensions 978 x 978. In the second step, this raster is then resampled to
#'   a user-specified dimension (determined by the \code{resample_n_side}
#'   parameter). For example, the user could set \code{resample_n_side} to be
#'   1024, which will resample the 978 x 978 raster to 1024 x 1024. This raster
#'   can then be used to create a quadtree. The dimensions should be a power of 
#'   2 (see above for an explanation), although other numbers will be accepted 
#'   (but will trigger a warning).
#'   
#'   The method used to determine whether or not to split a cell as well as the
#'   method used to aggregate cell values can be defined by the user. Simple
#'   methods are already provided, but custom functions can be defined. For
#'   splitting a cell, two methods are provided. "range" checks the difference
#'   between the minimum value and the maximum value within the quadrant - if
#'   this difference exceeds \code{split_threshold}, the quadrant is split. "sd"
#'   uses the standard deviation of the cell values within a quadrant - if the
#'   standard deviation exceeds \code{split_threshold}, the quadrant is split.
#'   
#'   Four methods to aggregate cell values are provided - "mean", "median",
#'   "min", and "max" - the names are self-explanatory.
#'   
#'   Custom functions can be written to apply more complex rules to splitting
#'   and combining. These functions \emph{must} take two parameters: \code{vals}
#'   and \code{args}. \code{vals} is a numeric vector of the values of the cells
#'   within the current quadrant. \code{args} is a named list that contains the
#'   arguments need by the custom function. Any parameters needed for the
#'   function should be accessed through \code{args}. Note that even if no extra
#'   parameters are needed, the custom function still needs to take an
#'   \code{args} parameter - in that case it just won't be used by the function.
#'
#'   \code{split_fun} must return a boolean, where \code{TRUE} indicates that
#'   the quadrant should be split. \code{combine_fun} must return a single
#'   numeric value.
#'
#'   For example, a simple splitting function that splits a quadrant when the
#'   variance exceeds a certain limit could be defined as follows:
#'
#'   \code{splt_fun = function(vals, args) return(var(vals) > args$var_limit)}
#'
#'   Because the function makes use of an element of \code{args} named
#'   \code{var_limit}, the \code{split_args} parameter would need to contain an
#'   element called \code{var_limit}. For example:
#'
#'   \code{qt = qt_create(rast, split_method="custom", split_fun=splt_fun,
#'   split_args=list(var_limit=.05))}
#'   
#'   Note that the provided splitting and combining functions are written in
#'   C++. So while we could define an R function to perform splitting based on
#'   the range, the C++ version will run much faster. Custom R functions will
#'   run slower than the provided C++ functions.
#' @examples
#' library(raster)
#' 
#' #create raster of random values
#' nrow = 57
#' ncol = 75
#' rast = raster(matrix(runif(nrow*ncol), nrow=nrow, ncol=ncol), xmn=0, xmx=ncol, ymn=0, ymx=nrow)
#' 
#' #####################################
#' # using 'adj_type'
#' #####################################
#' 
#' #create quadtree using the 'expand' method - automatically adds NA cells to
#' #bring the dimensions to 128 x 128 before creating the quadtree
#' qt1 = qt_create(rast, split_threshold = .9, split_method = "range", adj_type="expand")
#' qt_plot(qt1) #plot the quadtree
#' qt_plot(qt1, crop=TRUE, na_col=NULL) #we can use 'crop=TRUE' and 'na_col=NULL' 
#' #if we don't want to see the padded NA's
#' 
#' #create quadtree using the 'resample' method - we'll resample to 128 since it's a power of 2
#' qt2 = qt_create(rast, split_threshold = .9, split_method = "range", adj_type="resample", resample_n_side = 128)
#' qt_plot(qt2)
#' qt_plot(qt2, crop=TRUE, na_col=NULL)
#' 
#' #####################################
#' # using 'max_cell_length'
#' #####################################
#' 
#' #now use the 'max_cell_length' argument to force any cells with sides longer
#' #than 2 to split
#' qt3 = qt_create(rast, split_threshold = .9, split_method = "range", max_cell_length = 2, adj_type="expand")
#' 
#' #compare qt1 (no max cell length) and qt3 (max cell length = 2)
#' par(mfrow=c(1,2))
#' qt_plot(qt1, crop=TRUE, na_col=NULL, main="no max cell length")
#' qt_plot(qt3, crop=TRUE, na_col=NULL, main="max cell length = 2")
#' 
#' #####################################
#' # using 'split_method' and 'combine_method'
#' #####################################
#' 
#' #use the standard deviation instead of the range
#' qt4 = qt_create(rast, split_threshold=.25, split_method = "sd")
#' #use the max to aggregate values rather than the mean
#' qt5 = qt_create(rast, split_threshold=.25, split_method = "sd", combine_method="max")
#' 
#' #compare the two quadtrees
#' par(mfrow=c(1,2))
#' qt_plot(qt4, crop=TRUE, na_col=NULL, main="split_method='sd', combine_method='mean'")
#' qt_plot(qt5, crop=TRUE, na_col=NULL, main="split_method='sd', combine_method='max'")
#' par(mfrow=c(1,1))
#' 
#' #####################################
#' # using custom split and combine methods
#' #####################################
#' 
#' #custom split function - split a cell if the values exceed a given range
#' spl_fun = function(vals, args){ 
#'   return(any(vals < args$min) || any(vals > args$max))
#' }
#' 
#' qt6 = qt_create(rast, split_method="custom", split_fun=spl_fun, 
#'                 split_args=list(min=.02, max=.98))
#' qt_plot(qt6, crop=TRUE, na_col=NULL)
#' 
#' #custom combine function
#' cmb_fun = function(vals, args){
#'   if(any(is.na(vals))){
#'     return(NA)
#'   }
#'   if(any(vals < args$low)){
#'     return(args$low)
#'   } else if (any(vals > args$high)){
#'     return(args$high)   
#'   } else {
#'     return((args$low + args$high)/2)
#'   }
#' }
#' 
#' qt7 = qt_create(rast, split_threshold = .9, split_method="range", combine_method="custom",
#'                 combine_fun = cmb_fun, combine_args = list(low=.2, high=.8))
#' qt_plot(qt7, crop=TRUE, na_col=NULL)
#' 
#' #note that the split and combine functions are required to have an 'args'
#' #parameter, but they don't have to use it
#' cmb_fun2 = function(vals, args){
#'   return(max(vals) - min(vals))
#' }
#' 
#' qt8 = qt_create(rast, split_threshold = .9, split_method = "range", 
#'                 combine_fun = cmb_fun2)
#' qt_plot(qt8, crop=TRUE, na_col=NULL)
qt_create <- function(x, split_threshold = NULL, split_method = "range", combine_method = "mean", split_fun=NULL, split_args=list(), combine_fun=NULL, combine_args=list(), max_cell_length=NULL, adj_type="expand", resample_n_side=NULL, extent=NULL, proj4string=NULL, template_quadtree=NULL){
  #validate inputs
  if(!(split_method %in% c("range", "sd", "custom"))) stop(paste0("'", split_method, "' is not a valid value for 'split_method'. Acceptable values are 'range', 'sd', or 'custom'."))
  if(!(combine_method %in% c("mean", "median", "min", "max", "custom"))) stop(paste0("'", combine_method, "' is not a valid value for 'combine_method'. Acceptable values are 'mean', 'median', 'min', 'max', or 'custom'."))
  if(split_method != "custom" && is.null(split_threshold) && is.null(template_quadtree)) stop(paste0("When 'split_method' is not 'custom' and 'template_quadtree' is NULL, a value is required for 'split_threshold'"))
  if(split_method == "custom" && is.null(split_fun)) stop(paste0("When 'split_method' is 'custom', a function must be provided to 'split_fun'"))
  if(combine_method == "custom" && is.null(combine_fun)) stop(paste0("When 'combine_method' is 'custom', a function must be provided to 'combine_fun'"))
  if(!is.null(split_fun)){
    split_params = formalArgs(split_fun)
    if(!all(split_params == c("vals", "args"))) stop(paste0("The provided function for 'split_fun', takes the following parameters: ", paste(split_params, sep=", "), ". It must accept two arguments - 'vals' and 'args', in that order."))
  }
  if(!is.null(combine_fun)){
    combine_params = formalArgs(combine_fun)
    if(!all(combine_params == c("vals", "args"))) stop(paste0("The provided function for 'combine_fun', takes the following parameters: ", paste(combine_params, sep=", "), ". It must accept two arguments - 'vals' and 'args', in that order."))
  }
  if(split_method != "custom" && !is.null(split_fun)) warning(paste0("A function was provided to 'split_fun', but 'split_method' was not set to 'custom', so 'split_fun' will be ignored."))
  if(combine_method != "custom" && !is.null(combine_fun)) warning(paste0("A function was provided to 'combine_fun', but 'combine_method' was not set to 'custom', so 'combine_fun' will be ignored."))
  
  if(is.null(max_cell_length)) max_cell_length = -1 #if `max_cell_length` is not provided, set it to -1, which indicates no limit
  
  if("matrix" %in% class(x)){ #if x is a matrix, convert it to a raster
    if(is.null(extent)){
      if(is.null(template_quadtree)){
        extent = raster::extent(0,ncol(x),0,nrow(x))
      } else {
        extent = qt_extent(template_quadtree)
      }
    }
    x = raster::raster(x, extent[1], extent[2], extent[3], extent[4], crs=proj4string)
  }
  
  ext = raster::extent(x)
  dim = c(ncol(x), nrow(x))
  
  if(adj_type == "expand"){
    nXLog2 = log2(raster::ncol(x))
    nYLog2 = log2(raster::nrow(x))
    if(((nXLog2 %% 1) != 0) || (nYLog2 %% 1 != 0) || (raster::nrow(x) != raster::ncol(x))){  #check if the dimensions are a power of 2 or if the dimensions aren't the same (i.e. it's not square)
      newN = max(c(2^ceiling(nXLog2), 2^ceiling(nYLog2)))
      newExt = raster::extent(x)
      newExt[2] = newExt[1] + raster::res(x)[1] * newN
      newExt[4] = newExt[3] + raster::res(x)[2] * newN
      
      x = raster::extend(x,newExt)
    }
  } else if(adj_type == "resample"){
    if(is.null(resample_n_side)) { stop("adj_type is 'resample', but 'resample_n_side' is not specified. Please provide a value for 'resample_n_side'.")}
    if(log2(resample_n_side) %% 1 != 0) { warning(paste0("resample_n_side was given as ", resample_n_side, ", which is not a power of 2. Are you sure these are the dimensions you want? This could result in the smallest possible resoltion of the quadtree being much larger than the resolution of the raster"))}
    
    #first we need to make it square
    newN = max(c(raster::nrow(x), raster::ncol(x)))
    newExt = raster::extent(x)
    newExt[2] = newExt[1] + raster::res(x)[1] * newN
    newExt[4] = newExt[3] + raster::res(x)[2] * newN
    x = raster::extend(x,newExt)
    
    #now we can resample
    rastTemplate = raster::raster(newExt, nrow=resample_n_side, ncol=resample_n_side, crs=raster::crs(x))
    x = raster::resample(x, rastTemplate, method = "ngb")
  }
  
  qt = new(quadtree, raster::extent(x)[1:2], raster::extent(x)[3:4], max_cell_length, max_cell_length)
  blank_fun = function(){}
  if(is.null(split_fun)) split_fun = blank_fun
  if(is.null(split_threshold)) split_threshold = -1
  if(is.null(combine_fun)) combine_fun = blank_fun
  
  if(is.null(template_quadtree)){
    template_quadtree = new(quadtree)    
  }
  qt$createTree(raster::as.matrix(x), split_method, split_threshold, combine_method, split_fun, split_args, combine_fun, combine_args, template_quadtree)
  
  qt$setOriginalValues(ext[1], ext[2], ext[3], ext[4], dim[1], dim[2])
  qt$setProjection(raster::projection(x))
  return(qt)
}