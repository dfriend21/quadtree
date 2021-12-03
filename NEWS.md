# quadtree 0.1.7 (development version) (12/3/2021)

### enhancements and modifications

* In the LCP functionality, added the ability to manually set the points use to represent cells (by default the centroids are used). This is especially useful for setting the start and end points of a LCP to the user-specified points - it helps reduce error caused by large cell sizes. 
  * Added a `new_points` parameter that accepts a matrix of points to be used instead of the cell centroids.
  * Removed the `use_original_end_points` parameter. This modified the end points after the LCP functionality had already been run. This is inferior to what I have now implemented, so I removed it. This can now be achieved using the `new_points` parameter of `lcp_finder()`.
  * Modified the LCP generics. For `lcp_finder()` and `find_lcp()` reduced the number of arguments used for method selection to one. I changed the name of the parameter no longer used for method selection to be more descriptive.
  * Created an overload of `find_lcp()` that accepts a `Quadtree`. It allows for LCPs to be found in one step (rather than having to use `lcp_finder()` and then `find_lcp()`). While it means that the `LcpFinder` object can't be reused, it is more convenient in cases where only a single LCP needs to be calculated.
  * In `find_lcp(<LcpFinder>)`, added the `allow_same_cell_path`, which allows for paths to be found between points that fall in the same cell.

# quadtree 0.1.6 (development version) (11/30/2021)

### bug fixes

* Fixed issues #8 and #9 (see issues for details)
* Fixed error in the unit test for `projection()`

# quadtree 0.1.5 (development version) (11/16/2021)

### bug fixes 

* Neighbor relationships were not being assigned when reading a quadtree from file - this was causing functionality like LCP to fail. Fixed this by using `assignNeighbors()` in `QuadtreeWrapper::readQuadtree()`. Also added unit tests to detect this bug.

### enhancements and modifications

* Added `write_quadtree_ptr()` for writing only the `Quadtree` pointer to file (`write_quadtree()` writes the `QuadtreeWrapper` object to file). This is for my own use - the average user will never need to use this.
* Added additional attributes to `Quadtree::serialize()` (previously, some attributes were not being serialized).
* Added `NodeWrapper::toString()` and made it available to R - this simply prints a summary of a `NodeWrapper` object.
* Stopped importing the `extent()` and `projection()` generics from `raster`. Relying on the `extract` generic from `raster` had caused the code to break (see news for previous version). I decided to stop importing generics from raster to avoid any future issues like this. This has the disadvantage of masking `extent()` and `projection()` from `raster`. This means users will need to preface the functions with the package names when using both packages, but it'll hopefully avoid issues caused by changes in `raster`.

# quadtree 0.1.4 (development version) (11/9/2021)

### bug fixes

* No longer exports the `extract()` generic from `raster` - instead, it is set via `setGeneric()` in "R/generics.R". This is an attempted fix for an error - in some cases the `extract()` generic with signature "Quadtree", "matrix" was not being found.

# quadtree 0.1.3 (development version)

### enhancements and modifications

* In `add_legend()`, added parameters for controlling text color, font, and size. Also renamed `ticks_x_pct` parameter to `text_x_pct` parameter for consistency.
* Changed default border width of plots (`border_lwd` parameter of `plot(<Quadtree>)`) to .4, since that typically looks nicer.
* Added a 'coefficient of variation' split function (used when `split_method` parameter of `quadtree()` is `"cv"`)

# quadtree 0.1.2 (CRAN version)

Responded to comments after CRAN submission. This led to the following changes:

* In `plot(<Quadtree>)`, switched to resetting `par()` using `on.exit()`.
* In all examples, added code to reset `par()` if it was changed.
* Removed the 'rapidjson' and 'rapidxml' libraries from within 'cereal'.
* Added additional copyright holder in 'DESCRIPTION'.

# quadtree 0.1.1

* Added a missing `#include` in `Matrix.cpp` that appeared to be causing the CRAN build to fail.
* Cleaned up `#include`s in C++ files - removed unnecessary `#includes` and order them in a way that is more readable.
* Removed `PointUtilities.h` and `PointUtilities.cpp`. Only a single function (`distBtwPoints()`) in this namespace was being used (in `LcpFinder.cpp`), and only once.
* Switched C++ functions to consistently require `Point` objects as parameters (rather than having `double x` and `double y` parameters). 
* Removed unnecessary member functions of `Point`.
* Cleaned up C++ comments.
* Changed output of `makeNeighborList()` (from `QuadtreeWrapper`) - removed ambiguous `hasChildren` column and instead added `hasChildren0` and `hasChildren1` columns. Modified `plot_Quadtree.R` to work with the new columns.
* Added unit tests for `summary(<Quadtree>)`, `summary(<LcpFinder>)`, `lines(<LcpFinder>)`, and `points(<LcpFinder>)`. Also added a unit test for `search_by_centroid` option of `lcp_finder()`.

# quadtree 0.1.0

* initial release
