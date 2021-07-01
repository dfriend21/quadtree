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
  //Rcpp::NumericVector _endPoint; //DEBUGGING ONLY - REMOVE!!!!!!!!!!!!!!!!!!!!!!!!
  
  ShortestPathFinderWrapper(std::shared_ptr<Quadtree> quadtree, Rcpp::NumericVector _startPoint);
  ShortestPathFinderWrapper(std::shared_ptr<Quadtree> quadtree, Rcpp::NumericVector _startPoint, Rcpp::NumericVector xlims, Rcpp::NumericVector ylims);
  
  void makeNetworkAll();
  void makeNetworkDist(double constraint);
  void makeNetworkCost(double constraint);
  void makeNetworkCostDist(double constraint);
  // void makeShortestPathNetworkConstrained(double cost, std::string type);
  Rcpp::NumericMatrix getShortestPath(Rcpp::NumericVector endPoint);
  Rcpp::NumericMatrix getAllPathsSummary();
  Rcpp::NumericVector getStartPoint();
  Rcpp::NumericVector getSearchLimits();
  bool isValid();
};


RCPP_EXPOSED_CLASS(ShortestPathFinderWrapper);

#endif