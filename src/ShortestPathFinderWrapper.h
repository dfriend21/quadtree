#ifndef SHORTESTPATHFINDERWRAPPER_H
#define SHORTESTPATHFINDERWRAPPER_H

#include "ShortestPathFinder.h"
#include <Rcpp.h>
#include <string>
#include <memory>

class ShortestPathFinderWrapper{
public:
  ShortestPathFinder spf;
  Rcpp::NumericVector startPoint;
  
  ShortestPathFinderWrapper(std::shared_ptr<Quadtree> quadtree, Rcpp::NumericVector _startPoint);
  ShortestPathFinderWrapper(std::shared_ptr<Quadtree> quadtree, Rcpp::NumericVector _startPoint, Rcpp::NumericVector xlims, Rcpp::NumericVector ylims);
  
  void makeNetworkAll();
  // void makeNetworkCost(double constraint);
  void makeNetworkCostDist(double constraint);
  Rcpp::NumericMatrix getShortestPath(Rcpp::NumericVector endPoint);
  Rcpp::NumericMatrix getAllPathsSummary();
  Rcpp::NumericVector getStartPoint();
  Rcpp::NumericVector getSearchLimits();
};

RCPP_EXPOSED_CLASS(ShortestPathFinderWrapper);

#endif