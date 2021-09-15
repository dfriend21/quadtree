
<!-- README.md is generated from README.Rmd. Please edit that file -->

# `quadtree`: An R-package for region quadtrees

`quadtree` provides functionality for working with raster-like quadtrees
(called “region quadtrees”), which allow for variable-sized cells.

The package allows for flexibility in the quadtree creation process.
Several functions defining how to split and aggregate cells are
provided, and custom functions can be written for both of these
processes. In addition, quadtrees can be created using other quadtrees
as “templates”, so that the new quadtree has the identical structure as
the template quadtree.

The package also includes functionality for modifying quadtrees,
querying values, saving quadtrees to a file, and calculating least-cost
paths using the quadtree as a resistance surface.

## Installation

The package can be installed with the following R command:

``` r
devtools::install_github("dfriend21/quadtree")
```

## Documentation

Visit the [package
website](https://dfriend21.github.io/quadtree/index.html) for more
information.

## Example

A quadtree object is created from a raster or matrix:

``` r
library(quadtree)

data(habitat, package = "quadtree") # load sample data
qt <- quadtree(habitat, .03, "sd") # create a quadtree
```

<img src="man/figures/README-example_plot-1.png" width="100%" />

## Learning how to use the `quadtree` package

Three vignettes are included in this package - these are intended to
serve as an introduction to using the `quadtree` package. They can be
accessed online by visiting the
[website](https://dfriend21.github.io/quadtree/index.html) and selecting
the “Articles” tab on the top navigation bar. If you have installed the
package, you can see the available vignettes by running
`vignettes(package = "quadtree")` and view the vignettes using
`vignettes("vignette-name", package = "quadtree")`.

I’d recommend beginning with “Creating Quadtrees” - this covers the
process of creating quadtrees. Next, I’d suggest reading “Using
Quadtrees”, which covers methods for interacting and using a quadtree.
If you plan on using the least-cost path functionality, check out
“Finding LCPs”.
