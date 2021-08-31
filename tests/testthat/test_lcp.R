test_that("find_lcp() finds the correct path in a trivial example", {
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
  expect_equal(nrow(lcp), nrow(lcp_expected))
  expect_true(all(lcp[, 1:2] == lcp_expected))
})

test_that("find_lcps() works with all limit_types", {
  data(habitat)

  start_point <- c(6989, 34007)
  end_point <- c(33015, 38162)

  qt <- quadtree(habitat, .2)

  lcpf <- expect_error(lcp_finder(qt, start_point), NA)
  lcp <- expect_error(find_lcps(lcpf, "none"), NA)

  lcpf <- expect_error(lcp_finder(qt, start_point), NA)
  lcp <- expect_error(find_lcps(lcpf, "n"), NA)

  lcpf <- expect_error(lcp_finder(qt, start_point), NA)
  lcp <- expect_error(find_lcps(lcpf, "costdistance", 3000), NA)

  lcpf <- expect_error(lcp_finder(qt, start_point), NA)
  lcp <- expect_error(find_lcps(lcpf, "cd", 3000), NA)

  lcpf <- expect_error(lcp_finder(qt, start_point), NA)
  lcp <- expect_error(find_lcps(lcpf, "costdistance+distance", 6000), NA)

  lcpf <- expect_error(lcp_finder(qt, start_point), NA)
  lcp <- expect_error(find_lcps(lcpf, "cd+d", 6000), NA)
})

test_that("lcp_summary() runs without errors and produces expected output", {
  data(habitat)
  qt <- quadtree(habitat, .1, split_method = "sd")
  start_point <- c(19000, 27500)
  lcpf <- lcp_finder(qt, start_point)
  expect_error(find_lcps(lcpf, limit_type = "none"), NA)
  lcp_sum <- expect_error(lcp_summary(lcpf), NA)
  expect_true("data.frame" %in% class(lcp_sum))
})

test_that("find_lcps() finds the same paths as in previous runs", {
  # use qt_lcp_summary() to summarize all paths found by a 'lcpf', then check the
  # results against previous runs
  data(habitat)
  qt <- quadtree(habitat, 0, split_method = "sd", min_cell_length = 1000)
  start_point <- c(3900, 27500)
  lcpf <- lcp_finder(qt, start_point)
  lcp_sum <- expect_error(find_lcps(lcpf, limit_type = "none"), NA)
  # write.csv(lcp_sum,"lcps/qt_find_lcps_data.csv", row.names=FALSE)
  lcp_sum_prev <- read.csv("lcps/qt_find_lcps_data.csv")
  expect_true(all(round(lcp_sum, 6) == round(lcp_sum_prev, 6)))
})

test_that("find_lcp() finds the same path as in previous runs", {
  # basically I'm just including this so I that I get alerted if the output
  # ever changes from what I'm getting right now - doesn't guarantee
  # its correctness, but is still useful to know

  data(habitat)
  qt <- quadtree(habitat, .1)
  start_point <- c(6989, 34007)
  end_point <- c(33015, 38162)

  lcpf <- lcp_finder(qt, start_point)
  lcp <- find_lcp(lcpf, end_point)

  # write.csv(lcp,"lcps/qt_find_lcp_data.csv", row.names=FALSE)
  lcp_prev <- read.csv("lcps/qt_find_lcp_data.csv")
  expect_true(all(round(lcp, 6) == round(lcp_prev, 6))) # differences in precision was messing with this
})
