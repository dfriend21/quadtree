test_that("as_data_frame() runs without errors and produces expected output", {
  data(habitat)
  qt <- expect_error(quadtree(habitat, .4), NA)

  df_term <- expect_error(as_data_frame(qt, TRUE), NA)
  df_all <- expect_error(as_data_frame(qt, FALSE), NA)

  expect_s3_class(df_term, "data.frame")
  expect_s3_class(df_all, "data.frame")

  expect_true(nrow(df_term) > 0)
  expect_true(nrow(df_all) > 0)

  expect_true(qt@ptr$nNodes() == nrow(df_all))

  expect_true(nrow(df_term) < nrow(df_all))
})

test_that("as_raster() works", {
  data(habitat)
  qt <- quadtree(habitat, .1, split_method = "sd")
  rst1 <- expect_error(as_raster(qt), NA)
  rst2 <- expect_error(as_raster(qt, habitat), NA)

  rst_template <- raster::raster(nrows = 189, ncols = 204,
                                 xmn = 0, xmx = 30000, ymn = 10000, ymx = 45000)
  rst3 <- expect_error(as_raster(qt, rst_template), NA)

  pts1 <- raster::rasterToPoints(rst1, spatial = FALSE)
  pts2 <- raster::rasterToPoints(rst2, spatial = FALSE)
  pts3 <- raster::rasterToPoints(rst3, spatial = FALSE)

  expect_true(all(extract(qt, pts1[, 1:2]) == extract(rst1, pts1[, 1:2])))
  expect_true(all(extract(qt, pts2[, 1:2]) == extract(rst2, pts2[, 1:2])))
  expect_true(all(extract(qt, pts3[, 1:2]) == extract(rst3, pts3[, 1:2])))
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
  expect_true(all(sort(as.numeric(mat)) == sort(vec_term2)))
})

test_that("copy() runs without errors and produces expected output", {
  data(habitat)
  qt1 <- quadtree(habitat, .3, split_method = "sd")
  qt2 <- expect_error(copy(qt1), NA)
  expect_s4_class(qt2, "Quadtree")
  df1 <- as_data_frame(qt1, FALSE)
  df2 <- as_data_frame(qt2, FALSE)
  # first test w/o the value column since NA columns mess up the equality check
  expect_true(all(df1[, -1 * which(names(df1) == "value")] ==
                  df2[, -1 * which(names(df2) == "value")]))
  # now do the 'value' column separately
  expect_true(all(df1$value == df2$value, na.rm = TRUE))
  expect_true(all(which(is.na(df1$value)) == which(is.na(df2$value))))
})

test_that("extent() runs without errors and produces expected output", {
  library(raster)
  data(habitat)
  qt1 <- quadtree(habitat, .3, split_method = "sd")
  expect_error(extent(qt1, original = FALSE), NA)
  qt_ext <- expect_error(extent(qt1, original = TRUE), NA)
  expect_true(qt_ext == extent(habitat))
})

test_that("extract runs without errors and returns correct values", {
  library(raster)
  data(habitat)
  # use 0 to make sure everything gets split as small as possible
  qt1 <- quadtree(habitat, 0)

  ext <- extent(habitat)
  pts <- cbind(runif(1000, ext[1], ext[2]), runif(1000, ext[3], ext[4]))
  rst_ext <- extract(habitat, pts)
  qt_ext <- expect_error(extract(qt1, pts), NA)
  rst_ext[is.na(rst_ext)] <- -1
  qt_ext[is.na(qt_ext)] <- -1
  expect_true(all(qt_ext == rst_ext))

  # make sure it works with the 'extents=TRUE' option too
  qt_ext2 <- expect_error(extract(qt1, pts, extents = TRUE), NA)
  expect_true("matrix" %in% class(qt_ext2))
  expect_true(nrow(qt_ext2) > 0)
  nums <- qt_ext2[, "value"]
  nums[is.na(nums)] <- -1
  expect_true(all(nums == rst_ext))
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
  expect_true(all(sort(nbs[, "id"]) == sort(nb_ids)))
})

test_that("n_cells() works", {
  data(habitat)
  qt <- quadtree(habitat, .15)
  nc1 <- expect_error(n_cells(qt, TRUE), NA)
  nc2 <- expect_error(n_cells(qt, FALSE), NA)

  expect_true(nc2 > nc1)
})

test_that("n_cells(), as_vector(), and as_data_frame() agree on the number of
          nodes", {
  data(habitat)
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
  data(habitat)
  suppressWarnings({crs(habitat) <- "+init=EPSG:27700"})
  qt1 <- quadtree(habitat, .5)
  qt_proj <- expect_error(projection(qt1), NA)
  expect_true(qt_proj == projection(habitat))
})

test_that("read_quadtree() and write_quadtree() work", {
  data(habitat)
  qt1 <- quadtree(habitat, .1)
  filepath <- tempfile()
  expect_error(write_quadtree(filepath, qt1), NA)
  qt2 <- expect_error(read_quadtree(filepath), NA)

  expect_s4_class(qt2, "Quadtree")
  expect_true(extent(qt1, original = TRUE) == extent(qt2, original = TRUE))
  qt1_nb <- do.call(rbind, qt1@ptr$getNbList())
  qt2_nb <- do.call(rbind, qt2@ptr$getNbList())
  qt1_nb[is.na(qt1_nb[, "val1"]), "val1"] <- -1
  qt2_nb[is.na(qt2_nb[, "val1"]), "val1"] <- -1

  df1 <- as_data_frame(qt1, FALSE)
  df2 <- as_data_frame(qt2, FALSE)
  # first test w/o the value column since NA columns mess up the equality check
  expect_true(all(df1[, -1 * which(names(df1) == "value")] ==
                  df2[, -1 * which(names(df2) == "value")]))

  # now do the 'value' column separately
  expect_true(all(df1$value == df2$value, na.rm = TRUE))
  expect_true(all(which(is.na(df1$value)) == which(is.na(df2$value))))

  unlink(filepath)
})

test_that("set_values() works", {
  data(habitat)
  qt <- quadtree(habitat, .2)
  set.seed(10)
  ext <- extent(qt)
  pts <- cbind(runif(100, ext[1], ext[2]), runif(100, ext[3], ext[4]))
  expect_error(set_values(qt, pts, rep(-5, nrow(pts))), NA)
  vals <- extract(qt, pts)
  expect_true(all(vals == -5))
})

test_that("transform_values() works", {
  data(habitat)
  qt1 <- quadtree(habitat, .1, split_method = "sd")
  qt2 <- copy(qt1)

  expect_error(transform_values(qt2, function(x) 2 * x), NA)
  qt1df <- as_data_frame(qt1, FALSE)
  qt2df <- as_data_frame(qt2, FALSE)

  qt1df$value[is.na(qt1df$value)] <- 0
  qt2df$value[is.na(qt2df$value)] <- 0
  expect_true(all(qt1df$value * 2 == qt2df$value))
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
