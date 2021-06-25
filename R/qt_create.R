#' Create a quadtree from gridded data
#'
#' @param x a \code{raster} or a \code{matrix}. If \code{x} is a \code{matrix},
#'   the \code{extent} and \code{proj4string} parameters can be used to set the
#'   extent and projection of the quadtree. If \code{x} is a \code{raster}, the
#'   extent and projection are derived from the raster.
#' @param range_limit numeric; if the cell values within a quadrant have a range
#'   larger than this value, the quadrant is split. See 'Details' for more
#' @param max_cell_length double; the maximum size allowed for a quadtree cell.
#'   If \code{NULL} no restrictions are placed on the quadtree cell size. See
#'   'Details' for more
#' @param adj_type character; either \code{'expand'} or \code{'resample'}. See
#'   'Details' for more.
#' @param resample_n_side integer; if \code{adj_type} is \code{'expand'}, this
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
#' @details A quadtree is created from a raster by successively dividing the
#'   raster/matrix into smaller and smaller cells, with the decision on whether
#'   to divide a cell determined by \code{range_limit}. Initially, all of the
#'   cells in the raster are considered. If the difference between the maximum
#'   and minimum cell values exceeds \code{range_limit}, the raster is divided
#'   into four quadrants - otherwise, the raster is not divided further and the
#'   mean of all values in the raster is taken as the value for the resulting
#'   cell. Then, the process is repeated for each of those 'child' cells, and
#'   then for their children, and so on and so forth, until either
#'   \code{range_limit} is not exceeded or the smallest possible cell size has
#'   been reached.
#'
#'   If a quadrant contains both NA cells and non-NA cells, that quadrant is
#'   automatically divided. However, if a quadrant consists entirely of NA
#'   cells, that cell is not divided further (even if the cell is larger than
#'   \code{max_cell_length}).
#'
#'   If a given quadrant has dimensions that are not divisible by 2 (for
#'   example, 5x5), then the process stops. Because of this, only rasters that
#'   have dimensions that are a power of 2 can be divided down to their smallest
#'   cell size. In addition, the rasters should be square.
#'
#'   If \code{max_cell_length} is not \code{NA}, then the maximum cell size in
#'   the resulting quadtree will be \code{max_cell_length}. This essentially
#'   forces any quadrants larger than \code{max_cell_length} to split. The one
#'   exception is that a quadrant that contains entirely \code{NA} values will
#'   not be split.
#'
#'   To create quadtrees from rasters that have dimensions that are not a power
#'   of two and are not square, two options are provided. The choice of method
#'   is determined by the \code{adj_type} parameter.
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
#'   can then be used to create a quadtree.
#' @examples
#' #create raster of random values
#' nrow = 57
#' ncol = 75
#' rast = raster(matrix(runif(nrow*ncol), nrow=nrow, ncol=ncol), xmn=0, xmx=ncol, ymn=0, ymx=nrow)
#'
#' #create quadtree using the 'expand' method - automatically adds NA cells to
#' bring the dimensions to 128 x 128 before creating the quadtree
#' qt1 = qt_create(rast, range_limit = .9, adj_type="expand")
#' qt_plot(qt1) #plot the quadtree
#' qt_plot(qt1, crop=TRUE) #we can use 'crop=TRUE' if we don't want to see the padded NA's
#'
#' #create quadtree using the 'resample' method - we'll resample to 128 since it's a power of 2
#' qt2 = qt_create(rast, range_limit = .9, adj_type="resample", resample_n_side = 128)
#' qt_plot(qt2)
#' qt_plot(qt2, crop=TRUE)
#'
#' #now use the 'max_cell_length' argument to force any cells with sides longer
#' #than 2 to split
#' qt3 = qt_create(rast, range_limit = .9, max_cell_length = 2, adj_type="expand")
#'
#' #compare qt1 (no max cell length) and qt3 (max cell length = 2)
#' par(mfrow=c(1,2))
#' qt_plot(qt1,crop=TRUE, main="no max cell length")
#' qt_plot(qt3,crop=TRUE, main="max cell length = 2")
qt_create <- function(x, range_limit, max_cell_length=NULL, adj_type="expand", resample_n_side=NULL, extent=NULL, proj4string=NULL){
  if(is.null(max_cell_length)) max_cell_length = -1 #if `max_cell_length` is not provided, set it to -1, which indicates no limit
  
  if("matrix" %in% class(x)){ #if x is a matrix, convert it to a raster
    if(is.null(extent)){
      extent = raster::extent(0,ncol(x),0,nrow(x))
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
  
  qt = new(quadtree, raster::as.matrix(x), raster::extent(x)[1:2], raster::extent(x)[3:4], range_limit, max_cell_length, max_cell_length)
  qt$setOriginalValues(ext[1], ext[2], ext[3], ext[4], dim[1], dim[2])
  qt$setProjection(projection(x))
  return(qt)
}
