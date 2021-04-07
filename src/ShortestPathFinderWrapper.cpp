#include "ShortestPathFinderWrapper.h"

ShortestPathFinderWrapper::ShortestPathFinderWrapper(std::shared_ptr<Quadtree> quadtree, Rcpp::NumericVector _startPoint)
    : startPoint{_startPoint}{
  spf = ShortestPathFinder(quadtree,Point(startPoint[0], startPoint[1]));
}

ShortestPathFinderWrapper::ShortestPathFinderWrapper(std::shared_ptr<Quadtree> quadtree, Rcpp::NumericVector _startPoint, Rcpp::NumericVector xlims, Rcpp::NumericVector ylims)
  : startPoint {_startPoint}{
  spf = ShortestPathFinder(quadtree,Point(startPoint[0], startPoint[1]), xlims[0], xlims[1], ylims[0], ylims[1]);
}

void ShortestPathFinderWrapper::makeShortestPathNetwork(){
  spf.makeShortestPathNetwork();
}

Rcpp::NumericMatrix ShortestPathFinderWrapper::getShortestPath(Rcpp::NumericVector endPoint){
  //_endPoint = endPoint;
  std::vector<std::shared_ptr<Node>> path = spf.getShortestPath(Point(endPoint[0], endPoint[1]));
  Rcpp::NumericMatrix mat(path.size(),2);
  // Rcpp::Rcout << "endPoint[0]: " << endPoint[0] << "\n";
  // Rcpp::Rcout << "endPoint[1]: " << endPoint[1] << "\n";
  // Rcpp::Rcout << "path.size(): " << path.size() << "\n";
  //Rcpp::NumericMatrix mat(static_cast<int>(path.size()),2);
  //Rcpp::NumericMatrix mat(10,2);
  //for(int i = 0; i < path.size(); ++i){  
  for(size_t i = 0; i < path.size(); ++i){  
    mat(i,0) = (path.at(i)->xMin + path.at(i)->xMax)/2;
    mat(i,1) = (path.at(i)->yMin + path.at(i)->yMax)/2;
  }
  return mat;
}

Rcpp::NumericVector ShortestPathFinderWrapper::getStartPoint(){
  Rcpp::NumericVector vec(2);
  vec[0] = startPoint[0];
  vec[1] = startPoint[1];
  return vec;
}

Rcpp::NumericVector ShortestPathFinderWrapper::getSearchLimits(){
  Rcpp::NumericVector vec(4);
  vec[0] = spf.xMin;
  vec[1] = spf.xMax;
  vec[2] = spf.yMin;
  vec[3] = spf.yMax;
  return vec;
}