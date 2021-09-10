#ifndef LCPFINDERWRAPPER_H
#define LCPFINDERWRAPPER_H

#include "LcpFinder.h"
#include <Rcpp.h>
#include <string>
#include <memory>

class LcpFinderWrapper{
public:
  LcpFinder spf;
  Rcpp::NumericVector startPoint;
  
  LcpFinderWrapper(std::shared_ptr<Quadtree> quadtree, Rcpp::NumericVector _startPoint);
  LcpFinderWrapper(std::shared_ptr<Quadtree> quadtree, Rcpp::NumericVector _startPoint, Rcpp::NumericVector xlims, Rcpp::NumericVector ylims, bool searchByCentroid);
  
  void makeNetworkAll();
  void makeNetworkCostDist(double constraint);
  Rcpp::NumericMatrix getLcp(Rcpp::NumericVector endPoint);
  Rcpp::NumericMatrix getAllPathsSummary();
  Rcpp::NumericVector getStartPoint();
  Rcpp::NumericVector getSearchLimits();
};

RCPP_EXPOSED_CLASS(LcpFinderWrapper);

#endif