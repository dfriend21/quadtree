#include "Node.h"
#include "Matrix.h"
#include "Quadtree.h"

#include "R_Interface.h"
#include "NodeWrapper.h"
#include "QuadtreeWrapper.h"
#include "ShortestPathFinderWrapper.h"

#include <Rcpp.h>
#include <cassert>
#include <algorithm>
#include <string>
#include <functional>
#include <cmath>
#include <fstream>
#include <cereal/archives/portable_binary.hpp>
#include <cereal/types/memory.hpp>

QuadtreeWrapper::QuadtreeWrapper() : quadtree{nullptr} {}

QuadtreeWrapper::QuadtreeWrapper(std::shared_ptr<Quadtree> _quadtree) : quadtree{_quadtree} {}

//creates an empty quadtree
QuadtreeWrapper::QuadtreeWrapper(Rcpp::NumericVector xlims, Rcpp::NumericVector ylims, Rcpp::NumericVector maxCellLength, Rcpp::NumericVector minCellLength, bool splitAllNAs, bool splitAnyNAs){
  std::vector<double> xlimsNew(Rcpp::as<std::vector<double>>(xlims));
  std::vector<double> ylimsNew(Rcpp::as<std::vector<double>>(ylims));
  std::vector<double> maxLength(Rcpp::as<std::vector<double>>(maxCellLength));
  std::vector<double> minLength(Rcpp::as<std::vector<double>>(minCellLength));
  quadtree = std::make_shared<Quadtree>(xlimsNew[0], xlimsNew[1], ylimsNew[0], ylimsNew[1], maxLength[0], maxLength[1], minLength[0], minLength[1], splitAllNAs, splitAnyNAs);
}

int QuadtreeWrapper::nNodes() const{
  return quadtree->nNodes; 
}

NodeWrapper QuadtreeWrapper::root() const{
  return NodeWrapper(quadtree->root);
}

void QuadtreeWrapper::setProjection(std::string proj4string){
  quadtree->proj4string = proj4string;
}

void QuadtreeWrapper::setOriginalValues(double xMin, double xMax, double yMin, double yMax, double nX, double nY){
  originalXMin = xMin;
  originalXMax = xMax;
  originalYMin = yMin;
  originalYMax = yMax;
  originalNX = nX;
  originalNY = nY;
};

Rcpp::NumericVector QuadtreeWrapper::extent() const{
  Rcpp::NumericVector v = Rcpp::NumericVector::create(Rcpp::Named("xMin",quadtree->root->xMin), Rcpp::Named("xMax", quadtree->root->xMax), Rcpp::Named("yMin",quadtree->root->yMin), Rcpp::Named("yMax", quadtree->root->yMax));
  return v;
}

Rcpp::NumericVector QuadtreeWrapper::originalExtent() const{
  Rcpp::NumericVector v = Rcpp::NumericVector::create(Rcpp::Named("xMin",originalXMin), Rcpp::Named("xMax", originalXMax), Rcpp::Named("yMin",originalYMin), Rcpp::Named("yMax", originalYMax));
  return v;
}

Rcpp::NumericVector QuadtreeWrapper::originalDim() const{
  Rcpp::NumericVector v = Rcpp::NumericVector::create(Rcpp::Named("nX",originalNX), Rcpp::Named("nY",originalNY));
  return v;
}

Rcpp::NumericVector QuadtreeWrapper::originalRes() const{
  double xRes = (originalXMax - originalXMin)/originalNX;
  double yRes = (originalYMax - originalYMin)/originalNY;
  Rcpp::NumericVector v = Rcpp::NumericVector::create(Rcpp::Named("xRes", xRes), Rcpp::Named("yRes", yRes));
  return v;
}

Rcpp::NumericVector QuadtreeWrapper::minCellDims() const{
  Rcpp::NumericVector v = Rcpp::NumericVector::create(Rcpp::Named("xMinCellLength", quadtree->minXCellLength), Rcpp::Named("yMinCellLength", quadtree->minYCellLength));
  return v;
}

