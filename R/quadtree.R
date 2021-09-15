#' @include generics.R
#'
#' @name quadtree
#' @aliases quadtree,ANY-method
#' @title Create a \code{Quadtree} from a raster or matrix
#' @description Creates a \code{\link{Quadtree}} from a
#' \code{\link[raster:RasterLayer-class]{RasterLayer}} or a matrix.
#' @param x a \code{\link[raster:RasterLayer-class]{RasterLayer}} or a
#'   \code{matrix}. If \code{x} is a \code{matrix}, the \code{extent} and
#'   \code{proj4string} parameters can be used to set the extent and projection
#'   of the quadtree. If \code{x} is a
#'   \code{\link[raster:RasterLayer-class]{RasterLayer}}, the extent and
#'   projection are derived from the raster.
#' @param split_threshold numeric; the threshold value used by the split method
#'   (specified by \code{split_method}) to decide whether to split a quadrant.
#'   If the value for a quadrant is greater than this value, it is split into
#'   its four child cells. If \code{split_method} is \code{"custom"}, this
#'   parameter is ignored.
#' @param split_method character; one of \code{"range"} (the default),
#'   \code{"sd"} (standard deviation), or \code{"custom"}. Determines the method
#'   used for calculating the value used to determine whether or not to split a
#'   quadrant (this calculated value is compared with \code{split_threshold} to
#'   decide whether to split a cell). If \code{"custom"}, a function must be
#'   supplied to \code{split_fun}. See 'Details' for more.
#' @param split_fun function; function used on each quadrant to decide whether
#'   or not to split the quadrant. Only used when \code{split_method} is
#'   \code{"custom"}. Must take two arguments, \code{vals} (a numeric vector of
#'   the cell values in a quadrant) and \code{args} (a named list of arguments
#'   used within the function), and must output \code{TRUE} if the quadrant is
#'   to be split and \code{FALSE} otherwise. It must be able to handle \code{NA}
#'   values - if \code{NA} is ever returned, an error will occur.
#' @param split_args list; named list that contains the arguments needed by
#'   \code{split_fun}. This list is given to the \code{args} parameter of
#'   \code{split_fun}.
#' @param split_if_any_na boolean; if \code{TRUE} (the default), a quadrant is
#'   automatically split if any of the values within the quadrant are \code{NA}.
#' @param split_if_all_na boolean; if \code{FALSE} (the default), a quadrant
#'   that contains only \code{NA} values is not split. If \code{TRUE}, quadrants
#'   that contain all \code{NA} values are split to the smallest possible cell
#'   size.
#' @param combine_method character; one of \code{"mean"}, \code{"median"},
#'   \code{"min"}, \code{"max"}, or \code{"custom"}. Determines the method used
#'   for aggregating the values of multiple cells into a single value for a
#'   larger, aggregated cell. Default is \code{"mean"}. If \code{"custom"}, a
#'   function must be supplied to \code{combine_fun}.
#' @param combine_fun function; function used to calculate the value of a
#'   quadrant. Only used when \code{combine_method} is \code{"custom"}. Must
#'   take two arguments, \code{vals} (a numeric vector of the cell values in a
#'   quadrant) and \code{args} (a named list of arguments used within the
#'   function), and must output a single numeric value, which will be used as
#'   the cell value.
#' @param combine_args list; named list that contains the arguments needed by
#'   \code{combine_fun}. This list is given to the \code{args} parameter of
#'   \code{combine_fun}.
#' @param max_cell_length numeric; the maximum side length allowed for a
#'   quadtree cell. Any quadrants larger than \code{max_cell_length} will
#'   automatically be split. If \code{NULL} (the default) no restrictions are
#'   placed on the maximum cell length.
#' @param min_cell_length numeric; the minimum side length allowed for a
#'   quadtree cell. A quadrant will not be split if its children would be
#'   smaller than \code{min_cell_length}. If \code{NULL} (the default) no
#'   restrictions are placed on the minimum cell length.
#' @param adj_type character; one of \code{"expand"} (the default),
#'   \code{"resample"}, or \code{"none"}. Specifies the method used to adjust
#'   \code{x} so that its dimensions are suitable for quadtree creation (i.e.
#'   square and with the number of cells in each direction being a power of 2).
#'   See 'Details' for more on the two methods of adjustment.
#' @param resample_n_side integer; if \code{adj_type} is \code{'resample'}, this
#'   number is used to determine the dimensions to resample the raster to.
#' @param resample_pad_nas boolean; only applicable if \code{adj_type} is
#'   \code{'resample'}. If \code{TRUE} (the default), \code{NA}s are added to
#'   the shorter side of the raster to make it square before resampling. This
#'   ensures that the cells of the resulting quadtree will be square. If
#'   \code{FALSE}, no \code{NA}s are added - the cells in the quadtree will not
#'   be square.
#' @param extent \code{\link[raster:Extent-class]{Extent}} object or else a
#'   four-element numeric vector describing the extent of the data (in this
#'   order: xmin, xmax, ymin, ymax). Only used when \code{x} is a matrix - this
#'   parameter is ignored if \code{x} is a raster since the extent is derived
#'   directly from the raster. If no value is provided and \code{x} is a matrix,
#'   the extent is assumed to be \code{c(0,ncol(x),0,nrow(x))}.
#' @param proj4string character; proj4string describing the projection of the
#'   data. Only used when \code{x} is a matrix - this parameter is ignored if
#'   \code{x} is a raster since the proj4string of the raster is automatically
#'   used. If no value is provided and \code{x} is a matrix, the proj4string of
#'   the quadtree is set to \code{NA}.
#' @param template_quadtree \code{\link{Quadtree}}; if provided, the new
#'   quadtree will be created so that it has the exact same structure as the
#'   template quadtree. Thus, no split function is used because the decision
#'   about whether to split is pre-determined by the template quadtree. The
#'   raster used to create the template quadtree should have the exact same
#'   extent and dimensions as \code{x}. If \code{template_quadtree} is
#'   non-\code{NULL}, all \code{split_}* parameters are disregarded, as are
#'   \code{max_cell_length} and \code{min_cell_length}.
#' @details
#'   The 'quadtree-creation' vignette contains detailed explanations and
#'   examples for all of the various creation options - run
#'   \code{vignettes("quadtree-creation", package = "quadtree")} to view the
#'   vignette.
#'
#'   If \code{adj_type} is \code{"expand"}, \code{NA} cells are added to the
#'   raster in order to create an expanded raster whose dimensions are a power
#'   of two. The smallest number that is a power of two but greater than the
#'   larger dimension is used as the dimensions of the expanded raster. If
#'   \code{adj_type} is \code{"resample"}, the raster is resampled to a raster
#'   with \code{resample_n_side} rows and columns. If \code{resample_pad_nas} is
#'   \code{TRUE}, \code{NA} rows or columns are are added to the shorter
#'   dimension before resampling to make the raster square. This ensures that
#'   the quadtree cells will be square (assuming the original raster cells were
#'   square).
#'
#'   When \code{split_method} is \code{"range"}, the difference between the
#'   maximum and minimum cell values in a quadrant is calculated - if this value
#'   is greater than \code{split_threshold}, the quadrant is split. When
#'   \code{split_method} is \code{"sd"}, the standard deviation of the cell
#'   values in a quadrant is calculated - if this value is greater than
#'   \code{split_threshold}, the quadrant is split.
#' @return a \code{\link{Quadtree}}
#' @examples
#' ####### NOTE #######
#' # see the "quadtree-creation" vignette for more details and examples of all
#' # the different parameter options:
#' # vignette("quadtree-creation", package = "quadtree")
#' ####################
#'
#' library(quadtree)
#' data(habitat)
#'
#' qt <- quadtree(habitat, .15)
#' plot(qt)
#' # we can make it look nicer by customizing the plotting parameters
#' plot(qt, crop = TRUE, na_col = NULL, border_lwd = .3)
#'
#' # try a different splitting method
#' qt <- quadtree(habitat, .05, "sd")
#' plot(qt)
#'
#' # ---- using a custom split function ----
#'
#' # split a cell if any of the values are below a given value
#' split_fun = function(vals, args) {
#'   if (any(is.na(vals))) { # check for NAs first
#'     return(TRUE) # if there are any NAs we'll split automatically
#'   } else {
#'     return(any(vals < args$threshold))
#'   }
#' }
#'
#' qt <- quadtree(habitat, split_method = "custom", split_fun = split_fun,
#'                 split_args = list(threshold = .8))
#' plot(qt)
#' @export
setMethod("quadtree", signature(x = "ANY"),
  function(x, split_threshold = NULL, split_method = "range", split_fun = NULL,
           split_args = list(), split_if_any_na = TRUE, split_if_all_na = FALSE,
           combine_method = "mean", combine_fun = NULL, combine_args = list(),
           max_cell_length = NULL, min_cell_length = NULL, adj_type = "expand",
           resample_n_side = NULL, resample_pad_nas = TRUE, extent = NULL,
           proj4string = NULL, template_quadtree = NULL) {
    # validate inputs - this may be over the top, but many of these values get passed to C++ functionality, and if they're the wrong type the errors that are thrown are totally unhelpful - by type-checking them right away, I can provide easy-to-interpret error messages rather than messages that provide zero help
    # also, this is a complex function with a ton of options, and this function is basically the entryway into the entire package, so I want the errors to clearly point the user to the problem
    if (!inherits(x, c("matrix", "RasterLayer"))) stop(paste0('"x" must be a "matrix" or "RasterLayer" - an object of class "', paste(class(x), collapse = '" "'), '" was provided instead'))
    if (is.null(template_quadtree) && split_method != "custom" && ((!is.numeric(split_threshold) && !is.null(split_threshold)) || length(split_threshold) != 1)) stop(paste0("'split_threshold' must be a 'numeric' vector of length 1"))
    if (!is.function(split_fun) && !is.null(split_fun)) stop(paste0("'split_fun' must be a function"))
    if (!is.list(split_args) && !is.null(split_args)) stop(paste0("'split_args' must be a list"))
    if (!is.logical(split_if_any_na) || length(split_if_any_na) != 1) stop("'split_if_any_na' must be a 'logical' vector of length 1")
    if (!is.logical(split_if_all_na) || length(split_if_all_na) != 1) stop("'split_if_all_na' must be a 'logical' vector of length 1")
    if ((!is.null(max_cell_length)) && (!is.numeric(max_cell_length) || length(max_cell_length) != 1)) stop("'max_cell_length' must be a 'numeric' vector with length 1")
    if ((!is.null(min_cell_length)) && (!is.numeric(min_cell_length) || length(min_cell_length) != 1)) stop("'min_cell_length' must be a 'numeric' vector with length 1")
    if (!is.character(split_method) || length(split_method) != 1) stop("'split_method' must be a character vector with length 1")
    if (!is.character(combine_method) || length(combine_method) != 1) stop("'combine_method' must be a character vector with length 1")
    if (!is.function(combine_fun) && !is.null(combine_fun)) stop(paste0("'combine_fun' must be a function"))
    if (!is.list(combine_args) && !is.null(combine_args)) stop(paste0("'combine_args' must be a list"))
    if (!(split_method %in% c("range", "sd", "custom"))) stop(paste0("Invalid valid value given for 'split_method'. Acceptable values are 'range', 'sd', or 'custom'."))
    if (!(combine_method %in% c("mean", "median", "min", "max", "custom"))) stop(paste0("Invalid value given for 'combine_method'. Acceptable values are 'mean', 'median', 'min', 'max', or 'custom'."))
    if (split_method != "custom" && is.null(split_threshold) && is.null(template_quadtree)) stop(paste0("When 'split_method' is not 'custom' and 'template_quadtree' is NULL, a value is required for 'split_threshold'"))
    if (split_method == "custom" && is.null(split_fun)) stop(paste0("When 'split_method' is 'custom', a function must be provided to 'split_fun'"))
    if (combine_method == "custom" && is.null(combine_fun)) stop(paste0("When 'combine_method' is 'custom', a function must be provided to 'combine_fun'"))
    if (!is.null(split_fun)) {
      split_params <- methods::formalArgs(split_fun)
      if (!all(split_params == c("vals", "args")) || is.null(split_params)) stop("'split_fun' must accept two arguments - 'vals' and 'args', in that order.")
    }
    if (!is.null(combine_fun)) {
      combine_params <- methods::formalArgs(combine_fun)
      if (!all(combine_params == c("vals", "args")) || is.null(combine_params)) stop("'combine_fun' must accept two arguments - 'vals' and 'args', in that order.")
    }
    if (split_method != "custom" && !is.null(split_fun)) warning("A function was provided to 'split_fun', but 'split_method' was not set to 'custom', so 'split_fun' will be ignored.")
    if (combine_method != "custom" && !is.null(combine_fun)) warning("A function was provided to 'combine_fun', but 'combine_method' was not set to 'custom', so 'combine_fun' will be ignored.")
    if (!is.character(adj_type) || length(adj_type) != 1) stop("'adj_type' must be a character vector with length 1")
    if (!(adj_type %in% c("expand", "resample", "none"))) stop("Invalid value given for 'adj_type'. Valid values are 'expand', 'resample', or 'none'.")
    if (adj_type == "resample" && (!is.numeric(resample_n_side) || length(resample_n_side) != 1)) stop("'resample_n_side' must be an integer vector with length 1.")
    if (adj_type == "resample" && (!is.logical(resample_pad_nas) || length(resample_pad_nas) != 1)) stop("'resample_pad_nas' must be an logical vector with length 1.")
    if (!is.null(extent) && ((!inherits(extent, "Extent") && !is.numeric(extent)) || (is.numeric(extent) && length(extent) != 4))) stop("'extent' must either be an 'Extent' object or a numeric vector with 4 elements (xmin, xmax, ymin, ymax)")
    if (!is.null(extent) && "RasterLayer" %in% (class(x))) warning("a value for 'extent' was provided, but it will be ignored since 'x' is a raster (the extent will be derived from the raster itself)")
    if (!is.null(proj4string) && "RasterLayer" %in% (class(x))) warning("a value for 'proj4string' was provided, but it will be ignored since 'x' is a raster (the proj4string will be derived from the raster itself)")
    if (!is.null(template_quadtree) && !inherits(template_quadtree, "Quadtree")) stop("'template_quadtree' must be a 'Quadtree' object")

    if (is.null(max_cell_length)) max_cell_length <- -1 # if `max_cell_length` is not provided, set it to -1, which indicates no limit
    if (is.null(min_cell_length)) min_cell_length <- -1 # if `min_cell_length` is not provided, set it to -1, which indicates no limit

    if (is.matrix(x)) { # if x is a matrix, convert it to a raster
      if (is.null(extent)) {
        if (is.null(template_quadtree)) {
          extent <- raster::extent(0, ncol(x), 0, nrow(x))
        } else {
          extent <- extent(template_quadtree)
        }
      }
      proj4string <- tryCatch(raster::crs(proj4string), error = function(cond) { # if the proj4string is invalid, use an empty string for 'proj4string'
        message("warning in 'quadtree()': invalid 'proj4string' provided - no projection will be assigned")
        return(raster::crs(""))
      })
      x <- raster::raster(x, extent[1], extent[2], extent[3], extent[4], crs = proj4string)
    }

    ext <- raster::extent(x)
    dim <- c(ncol(x), nrow(x))

    # if adj_type is either "expand" or "resample", we'll adjust the dimensions of the raster
    if (adj_type == "expand") {
      nx_log2 <- log2(raster::ncol(x)) # we'll use this to find the smallest number greater than 'ncol' that is also a power of 2
      ny_log2 <- log2(raster::nrow(x)) # same as above, but for the number of rows
      if (((nx_log2 %% 1) != 0) ||
          (ny_log2 %% 1 != 0) ||
          (raster::nrow(x) != raster::ncol(x))) {  # check if the dimensions are a power of 2 or if the dimensions aren't the same (i.e. it's not square)
        # calculate the new extent
        new_n <- max(c(2^ceiling(nx_log2), 2^ceiling(ny_log2)))
        new_ext <- raster::extent(x)
        new_ext[2] <- new_ext[1] + raster::res(x)[1] * new_n
        new_ext[4] <- new_ext[3] + raster::res(x)[2] * new_n

        # expand the raster
        x <- raster::extend(x, new_ext)
      }
    } else if (adj_type == "resample") {
      if (is.null(resample_n_side)) stop("'adj_type' is 'resample', but 'resample_n_side' is not specified. Please provide a value for 'resample_n_side'.")
      if (log2(resample_n_side) %% 1 != 0) warning(paste0("'resample_n_side' was given as ", resample_n_side, ", which is not a power of 2. Are you sure these are the dimensions you want? This will result in the smallest possible resolution of the quadtree being larger than the resolution of the raster"))

      new_ext <- raster::extent(x)
      if (resample_pad_nas) {
        # first we need to make it square
        new_n <- max(c(raster::nrow(x), raster::ncol(x))) #get the larger dimension
        # now expand the extent
        new_ext[2] <- new_ext[1] + raster::res(x)[1] * new_n
        new_ext[4] <- new_ext[3] + raster::res(x)[2] * new_n
        x <- raster::extend(x, new_ext)
      }
      # now we can resample
      rast_template <- raster::raster(new_ext, nrow = resample_n_side,
                                      ncol = resample_n_side,
                                      crs = raster::crs(x))
      x <- raster::resample(x, rast_template, method = "ngb")
    }

    # create the quadtree object (but we haven't actually constructed the quadtree yet)
    qt <- methods::new("Quadtree")
    qt@ptr <- methods::new(CppQuadtree,
                           raster::extent(x)[1:2],
                           raster::extent(x)[3:4],
                           c(max_cell_length, max_cell_length),
                           c(min_cell_length, min_cell_length),
                           split_if_all_na,
                           split_if_any_na)

    # deal with any NULL parameters
    blank_fun <- function() {}
    if (is.null(split_fun)) split_fun <- blank_fun
    if (is.null(split_threshold)) split_threshold <- -1
    if (is.null(combine_fun)) combine_fun <- blank_fun
    if (is.null(template_quadtree)) {
      template_quadtree <- methods::new("Quadtree")
      template_quadtree@ptr <- methods::new(CppQuadtree)
    }
    # construct the quadtree
    qt@ptr$createTree(raster::as.matrix(x),
                      split_method,
                      split_threshold,
                      combine_method,
                      split_fun,
                      split_args,
                      combine_fun,
                      combine_args,
                      template_quadtree@ptr)
    qt@ptr$setOriginalValues(ext[1], ext[2], ext[3], ext[4], dim[1], dim[2])
    proj <- raster::projection(x)
    if (!is.na(proj)) {
      qt@ptr$setProjection(proj)
    } else {
      qt@ptr$setProjection("")
    }
    return(qt)
  }
)
