#' Create a quadtree from gridded data
#'
#' @param x a \code{raster} or a \code{matrix}. If \code{x} is a \code{matrix},
#'   the \code{extent} and \code{proj4string} parameters can be used to set the
#'   extent and projection of the quadtree. If \code{x} is a \code{raster}, the
#'   extent and projection are derived from the raster.
#' @param split_threshold numeric; the threshold value used by the split method
#'   (specified by \code{split_method}) to decide whether to split a cell. If
#'   the value for a quadrant is greater than this value, the cell is split. If
#'   \code{split_method} is "custom", this parameter is ignored.
#' @param split_method character; one of \code{"range"}, \code{"sd"} (standard
#'   deviation), or \code{"custom"}. Determines the method used for calculating
#'   the value used to determine whether or not to split a cell (this calculated
#'   value is compared with \code{split_threshold} to decide whether to split a
#'   cell). See 'Details' for more.
#' @param combine_method character; one of \code{"mean"}, \code{"median"},
#'   \code{"min"}, \code{"max"}, or \code{"custom"}. Determines the method used
#'   for aggregating the values of multiple cells into a single value for a
#'   larger, aggregated cell. Default is \code{"mean"}.
#' @param split_fun function; function used on each quadrant to decide whether
#'   or not to split the cell. Only used when \code{split_method} is "custom".
#'   Must take two arguments, \code{"vals"} (a numeric vector) and \code{"args"}
#'   (a named list of arguments used within the function), and must output
#'   \code{TRUE} if the quadrant is to be split and \code{FALSE} otherwise. See
#'   'Details' and 'Examples' for more.
#' @param split_args list; named list that contains the arguments needed by
#'   \code{split_fun}. This list is given to the \code{args} parameter of
#'   \code{split_fun}
#' @param split_if_any_NA boolean; if \code{TRUE} (the default), a quadrant is
#'   automatically split if any of the values within the quadrant are NA
#' @param split_if_all_NA boolean; if \code{FALSE} (the default), a quadrant
#'   that contains only \code{NA} values is not split. If \code{TRUE}, quadrants
#'   that contain all \code{NA} values are split to the smallest possible cell
#'   size.
#' @param combine_fun function; function used to calculate the value of a
#'   quadrant that consists of multiple cells. Only used when
#'   \code{combine_method} is "custom" Must take two arguments, \code{"vals"} (a
#'   numeric vector) and \code{"args"} (a named list of arguments used within
#'   the function), and must output a single numeric value, which will be used
#'   as the cell value See 'Details' and 'Examples' for more.
#' @param combine_args list; named list that contains the arguments needed by
#'   \code{combine_fun}. This list is given to the \code{args} parameter of
#'   \code{combine_fun}
#' @param max_cell_length numeric; the maximum side length allowed for a
#'   quadtree cell. If \code{NULL} (the default) no restrictions are placed on
#'   the maximum cell length. See 'Details' for more.
#' @param min_cell_length numeric; the minimum side length allowed for a quadtree
#'   cell. If \code{NULL} (the default) no restrictions are placed on the 
#'   minimum cell length. See 'Details' for more.
#' @param adj_type character; one of \code{'expand'} (the default),
#'   \code{'resample'}, or \code{'none'}. Specifies the method used to adjust
#'   \code{x} so that its dimensions are suitable for quadtree creation (i.e.
#'   square and with the number of cells in each direction being a power of 2).
#'   See 'Details' for more on the two methods of adjustment.
#' @param resample_n_side integer; if \code{adj_type} is \code{'resample'}, this
#'   number is used to determine the dimensions to resample the raster to
#' @param resample_pad_NAs boolean; only applicable if \code{adj_type} is
#'   \code{'resample'}. If \code{TRUE} (the default), \code{NA}s are added to
#'   the shorter side of the raster to make it square before resampling. This
#'   ensures that the cells of the resulting quadtree will be square. If
#'   \code{FALSE}, no \code{NA}s are added - the cells in the quadtree will not
#'   be square.
#' @param extent \code{Extent} object or else a four-element numeric vector
#'   describing the extent of the data (in this order: xmin, xmax, ymin, ymax).
#'   Only used when \code{x} is a matrix - this parameter is ignored if \code{x}
#'   is a raster since the extent is derived directly from the raster. If no
#'   value is provided and \code{x} is a matrix, the extent is assumed to be
#'   \code{c(0,ncol(x),0,nrow(x))}.
#' @param proj4string character; proj4string describing the projection of the
#'   data. Only used when \code{x} is a matrix - this parameter is ignored if
#'   \code{x} is a raster since the proj4string of the raster is automatically
#'   used. If no value is provided and \code{x} is a matrix, the 'proj4string'
#'   of the quadtree is set to \code{NA}.
#' @param template_quadtree quadtree object; if provided, the new quadtree will
#'   be created so that it has the exact same structure as the template
#'   quadtree. Thus, no split function is used because the decision about
#'   whether to split is pre-determined by the template quadtree. The raster
#'   used to create the template quadtree should have the exact same extent and
#'   dimensions as \code{x}. If \code{template_quadtree} is non-\code{NULL}, all
#'   \code{split_}* parameters are disregarded, as are \code{max_cell_length}
#'   and \code{min_cell_length}
#' @details 
#'  \strong{Overview of quadtree creation}
#' 
#'   A quadtree is created from a raster or a matrix by successively dividing
#'   the raster/matrix into smaller and smaller cells, with the decision on
#'   whether to divide a quadrant determined by a function that checks the cell
#'   values within each quadrant and returns \code{TRUE} if it should be split,
#'   and \code{FALSE} otherwise. Initially, all of the cells in the raster are
#'   considered. If the cell values meet the condition determined by the
#'   splitting function, the raster is divided into four quadrants - otherwise,
#'   the raster is not divided further and the value of this larger cell is
#'   calculated by applying a 'combine function' that aggregates the cell values
#'   into a single value (for example, mean and median). If the given cell is
#'   split, the process is repeated for each of those 'child' quadrants, and
#'   then for their children, and so on and so forth, until either the split
#'   function returns \code{FALSE} or the smallest possible cell size has been
#'   reached.
#'   
#'   \strong{Pre-creation dimension adjustment}
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
#'   square matrix with dimensions that are a power of two. If the data does not
#'   have same number of rows and columns, resampling the raster to have an
#'   equal number of rows and column will result in rectangular but non-square
#'   cells. If square cells are desired, an additional step is added to make the
#'   raster square by setting \code{resample_pad_NAs} to be \code{TRUE} (the
#'   default). This is done in a way similar to the method described above. The
#'   smaller dimension is padded with NA cells in order to equal the larger
#'   dimension. For example, if the raster has dimensions 546 x 978, NA rows are
#'   added in order to create a raster with dimensions 978 x 978. Then,
#'   regardless of whether \code{resample_pad_NAs} is \code{TRUE} or
#'   \code{FALSE}, the raster is resampled to a user-specified dimension
#'   (determined by the \code{resample_n_side} parameter). For example, the user
#'   could set \code{resample_n_side} to be 1024, which will resample the 978 x
#'   978 raster to 1024 x 1024. This raster can then be used to create a
#'   quadtree. \code{resample_n_side} should be a power of 2 (see above for an
#'   explanation), although other numbers will be accepted (but will trigger a
#'   warning).
#'   
#'   If \code{adj_type} is 'none', the provided matrix/raster is used 'as is', 
#'   with no dimension adjustment.
#'   
#'   \strong{Splitting and aggregating functions}
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
#'   the quadrant should be split. An \strong{important note} to make is that
#'   any custom function must be able to handle \code{NA} values. The function
#'   must \emph{always} return either \code{TRUE} or \code{FALSE} - if \code{NA}
#'   is ever returned an error will occur. 
#'
#'   For example, a simple splitting function that splits a quadrant when the
#'   variance exceeds a user-defined limit could be defined as follows:
#'
#'   \preformatted{
#'   splt_fun = function(vals, args) {
#'      if(any(is.na(vals))){
#'         return(TRUE);
#'      } else {
#'         return(sd(vals) > args$var_limit)
#'      }
#'   }}
#'
#'   Because the function makes use of an element of \code{args} named
#'   \code{var_limit}, the \code{split_args} parameter would need to contain an
#'   element called \code{var_limit}. For example:
#'
#'   \code{qt = qt_create(rast, split_method="custom", split_fun=splt_fun,
#'   split_args=list(var_limit=.05))}
#'   
#'   \code{combine_fun} must return a single numeric value. Unlike
#'   \code{split_fun}, \code{combine_fun} is allowed to return \code{NA} values.
#'   See Examples for an example of a custom combine function.
#'   
#'   Note that the provided splitting and combining functions are written in
#'   C++. So while we could define an R function to perform splitting based on
#'   the range, the C++ version will run much faster. Custom R functions will
#'   run slower than the provided C++ functions.
#'
#'   \strong{Creating a quadtree using a template}
#'
#'   This function also allows users to create a quadtree using another quadtree
#'   as a "template" (via the \code{template_quadtree} parameter). The structure
#'   of the new quadtree will be identical to that of the template quadtree, but
#'   the values of the cells will be derived from the raster used to create the
#'   new quadtree. The rasters used to make the template quadtree and the new
#'   quadtree should have the exact same extent and dimensions - in addition the
#'   exact same 'expansion method' (i.e. the method specified by
#'   \code{adj_type}) should be used to create both quadtrees.
#'   
#'   \strong{Other parameters}
#'   
#'   There are a few other parameters that control various aspects of the 
#'   quadtree creation process.
#'
#'   The \code{max_cell_length} and \code{min_cell_length} parameters let the
#'   user specify the range of allowable cell sizes. If \code{max_cell_length}
#'   is not \code{NULL}, then the maximum cell size in the resulting quadtree
#'   will be \code{max_cell_length}. This essentially forces any quadrants
#'   larger than \code{max_cell_length} to split. The one exception is that a
#'   quadrant that contains entirely \code{NA} values will not be split.
#'   Similarly, the \code{min_cell_length} parameter can be used to define a
#'   minimum side length for all cells, such that a quadrant cannot be split if
#'   its children would be smaller than \code{min_cell_length}.
#'   
#'   The \code{split_if_any_NA} and \code{split_if_all_NA} parameters control
#'   how \code{NA} values are handled. If \code{split_if_any_NA} is \code{TRUE}
#'   (the default), a quadrant will be split if any of the values are \code{NA}.
#'   This ensures that rasters with irregular shapes maintain their shape in the
#'   resulting quadtree representation. If \code{FALSE}, quadrants with
#'   \code{NA}s are not automatically split - note that this can produce
#'   unexpected results if the raster is irregularly shaped.
#'   \code{split_if_all_NA} controls what happens when a quadrant consists
#'   entirely of \code{NA} values. If \code{FALSE} (the default), these
#'   quadrants are not split. If \code{TRUE}, these quadrants are automatically
#'   split, which results in quadrants with all \code{NA} values being split to
#'   the smallest possible cell size.
#' @examples
#' library(raster)
#' 
#' # retrieve the sample data
#' data(habitat)
#' rast = habitat
#' 
#' #####################################
#' # using 'adj_type'
#' #####################################
#' 
#' # create quadtree using the 'expand' method - automatically adds NA cells to
#' # bring the dimensions to 128 x 128 before creating the quadtree
#' qt1 = qt_create(rast, split_threshold = .15, split_method = "range", adj_type="expand")
#' qt_plot(qt1) #plot the quadtree
#' qt_plot(qt1, crop=TRUE, na_col=NULL) #we can use 'crop=TRUE' and 'na_col=NULL' 
#' # if we don't want to see the padded NA's
#' 
#' # create quadtree using the 'resample' method - we'll resample to 128 since it's a power of 2
#' 
#' # first we'll do it WITHOUT adding NAs to the shorter dimension, which
#' # will result in non-square cells
#' qt2 = qt_create(rast, split_threshold = .15, split_method = "range", 
#'    adj_type="resample", resample_n_side = 128, resample_pad_NAs=FALSE)
#' qt_plot(qt2)
#' qt_plot(qt2, crop=TRUE, na_col=NULL)
#' 
#' # now we'll add 'padding' NAs so that the cells of the quadtree are square
#' qt3 = qt_create(rast, split_threshold = .15, split_method = "range", 
#'    adj_type="resample", resample_n_side = 128)
#' qt_plot(qt3)
#' qt_plot(qt3, crop=TRUE, na_col=NULL)
#' 
#' #####################################
#' # using 'max_cell_length' and 'min_cell_length'
#' #####################################
#' 
#' # we can use the 'max_cell_length' and 'min_cell_length' parameters to control the
#' # maximum and minimum cell sizes
#' qt4 = qt_create(rast, split_threshold = .15, split_method = "range", 
#'    max_cell_length = 1000, adj_type="expand")
#' qt5 = qt_create(rast, split_threshold = .15, split_method = "range", 
#'    min_cell_length = 1000, adj_type="expand")
#' 
#' par(mfrow=c(1,3))
#' qt_plot(qt1, crop=TRUE, na_col=NULL, main="no cell length restrictions")
#' qt_plot(qt4, crop=TRUE, na_col=NULL, main="max cell length = 1000")
#' qt_plot(qt5, crop=TRUE, na_col=NULL, main="min cell length = 1000")
#' par(mfrow=c(1,1))
#' 
#' #####################################
#' # using 'split_if_any_NA' and 'split_if_all_NA'
#' #####################################
#' 
#' # split quadrants with all NA values - this will result in NA quadrants being split
#' # to the smallest possible cell size
#' qt6 = qt_create(rast, split_threshold=.15, split_method="range", split_if_all_NA=TRUE)
#' # don't force quadrants with NA cells to automatically split - note that this
#' # can produce rather unexpected results (see the plot of qt7)
#' qt7 = qt_create(rast, split_threshold=.15, split_method="range", split_if_any_NA=FALSE)
#' # 'split_if_any_NA=FALSE' can be used in conjunction with 'max_cell_size' to 
#' # avoid tiny cells on the border of an irregularly shaped raster
#' qt8 = qt_create(rast, split_threshold=.15, split_method="range", 
#'    split_if_any_NA=FALSE, max_cell_length=1000)
#' 
#' par(mfrow=c(1,3))
#' qt_plot(qt6, border_lwd=.4)
#' qt_plot(qt7)
#' qt_plot(qt8)
#' par(mfrow=c(1,1))
#' 
#' #####################################
#' # using 'split_method' and 'combine_method'
#' #####################################
#' 
#' # use the standard deviation instead of the range
#' qt9 = qt_create(rast, split_threshold=.1, split_method = "sd")
#' # use the min to aggregate values rather than the mean
#' qt10 = qt_create(rast, split_threshold=.1, split_method = "sd", combine_method="min")
#' 
#' # compare the two quadtrees - note that their structures are identical
#' par(mfrow=c(1,2))
#' qt_plot(qt9, crop=TRUE, na_col=NULL, main="split_method='sd', combine_method='mean'", zlim=c(0,1))
#' qt_plot(qt10, crop=TRUE, na_col=NULL, main="split_method='sd', combine_method='min'", zlim=c(0,1))
#' par(mfrow=c(1,1))
#' 
#' #####################################
#' # using custom split and combine functions
#' #####################################
#' 
#' # custom split function - split a cell if any of the values are below a given value
#' split_fun = function(vals, args){ 
#'   if(any(is.na(vals))){ #check for NAs first
#'     return(TRUE); #if there are any NAs we'll split automatically
#'   } else {
#'     return(any(vals < args$threshold))
#'   }
#' }
#' 
#' qt11 = qt_create(rast, split_method="custom", split_fun=split_fun, 
#'                  split_args=list(threshold=.8))
#' qt_plot(qt11, crop=TRUE, na_col=NULL, border_lwd=.5)
#' 
#' # custom combine function - if the mean of the values is less than 
#' # 'threshold', set the cell value to 'low_val'. If it's greater
#' # than 'threshold', set the cell value to 'high_val'
#' cmb_fun = function(vals, args){
#'   if(any(is.na(vals))){
#'     return(NA)
#'   }
#'   if(mean(vals) < args$threshold){
#'     return(args$low_val)
#'   } else {
#'     return(args$high_val)   
#'   } 
#' }
#' 
#' qt12 = qt_create(rast, split_threshold = .1, split_method="range", combine_method="custom",
#'                  combine_fun = cmb_fun, combine_args = list(threshold=.5, low_val=0, high_val=1))
#' qt_plot(qt12, crop=TRUE, na_col=NULL)
#' 
#' # note that the split and combine functions are required to have an 'args'
#' # parameter, but they don't have to use it
#' cmb_fun2 = function(vals, args){
#'   return(max(vals) - min(vals))
#' }
#' 
#' qt13 = qt_create(rast, split_threshold = .1, split_method = "range", 
#'                  combine_method="custom", combine_fun = cmb_fun2)
#' qt_plot(qt13, crop=TRUE, na_col=NULL, border_lwd=.5)
#' 
#' #####################################
#' # using template quadtrees
#' #####################################
#' # 'habitat_roads' has the exact same extent and resolution as 'rast' - it has
#' # 1 where a road occurs and 0 otherwise
#' data(habitat_roads)
#' template = habitat_roads
#' 
#' plot(template)
#' 
#' # we can use a custom function so that a quadrant is split if it contains any 1's
#' split_if_one = function(vals, args){
#'   if(any(vals == 1, na.rm=TRUE)) return(TRUE)
#'   return(FALSE)
#' }
#' qt_template = qt_create(template, split_method="custom", split_fun=split_if_one, 
#'    split_threshold=.01)
#' # now use the template to create a quadtree from 'rast'
#' qt14 = qt_create(rast, template_quadtree = qt_template)
#' 
#' par(mfrow=c(1,2))
#' qt_plot(qt_template, crop=TRUE, na_col=NULL, border_lwd=.5)
#' qt_plot(qt14, crop=TRUE, na_col=NULL, border_lwd=.5)
#' par(mfrow=c(1,1))
qt_create <- function(x, split_threshold=NULL, split_method = "range", split_fun=NULL, split_args=list(), split_if_any_NA=TRUE, split_if_all_NA=FALSE, combine_method = "mean", combine_fun=NULL, combine_args=list(), max_cell_length=NULL, min_cell_length=NULL, adj_type="expand", resample_n_side=NULL, resample_pad_NAs=TRUE, extent=NULL, proj4string=NULL, template_quadtree=NULL){
  #validate inputs - this may be over the top, but many of these values get passed to C++ functionality, and if they're the wrong type the errors that are thrown are totally unhelpful - by type-checking them right away, I can provide easy-to-interpret error messages rather than messages that provide zero help
  #also, this is a complex function with a ton of options, and I want the errors to clearly point the user to the problem 
  if(!inherits(x, c("matrix", "RasterLayer"))) stop(paste0('"x" must be a "matrix" or "RasterLayer" - an object of class "', paste(class(x), collapse='" "'), '" was provided instead'))
  if(is.null(template_quadtree) && split_method != "custom" && ((!is.numeric(split_threshold) && !is.null(split_threshold)) || length(split_threshold) != 1)) stop(paste0("'split_threshold' must be a 'numeric' vector of length 1"))
  if(!is.function(split_fun) && !is.null(split_fun)) stop(paste0("'split_fun' must be a function"))  
  if(!is.list(split_args) && !is.null(split_args)) stop(paste0("'split_args' must be a list"))
  if(!is.logical(split_if_any_NA) || length(split_if_any_NA) != 1) stop("'split_if_any_NA' must be a 'logical' vector of length 1")
  if(!is.logical(split_if_all_NA) || length(split_if_all_NA) != 1) stop("'split_if_all_NA' must be a 'logical' vector of length 1")
  if((!is.null(max_cell_length)) && (!is.numeric(max_cell_length) || length(max_cell_length) != 1)) stop("'max_cell_length' must be a 'numeric' vector with length 1")
  if((!is.null(min_cell_length)) && (!is.numeric(min_cell_length) || length(min_cell_length) != 1)) stop("'min_cell_length' must be a 'numeric' vector with length 1")
  if(!is.character(split_method) || length(split_method) != 1) stop("'split_method' must be a character vector with length 1")
  if(!is.character(combine_method) || length(combine_method) != 1) stop("'combine_method' must be a character vector with length 1")
  if(!is.function(combine_fun) && !is.null(combine_fun)) stop(paste0("'combine_fun' must be a function"))
  if(!is.list(combine_args) && !is.null(combine_args)) stop(paste0("'combine_args' must be a list"))
  if(!(split_method %in% c("range", "sd", "custom"))) stop(paste0("Invalid valid value given for 'split_method'. Acceptable values are 'range', 'sd', or 'custom'."))
  if(!(combine_method %in% c("mean", "median", "min", "max", "custom"))) stop(paste0("Invalid value given for 'combine_method'. Acceptable values are 'mean', 'median', 'min', 'max', or 'custom'."))
  if(split_method != "custom" && is.null(split_threshold) && is.null(template_quadtree)) stop(paste0("When 'split_method' is not 'custom' and 'template_quadtree' is NULL, a value is required for 'split_threshold'"))
  if(split_method == "custom" && is.null(split_fun)) stop(paste0("When 'split_method' is 'custom', a function must be provided to 'split_fun'"))
  if(combine_method == "custom" && is.null(combine_fun)) stop(paste0("When 'combine_method' is 'custom', a function must be provided to 'combine_fun'"))
  if(!is.null(split_fun)){
    split_params = methods::formalArgs(split_fun)
    if(!all(split_params == c("vals", "args")) || is.null(split_params)) stop("'split_fun' must accept two arguments - 'vals' and 'args', in that order.")
  }
  if(!is.null(combine_fun)){
    combine_params = methods::formalArgs(combine_fun)
    if(!all(combine_params == c("vals", "args")) || is.null(combine_params)) stop("'combine_fun' must accept two arguments - 'vals' and 'args', in that order.")
  }
  if(split_method != "custom" && !is.null(split_fun)) warning("A function was provided to 'split_fun', but 'split_method' was not set to 'custom', so 'split_fun' will be ignored.")
  if(combine_method != "custom" && !is.null(combine_fun)) warning("A function was provided to 'combine_fun', but 'combine_method' was not set to 'custom', so 'combine_fun' will be ignored.")
  if(!is.character(adj_type) || length(adj_type) != 1) stop("'adj_type' must be a character vector with length 1")
  if(!(adj_type %in% c("expand", "resample", "none"))) stop("Invalid value given for 'adj_type'. Valid values are 'expand', 'resample', or 'none'.")
  if(adj_type == "resample" && (!is.numeric(resample_n_side) || length(resample_n_side) != 1)) stop("'resample_n_side' must be an integer vector with length 1.")  
  if(adj_type == "resample" && (!is.logical(resample_pad_NAs) || length(resample_pad_NAs) != 1)) stop("'resample_pad_NAs' must be an logical vector with length 1.")  
  if(!is.null(extent) && ((!inherits(extent, "Extent") && !is.numeric(extent)) || (is.numeric(extent) && length(extent) != 4))) stop("'extent' must either be an 'Extent' object or a numeric vector with 4 elements (xmin, xmax, ymin, ymax)")
  if(!is.null(extent) && "RasterLayer" %in% (class(x))) warning("a value for 'extent' was provided, but it will be ignored since 'x' is a raster (the extent will be derived from the raster itself)")
  if(!is.null(proj4string) && "RasterLayer" %in% (class(x))) warning("a value for 'proj4string' was provided, but it will be ignored since 'x' is a raster (the proj4string will be derived from the raster itself)")
  if(!is.null(template_quadtree) && !inherits(template_quadtree, "Rcpp_quadtree")) stop("'template_quadtree' must be a quadtree object (i.e. have class 'Rcpp_quadtree')")
  
  if(is.null(max_cell_length)) max_cell_length = -1 #if `max_cell_length` is not provided, set it to -1, which indicates no limit
  if(is.null(min_cell_length)) min_cell_length = -1 #if `min_cell_length` is not provided, set it to -1, which indicates no limit
  
  if(is.matrix(x)){ #if x is a matrix, convert it to a raster
    if(is.null(extent)){
      if(is.null(template_quadtree)){
        extent = raster::extent(0,ncol(x),0,nrow(x))
      } else {
        extent = qt_extent(template_quadtree)
      }
    }
    proj4string = tryCatch(raster::crs(proj4string), error=function(cond){ #if the proj4string is invalid, use an empty string for 'proj4string'
      message("warning in 'qt_create()': invalid 'proj4string' provided - no projection will be assigned")
      return(raster::crs(""))
    })
    x = raster::raster(x, extent[1], extent[2], extent[3], extent[4], crs=proj4string)
  }
  
  ext = raster::extent(x)
  dim = c(ncol(x), nrow(x))
  
  #if adj_type is either "expand" or "resample", we'll adjust the dimensions of the raster
  if(adj_type == "expand"){
    nXLog2 = log2(raster::ncol(x)) #we'll use this to find the smallest number greater than 'ncol' that is also a power of 2
    nYLog2 = log2(raster::nrow(x)) #same as above, but for the number of rows
    if(((nXLog2 %% 1) != 0) || (nYLog2 %% 1 != 0) || (raster::nrow(x) != raster::ncol(x))){  #check if the dimensions are a power of 2 or if the dimensions aren't the same (i.e. it's not square)
      #calculate the new extent
      newN = max(c(2^ceiling(nXLog2), 2^ceiling(nYLog2)))
      newExt = raster::extent(x)
      newExt[2] = newExt[1] + raster::res(x)[1] * newN
      newExt[4] = newExt[3] + raster::res(x)[2] * newN
      
      #expand the raster
      x = raster::extend(x,newExt)
    }
  } else if(adj_type == "resample"){
    if(is.null(resample_n_side)) { stop("'adj_type' is 'resample', but 'resample_n_side' is not specified. Please provide a value for 'resample_n_side'.")}
    if(log2(resample_n_side) %% 1 != 0) { warning(paste0("'resample_n_side' was given as ", resample_n_side, ", which is not a power of 2. Are you sure these are the dimensions you want? This will result in the smallest possible resolution of the quadtree being larger than the resolution of the raster"))}
    
    newExt = raster::extent(x)
    if(resample_pad_NAs){
      #first we need to make it square
      newN = max(c(raster::nrow(x), raster::ncol(x))) #get the larger dimension then
      #now expand the extent
      newExt[2] = newExt[1] + raster::res(x)[1] * newN 
      newExt[4] = newExt[3] + raster::res(x)[2] * newN
      x = raster::extend(x,newExt)
    }
    #now we can resample
    rastTemplate = raster::raster(newExt, nrow=resample_n_side, ncol=resample_n_side, crs=raster::crs(x))
    x = raster::resample(x, rastTemplate, method = "ngb")
  }
  
  #create the quadtree object (but we haven't actually constructed the quadtree yet)
  qt = methods::new(quadtree, raster::extent(x)[1:2], raster::extent(x)[3:4], c(max_cell_length, max_cell_length), c(min_cell_length, min_cell_length), split_if_all_NA, split_if_any_NA)
  
  #deal with any NULL parameters
  blank_fun = function(){}
  if(is.null(split_fun)) split_fun = blank_fun
  if(is.null(split_threshold)) split_threshold = -1
  if(is.null(combine_fun)) combine_fun = blank_fun
  if(is.null(template_quadtree)){
    template_quadtree = methods::new(quadtree)    
  }
  #construct the quadtree
  qt$createTree(raster::as.matrix(x), split_method, split_threshold, combine_method, split_fun, split_args, combine_fun, combine_args, template_quadtree)
  qt$setOriginalValues(ext[1], ext[2], ext[3], ext[4], dim[1], dim[2])
  qt$setProjection(raster::projection(x))
  return(qt)
}