Rcpp::NumericVector QuadtreeWrapper::maxCellDims() const{
  Rcpp::NumericVector v = Rcpp::NumericVector::create(Rcpp::Named("xMaxCellLength", quadtree->maxXCellLength), Rcpp::Named("yMaxCellLength", quadtree->maxYCellLength));
  return v;
}

std::string QuadtreeWrapper::projection() const{
  return quadtree->proj4string;
}

void QuadtreeWrapper::createTree(Rcpp::NumericMatrix &mat, std::string splitMethod, double splitThreshold, std::string combineMethod, Rcpp::Function splitFun, Rcpp::List splitArgs, Rcpp::Function combineFun, Rcpp::List combineArgs, QuadtreeWrapper templateQuadtree){
  Matrix matNew(rInterface::rMatToCppMat(mat));
  
  // set the combine function
  std::function<double (const Matrix&)> combine = [](const Matrix &mat) -> double {
    return Quadtree::combineMean(mat);
  };
  if(combineMethod != "custom"){
    if(combineMethod == "median"){
      combine = [](const Matrix &mat) -> double {
        return Quadtree::combineMedian(mat);
      };   
    } else if(combineMethod == "min"){
      combine = [](const Matrix &mat) -> double {
        return Quadtree::combineMin(mat);
      };
    } else if(combineMethod == "max"){
      combine = [](const Matrix &mat) -> double {
        return Quadtree::combineMax(mat);
      };
    }
  } else {
    combine = [&combineArgs, &combineFun] (const Matrix &mat) -> double{
      return Rcpp::as<double>(combineFun(mat.vec, combineArgs));
    };
  }
  
  if(templateQuadtree.quadtree){
    quadtree->makeTreeWithTemplate(matNew, templateQuadtree.quadtree, combine);
  } else {
    // set the split function
    std::function<bool (const Matrix&)> split = [&splitThreshold](const Matrix &mat) -> bool {
      return Quadtree::splitRange(mat, splitThreshold);
    };
    if(splitMethod != "custom"){
      if(splitMethod == "sd"){
        split = [&splitThreshold](const Matrix &mat) -> bool {
          return Quadtree::splitSD(mat, splitThreshold);
        };
      }
    } else {
      split = [&splitArgs, &splitFun] (const Matrix &mat) -> bool{
        return Rcpp::as<bool>(splitFun(mat.vec, splitArgs));
      };
    }
    
    quadtree->makeTree(matNew, split, combine);
  }
}

std::vector<double> QuadtreeWrapper::getValues(const std::vector<double> &x, const std::vector<double> &y) const{
  assert(x.size() == y.size());
  
  std::vector<double> vals(x.size());
  for(int i = 0; i < x.size(); ++i){
    vals[i] = quadtree->getValue(x[i], y[i]);
  }
  return(vals);
}

Rcpp::NumericMatrix QuadtreeWrapper::getNeighbors(Rcpp::NumericVector pt) const{
  std::vector<double> ptVec(Rcpp::as<std::vector<double>>(pt));
  auto node = quadtree->getNode(ptVec[0],ptVec[1]);
  Rcpp::NumericMatrix mat(node->neighbors.size(),6);
  colnames(mat) = Rcpp::CharacterVector({"id","xmin","xmax","ymin","ymax","value"}); //name the columns
  for(size_t i = 0; i < node->neighbors.size(); ++i){
    auto nb_i = node->neighbors[i].lock();
    mat(i,0) = nb_i->id;
    mat(i,1) = nb_i->xMin;
    mat(i,2) = nb_i->xMax;
    mat(i,3) = nb_i->yMin;
    mat(i,4) = nb_i->yMax;
    mat(i,5) = nb_i->value;
  }
  return mat;
}

