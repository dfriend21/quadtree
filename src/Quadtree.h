#ifndef QUADTREE_H
#define QUADTREE_H

//#include "Matrix.h"
//#include "Node.h"
#include <memory>
#include <vector>
#include <list>
#include <string>
#include <iostream> //TEMPORARY (for debugging)
//#include <Rcpp.h>

class Matrix;

class Node;

class Quadtree
{
public:
  std::shared_ptr<Node> root;
  double rangeLim;
  int nNodes;
  
  double originalXMin;
  double originalXMax;
  double originalYMin;
  double originalYMax;
  double originalNX;
  double originalNY;
  double maxXCellLength;
  double maxYCellLength;

  std::string proj4string;
  
  Quadtree();
  Quadtree(double _rangeLim, double _maxXCellLength = -1, double _maxYCellLength = -1);
  Quadtree(double xMin, double xMax, double yMin, double yMax, double _rangeLim, double _maxXCellLength = -1, double _maxYCellLength = -1);
  Quadtree(double xMin, double xMax, double yMin, double yMax, double _rangeLim, double _originalXMin, double _originalXMax, double _originalYMin, double _originalYMax, double _originalNX, double _originalNY, std::string _proj4string, double _maxXCellLength = -1, double _maxYCellLength = -1);
  //~Quadtree();
  
  //std::shared_ptr<Node> makeNode(double xMin, double xMax, double yMin, double yMax, double value);
  double getValue(double x, double y, std::shared_ptr<Node> node) const;
  double getValue(double x, double y) const;
  std::shared_ptr<Node> getNode(double x, double y, const std::shared_ptr<Node> node) const;
  std::shared_ptr<Node> getNode(double x, double y) const;
  std::list<std::shared_ptr<Node>> getNodesInBox(double xMin, double xMax, double yMin, double yMax);
  void getNodesInBox(std::shared_ptr<Node> node, std::list<std::shared_ptr<Node>> &returnNodes, double xMin, double xMax, double yMin, double yMax);
  //std::shared_ptr<Node> getNode(double x, double y, Node *leaf);
  
  int makeTree(const Matrix &mat, const std::shared_ptr<Node> node, int id, int level);
  void makeTree(const Matrix &mat);
  std::vector<std::shared_ptr<Node> > findNeighbors(const std::shared_ptr<Node> node, double searchSideLength) const;
  void assignNeighbors(const std::shared_ptr<Node> node);
  void assignNeighbors();
  
  // std::vector<std::shared_ptr<Node>> getSubset(double xMin, double xMax, double yMin, double yMax) const;
  // std::vector<std::shared_ptr<Node>> getSubset(std::shared_ptr<Node> node, double xMin, double xMax, double yMin, double yMax) const;


  // bool isReachable(double x1, double y1, double x2, double y2, double distance) const;
  // bool doesPathExist(std::shared_ptr<Node> node, int endNodeId, double xMin, double xMax, double yMin, double yMax, std::list<int> &prevIds);

  std::string toString() const;
  std::string toString(const std::shared_ptr<Node> node, const std::string prefix) const;
  //void print(std::string prefix="");
  //void makeTree();
  //void destroy(Node node);
  
  template<class Archive>
  void serialize(Archive & archive){ //couldn't get serialization to work unless I defined 'serialize' in the header rather than in 'Quadtree.cpp'. WHY???????????????????????????
    // std::cout << "Quadtree::serialize(Archive & archive)\n";
    archive(rangeLim,nNodes,originalXMin,originalXMax,originalYMin,originalYMax,originalNX,originalNY,proj4string,root);
  }

  
  static void writeQuadtree(std::shared_ptr<Quadtree> quadtree, std::string filePath);
  //static void writeQuadtree(Quadtree &quadtree, std::string filePath);
  static std::shared_ptr<Quadtree> readQuadtree(std::string filePath);
  //static Quadtree readQuadtree(std::string filePath);

};



#endif