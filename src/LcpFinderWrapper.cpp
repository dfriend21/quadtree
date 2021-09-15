#include "LcpFinderWrapper.h"

LcpFinderWrapper::LcpFinderWrapper(std::shared_ptr<Quadtree> quadtree, Rcpp::NumericVector _startPoint)
    : startPoint{_startPoint}{
  spf = LcpFinder(quadtree,Point(startPoint[0], startPoint[1]));
}

LcpFinderWrapper::LcpFinderWrapper(std::shared_ptr<Quadtree> quadtree, Rcpp::NumericVector _startPoint, Rcpp::NumericVector xlim, Rcpp::NumericVector ylim, bool searchByCentroid)
  : startPoint {_startPoint}{
  spf = LcpFinder(quadtree,Point(startPoint[0], startPoint[1]), xlim[0], xlim[1], ylim[0], ylim[1], searchByCentroid);
}

void LcpFinderWrapper::makeNetworkAll(){
  spf.makeNetworkAll();
}

void LcpFinderWrapper::makeNetworkCostDist(double constraint){
  spf.makeNetworkCostDist(constraint);
}

Rcpp::NumericMatrix LcpFinderWrapper::getLcp(Rcpp::NumericVector endPoint){
  std::vector<std::tuple<std::shared_ptr<Node>,double,double>> path = spf.getLcp(Point(endPoint[0], endPoint[1]));
  Rcpp::NumericMatrix mat(path.size(),5);
  colnames(mat) = Rcpp::CharacterVector({"x","y","cost_tot","dist_tot", "cost_cell"}); //name the columns
  for(size_t i = 0; i < path.size(); ++i){  
    mat(i,0) = (std::get<0>(path.at(i))->xMin + std::get<0>(path.at(i))->xMax)/2;
    mat(i,1) = (std::get<0>(path.at(i))->yMin + std::get<0>(path.at(i))->yMax)/2;
    mat(i,2) = std::get<1>(path.at(i));
    mat(i,3) = std::get<2>(path.at(i));
    mat(i,4) = std::get<0>(path.at(i))->value;
  }
  return mat;
}

Rcpp::NumericMatrix LcpFinderWrapper::getAllPathsSummary(){
  //first we need to know how many "found" paths are currently in the network
  int nPaths{0};
  for(size_t i = 0; i < spf.nodeEdges.size(); ++i){
    if(spf.nodeEdges.at(i)->parent.lock()){
      nPaths++;
    }
  }
  
  //now we can construct a matrix to store info on each path
  Rcpp::NumericMatrix mat(nPaths,9);
  colnames(mat) = Rcpp::CharacterVector({"id","xmin","xmax", "ymin", "ymax","value","area","lcp_cost","lcp_dist"}); //name the columns
  int counter = 0; 
  for(size_t i = 0; i < spf.nodeEdges.size(); ++i){
    if(spf.nodeEdges[i]->parent.lock()){
      std::shared_ptr<Node> node = spf.nodeEdges[i]->node.lock();
      mat(counter,0) = node->id;
      mat(counter,1) = node->xMin;
      mat(counter,2) = node->xMax;
      mat(counter,3) = node->yMin;
      mat(counter,4) = node->yMax;
      mat(counter,5) = node->value;
      mat(counter,6) = (node->xMax - node->xMin) * (node->yMax - node->yMin);
      mat(counter,7) = spf.nodeEdges[i]->cost;
      mat(counter,8) = spf.nodeEdges[i]->dist;
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
  vec[0] = spf.xMin;
  vec[1] = spf.xMax;
  vec[2] = spf.yMin;
  vec[3] = spf.yMax;
  vec.names() = Rcpp::CharacterVector({"xmin","xmax","ymin","ymax"});
  return vec;
}