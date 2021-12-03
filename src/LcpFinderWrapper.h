#ifndef LCPFINDERWRAPPER_H
#define LCPFINDERWRAPPER_H

#include "LcpFinder.h"

#include <Rcpp.h>

#include <memory>
#include <string>

class LcpFinderWrapper{
public:
  LcpFinder lcpFinder;
  Rcpp::NumericVector startPoint;
  std::shared_ptr<Node> startNode;
  
  LcpFinderWrapper(std::shared_ptr<Quadtree> quadtree, Rcpp::NumericVector _startPoint);
  LcpFinderWrapper(std::shared_ptr<Quadtree> quadtree, Rcpp::NumericVector _startPoint, Rcpp::NumericVector xlim, Rcpp::NumericVector ylim, bool searchByCentroid);
  LcpFinderWrapper(std::shared_ptr<Quadtree> quadtree, Rcpp::NumericVector _startPoint, Rcpp::NumericVector xlim, Rcpp::NumericVector ylim, Rcpp::NumericMatrix newPoints, bool searchByCentroid);
  
  void makeNetworkAll();
  void makeNetworkCostDist(double constraint);
  Rcpp::NumericMatrix getLcp(Rcpp::NumericVector endPoint, bool sameCellPath);

  Rcpp::NumericMatrix getAllPathsSummary();
  Rcpp::NumericVector getStartPoint();
  Rcpp::NumericVector getSearchLimits();
};

RCPP_EXPOSED_CLASS(LcpFinderWrapper);

#endif