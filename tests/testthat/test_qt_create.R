test_that("we can create a quadtree from a matrix",{
  mat = matrix(runif(16),4)
  qt = quadtree(mat,split_threshold=.2,split_method="range",combine_method="mean")
  expect_s4_class(qt,"quadtree")
})

test_that("we can create a quadtree from a raster",{
  mat = matrix(runif(16),4)
  rast = raster::raster(mat)
  qt = quadtree(rast,split_threshold=.2, split_method="range",combine_method="mean")
  expect_s4_class(qt,"quadtree")
})

test_that("quadtree creation with templates works",{
  data(habitat)
  data(habitat_roads)
  qt1 = quadtree(habitat_roads, .1)
  qt2 = quadtree(habitat, template_quadtree = qt1)
  qt1_df = as_data_frame(qt1)
  qt2_df = as_data_frame(qt2)
  expect_true(all(dim(qt1_df) == dim(qt2_df)))
  qt1_df2 = qt1_df[,-1*which(names(qt1_df) == "value")]
  qt2_df2 = qt2_df[,-1*which(names(qt2_df) == "value")]
  expect_true(all(qt1_df2 == qt2_df2))
})

test_that("'quadtree()' runs without errors for all parameter settings",{
  library(raster)
  
  # retrieve the sample data
  data(habitat)
  rast = habitat
  qts = list()
  qts[[1]] = expect_error(quadtree(rast, .15),NA)
  
  qts[[2]] = expect_error(quadtree(rast, .15, adj_type="resample", resample_n_side = 128), NA)
  qts[[3]] = expect_error(quadtree(rast, .15, adj_type="resample", resample_n_side = 128, resample_pad_NAs=FALSE),NA)
  qts[[4]] = expect_error(quadtree(rast, .15, max_cell_length = 1000),NA)
  qts[[5]] = expect_error(quadtree(rast, .15, min_cell_length = 1000),NA)
  expect_true(qts[[5]]@ptr$root()$smallestChildSideLength() == 1000) #make sure the minimum length restriction works
  
  qts[[6]] = expect_error(quadtree(rast, .15, split_if_all_NA=TRUE),NA)
  qts[[7]] = expect_error(quadtree(rast, .15, split_if_any_NA=FALSE),NA)
  qts[[8]] = expect_error(quadtree(rast, .15, split_if_any_NA=FALSE, max_cell_length=1000),NA)
  qts[[9]] = expect_error(quadtree(rast, .15, split_method = "range"),NA)
  qts[[10]] = expect_error(quadtree(rast, .15, split_method = "sd"),NA)
  qts[[11]] = expect_error(quadtree(rast, .15, combine_method = "mean"),NA)
  qts[[12]] = expect_error(quadtree(rast, .15, combine_method = "median"),NA)
  qts[[13]] = expect_error(quadtree(rast, .15, combine_method = "min"),NA)
  qts[[14]] = expect_error(quadtree(rast, .15, combine_method = "max"),NA)
  qts[[15]] = expect_error(quadtree(rast, .15, split_method = "sd", combine_method="min"),NA)
  #----
  split_fun = function(vals, args){ 
    if(any(is.na(vals))){ #check for NAs first
      return(TRUE); #if there are any NAs we'll split automatically
    } else {
      return(any(vals < args$threshold))
    }
  }
  qts[[16]] = expect_error(quadtree(rast, split_method="custom", split_fun=split_fun, split_args=list(threshold=.8)),NA)
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
  qts[[17]] = expect_error(quadtree(rast, .1, combine_method="custom", combine_fun = cmb_fun, combine_args = list(threshold=.5, low_val=0, high_val=1)),NA)
  #----
  cmb_fun2 = function(vals, args){
    return(max(vals) - min(vals))
  }
  qts[[18]] = expect_error(quadtree(rast, .1, combine_method="custom", combine_fun = cmb_fun2),NA)
  #----
  data(habitat_roads)
  template = habitat_roads
  split_if_one = function(vals, args){
    if(any(vals == 1, na.rm=TRUE)) return(TRUE)
    return(FALSE)
  }
  qt_template = quadtree(template, .1)
  qts[[19]] = expect_error(quadtree(rast, template_quadtree = qt_template),NA)
  
  #------------------------
  # now I'll check to see if the structure of the quadtrees is the same as in
  # previous runs. Note that this doesn't guarantee correctness but is still 
  # useful for alerting me when the result of 'qt_create' changes
  
  # for(i in 1:length(qts)){
  #   qt_write(qts[[i]], paste0("qtrees/qt",sprintf("%03d",i),".qtree"))
  # }

  paths = list.files("qtrees/",pattern="*.qtree",full.names=TRUE)
  qtsp = lapply(paths, read_quadtree) #'p' in 'qtsp' stands for 'previous'
  expect_true(length(qts) == length(qtsp))
  for(i in 1:length(qtsp)){
    qts_df = as_data_frame(qts[[i]])
    qtsp_df = as_data_frame(qtsp[[i]])
    qts_df$value[is.na(qts_df$value)] = -1
    qtsp_df$value[is.na(qtsp_df$value)] = -1
    expect_true(all(qts_df == qtsp_df))
  }
})