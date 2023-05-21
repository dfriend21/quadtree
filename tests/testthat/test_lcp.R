test_that("find_lcp(<LcpFinder>) finds the correct path in a trivial example", {
  mat <- rbind(c(0, 1, 1, 1),
               c(1, 0, 0, 1),
               c(1, 1, 1, 0),
               c(0, 0, 0, 1))
  qt <- quadtree(mat, 0)
  lcpf <- expect_error(lcp_finder(qt, c(.5, .5)), NA)
  lcp <- expect_error(find_lcp(lcpf, c(.5, 3.5)), NA)
  lcp_expected <- rbind(c(0.5, 0.5),
                        c(1.5, 0.5),
                        c(2.5, 0.5),
                        c(3.5, 1.5),
                        c(2.5, 2.5),
                        c(1.5, 2.5),
                        c(0.5, 3.5))
  colnames(lcp_expected) <- c("x", "y")
  expect_equal(nrow(lcp), nrow(lcp_expected))
  expect_equal(as.matrix(lcp[, 1:2]), lcp_expected)
})

test_that("lcp_finder() with search limits works as expected", {
  habitat <- rast(system.file("extdata", "habitat.tif", package="quadtree"))

  s_pt <- c(8488.439, 25842.65)
  e_pt1 <- c(14750.149, 27929.89)
  e_pt2 <- c(26925.696, 31176.70)
  qt <- quadtree(habitat, .2)

  dist <- 7112
  xlim <- c(s_pt[1] - dist, s_pt[1] + dist)
  ylim <- c(s_pt[2] - dist, s_pt[2] + dist)
  
  # test when search_by_centroid = FALSE (lcpf1)
  lcpf1 <- expect_error(lcp_finder(qt, s_pt, xlim = xlim, ylim = ylim), NA)
  lcpf1_all <- find_lcps(lcpf1)
  lcp1_1 <- expect_error(find_lcp(lcpf1, e_pt1), NA)
  lcp1_2 <- expect_error(find_lcp(lcpf1, e_pt2), NA)
  expect_true(nrow(lcp1_1) > 0)
  expect_equal(nrow(lcp1_2), 0)
  
  # test that all nodes overlap with the search area (lcpf1_)
  lcpf1_all$x <- (lcpf1_all$xmin + lcpf1_all$xmax) / 2
  lcpf1_all$y <- (lcpf1_all$ymin + lcpf1_all$ymax) / 2
  lcpf1_is_valid <- with(lcpf1_all, !(xmax < xlim[1] | xmin > xlim[2]) &
                                    !(ymax < ylim[1] | ymin > ylim[2]))
  expect_true(all(lcpf1_is_valid))
  
  # test when search_by_centroid = TRUE (lcpf2)
  lcpf2 <- expect_error(lcp_finder(qt, s_pt, xlim = xlim,ylim = ylim,
                                   search_by_centroid = TRUE), NA)
  lcpf2_all <- find_lcps(lcpf2)
  lcp2_1 <- expect_error(find_lcp(lcpf2, e_pt1), NA)
  lcp2_2 <- expect_error(find_lcp(lcpf2, e_pt2), NA)
  expect_true(nrow(lcp2_1) > 0)
  expect_equal(nrow(lcp2_2), 0)
  
  # test that all centroids fall within the search area (lcpf2)
  lcpf2_all$x <- (lcpf2_all$xmin + lcpf2_all$xmax) / 2
  lcpf2_all$y <- (lcpf2_all$ymin + lcpf2_all$ymax) / 2
  lcpf2_is_valid <- with(lcpf2_all, x >= xlim[1] & x <= xlim[2] & 
                                    y >= ylim[1] & y <= ylim[2])
  expect_true(all(lcpf2_is_valid))  
  
  # test that lcpf2 finds fewer paths
  expect_true(nrow(lcpf1_all) > nrow(lcpf2_all))
  
})

test_that("find_lcp(<Quadtree>) works as expected", {
  habitat <- rast(system.file("extdata", "habitat.tif", package="quadtree"))
  
  s_pt <- c(2372, 29510)
  e_pt <- c(37654, 26400)
  qt <- quadtree(habitat, .2)
  
  plot(qt, crop = TRUE, border_lwd = .1)
  points(rbind(s_pt, e_pt)) 
  lcp1 <- expect_error(find_lcp(qt, s_pt, e_pt), NA)
  
  # check to make sure it matches find_lcp(<LcpFinder>)
  lcpf2 <- lcp_finder(qt, s_pt, new_points = rbind(s_pt, e_pt))
  lcp2 <- find_lcp(lcpf2, e_pt)
  
  lcp3 <- expect_error(find_lcp(qt, s_pt, e_pt, use_orig_points = FALSE), NA)
  
  lcpf4 <- lcp_finder(qt, s_pt)
  lcp4 <- find_lcp(lcpf4, e_pt)
  expect_equal(lcp3, lcp4)
  
  # check that same cell paths are found
  lcp5 <- expect_error(find_lcp(qt, s_pt, s_pt-10), NA)
  expect_true(nrow(lcp5) == 2)
  
  # check that edge cases are handled
  expect_error(find_lcp(qt, c(NA, 1), e_pt))
  expect_warning(find_lcp(qt, c(-1,-1), e_pt))
})

test_that("lcp_finder(<LcpFinder>) treats same-cell paths appropriately", {
  habitat <- rast(system.file("extdata", "habitat.tif", package="quadtree"))
  
  pt <- c(2372, 29510)
  qt <- quadtree(habitat, .2)
  
  lcpf <- lcp_finder(qt, pt)
  lcp1 <- find_lcp(lcpf, pt-10)
  expect_true(nrow(lcp1) == 1)
  
  lcp2 <- find_lcp(lcpf, pt - 10, allow_same_cell_path = TRUE)
  expect_true(nrow(lcp2) == 2)
  expect_equal(lcp2[2,c("x", "y")], pt - 10, ignore_attr = TRUE)
})

