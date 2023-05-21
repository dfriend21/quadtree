test_that("as_data_frame() runs without errors and produces expected output", {
  habitat <- terra::rast(system.file("extdata", "habitat.tif", package="quadtree"))
  qt <- expect_error(quadtree(habitat, .4), NA)

  df_term <- expect_error(as_data_frame(qt, TRUE), NA)
  df_all <- expect_error(as_data_frame(qt, FALSE), NA)

  expect_s3_class(df_term, "data.frame")
  expect_s3_class(df_all, "data.frame")

  expect_true(nrow(df_term) > 0)
  expect_true(nrow(df_all) > 0)

  expect_equal(qt@ptr$nNodes(), nrow(df_all))

  expect_true(nrow(df_term) < nrow(df_all))
})

test_that("as_raster() works", {
  habitat <- terra::rast(system.file("extdata", "habitat.tif", package="quadtree"))
  qt <- quadtree(habitat, .1, split_method = "sd")
  rst1 <- expect_error(as_raster(qt), NA)
  rst2 <- expect_error(as_raster(qt, habitat), NA)
  rst_template <- terra::rast(nrows = 189, ncols = 204,
                              xmin = 0, xmax = 30000, ymin = 10000, ymax = 45000)
  rst3 <- expect_error(as_raster(qt, rst_template), NA)

  pts1 <- terra::crds(rst1)
  pts2 <- terra::crds(rst2)
  pts3 <- terra::crds(rst3)

  expect_equal(quadtree::extract(qt, pts1), 
               terra::extract(rst1, pts1)[[1]])
  expect_equal(quadtree::extract(qt, pts2), 
               terra::extract(rst2, pts2)[[1]])
  expect_equal(quadtree::extract(qt, pts3), 
               terra::extract(rst3, pts3)[[1]])
})

test_that("as_vector() works", {
  mat <- matrix(runif(10000, 0, 1), nrow = 100)
  qt <- quadtree(mat, 0) # force it to split to the smallest cell size
  vec_term <- expect_error(as_vector(qt, TRUE), NA)
  vec_all <- expect_error(as_vector(qt, FALSE), NA)

  expect_true(inherits(vec_term, "numeric"))
  expect_true(inherits(vec_all, "numeric"))

  expect_true(length(vec_all) > length(vec_term))

  vec_term2 <- vec_term[!is.na(vec_term)]
  expect_true(length(vec_term2) == length(mat))
  expect_equal(sort(as.numeric(mat)), sort(vec_term2))
})

test_that("foreign object conversion functions run without errors", {
  habitat <- terra::rast(system.file("extdata", "habitat.tif", package="quadtree"))
  qt <- quadtree(habitat, .3, split_method = "sd")
  
  ch <- expect_error(as(qt, "character"), NA)
  sf <- expect_error(as(qt, "sf"), NA)
  v <- expect_error(as(qt, "SpatVector"), NA)
})

test_that("copy() runs without errors and produces expected output", {
  habitat <- terra::rast(system.file("extdata", "habitat.tif", package="quadtree"))
  qt1 <- quadtree(habitat, .3, split_method = "sd")
  qt2 <- expect_error(copy(qt1), NA)
  expect_s4_class(qt2, "Quadtree")

  df1 <- as_data_frame(qt1, FALSE)
  df2 <- as_data_frame(qt2, FALSE)

  expect_equal(df1, df2)
})

test_that("extent() runs without errors and produces expected output", {
  # library(terra)
  habitat <- terra::rast(system.file("extdata", "habitat.tif", package="quadtree"))
  qt1 <- quadtree(habitat, .3, split_method = "sd")
  expect_error(extent(qt1, original = FALSE), NA)
  qt_ext <- expect_error(extent(qt1, original = TRUE), NA)
  expect_equal(qt_ext[1:4], terra::ext(habitat)[1:4])
})

test_that("extract() runs without errors and returns correct values", {
  # library(terra)
  habitat <- terra::rast(system.file("extdata", "habitat.tif", package="quadtree"))
  # use 0 to make sure everything gets split as small as possible
  qt1 <- quadtree(habitat, 0)

  ext <- terra::ext(habitat)
  pts <- cbind(runif(1000, ext[1], ext[2]), runif(1000, ext[3], ext[4]))
  rst_ext <- terra::extract(habitat, pts)[[1]]
  qt_ext <- expect_error(extract(qt1, pts), NA)
  qt_ext[is.nan(qt_ext)] <- NA
  expect_equal(qt_ext, rst_ext)

  # make sure it works with the 'extents=TRUE' option too
  qt_ext2 <- expect_error(extract(qt1, pts, extents = TRUE), NA)
  expect_true("matrix" %in% class(qt_ext2))
  expect_true(nrow(qt_ext2) > 0)
  nums <- qt_ext2[, "value"]
  nums[is.nan(nums)] <- NA
  expect_equal(nums, rst_ext)
})

test_that("get_neighbors() works", {
  mat <- as.matrix(read.table("sample_data/8by8_01_matrix.txt", sep = ","))
  qt <- quadtree(mat, .1)

  pt <- c(5, 5)
  nbs <- expect_error(get_neighbors(qt, pt), NA)

  nb_centroids <- rbind(c(2.0, 6.0),
                        c(4.5, 6.5),
                        c(5.5, 6.5),
                        c(7.0, 7.0),
                        c(7.0, 5.0),
                        c(7.0, 3.0),
                        c(5.5, 3.5),
                        c(4.5, 3.5),
                        c(3.5, 3.5))
  expect_true(nrow(nbs) == nrow(nb_centroids))

  nb_ids <- extract(qt, nb_centroids, extents = TRUE)[, "id"]
  expect_equal(sort(nbs[, "id"]), sort(nb_ids))
})

