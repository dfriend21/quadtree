# test_that("examples run",{
#   devtools::run_examples("quadtree")
# })
# # test_that("we can create a quadtree from a matrix"){
# #   mat = matrix(runif(16),4)
# #   qt = qt_create(mat,split_threshold=.2,split_method="range",combine_method="mean")
# #   expect_s4_class(qt,"Rcpp_quadtree")
# # }
# # 
# # test_that("we can create a quadtree from a raster"){
# #   mat = matrix(runif(16),4)
# #   rast = raster::raster(mat)
# #   qt = qt_create(rast,split_threshold=.2, split_method="range",combine_method="mean")
# #   expect_s4_class(qt,"Rcpp_quadtree")
# # }
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
