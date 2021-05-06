#include <Rcpp.h>
#include <cassert>
#include <algorithm>
#include <string>

#include "Node.h"
#include "Matrix.h"
#include "Quadtree.h"

#include "R_Interface.h"
#include "NodeWrapper.h"
#include "QuadtreeWrapper.h"
#include "ShortestPathFinderWrapper.h"


QuadtreeWrapper::QuadtreeWrapper(std::shared_ptr<Quadtree> _quadtree) : quadtree{_quadtree} {}
// QuadtreeWrapper::QuadtreeWrapper(Quadtree _quadtree) : quadtree{_quadtree} {}

//creates an empty quadtree with the given x and y limits, and the given
//range limit
QuadtreeWrapper::QuadtreeWrapper(Rcpp::NumericVector xlims, Rcpp::NumericVector ylims, double rangelim){
  //Matrix matNew(rMatToCppMat(mat));
  std::vector<double> xlimsNew(Rcpp::as<std::vector<double>>(xlims));
  std::vector<double> ylimsNew(Rcpp::as<std::vector<double>>(ylims));
  quadtree = std::shared_ptr<Quadtree>(new Quadtree(rangelim));
  // quadtree = Quadtree(rangelim);
  quadtree->root = Node::makeNode(xlimsNew[0], xlimsNew[1], ylimsNew[0], ylimsNew[1], 0, 0, 0)->ptr;
  nodeList = Rcpp::List::create(); 
  //nodeVec = std::vector<Rcpp::NumericVector>(0);
}

// Quadtree::Quadtree(double xMin, double xMax, double yMin, double yMax, double rangelim){
//   root = makeNode(xMin, xMax, yMin, yMax, 0)->ptr;
//   rangeLim = rangelim;
// }

//creates a quadtree from a given matrix
QuadtreeWrapper::QuadtreeWrapper(Rcpp::NumericMatrix mat, Rcpp::NumericVector xlims, Rcpp::NumericVector ylims, double rangelim){
  Matrix matNew(rInterface::rMatToCppMat(mat));
  std::vector<double> xlimsNew(Rcpp::as<std::vector<double>>(xlims));
  std::vector<double> ylimsNew(Rcpp::as<std::vector<double>>(ylims));
  quadtree = std::shared_ptr<Quadtree>(new Quadtree(rangelim));
  // quadtree = Quadtree(rangelim);
  quadtree->root = Node::makeNode(xlimsNew[0], xlimsNew[1], ylimsNew[0], ylimsNew[1], 0, 0, 0)->ptr;
  //list = Rcpp::List(0);
  nodeList = Rcpp::List::create();
  //nodeVec = std::vector<Rcpp::NumericVector>(0);
  //Rcpp::Rcout << matNew.toString();
  //Rcpp::Rcout << matNew.countNans();
  quadtree->makeTree(matNew);
  //quadtree->assignNeighbors();
}


int QuadtreeWrapper::nNodes() const{
  return quadtree->nNodes; 
}
double QuadtreeWrapper::rangeLim() const{
  return quadtree->rangeLim;
}

NodeWrapper QuadtreeWrapper::root() const{
  return NodeWrapper(quadtree->root);
}

void QuadtreeWrapper::setProjection(std::string proj4string){
  quadtree->proj4string = proj4string;
}

void QuadtreeWrapper::setOriginalValues(double xMin, double xMax, double yMin, double yMax, double nX, double nY){
  quadtree->originalXMin = xMin;
  quadtree->originalXMax = xMax;
  quadtree->originalYMin = yMin;
  quadtree->originalYMax = yMax;
  quadtree->originalNX = nX;
  quadtree->originalNY = nY;
};

Rcpp::NumericVector QuadtreeWrapper::extent(){
  Rcpp::NumericVector v = Rcpp::NumericVector::create(Rcpp::Named("xMin",quadtree->root->xMin), Rcpp::Named("xMax", quadtree->root->xMax), Rcpp::Named("yMin",quadtree->root->yMin), Rcpp::Named("yMax", quadtree->root->yMax));
  return v;
}

