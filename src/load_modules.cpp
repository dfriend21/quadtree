#include "NodeWrapper.h"
#include "QuadtreeWrapper.h"
#include "LcpFinderWrapper.h"
#include "R_Interface.h"

RCPP_MODULE(qt) {
  using namespace Rcpp;
  
  class_<NodeWrapper>("CppNode")
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
  
  class_<QuadtreeWrapper>("CppQuadtree") 
    .constructor()
    .constructor<Rcpp::NumericVector, Rcpp::NumericVector, Rcpp::NumericVector, Rcpp::NumericVector, bool, bool>()
    .method("asVector", &QuadtreeWrapper::asVector)
    .method("nNodes", &QuadtreeWrapper::nNodes)
    .method("root", &QuadtreeWrapper::root)
    .method("createTree", &QuadtreeWrapper::createTree)
    .method("getValues", &QuadtreeWrapper::getValues)
    .method("setValues", &QuadtreeWrapper::setValues)
    .method("transformValues", &QuadtreeWrapper::transformValues)
    .method("getCell", &QuadtreeWrapper::getCell)
    .method("getCells", &QuadtreeWrapper::getCells)
    .method("getCellDetails", &QuadtreeWrapper::getCellDetails)
    .method("getNeighbors", &QuadtreeWrapper::getNeighbors)
    .method("asList", &QuadtreeWrapper::asList)
    .method("print", &QuadtreeWrapper::print)
    .method("getNbList", &QuadtreeWrapper::getNbList)
    .method("getLcpFinder", &QuadtreeWrapper::getLcpFinder)
    .method("copy", &QuadtreeWrapper::copy)
    .method("setProjection", &QuadtreeWrapper::setProjection)
    .method("setOriginalValues", &QuadtreeWrapper::setOriginalValues)
    .method("extent", &QuadtreeWrapper::extent)
    .method("originalExtent", &QuadtreeWrapper::originalExtent)
    .method("originalDim", &QuadtreeWrapper::originalDim)
    .method("originalRes", &QuadtreeWrapper::originalRes)
    .method("minCellDims", &QuadtreeWrapper::minCellDims)
    .method("maxCellDims", &QuadtreeWrapper::maxCellDims)
    .method("projection", &QuadtreeWrapper::projection);
  
  class_<LcpFinderWrapper>("CppLcpFinder")
    .method("makeNetworkAll", &LcpFinderWrapper::makeNetworkAll)
    .method("makeNetworkCostDist", &LcpFinderWrapper::makeNetworkCostDist)
    .method("getLcp", &LcpFinderWrapper::getLcp)
    .method("getAllPathsSummary", &LcpFinderWrapper::getAllPathsSummary)
    .method("getStartPoint", &LcpFinderWrapper::getStartPoint)
    .method("getSearchLimits", &LcpFinderWrapper::getSearchLimits);

  function("readQuadtreeCpp", &QuadtreeWrapper::readQuadtree);
  function("writeQuadtreeCpp", &QuadtreeWrapper::writeQuadtree);
}