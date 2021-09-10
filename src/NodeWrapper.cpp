#include "Matrix.h"
#include "Node.h"
#include "NodeWrapper.h"
#include <memory>
#include <vector>
#include <string>
#include <Rcpp.h>

NodeWrapper::NodeWrapper(){
  node = nullptr;
}

NodeWrapper::NodeWrapper(std::shared_ptr<Node> _node){
  node = _node;
}

Rcpp::NumericVector NodeWrapper::xLims() const{
  Rcpp::NumericVector vec = {node->xMin, node->xMax};
  return vec;
}

Rcpp::NumericVector NodeWrapper::yLims() const{
  Rcpp::NumericVector vec = {node->yMin, node->yMax};
  return vec;
}

double NodeWrapper::value() const{
  return node->value;
}

double NodeWrapper::id() const{
  return node->id;
}

double NodeWrapper::smallestChildSideLength() const{
  return node->smallestChildSideLength;
}

double NodeWrapper::level() const{
  return node->level;
}

bool NodeWrapper::hasChildren() const{
  return node->hasChildren;
}

Rcpp::List NodeWrapper::getChildren() const{
  Rcpp::List list;
  if(node->hasChildren){
    list = Rcpp::List(node->children.size());
    for(size_t i = 0; i < node->children.size(); i++){
      list[i] = NodeWrapper(node->children[i]);
    }
  } else {
    list = Rcpp::List(0);
  }
  return list;
}

Rcpp::List NodeWrapper::getNeighbors() const{
  Rcpp::List list;
  list = Rcpp::List(node->neighbors.size());
  for(size_t i = 0; i < node->neighbors.size(); i++){
    auto node_i = node->neighbors[i].lock();
    list[i] = NodeWrapper(node_i);
  }
  return list;
}

int nCorners(double min, double max, double minNb, double maxNb){
  int nCorn{0};
  if(maxNb > max){
    nCorn+=1;
  }
  if(minNb < min){
    nCorn+=1;
  }
  return nCorn;
}

Rcpp::NumericVector getOverlapInfo(std::shared_ptr<Node> node, std::shared_ptr<Node> nb){
  double xOverlap = std::min(node->xMax, nb->xMax) - std::max(node->xMin, nb->xMin);
  double yOverlap = std::min(node->yMax, nb->yMax) - std::max(node->yMin, nb->yMin);
  double nCorn = 0;
  if(xOverlap != 0 && yOverlap == 0){
    nCorn = nCorners(node->xMin, node->xMax, nb->xMin, nb->xMax);
  } else if(xOverlap == 0 && yOverlap != 0){
    nCorn = nCorners(node->yMin, node->yMax, nb->yMin, nb->yMax);
  } else if(xOverlap == 0 && yOverlap == 0){
    nCorn = 1;
  }
  Rcpp::NumericVector vals = {xOverlap, yOverlap, nCorn};
  return vals;
}

Rcpp::NumericMatrix NodeWrapper::getNeighborInfo() const{
  Rcpp::NumericMatrix mat(node->neighbors.size(), 13);
  colnames(mat) = Rcpp::CharacterVector({"id", "xMin", "xMax", "yMin", "yMax", "xMean", "yMean", "value", "hasChdn", "xOverlap", "yOverlap", "totOverlap", "nCorners"});
  for(size_t i = 0; i < node->neighbors.size(); i++){
    auto node_i = node->neighbors[i].lock();
    mat(i,0) = node_i->id;
    mat(i,1) = node_i->xMin;
    mat(i,2) = node_i->xMax;
    mat(i,3) = node_i->yMin;
    mat(i,4) = node_i->yMax;
    mat(i,5) = (node_i->xMin + node_i->xMax)/2;
    mat(i,6) = (node_i->yMin + node_i->yMax)/2;
    mat(i,7) = node_i->value;
    mat(i,8) = node_i->hasChildren ? 1 : 0;
    Rcpp::NumericVector overlapVals = getOverlapInfo(node, node_i);
    mat(i,9) = overlapVals[0];
    mat(i,10) = overlapVals[1];
    mat(i,11) = overlapVals[0] + overlapVals[1]; //one of these will always be 0 so this should be the same as taking the maximum of the two values
    mat(i,12) = overlapVals[2];
  }
  return mat;
}

Rcpp::NumericVector NodeWrapper::getNeighborIds() const{
  Rcpp::NumericVector vec(node->neighbors.size());
  for(size_t i = 0; i < node->neighbors.size(); i++){
    auto node_i = node->neighbors[i].lock();
    vec[i] = node_i->id;
  }
  return vec;
}

Rcpp::NumericVector NodeWrapper::getNeighborVals() const{
  Rcpp::NumericVector vec(node->neighbors.size());
  for(size_t i = 0; i < node->neighbors.size(); i++){
    auto node_i = node->neighbors[i].lock();
    vec[i] = node_i->value;
  }
  return vec;
}

Rcpp::NumericVector NodeWrapper::asVector() const{
  double hasChildrenInt = node->hasChildren ? 1 : 0;
  Rcpp::NumericVector vec = {(double)node->id, hasChildrenInt, (double)node->level, node->xMin, node->xMax, node->yMin, node->yMax, node->value, node->smallestChildSideLength};
  vec.names() = Rcpp::CharacterVector({"id","hasChdn","level","xMin","xMax", "yMin", "yMax", "value", "smSide"});
  return vec;
}