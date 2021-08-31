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

//-------------------------
// constructors
//-------------------------

Node::Node() {
  children = std::vector<std::shared_ptr<Node>>(4);
  neighbors = std::vector<std::weak_ptr<Node>>();
}

Node::Node(double _xMin, double _xMax, double _yMin, double _yMax, double _value, int _id, int _level)
  : Node{} {
    xMin = _xMin;
    xMax = _xMax;
    yMin = _yMin;
    yMax = _yMax;
    value = _value;
    id = _id;
    level = _level;

    smallestChildSideLength = xMax-xMin;
  }

Node::Node(double _xMin, double _xMax, double _yMin, double _yMax, double _value, int _id, int _level, double _smallestChildSideLength, bool _hasChildren)
  : Node{_xMin, _xMax, _yMin, _yMax, _value, _id, _level} {

  smallestChildSideLength = _smallestChildSideLength;
  hasChildren = _hasChildren;
}

//-------------------------
// getChildIndex
//-------------------------
//given an x and a y coordinate, returns the index of the child that contains
//the point. Based on the assumption that the first element is lower left corner. 
//Indexing then proceeds by row
int Node::getChildIndex(double x, double y) const {
  if( (x < xMin) | (x > xMax) | (y < yMin) | (y > yMax) ){ //check to make sure the point falls within our extent
    return std::numeric_limits<double>::quiet_NaN(); //if not, return Nan
  }
  int col = (x < (xMin + xMax)/2) ? 0 : 1; 
  int row = (y < (yMin + yMax)/2) ? 0 : 1;
  int index = row*2 + col;
  return index;
}

//-------------------------
// getNearestNeighborDistance
//-------------------------
//get the distance to the nearest neighbor (using centroids)
double Node::getNearestNeighborDistance() const{
  double min{0};
  double xMean{(xMin + xMax)/2};
  double yMean{(yMin + yMax)/2};
  for(size_t i = 0; i < neighbors.size(); ++i){
    auto nb_i = neighbors[i].lock();
    double xMeanNb{(nb_i->xMin + nb_i->xMax)/2};
    double yMeanNb{(nb_i->yMin + nb_i->yMax)/2};
    double dist = std::pow(xMean - xMeanNb,2) + std::pow(yMean - yMeanNb,2);
    if( (dist < min) | (i == 0)){
      min = dist;
    }
  }
  return std::sqrt(min);
}

//find the minimum distance from a point to the centroids of the neighbors of this node
double Node::getNearestNeighborDistance(const Point& point) const{
  double min{0};
  for(size_t i = 0; i < neighbors.size(); ++i){
    auto nb_i = neighbors[i].lock();
    double xMeanNb{(nb_i->xMin + nb_i->xMax)/2};
    double yMeanNb{(nb_i->yMin + nb_i->yMax)/2};
    double dist = pow(point.getX() - xMeanNb,2) + pow(point.getY() - yMeanNb,2);
    if( (dist < min) | (i == 0) ){
      min = dist;
    }
  }
  return sqrt(min);
}

//-------------------------
// toString
//-------------------------
std::string Node::toString() const{
  std::string str = "x: [" + std::to_string(xMin) + ", " + std::to_string(xMax) + "] | y: [" + std::to_string(yMin) + ", " + std::to_string(yMax) + "]";
  str = str + " | value: " + std::to_string(value) + " | hasChildren: " + std::to_string(hasChildren) + " | smallestChildSideLength: " +
    std::to_string(smallestChildSideLength)+ " | size(children): " + std::to_string(children.size()) + " | size(neighbors): " + std::to_string(neighbors.size()) +
    " | level: " + std::to_string(level) + " | id: " + std::to_string(id);
  return str;
}
