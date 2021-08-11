#ifndef NODEWRAPPER_H
#define NODEWRAPPER_H

#include "Node.h"
#include <vector>
#include <memory>
#include <Rcpp.h>
#include <string>

class NodeWrapper{
public:
  std::shared_ptr<Node> node;
  
  NodeWrapper();
  NodeWrapper(std::shared_ptr<Node> _node);
  
  Rcpp::NumericVector xLims() const;
  Rcpp::NumericVector yLims() const;
  double value() const;
  double id() const;
  double smallestChildSideLength() const;
  double level() const;
  bool hasChildren() const;
  
  Rcpp::List getChildren() const;
  Rcpp::List getNeighbors() const;
  Rcpp::NumericMatrix getNeighborInfo() const;
  Rcpp::NumericVector getNeighborIds() const;
  Rcpp::NumericVector getNeighborVals() const;
  Rcpp::NumericVector asVector() const;
};

RCPP_EXPOSED_CLASS(NodeWrapper);

#endif