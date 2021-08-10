#include "NodeWrapper.h"
#include "QuadtreeWrapper.h"
#include "ShortestPathFinderWrapper.h"
#include "R_Interface.h"
// #include "abm.hpp"
// #include "abm2.hpp"

//RCPP_EXPOSED_CLASS(NodeWrapper);

//RCPP_EXPOSED_CLASS(QuadtreeWrapper);

RCPP_MODULE(qt) {
  using namespace Rcpp;
  
  class_<NodeWrapper>("node")
    .method("xLims", &NodeWrapper::xLims)
    .method("yLims", &NodeWrapper::yLims)
    .method("value", &NodeWrapper::value)
    .method("smallestChildSideLength", &NodeWrapper::smallestChildSideLength)
    .method("level", &NodeWrapper::level)
    .method("id", &NodeWrapper::id)
    .method("hasChildren", &NodeWrapper::hasChildren)
    .method("getChildren", &NodeWrapper::getChildren)
    .method("getNeighbors", &NodeWrapper::getNeighbors)
    .method("getNeighborInfo", &NodeWrapper::getNeighborInfo)
    .method("getNeighborIds", &NodeWrapper::getNeighborIds)
    .method("getNeighborVals", &NodeWrapper::getNeighborVals)
    .method("asVector", &NodeWrapper::asVector);
  //.field("smallestChildSideLength", &Node::smallestChildSideLength)
  //.field("hasChildren", &Node::hasChildren)
  //.field("children", &Node::children);
  
  class_<QuadtreeWrapper>("quadtree") 
    .constructor()
    //.constructor<double, double, double, double, double>()
      //.constructor<Rcpp::NumericMatrix, Rcpp::NumericVector, Rcpp::NumericVector, double, double, double>()
                  // <Rcpp::NumericMatrix, Rcpp::NumericVector, Rcpp::NumericVector, Rcpp::Function, Rcpp::List, double, double);
      // .constructor<Rcpp::NumericMatrix, Rcpp::NumericVector, Rcpp::NumericVector, Rcpp::Function, Rcpp::List, double, double>()
         // .constructor<Rcpp::NumericMatrix, Rcpp::NumericVector, Rcpp::NumericVector, Rcpp::Function, Rcpp::List, Rcpp::Function, Rcpp::List, double, double>() //GAH WHY DO YOU ONLY ALLOW 6 PARAMETERS?!! @#*@^%#!!!! (https://rdrr.io/rforge/Rcpp/f/inst/doc/Rcpp-modules.pdf)
    // .constructor<Rcpp::NumericVector, Rcpp::NumericVector, double, double, double, double>()
    .constructor<Rcpp::NumericVector, Rcpp::NumericVector, Rcpp::NumericVector, Rcpp::NumericVector, bool, bool>()
    //.constructor<Rcpp::NumericVector, Rcpp::NumericVector, double>()
      // .method("rangeLim", &QuadtreeWrapper::rangeLim)
    .method("nNodes", &QuadtreeWrapper::nNodes)
    .method("root", &QuadtreeWrapper::root)
    .method("createTree", &QuadtreeWrapper::createTree)
    .method("getValues", &QuadtreeWrapper::getValues)
    .method("setValues", &QuadtreeWrapper::setValues)
    .method("getCell", &QuadtreeWrapper::getCell)
    .method("getCells", &QuadtreeWrapper::getCells)
    .method("getCellDetails", &QuadtreeWrapper::getCellDetails)
    .method("asList", &QuadtreeWrapper::asList)
    .method("print", &QuadtreeWrapper::print)
    .method("getNbList", &QuadtreeWrapper::getNbList)
    .method("getShortestPathFinder", &QuadtreeWrapper::getShortestPathFinder)
    .method("copy", &QuadtreeWrapper::copy)
    .method("writeQuadtree", &QuadtreeWrapper::writeQuadtree)
    .method("setProjection", &QuadtreeWrapper::setProjection)
    .method("setOriginalValues", &QuadtreeWrapper::setOriginalValues)
    .method("extent", &QuadtreeWrapper::extent)
    .method("originalExtent", &QuadtreeWrapper::originalExtent)
    .method("originalDim", &QuadtreeWrapper::originalDim)
    .method("originalRes", &QuadtreeWrapper::originalRes)
    .method("maxCellDims", &QuadtreeWrapper::maxCellDims)
    .method("projection", &QuadtreeWrapper::projection);
  
  // ShortestPathFinderWrapper(std::shared_ptr<Quadtree> quadtree, std::vector<double> startPoint);
  // ShortestPathFinderWrapper(std::shared_ptr<Quadtree> quadtree, std::vector<double> startPoint, std::vector<double> xlims, std::vector<double> ylims);
  // 
  // Rcpp::NumericMatrix makeShortestPathNetwork();
  // Rcpp::NumericMatrix getShortestPath(std::vector<double> endPoint);
  class_<ShortestPathFinderWrapper>("shortestPathFinder")
    //.constructor<QuadtreeWrapper, Rcpp::NumericVector>()
    //.constructor<QuadtreeWrapper, Rcpp::NumericVector, Rcpp::NumericVector, Rcpp::NumericVector>()
    .method("makeNetworkAll", &ShortestPathFinderWrapper::makeNetworkAll)
    .method("makeNetworkCost", &ShortestPathFinderWrapper::makeNetworkCost)
    .method("makeNetworkCostDist", &ShortestPathFinderWrapper::makeNetworkCostDist)
    .method("getShortestPath", &ShortestPathFinderWrapper::getShortestPath)
    .method("getAllPathsSummary", &ShortestPathFinderWrapper::getAllPathsSummary)
    .method("getStartPoint", &ShortestPathFinderWrapper::getStartPoint)
    .method("getSearchLimits", &ShortestPathFinderWrapper::getSearchLimits);
    //.method("isValid", &ShortestPathFinderWrapper::isValid);

  function("readQuadtree", &QuadtreeWrapper::readQuadtree);
  //.
  //
  //function("getNextPoint" , &getNextPoint);
  //function("getAngle" , &getAngle);
  //function("getPointsAroundPoint" , &getPointsAroundPoint);
  //function("getAngleMoveProbs", &getAngleMoveProbs);
  //function("getAngleOffsetVal", &getAngleOffsetVal);
  //function("getRandomPointOnCircle", &getRandomPointOnCircle);
  //function("getMaxDistPoint", &getMaxDistPoint);
  //function("getRandomPointOnCircle", &getRandomPointOnCircle_cpp);
  //function("moveTort", &moveTort);
  //function("moveAgent_2", &moveAgent_2);
  //function("getRandomPointsOnCircle", &getRandomPointsOnCircle);
}