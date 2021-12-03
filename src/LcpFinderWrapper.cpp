#include "LcpFinderWrapper.h"

#include "Point.h"

#include <map>

LcpFinderWrapper::LcpFinderWrapper(std::shared_ptr<Quadtree> quadtree, Rcpp::NumericVector _startPoint)
    : startPoint{_startPoint}{
  startNode = quadtree->getNode(Point(startPoint[0], startPoint[1]));
  lcpFinder = LcpFinder(quadtree,Point(startPoint[0], startPoint[1]));
}

LcpFinderWrapper::LcpFinderWrapper(std::shared_ptr<Quadtree> quadtree, Rcpp::NumericVector _startPoint, Rcpp::NumericVector xlim, Rcpp::NumericVector ylim, bool searchByCentroid)
  : startPoint {_startPoint}{
  startNode = quadtree->getNode(Point(startPoint[0], startPoint[1]));
  lcpFinder = LcpFinder(quadtree,Point(startPoint[0], startPoint[1]), xlim[0], xlim[1], ylim[0], ylim[1], searchByCentroid);
}

LcpFinderWrapper::LcpFinderWrapper(std::shared_ptr<Quadtree> quadtree, Rcpp::NumericVector _startPoint, Rcpp::NumericVector xlim, Rcpp::NumericVector ylim, Rcpp::NumericMatrix newPoints, bool searchByCentroid)
  : startPoint {_startPoint}{
  startNode = quadtree->getNode(Point(startPoint[0], startPoint[1]));
  std::vector<Point> points(newPoints.nrow());
  for(int i = 0; i < newPoints.nrow(); ++i){
    points[i] = Point(newPoints(i,0), newPoints(i,1));
  }
  lcpFinder = LcpFinder(quadtree, Point(startPoint[0], startPoint[1]), xlim[0], xlim[1], ylim[0], ylim[1], points, searchByCentroid);
}

void LcpFinderWrapper::makeNetworkAll(){
  lcpFinder.makeNetworkAll();
}

void LcpFinderWrapper::makeNetworkCostDist(double constraint){
  lcpFinder.makeNetworkCostDist(constraint);
}

Rcpp::NumericMatrix LcpFinderWrapper::getLcp(Rcpp::NumericVector endPoint, bool allowSameCellPath){
  std::vector<std::shared_ptr<LcpFinder::NodeEdge>> path = lcpFinder.getLcp(Point(endPoint[0], endPoint[1]));
  
  int nRow = path.size();
  bool addEndPoint = false;
  if(allowSameCellPath && path.size() == 1){
    addEndPoint = true;
    nRow = path.size() + 1;
  }
  Rcpp::NumericMatrix mat(nRow,6);
  colnames(mat) = Rcpp::CharacterVector({"x", "y", "cost_tot", "dist_tot", "cost_cell", "cell_id"}); //name the columns
  for(size_t i = 0; i < path.size(); ++i){  
    auto node = path.at(i)->node.lock();
    mat(i,0) = path.at(i)->pt.x;
    mat(i,1) = path.at(i)->pt.y;
    mat(i,2) = path.at(i)->cost; 
    mat(i,3) = path.at(i)->dist;
    mat(i,4) = node->value;
    mat(i,5) = node->id;
  }
  if(addEndPoint){
    double dist = std::sqrt(std::pow(endPoint[0] - path.at(0)->pt.x, 2) + std::pow(endPoint[1] - path.at(0)->pt.y, 2));
    auto node = path.at(0)->node.lock();
    double cost = node->value * dist;
    colnames(mat) = Rcpp::CharacterVector({"x", "y", "cost_tot", "dist_tot", "cost_cell", "cell_id"});
    mat(nRow - 1, 0) = endPoint[0];
    mat(nRow - 1, 1) = endPoint[1];
    mat(nRow - 1, 2) = cost;
    mat(nRow - 1, 3) = dist;
    mat(nRow - 1, 4) = node->value;
    mat(nRow - 1, 5) = node->id;
  }
  return mat;
}

Rcpp::NumericMatrix LcpFinderWrapper::getAllPathsSummary(){
  //first we need to know how many "found" paths are currently in the network
  int nPaths{0};
  for(size_t i = 0; i < lcpFinder.nodeEdges.size(); ++i){
    if(lcpFinder.nodeEdges.at(i)->parent.lock()){
      nPaths++;
    }
  }
  
  //now we can construct a matrix to store info on each path
  Rcpp::NumericMatrix mat(nPaths,9);
  colnames(mat) = Rcpp::CharacterVector({"id","xmin","xmax", "ymin", "ymax","value","area","lcp_cost","lcp_dist"}); //name the columns
  int counter = 0; 
  for(size_t i = 0; i < lcpFinder.nodeEdges.size(); ++i){
    if(lcpFinder.nodeEdges[i]->parent.lock()){
      std::shared_ptr<Node> node = lcpFinder.nodeEdges[i]->node.lock();
      mat(counter,0) = node->id;
      mat(counter,1) = node->xMin;
      mat(counter,2) = node->xMax;
      mat(counter,3) = node->yMin;
      mat(counter,4) = node->yMax;
      mat(counter,5) = node->value;
      mat(counter,6) = (node->xMax - node->xMin) * (node->yMax - node->yMin);
      mat(counter,7) = lcpFinder.nodeEdges[i]->cost;
      mat(counter,8) = lcpFinder.nodeEdges[i]->dist;
      counter++;
    }
  }
  return mat;
}

Rcpp::NumericVector LcpFinderWrapper::getStartPoint(){
  Rcpp::NumericVector vec(2);
  vec[0] = startPoint[0];
  vec[1] = startPoint[1];
  vec.names() = Rcpp::CharacterVector({"x","y"});
  return vec;
}

Rcpp::NumericVector LcpFinderWrapper::getSearchLimits(){
  Rcpp::NumericVector vec(4);
  vec[0] = lcpFinder.xMin;
  vec[1] = lcpFinder.xMax;
  vec[2] = lcpFinder.yMin;
  vec[3] = lcpFinder.yMax;
  vec.names() = Rcpp::CharacterVector({"xmin","xmax","ymin","ymax"});
  return vec;
}