//I should maybe switch this to accept NumericVectors for consistency...
void QuadtreeWrapper::setValues(const std::vector<double> &x, const std::vector<double> &y, const std::vector<double> &newVals){
  assert(x.size() == y.size() && y.size() == newVals.size());
  
  for(size_t i = 0; i < x.size(); ++i){
    quadtree->setValue(x[i], y[i], newVals[i]);
  }
}

void QuadtreeWrapper::transformValues(Rcpp::Function transformFun){
  std::function<double (const double)> transform = [&transformFun] (const double val) -> double{
    return Rcpp::as<double>(transformFun(val));
  };
  quadtree->transformValues(transform);
}


NodeWrapper QuadtreeWrapper::getCell(double x, double y) const{
  return NodeWrapper(quadtree->getNode(x, y));
}

Rcpp::List QuadtreeWrapper::getCells(Rcpp::NumericVector x, Rcpp::NumericVector y) const{
  assert(x.length() == y.length());
  Rcpp::List list = Rcpp::List(x.length());
  for(int i = 0; i < x.length(); ++i){
    list[i] = NodeWrapper(quadtree->getNode(x[i], y[i]));
  }
  return list;
}

Rcpp::NumericMatrix QuadtreeWrapper::getCellDetails(Rcpp::NumericVector x, Rcpp::NumericVector y) const{
  assert(x.length() == y.length());
  Rcpp::NumericMatrix mat(x.length(),6);
  colnames(mat) = Rcpp::CharacterVector({"id","xmin","xmax","ymin","ymax","value"}); //name the columns
  for(int i = 0; i < x.length(); ++i){
    auto node = quadtree->getNode(x[i],y[i]);
    if(node){
      mat(i,0) = node->id;
      mat(i,1) = node->xMin;
      mat(i,2) = node->xMax;
      mat(i,3) = node->yMin;
      mat(i,4) = node->yMax;
      mat(i,5) = node->value;
    } else {
      mat(i,0) = std::numeric_limits<double>::quiet_NaN();
      mat(i,1) = std::numeric_limits<double>::quiet_NaN();
      mat(i,2) = std::numeric_limits<double>::quiet_NaN();
      mat(i,3) = std::numeric_limits<double>::quiet_NaN();
      mat(i,4) = std::numeric_limits<double>::quiet_NaN();
      mat(i,5) = std::numeric_limits<double>::quiet_NaN();
    }
  }
  return mat;
}

std::string QuadtreeWrapper::print() const{
  return quadtree->toString();
}

void QuadtreeWrapper::makeList(std::shared_ptr<Node> node, Rcpp::List &list, int parentID) const{
  NodeWrapper nodew(node);
  Rcpp::NumericVector vec = nodew.asVector();
  vec.push_back(parentID, "parentID");
  list[node->id] = vec;
  if(node->hasChildren){
    for(int i = 0; i < node->children.size(); ++i){
      makeList(node->children[i], list, node->id);
    }
  }
}


Rcpp::List QuadtreeWrapper::asList(){
  Rcpp::List list = Rcpp::List(quadtree->nNodes);
  makeList(quadtree->root, list, -1);
  return list;
}

std::vector<double> QuadtreeWrapper::asVector() const{
  return quadtree->toVector();
}