Rcpp::NumericVector QuadtreeWrapper::originalExtent(){
  //Rcpp::NumericVector v = Rcpp::NumericVector::create(Rcpp::Named("xMin",originalXMin), Rcpp::Named("xMax", originalXMax), Rcpp::Named("yMin",originalYMin), Rcpp::Named("yMax", originalYMax));
  Rcpp::NumericVector v = Rcpp::NumericVector::create(Rcpp::Named("xMin",quadtree->originalXMin), Rcpp::Named("xMax", quadtree->originalXMax), Rcpp::Named("yMin",quadtree->originalYMin), Rcpp::Named("yMax", quadtree->originalYMax));
  return v;
}

Rcpp::NumericVector QuadtreeWrapper::originalDim(){
  Rcpp::NumericVector v = Rcpp::NumericVector::create(Rcpp::Named("nX", quadtree->originalNX), Rcpp::Named("nY", quadtree->originalNY));
  return v;
}

Rcpp::NumericVector QuadtreeWrapper::originalRes(){
  double xRes = (quadtree->originalXMax - quadtree->originalXMin)/quadtree->originalNX;
  double yRes = (quadtree->originalYMax - quadtree->originalYMin)/quadtree->originalNY;
  Rcpp::NumericVector v = Rcpp::NumericVector::create(Rcpp::Named("xRes", xRes), Rcpp::Named("yRes", yRes));
  return v;
}

std::string QuadtreeWrapper::projection(){
  return quadtree->proj4string;
}

void QuadtreeWrapper::createTree(Rcpp::NumericMatrix &mat){
  Matrix matNew(rInterface::rMatToCppMat(mat));
  quadtree->makeTree(matNew);
  quadtree->assignNeighbors();
}
// void Quadtree::makeTree(Rcpp::NumericMatrix &mat){
//   Matrix matNew(rMatToCppMat(mat));
//   Quadtree::makeTree(matNew);
// }

std::vector<double> QuadtreeWrapper::getValues(const std::vector<double> &x, const std::vector<double> &y) const{
  assert(x.size() == y.size());
  
  std::vector<double> vals(x.size());
  for(int i = 0; i < x.size(); ++i){
    vals[i] = quadtree->getValue(x[i], y[i]);
  }
  return(vals);
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
  Rcpp::NumericMatrix mat(x.length(),5);
  colnames(mat) = Rcpp::CharacterVector({"xmin","xmax","ymin","ymax","value"}); //name the columns
  for(int i = 0; i < x.length(); ++i){
    auto node = quadtree->getNode(x[i],y[i]);
    if(node){
      mat(i,0) = node->xMin;
      mat(i,1) = node->xMax;
      mat(i,2) = node->yMin;
      mat(i,3) = node->yMax;
      mat(i,4) = node->value;
    } else {
      mat(i,0) = std::numeric_limits<double>::quiet_NaN();
      mat(i,1) = std::numeric_limits<double>::quiet_NaN();
      mat(i,2) = std::numeric_limits<double>::quiet_NaN();
      mat(i,3) = std::numeric_limits<double>::quiet_NaN();
      mat(i,4) = std::numeric_limits<double>::quiet_NaN();
    }
  }
  return mat;
}


std::string QuadtreeWrapper::print() const{
  return quadtree->toString();
}



void QuadtreeWrapper::makeList(std::shared_ptr<Node> node, Rcpp::List &list) const{
  //list.insert(node->id,node->asVector());
  NodeWrapper nodew(node);
  list[node->id] = nodew.asVector();
  //nodeVec[node->id] = node->asVector();
  if(node->hasChildren){
    for(int i = 0; i < node->children.size(); ++i){
      makeList(node->children[i], list);
    }
  }
}


