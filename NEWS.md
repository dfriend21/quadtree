# quadtree 0.1.4 (development version) (10/9/2021)

## bug fixes

* No longer exports the `extract()` generic from `raster` - instead, it is set via `setGeneric()` in "R/generics.R". This is an attempted fix for an error - in some cases the `extract()` generic with signature "Quadtree", "matrix" was not being found.

# quadtree 0.1.3 (development version)

## enhancements and modifications

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