//not directly callable from R - called by 'getNbList()'
//recursively creates a matrix of that represents all the neighbors of a node
//returns a matrix with 9 columns, in this order:
//id of this node
//x coordinate of centroid of this node
//y coordinate of centroid of this node
//value of this node
//id of the neighbor
//x coordinate of centroid of the neighbor
//y coordinate of centroid of the neighbor
//value of the neighbor
//0 if either of the nodes has children, 1 otherwise (think of this column as 'are both of these cells at the bottom of the tree?')
void QuadtreeWrapper::makeNbList(std::shared_ptr<Node> node, Rcpp::List &list) const{
  std::vector<std::shared_ptr<Node>> neighbors = quadtree->findNeighbors(node, quadtree->root->smallestChildSideLength);
  Rcpp::NumericMatrix nbMat(neighbors.size(), 9); //initialize a matrix
  colnames(nbMat) = Rcpp::CharacterVector({"id0", "x0", "y0", "val0", "id1", "x1", "y1", "val1", "isLowest"}); //name the columns
  
  //loop through the neighbors and create an entry in the matrix for each neighbor
  for(int i = 0; i < neighbors.size(); ++i){
    nbMat(i,0) = node->id;
    nbMat(i,1) = (node->xMin+node->xMax)/2;
    nbMat(i,2) = (node->yMin+node->yMax)/2;
    nbMat(i,3) = node->value;
    nbMat(i,4) = neighbors[i]->id;
    nbMat(i,5) = (neighbors[i]->xMin + neighbors[i]->xMax)/2;
    nbMat(i,6) = (neighbors[i]->yMin + neighbors[i]->yMax)/2;
    nbMat(i,7) = neighbors[i]->value;
    nbMat(i,8) = (node->hasChildren | neighbors[i]->hasChildren) ? 0 : 1;
  }
  list[node->id] = nbMat;
  if(node->hasChildren){
    for(int i = 0; i < node->children.size(); ++i){
      makeNbList(node->children[i], list);
    }
  }
}

//returns a list of neighbor matrices, one for each node. If it's already been 
//created, just return it. Otherwise, create it first, then return it.
Rcpp::List QuadtreeWrapper::getNbList(){
  if(nbList.length() == 0){
    Rcpp::List list = Rcpp::List(quadtree->nNodes);
    makeNbList(quadtree->root, list);
    nbList = list;
  } 
  return nbList;
}

ShortestPathFinderWrapper QuadtreeWrapper::getShortestPathFinder(Rcpp::NumericVector startPoint, Rcpp::NumericVector xlims, Rcpp::NumericVector ylims, bool searchByCentroid) const{
  return ShortestPathFinderWrapper(quadtree, startPoint, xlims, ylims, searchByCentroid);
}

QuadtreeWrapper QuadtreeWrapper::copy() const{
  QuadtreeWrapper qtw = QuadtreeWrapper();
  
  qtw.proj4String = proj4String;
  qtw.originalXMin = originalXMin;
  qtw.originalXMax = originalXMax;
  qtw.originalYMin = originalYMin;
  qtw.originalYMax = originalYMax;
  qtw.originalNX = originalNX;
  qtw.originalNY = originalNY;
  qtw.quadtree = quadtree->copy();
  return(qtw);
}
// 
// void QuadtreeWrapper::writeQuadtree(std::string filePath){
//   Quadtree::writeQuadtree(quadtree, filePath);
// }

// QuadtreeWrapper QuadtreeWrapper::readQuadtree(std::string filePath){
//   return(QuadtreeWrapper(Quadtree::readQuadtree(filePath)));
// }

void QuadtreeWrapper::writeQuadtree(QuadtreeWrapper qw, std::string filePath){
  //Quadtree::writeQuadtree(quadtree, filePath);
  std::ofstream os(filePath, std::ios::binary);
  cereal::PortableBinaryOutputArchive oarchive(os);
  oarchive(qw);
}

QuadtreeWrapper QuadtreeWrapper::readQuadtree(std::string filePath){
  std::ifstream is(filePath, std::ios::binary);
  cereal::PortableBinaryInputArchive iarchive(is);
  QuadtreeWrapper qw;
  iarchive(qw);
  return qw;
}


// void QuadtreeWrapper::writeQuadtree(QuadtreeWrapper qw, std::string filePath){
//   int x = 0;
// }
// 
// QuadtreeWrapper QuadtreeWrapper::readQuadtree(std::string filePath){
//   QuadtreeWrapper qw;
//   return qw;
// }