test_that("lcp_finder() with 'new_points' works as expected", {
  habitat <- rast(system.file("extdata", "habitat.tif", package="quadtree"))
  
  s_pt1 <- c(2309, 27669)
  s_pt2 <- c(2245, 26083)
  e_pt <- c(722, 26907)
  qt <- quadtree(habitat, .2)
  
  lcpf1 <- expect_error(lcp_finder(qt, s_pt1, 
                                   new_points = rbind(s_pt1, e_pt)), NA)
  lcp1 <- find_lcp(lcpf1, e_pt)  
  expect_equal(lcp1[1,c("x", "y")], s_pt1, ignore_attr = TRUE)
  expect_equal(lcp1[nrow(lcp1),c("x", "y")], e_pt, ignore_attr = TRUE)
  
  lcpf2 <- expect_error(lcp_finder(qt, s_pt2, 
                                   new_points = rbind(s_pt2, e_pt)), NA)
  lcp2 <- find_lcp(lcpf2, e_pt)  
  expect_equal(lcp2[1,c("x", "y")], s_pt2, ignore_attr = TRUE)
  expect_equal(lcp2[nrow(lcp2),c("x", "y")], e_pt, ignore_attr = TRUE)

  expect_true(lcp1[2,"cell_id"] != lcp2[2,"cell_id"])
})

test_that("find_lcps() runs without errors", {
  habitat <- rast(system.file("extdata", "habitat.tif", package="quadtree"))

  start_point <- c(6989, 34007)
  end_point <- c(33015, 38162)

  qt <- quadtree(habitat, .2)

  lcpf <- expect_error(lcp_finder(qt, start_point), NA)
  lcp <- expect_error(find_lcps(lcpf, NULL), NA)

  lcpf <- expect_error(lcp_finder(qt, start_point), NA)
  lcp <- expect_error(find_lcps(lcpf, 3000), NA)
})

test_that("summarize_lcps() runs without errors and produces expected output", {
  habitat <- rast(system.file("extdata", "habitat.tif", package="quadtree"))
  qt <- quadtree(habitat, .1, split_method = "sd")
  start_point <- c(19000, 27500)
  lcpf <- lcp_finder(qt, start_point)
  find_lcps(lcpf, limit = NULL)
  lcp_sum <- expect_error(summarize_lcps(lcpf), NA)
  expect_s3_class(lcp_sum, "data.frame")
})

test_that("summary(<LcpFinder>) runs without errors", {
  habitat <- rast(system.file("extdata", "habitat.tif", package="quadtree"))
  qt <- quadtree(habitat, .1, split_method = "sd")
  start_point <- c(19000, 27500)
  lcpf <- lcp_finder(qt, start_point)
  find_lcps(lcpf, limit = NULL)
  expect_output(summary(lcpf))
})

test_that("find_lcps() finds the same paths as in previous runs", {
  # use summarize_lcps() to summarize all paths found by a 'LcpFinder', then
  # check the results against previous runs
  habitat <- rast(system.file("extdata", "habitat.tif", package="quadtree"))
  qt <- quadtree(habitat, 0, split_method = "sd", min_cell_length = 1000)
  start_point <- c(3900, 27500)
  lcpf <- lcp_finder(qt, start_point)
  lcp_sum <- expect_error(find_lcps(lcpf, limit = NULL), NA)
  # write.csv(lcp_sum,"lcps/qt_find_lcps_data.csv", row.names=FALSE)
  lcp_sum_prev <- read.csv("lcps/qt_find_lcps_data.csv")
  expect_equal(lcp_sum, lcp_sum_prev)
})

test_that("find_lcp(<LcpFinder>) finds the same path as in previous runs", {
  # basically I'm just including this so I that I get alerted if the output
  # ever changes from what I'm getting right now - doesn't guarantee
  # its correctness, but is still useful to know
  
  ## previously used RasterLayer stored in .Rda
  data(habitat)
  
  ## no apparent issue with in mem conversion of RasterLayer -> SpatRaster
  habitat <- terra::rast(habitat)
  qt <- quadtree(habitat, .1)
  start_point <- c(6989, 34007)
  end_point <- c(33015, 38162)
  
  lcpf <- lcp_finder(qt, start_point)
  lcp <- find_lcp(lcpf, end_point)
  
  lcp_old <- read.csv("lcps/qt_find_lcp_data-RasterLayer-data.csv")
  expect_equal(lcp, as.matrix(lcp_old))
  
  ## But, now we are using GeoTIFF in inst/extdata
  ##  -> floating point difference relative to old result (after writing TIFF)
  habitat <- rast(system.file("extdata", "habitat.tif", package="quadtree"))
  
  qt <- quadtree(habitat, .1)
  start_point <- c(6989, 34007)
  end_point <- c(33015, 38162)

  lcpf <- lcp_finder(qt, start_point)
  lcp <- find_lcp(lcpf, end_point)

  # write.csv(lcp,"lcps/qt_find_lcp_data.csv", row.names=FALSE)
  lcp_prev <- read.csv("lcps/qt_find_lcp_data.csv")
  expect_equal(lcp, as.matrix(lcp_prev))
  
  ## visually inspect path differences
  # plot(terra::vect(lcp[,1:2]))
  # plot(terra::vect(as.matrix(lcp_old[, 1:2])), add = TRUE, col = "blue")
  # plot(terra::vect(as.matrix(lcp_prev[, 1:2])), add = TRUE, col = "red")
})
