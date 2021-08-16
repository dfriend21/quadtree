test_that("qt_as_data_frame runs without errors and produces expected output",{
  data(habitat)
  qt = expect_error(qt_create(habitat,.4),NA)
  df = qt_as_data_frame(qt)
  expect_s3_class(df, "data.frame")
  expect_true(nrow(df) > 0)
  expect_true(qt$nNodes() == nrow(df))
})

test_that("qt_copy runs without errors and produces expected output",{
  data(habitat)
  qt1 = qt_create(habitat,.3,split_method="sd")
  qt2 = expect_error(qt_copy(qt1),NA)
  expect_s4_class(qt2,"Rcpp_quadtree")
  df1 = qt_as_data_frame(qt1)
  df2 = qt_as_data_frame(qt2)
  #first test w/o the value column because NA columns mess up the equality check
  expect_true(all(df1[,-1*which(names(df1)=="value")] == df2[,-1*which(names(df2)=="value")]))
  #now do the 'value' column separately
  expect_true(all(df1$value == df2$value,na.rm=TRUE))
  expect_true(all(which(is.na(df1$value)) == which(is.na(df2$value))))
})

test_that("qt_extent runs without errors and produces expected output",{
  library(raster)
  data(habitat)
  qt1 = qt_create(habitat,.3,split_method="sd")
  expect_error(qt_extent(qt1,original=FALSE),NA)
  qt_ext = expect_error(qt_extent(qt1,original=TRUE),NA)
  expect_true(qt_ext == extent(habitat))
})

test_that("qt_extract runs without errors and returns correct values",{
  library(raster)
  data(habitat)
  qt1 = qt_create(habitat,0) #use 0 to make sure everything gets split as small as possible
  
  ext = extent(habitat)
  pts = cbind(runif(1000, ext[1], ext[2]), runif(1000, ext[3], ext[4]))  
  rst_ext = extract(habitat,pts)
  qt_ext = expect_error(qt_extract(qt1,pts),NA)
  rst_ext[is.na(rst_ext)] = -1
  qt_ext[is.na(qt_ext)] = -1
  expect_true(all(qt_ext == rst_ext))

  #make sure it works with the 'extents=TRUE' option too  
  qt_ext2 = expect_error(qt_extract(qt1,pts,extents=TRUE),NA)
  expect_true("matrix" %in% class(qt_ext2))
  expect_true(nrow(qt_ext2) > 0)
  nums = qt_ext2[,"value"]
  nums[is.na(nums)] = -1
  expect_true(all(nums == rst_ext))
})

test_that("qt_proj4string runs without errors and returns correct value",{
  data(habitat)
  suppressWarnings({crs(habitat) = "+init=EPSG:27700"})
  qt1 = qt_create(habitat,.5)
  qt_proj = expect_error(qt_proj4string(qt1),NA)
  expect_true(qt_proj == proj4string(habitat))
})

test_that("reading and writing quadtrees works",{
  data(habitat)
  qt1 = qt_create(habitat,.1)
  filepath = tempfile()
  expect_error(qt_write(qt1,filepath),NA)
  qt2 = expect_error(qt_read(filepath),NA)
  
  df1 = qt_as_data_frame(qt1)
  df2 = qt_as_data_frame(qt2)
  #first test w/o the value column because NA columns mess up the equality check
  expect_true(all(df1[,-1*which(names(df1)=="value")] == df2[,-1*which(names(df2)=="value")]))
  #now do the 'value' column separately
  expect_true(all(df1$value == df2$value,na.rm=TRUE))
  expect_true(all(which(is.na(df1$value)) == which(is.na(df2$value))))
  
  unlink(filepath)
})

test_that("changing quadtree values works",{
  data(habitat)
  qt = qt_create(habitat,.2)
  set.seed(10)
  ext = qt_extent(qt)
  pts = cbind(runif(100,ext[1],ext[2]),runif(100,ext[3],ext[4]))
  expect_error(qt_set_values(qt,pts,rep(-5,nrow(pts))),NA)
  vals = qt_extract(qt,pts)  
  expect_true(all(vals == -5))
})
