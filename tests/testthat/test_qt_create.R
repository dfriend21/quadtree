test_that("we can create a quadtree from a matrix",{
  mat = matrix(runif(16),4)
  qt = qt_create(mat,split_threshold=.2,split_method="range",combine_method="mean")
  expect_s4_class(qt,"Rcpp_quadtree")
})

test_that("we can create a quadtree from a raster",{
  mat = matrix(runif(16),4)
  rast = raster::raster(mat)
  qt = qt_create(rast,split_threshold=.2, split_method="range",combine_method="mean")
  expect_s4_class(qt,"Rcpp_quadtree")
})

test_that("quadtree creation with templates works",{
  data(habitat)
  data(habitat_roads)
  qt1 = qt_create(habitat_roads, .1)
  qt2 = qt_create(habitat, template_quadtree = qt1)
  qt1_df = qt_as_data_frame(qt1)
  qt2_df = qt_as_data_frame(qt2)
  expect_true(all(dim(qt1_df) == dim(qt2_df)))
  qt1_df2 = qt1_df[,-1*which(names(qt1_df) == "value")]
  qt2_df2 = qt2_df[,-1*which(names(qt2_df) == "value")]
  expect_true(all(qt1_df2 == qt2_df2))
})

test_that("qt_create runs without errors for all parameter settings",{
  library(raster)
  
  # retrieve the sample data
  data(habitat)
  rast = habitat
  expect_error(qt_create(rast, .15),NA)
  expect_error(qt_create(rast, .15, adj_type="resample", resample_n_side = 128),NA)
  expect_error(qt_create(rast, .15, adj_type="resample", resample_n_side = 128, resample_pad_NAs=FALSE),NA)
  expect_error(qt_create(rast, .15, max_cell_length = 1000),NA)
  expect_error(qt_create(rast, .15, min_cell_length = 1000),NA)
  
  qt = qt_create(rast, .15, min_cell_length = 1000)
  expect_true(qt$root()$smallestChildSideLength() == 1000)
  
  expect_error(qt_create(rast, .15, split_if_all_NA=TRUE),NA)
  expect_error(qt_create(rast, .15, split_if_any_NA=FALSE),NA)
  expect_error(qt_create(rast, .15, split_if_any_NA=FALSE, max_cell_length=1000),NA)
  expect_error(qt_create(rast, .15, split_method = "range"),NA)
  expect_error(qt_create(rast, .15, split_method = "sd"),NA)
  expect_error(qt_create(rast, .15, combine_method = "mean"),NA)
  expect_error(qt_create(rast, .15, combine_method = "median"),NA)
  expect_error(qt_create(rast, .15, combine_method = "min"),NA)
  expect_error(qt_create(rast, .15, combine_method = "max"),NA)
  expect_error(qt_create(rast, .15, split_method = "sd", combine_method="min"),NA)
  #----
  split_fun = function(vals, args){ 
    if(any(is.na(vals))){ #check for NAs first
      return(TRUE); #if there are any NAs we'll split automatically
    } else {
      return(any(vals < args$threshold))
    }
  }
  expect_error(qt_create(rast, split_method="custom", split_fun=split_fun, split_args=list(threshold=.8)),NA)
  #----
  cmb_fun = function(vals, args){
    if(any(is.na(vals))){
      return(NA)
    }
    if(mean(vals) < args$threshold){
      return(args$low_val)
    } else {
      return(args$high_val)   
    } 
  }
  expect_error(qt_create(rast, .1, combine_method="custom", combine_fun = cmb_fun, combine_args = list(threshold=.5, low_val=0, high_val=1)),NA)
  #----
  cmb_fun2 = function(vals, args){
    return(max(vals) - min(vals))
  }
  expect_error(qt_create(rast, .1, combine_method="custom", combine_fun = cmb_fun2),NA)
  #----
  data(habitat_roads)
  template = habitat_roads
  split_if_one = function(vals, args){
    if(any(vals == 1, na.rm=TRUE)) return(TRUE)
    return(FALSE)
  }
  qt_template = qt_create(template, .1)
  expect_error(qt_create(rast, template_quadtree = qt_template),NA)
})

# test_that("reading and writing quadtrees works",{
#   data(habitat)
#   qt1 = qt_create(habitat,.1)
#   filepath = "/Users/dfriend/Desktop/testing/testingqt1.qt"
#   qt_write(qt1,filepath)
#   qt2 = qt_read(filepath)
#   qt_plot(qt1)
#   qt_plot(qt2)
# })
# # 
# test_that("edge cases of qt_create respond appropriately",{
#   expect_error(qt_create(NULL,1))
#   qt_create(matrix(),1)
# })
#test_that("examples run",{
#   devtools::run_examples("quadtree")
# })

# # 
# # 
# # 
# # 
# # test_that("quadtree creation works",{
# #   data(habitat)
# #   rast = habitat
# #   mat = rbind(c(0,0,1,0),
# #               c(0,0,0,1),
# #               c(1,0,0,0),
# #               c(0,1,0,0))
# #   qt = qt_create(mat,split_threshold=.1,split_method="range")
# #   expect_s4_class(qt, "Rcpp_quadtree")
# #   pts = expand.grid(x=seq(.5,3.5,1),y=seq(.5,3.5,1))
# #   extract = qt_extract(qt, pts,extent=TRUE)
# #   extract_exp = structure(c(0, 1, 2, 2, 0, 1, 2, 2, 0, 0, 2, 3, 0, 0, 2, 3, 1, 
# #                     2, 4, 4, 1, 2, 4, 4, 2, 2, 3, 4, 2, 2, 3, 4, 0, 0, 0, 0, 1, 1, 
# #                     0, 0, 2, 2, 2, 2, 2, 2, 3, 3, 1, 1, 2, 2, 2, 2, 2, 2, 4, 4, 3, 
# #                     3, 4, 4, 4, 4, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0
# #   ), .Dim = c(16L, 5L), .Dimnames = list(NULL, c("xmin", "xmax", 
# #                                                  "ymin", "ymax", "value")))
# #   expect_equal(nrow(extract),nrow(extract_exp))
# #   expect_true(all(extract == extract_exp))
# # })
# 
