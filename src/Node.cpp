#include "Node.h"
#include "Point.h"
#include <vector>
#include <memory>
#include <string>
#include <cassert>
#include <limits>
#include <cmath>
#include <cereal/archives/portable_binary.hpp>
#include <cereal/types/memory.hpp>
#include <cereal/types/vector.hpp>

  // double xMin;    
  // double xMax;
  // double yMin;
  // double yMax;
  // double value;
  // double id;
  // double level;
  // double smallestChildSideLength;
  // bool hasChildren;
  // std::shared_ptr<Node> ptr;                                                              //                           2 3
  // std::vector<std::shared_ptr<Node>> children;//first element is lower left corner. Indexing then proceeds by row -->  0 1 
  // std::vector<std::shared_ptr<Node>> neighbors;

Node::Node()
  : xMin{0}, xMax{0}, yMin{0}, yMax{0}, value{0}, id{0}, level{0}, smallestChildSideLength{0}, hasChildren{false}{
    ptr = std::shared_ptr<Node>(nullptr);
    children = std::vector<std::shared_ptr<Node>>(0);
    neighbors = std::vector<std::shared_ptr<Node>>(0);
  }

//given an x and a y coordinate, returns the index of the child that contains
//the point. Based on the assumption that the first element is lower left corner. 
//Indexing then proceeds by row
int Node::getChildIndex(double x, double y) const {
  if( (x < xMin) | (x > xMax) | (y < yMin) | (y > yMax) ){ //check to make sure the point falls within our extent
    //return -999; //if not, return NULL
    return std::numeric_limits<double>::quiet_NaN(); 
  }
  int col = (x < (xMin + xMax)/2) ? 0 : 1; 
  int row = (y < (yMin + yMax)/2) ? 0 : 1;
  int index = row*2 + col;
  return index;
}

double Node::getNearestNeighborDistance() const{
  //std::vector<double> vals(ptr->neighbors.size());
  double min{0};
  double xMean{(ptr->xMin + ptr->xMax)/2};
  double yMean{(ptr->yMin + ptr->yMax)/2};
  for(size_t i = 0; i < ptr->neighbors.size(); ++i){
    double xMeanNb{(ptr->neighbors[i]->xMin + ptr->neighbors[i]->xMax)/2};
    double yMeanNb{(ptr->neighbors[i]->yMin + ptr->neighbors[i]->yMax)/2};
    double dist = std::pow(xMean - xMeanNb,2) + std::pow(yMean - yMeanNb,2);
    if( (dist < min) | (i == 0)){
      min = dist;
    }
  }
  return std::sqrt(min);
}

//find the minimum distance from a point to the centroids of the neighbors of this node
double Node::getNearestNeighborDistance(const Point& point) const{
  //std::vector<double> vals(node->neighbors.size());
  double min{0};
  //double xMean{(node->xMin + node->xMax)/2};
  //double yMean{(node->yMin + node->yMax)/2};
  for(size_t i = 0; i < neighbors.size(); ++i){
    double xMeanNb{(neighbors[i]->xMin + neighbors[i]->xMax)/2};
    double yMeanNb{(neighbors[i]->yMin + neighbors[i]->yMax)/2};
    double dist = pow(point.getX() - xMeanNb,2) + pow(point.getY() - yMeanNb,2);
    if( (dist < min) | (i == 0) ){
      min = dist;
    }
  }
  return sqrt(min);
}

std::string Node::toString() const{
  std::string str = "x: [" + std::to_string(xMin) + ", " + std::to_string(xMax) + "] | y: [" + std::to_string(yMin) + ", " + std::to_string(yMax) + "]";
  str = str + " | value: " + std::to_string(value) + " | hasChildren: " + std::to_string(hasChildren) + " | smallestChildSideLength: " +
    std::to_string(smallestChildSideLength)+ " | size(children): " + std::to_string(children.size()) + " | size(neighbors): " + std::to_string(neighbors.size()) +
    " | level: " + std::to_string(level) + " | id: " + std::to_string(id);
  return str;
}

// template<class Archive> 
//   void Node::serialize(Archive & archive){
//   //archive(xMin, xMax, yMin, yMax, value, id, level, smallestChildSideLength, hasChildren, ptr, children, neighbors);
//   //archive(xMin, xMax, yMin, yMax, value, id, level, smallestChildSideLength, hasChildren);
//   archive(xMin);
// }

// template<class Archive>
//   void Node::save(Archive & archive) const
//   {
//     archive(xMin); 
//   }

//   template<class Archive>
//   void Node::load(Archive & archive)
//   {
//     archive(xMin); 
//   }

std::shared_ptr<Node> Node::makeNode(double xMin, double xMax, double yMin, double yMax, double value, int id, int level){
  //Node node(xMin, xMax, yMin, yMax, value);
  assert(xMax-xMin == yMax-yMin);
  Node* node = new Node();
  node->xMin = xMin;
  node->xMax = xMax;
  node->yMin = yMin;
  node->yMax = yMax;
  node->value = value;
  node->id = id;
  node->level = level;
  node->smallestChildSideLength = xMax-xMin;
  node->ptr = std::shared_ptr<Node>(node);
  node->children = std::vector<std::shared_ptr<Node>>(4);
  node->neighbors = std::vector<std::shared_ptr<Node>>();
  return node->ptr;
}