test_that("n_cells() works", {
  habitat <- terra::rast(system.file("extdata", "habitat.tif", package="quadtree"))
  qt <- quadtree(habitat, .15)
  nc1 <- expect_error(n_cells(qt, TRUE), NA)
  nc2 <- expect_error(n_cells(qt, FALSE), NA)

  expect_true(nc2 > nc1)
})

test_that("n_cells(), as_vector(), and as_data_frame() agree on the number of
          nodes", {
  habitat <- terra::rast(system.file("extdata", "habitat.tif", package="quadtree"))
  qt <- quadtree(habitat, .15)

  nc_term <- n_cells(qt, TRUE)
  nc_all <- n_cells(qt, FALSE)

  vec_term <- as_vector(qt, TRUE)
  vec_all <- as_vector(qt, FALSE)

  df_term <- as_data_frame(qt, TRUE)
  df_all <- as_data_frame(qt, FALSE)

  expect_true(nc_term == length(vec_term) && nc_term == nrow(df_term))
  expect_true(nc_all == length(vec_all) && nc_all == nrow(df_all))
})

test_that("projection() runs without errors and returns correct value", {
  habitat <- terra::rast(system.file("extdata", "habitat.tif", package="quadtree"))
  terra::crs(habitat) <- "EPSG:27700"
  qt1 <- quadtree(habitat, .5)
  qt_proj <- expect_error(quadtree::projection(qt1), NA)
  expect_equal(qt_proj, terra::crs(terra::rast(habitat)))

  expect_error(quadtree::projection(qt1) <- "stuff", NA)
  expect_equal(quadtree::projection(qt1), "stuff")
})

test_that("read_quadtree() and write_quadtree() work", {
  habitat <- terra::rast(system.file("extdata", "habitat.tif", package="quadtree"))
  qt1 <- quadtree(habitat, .3, "sd")
  filepath <- tempfile()
  expect_error(write_quadtree(filepath, qt1), NA)
  qt2 <- expect_error(read_quadtree(filepath), NA)

  expect_s4_class(qt2, "Quadtree")
  expect_equal(extent(qt1, original = TRUE)[1:4], 
               extent(qt2, original = TRUE)[1:4])
  qt1_nb <- do.call(rbind, qt1@ptr$getNeighborList())
  qt2_nb <- do.call(rbind, qt2@ptr$getNeighborList())
  qt1_nb <- qt1_nb[order(qt1_nb[, "id0"], qt1_nb[, "id1"]), ]
  qt2_nb <- qt2_nb[order(qt2_nb[, "id0"], qt2_nb[, "id1"]), ]
  expect_equal(qt1_nb, qt2_nb)

  df1 <- as_data_frame(qt1, FALSE)
  df2 <- as_data_frame(qt2, FALSE)
  expect_equal(df1, df2)

  # make sure neighbors are being assigned when read in. The above code was supposed
  # to test this using 'getNeighborList()', but turns it doesn't actually catch the problem
  # since 'getNeighborList()' calls 'findNeighbors()' rather than using the previously calculated
  # neighbors. This next code actually catches the problem.
  cell1 <- qt1@ptr$getCell(c(20000,20000))
  cell2 <- qt2@ptr$getCell(c(20000,20000))
  expect_equal(sort(cell1$getNeighborIds()), sort(cell2$getNeighborIds()))
  
  unlink(filepath)
})

test_that("set_values() works", {
  habitat <- terra::rast(system.file("extdata", "habitat.tif", package="quadtree"))
  qt <- quadtree(habitat, .2)
  set.seed(10)
  ext <- extent(qt)
  pts <- cbind(runif(100, ext[1], ext[2]), runif(100, ext[3], ext[4]))
  new_vals <- rep(-5, nrow(pts))
  expect_error(set_values(qt, pts, new_vals), NA)

  vals <- extract(qt, pts)
  expect_equal(vals, new_vals)
})

test_that("transform_values() works", {
  habitat <- terra::rast(system.file("extdata", "habitat.tif", package="quadtree"))
  qt1 <- quadtree(habitat, .1, split_method = "sd")
  qt2 <- copy(qt1)

  expect_error(transform_values(qt2, function(x) 2 * x), NA)
  qt1df <- as_data_frame(qt1, FALSE)
  qt2df <- as_data_frame(qt2, FALSE)

  qt1df$value[is.na(qt1df$value)] <- 0
  qt2df$value[is.na(qt2df$value)] <- 0
  expect_equal(qt1df$value * 2, qt2df$value)
})

# mat = rbind(c(1,1,1,1,0,1,1,1),
#             c(1,1,1,1,1,0,1,1),
#             c(1,1,1,1,0,0,1,1),
#             c(1,1,1,1,0,0,1,1),
#             c(0,0,1,0,1,0,1,1),
#             c(0,0,0,1,0,1,1,1),
#             c(1,0,1,1,0,1,0,0),
#             c(0,1,1,1,1,0,0,0))
# write.table(mat, "sample_data/8by8_01_matrix.txt",sep=",",col.names=FALSE,row.names=FALSE)
# qt = quadtree(mat,.1)
# plot(qt,col="white")
