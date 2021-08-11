test_that("least-cost path functionality works", {
  mat = rbind(c(0,1,1,1),c(1,0,0,1),c(1,1,1,0),c(0,0,0,1))
  qt = qt_create(mat,0)
  lcpf = qt_lcp_finder(qt,c(.5,.5))
  lcp = qt_find_lcp(lcpf,c(.5,3.5))
  lcp_expected = rbind(c(0.5,0.5),
                       c(1.5,0.5),
                       c(2.5,0.5),
                       c(3.5,1.5),
                       c(2.5,2.5),
                       c(1.5,2.5),
                       c(0.5,3.5))
  expect_equal(nrow(lcp), nrow(lcp_expected))
  expect_true(all(lcp[,1:2] == lcp_expected))


  # lcp[,1:2] == lcp_expected
  # qt_plot(qt)
  # lines(lcp)
})