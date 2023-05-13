test_that("we can create a quadtree from a matrix", {
  mat <- matrix(runif(16), 4)
  qt <- expect_error(quadtree(mat, .2), NA)
  expect_s4_class(qt, "Quadtree")
})

test_that("we can create a quadtree from a raster", {
  mat <- matrix(runif(16), 4)
  rast <- terra::rast(mat)
  qt <- expect_error(quadtree(rast, .2), NA)
  expect_s4_class(qt, "Quadtree")
})

test_that("quadtree creation with templates works", {
  data(habitat)
  data(habitat_roads)
  qt1 <- expect_error(quadtree(habitat_roads, .1), NA)
  qt2 <- expect_error(quadtree(habitat, template_quadtree = qt1), NA)

  qt1_df <- as_data_frame(qt1, FALSE)
  qt2_df <- as_data_frame(qt2, FALSE)
  expect_equal(dim(qt1_df), dim(qt2_df))

  # everything except for the cell values should be the same
  qt1_df2 <- qt1_df[, -1 * which(names(qt1_df) == "value")]
  qt2_df2 <- qt2_df[, -1 * which(names(qt2_df) == "value")]
  expect_equal(qt1_df2, qt2_df2)
})

test_that("summary(<Quadtree>) runs without errors", {
  data(habitat)
  qt <- quadtree(habitat, .1, split_method = "sd")
  expect_output(summary(qt))
})

test_that("'quadtree()' runs without errors for all parameter settings", {
  # library(raster)

  # retrieve the sample data
  data(habitat)
  # make the raster smaller so the output files are smaller
  rast <- raster::aggregate(habitat, 6)

  qts <- list()
  qts[[1]] <- expect_error(quadtree(rast, .3), NA)
  qts[[2]] <- expect_error(quadtree(rast, .3, adj_type = "resample", resample_n_side = 32), NA)
  qts[[3]] <- expect_error(quadtree(rast, .3, adj_type = "resample", resample_n_side = 32, resample_pad_nas = FALSE), NA)
  qts[[4]] <- expect_error(quadtree(rast, .3, adj_type = "none"), NA)
  qts[[5]] <- expect_error(quadtree(rast, .3, max_cell_length = 3000), NA)
  qts[[6]] <- expect_error(quadtree(rast, .3, min_cell_length = 3000), NA)
  expect_equal(qts[[6]]@ptr$root()$smallestChildSideLength(), 3000) #make sure the minimum length restriction works

  qts[[7]] <- expect_error(quadtree(rast, .3, split_if_all_na = TRUE), NA)
  qts[[8]] <- expect_error(quadtree(rast, .3, split_if_any_na = FALSE), NA)
  qts[[9]] <- expect_error(quadtree(rast, .3, split_if_any_na = FALSE, max_cell_length = 3000), NA)
  qts[[10]] <- expect_error(quadtree(rast, .3, split_method = "range"), NA)
  qts[[11]] <- expect_error(quadtree(rast, .1, split_method = "sd"), NA)
  qts[[12]] <- expect_error(quadtree(rast, .1, split_method = "cv"), NA)
  qts[[13]] <- expect_error(quadtree(rast, .3, combine_method = "mean"), NA)
  qts[[14]] <- expect_error(quadtree(rast, .3, combine_method = "median"), NA)
  qts[[15]] <- expect_error(quadtree(rast, .3, combine_method = "min"), NA)
  qts[[16]] <- expect_error(quadtree(rast, .3, combine_method = "max"), NA)
  qts[[17]] <- expect_error(quadtree(rast, .1, split_method = "sd", combine_method = "min"), NA)
  #----
  split_fun <- function(vals, args) {
    if (any(is.na(vals))) { #check for NAs first
      return(TRUE) #if there are any NAs we'll split automatically
    } else {
      return(any(vals < args$threshold))
    }
  }
  qts[[18]] <- expect_error(quadtree(rast, split_method = "custom", split_fun = split_fun, split_args = list(threshold = .8)), NA)
  #----
  cmb_fun <- function(vals, args) {
    if (any(is.na(vals))) {
      return(NA)
    }
    if (mean(vals) < args$threshold) {
      return(args$low_val)
    } else {
      return(args$high_val)
    }
  }
  qts[[19]] <- expect_error(quadtree(rast, .1, combine_method = "custom", combine_fun = cmb_fun, combine_args = list(threshold = .5, low_val = 0, high_val = 1)), NA)
  #----
  cmb_fun2 <- function(vals, args) {
    return(max(vals) - min(vals))
  }
  qts[[20]] <- expect_error(quadtree(rast, .1, combine_method = "custom", combine_fun = cmb_fun2), NA)
  #----
  data(habitat_roads)
  template <- raster::aggregate(habitat_roads, 6)
  split_if_road <- function(vals, args) {
    if (any(vals > 0, na.rm = TRUE)) return(TRUE)
    return(FALSE)
  }
  qt_template <- quadtree(template, split_method = "custom", split_fun = split_if_road)
  qts[[21]] <- expect_error(quadtree(rast, template_quadtree = qt_template), NA)

  #------------------------
  # now I'll check to see if the structure of the quadtrees is the same as in
  # previous runs. Note that this doesn't guarantee correctness but is still
  # useful for alerting me if the result of 'quadtree()' changes

  # # need to use 'setwd()' first
  # for (i in seq_len(length(qts))) {
  #   write_quadtree(paste0("tests/testthat/qtrees/qt", sprintf("%03d", i), ".qtree"), qts[[i]])
  # }

  paths <- list.files("qtrees/", pattern = "*.qtree", full.names = TRUE)
  qtsp <- lapply(paths, read_quadtree) #'p' in 'qtsp' stands for 'previous'
  expect_equal(length(qts), length(qtsp))
  for (i in seq_len(length(qtsp))) {
    qts_df <- as_data_frame(qts[[i]], FALSE)
    qtsp_df <- as_data_frame(qtsp[[i]], FALSE)
    expect_equal(qts_df, qtsp_df)
  }
})
