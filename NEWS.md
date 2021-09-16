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
