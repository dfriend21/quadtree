test_that("plot(<Quadtree>) output runs without errors and looks right for all parameter options", {
  # skip("these tests should be manually run and visually inspected")
  # library(terra)
  habitat <- terra::rast(system.file("extdata", "habitat.tif", package="quadtree"))
  rast <- habitat
  # create quadtree
  qt1 <- quadtree(rast, split_threshold = .1, adj_type = "expand")

  # png("plots/plots1.png", height = 1200, width = 1600)
  # par(mfrow = c(3, 4))
  expect_error(plot(qt1, main = "default - no additional parameters provided"), NA)
  expect_error(plot(qt1, crop = TRUE, main = "crop extent to the original extent of the raster"), NA)
  expect_error(plot(qt1, crop = TRUE, na_col = NULL, main = "crop and don't plot NA cells"), NA)
  expect_error(plot(qt1, xlim = c(10000, 20000), ylim = c(20000, 30000), main = "use 'xlim' and 'ylim' to zoom in on an area"), NA)
  expect_error(plot(qt1, border_col = "transparent", main = "change border color: no borders"), NA)
  expect_error(plot(qt1, border_col = "gray60", main = "change border color: gray borders"), NA)
  expect_error(plot(qt1, border_lwd = .3, main = "change border width"), NA)
  expect_error(plot(qt1, col = c("blue", "yellow", "red"), main = "change color palette: c('blue','yellow','red)"), NA)
  expect_error(plot(qt1, col = hcl.colors(100), main = "change color palette: hcl.colors(100)"), NA)
  expect_error(plot(qt1, alpha = .5, main = "change color transparency: alpha=.5"), NA)
  expect_error(plot(qt1, na_col = "lavender", main = "change color of NA cells"), NA)
  expect_error(plot(qt1, na_col = NULL, main = "don't plot NA cells at all (na_col=NULL)"), NA)
  # dev.off()

  # png("plots/plots2.png", height = 1200, width = 1600)
  # par(mfrow = c(3, 4))
  expect_error(plot(qt1, zlim = c(0, 5), main = "change zlim: c(0,5)"), NA)
  expect_error(plot(qt1, zlim = c(.2, .7), main = "change zlim: c(.2,.7)"), NA)
  expect_error(plot(qt1, nb_line_col = "black", border_col = "gray60", main = "plot all neighbor connections"), NA)
  expect_error(plot(qt1, nb_line_col = "black", border_col = "gray60", na_col = NULL, main = "don't plot connections to NA cells"), NA)
  expect_error(plot(qt1, legend = FALSE, main = "no legend"), NA)
  expect_error(plot(qt1, adj_mar_auto = 10, main = "increase right margin size"), NA)
  expect_error(plot(qt1, adj_mar_auto = 10, legend_args = list(lgd_ht_pct = .8, bar_wd_pct = .4), main = "'legend_args': lgd_ht_pct=.8, bar_wd_pct=.4"), NA)
  # dev.off()
})

test_that("points(<LcpFinder>) and lines(<LcpFinder>) run without errors", {
  habitat <- terra::rast(system.file("extdata", "habitat.tif", package="quadtree"))
  
  s_pt <- c(8488.439, 25842.65)
  qt <- quadtree(habitat, .2)
  
  dist <- 7112
  xlim <- c(s_pt[1] - dist, s_pt[1] + dist)
  ylim <- c(s_pt[2] - dist, s_pt[2] + dist)
  
  lcpf <- lcp_finder(qt, s_pt, xlim = xlim, ylim = ylim)
  find_lcps(lcpf, return_summary = FALSE)
  plot(qt, crop = TRUE, border_lwd = .3, na_col = NULL)
  expect_error(lines(lcpf), NA)
  expect_error(points(lcpf, col = "red", pch = 16, cex = .5), NA)
})

unlink("Rplots.pdf")