Rcpp::List QuadtreeWrapper::asList(){
  //if(nodeVec.size() == 0){
  if(nodeList.length() == 0){
    //nodeVec = std::vector<Rcpp::NumericVector>(nNodes);
    Rcpp::List list = Rcpp::List(quadtree->nNodes);
    makeList(quadtree->root, list);
    nodeList = list;
  } 
  return nodeList;
}

//not directly callable from R - called by 'getNbList()'
//recursively creates a matrix of that represents all the neighbors of a node
//returns a matrix with 7 columns, in this order:
//id of this node
//x coordinate of centroid of this node
//y coordinate of centroid of this node
//id of the neighbor
//x coordinate of centroid of the neighbor
//y coordinate of centroid of the neighbor
//0 if either of the nodes has children, 1 otherwise (think of this column as 'are both of these cells at the bottom of the tree?')
void QuadtreeWrapper::makeNbList(std::shared_ptr<Node> node, Rcpp::List &list) const{
  //list.insert(node->id,node->asVector());
  //Rcpp::NumericVector nbVec(node->neighbors.size());
  std::vector<std::shared_ptr<Node>> neighbors = quadtree->findNeighbors(node, quadtree->root->smallestChildSideLength);
  Rcpp::NumericMatrix nbMat(neighbors.size(), 7); //initialize a matrix
  colnames(nbMat) = Rcpp::CharacterVector({"id0", "x0", "y0", "id1", "x1", "y1", "isLowest"}); //name the columns
  
  //loop through the neighbors and create an entry in the matrix for each neighbor
  for(int i = 0; i < neighbors.size(); ++i){
    nbMat(i,0) = node->id;
    nbMat(i,1) = (node->xMin+node->xMax)/2;
    nbMat(i,2) = (node->yMin+node->yMax)/2;
    nbMat(i,3) = neighbors[i]->id;
    nbMat(i,4) = (neighbors[i]->xMin + neighbors[i]->xMax)/2;
    nbMat(i,5) = (neighbors[i]->yMin + neighbors[i]->yMax)/2;
    nbMat(i,6) = (node->hasChildren | neighbors[i]->hasChildren) ? 0 : 1;
    // nbMat(i,0) = node->id;
    // nbMat(i,1) = (node->xMin+node->xMax)/2;
    // nbMat(i,2) = (node->yMin+node->yMax)/2;
    // nbMat(i,3) = node->neighbors[i]->id;
    // nbMat(i,4) = (node->neighbors[i]->xMin + node->neighbors[i]->xMax)/2;
    // nbMat(i,5) = (node->neighbors[i]->yMin + node->neighbors[i]->yMax)/2;
    // nbMat(i,6) = (node->hasChildren | node->neighbors[i]->hasChildren) ? 0 : 1;
  }
  //list[node->id] = nbVec;
  list[node->id] = nbMat;
  //nodeVec[node->id] = node->asVector();
  if(node->hasChildren){
    for(int i = 0; i < node->children.size(); ++i){
      makeNbList(node->children[i], list);
    }
  }
}

//returns a list of neighbor matrices, one for each node. If it's already been 
//created, just return it. Otherwise, create it first, then return it.
Rcpp::List QuadtreeWrapper::getNbList(){
  //if(nodeVec.size() == 0){
  if(nbList.length() == 0){
    //nodeVec = std::vector<Rcpp::NumericVector>(nNodes);
    Rcpp::List list = Rcpp::List(quadtree->nNodes);
    makeNbList(quadtree->root, list);
    nbList = list;
  } 
  return nbList;
}

ShortestPathFinderWrapper QuadtreeWrapper::getShortestPathFinder(Rcpp::NumericVector startPoint, Rcpp::NumericVector xlims, Rcpp::NumericVector ylims) const{
  return ShortestPathFinderWrapper(quadtree,startPoint,xlims,ylims);
}

void QuadtreeWrapper::writeQuadtree(std::string filePath){
  Quadtree::writeQuadtree(quadtree, filePath);
}

QuadtreeWrapper QuadtreeWrapper::readQuadtree(std::string filePath){
  return(QuadtreeWrapper(Quadtree::readQuadtree(filePath)));
}

