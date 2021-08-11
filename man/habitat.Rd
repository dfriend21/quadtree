\name{habitat}
\alias{habitat}
\alias{habitat_roads}
\docType{data}
\title{
Sample raster data for the 'quadtree' package
}
\description{
'habitat' is a raster containing habitat suitability values where each cell takes on a value between 0 and 1.
'habitat_roads' has the exact same footprint as 'habitat', but the values represent the presence/absence of roads in that cell. 1 indicates presence, while 0 indicates absence.
}
\usage{
data("habitat")
data("habitat_roads")
}
\format{
'RasterLayer' (from the 'raster' package)
}
\details{
These rasters are included for two reasons: first, thet provide the datasets that are
used for the examples. Second, they provide easy-to-access datasets for users
to experiment with when learning about the 'quadtree' package.
}
\examples{
data("habitat")
data("habitat_roads")
}
\keyword{datasets}