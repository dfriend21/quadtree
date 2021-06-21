#ifndef NODE_H
#define NODE_H

#include <memory>
#include <vector>
#include <string>
#include <iostream> //TEMPORARY (for debugging)
#include <cereal/archives/portable_binary.hpp>
#include <cereal/types/vector.hpp>



//CEREAL_REGISTER_TYPE(Node);

class Point;

class Node 
{ 
public:
  double xMin;    
  double xMax;
  double yMin;
  double yMax;
  double value;
  int id;
  int level;
  double smallestChildSideLength;
  bool hasChildren;
  //std::shared_ptr<Node> ptr;                                                              //                         2 3
  std::vector<std::shared_ptr<Node>> children;//first element is lower left corner. Indexing then proceeds by row -->  0 1 
  //std::vector<std::shared_ptr<Node>> neighbors;
  std::vector<std::weak_ptr<Node>> neighbors; //pointers to the neighboring cells. 'weak_ptr' is used because neighbors will contain references to each other - if 'shared_ptr' is used, then they'll never get deleted because the reference count of the pointers will never reach 0. I was originally using 'shared_ptr' and it was causing a really bad memory leak - switching to 'weak_ptr' fixed it.
  
  Node();
  Node(double _xMin, double _xMax, double _yMin, double _yMax, double _value, int _id, int _level);
  Node(double _xMin, double _xMax, double _yMin, double _yMax, double _value, int _id, int _level, double _smallestChildSideLength, bool _hasChildren);
//static std::shared_ptr<Node> makeNode(double xMin, double xMax, double yMin, double yMax, double value, int id, int level);
  int getChildIndex(double x, double y) const;
  double getNearestNeighborDistance() const;
  double getNearestNeighborDistance(const Point& point) const;
  std::string toString() const;

  template<class Archive> 
  void serialize(Archive & archive){ //couldn't get serialization to work unless I defined 'serialize' in the header rather than in 'Node.cpp'. WHY???????????????????????????
    //archive(xMin, xMax, yMin, yMax, value, id, level, smallestChildSideLength, hasChildren, ptr, children, neighbors);
    // archive(xMin, xMax, yMin, yMax, value, id, level, smallestChildSideLength, hasChildren, ptr, children);
    // std::cout << "Node::serialize(Archive & archive)\n";
    archive(xMin, xMax, yMin, yMax, value, id, level, smallestChildSideLength, hasChildren, children);
    //archive(xMin);
  }

  // template<class Archive>
  // void save(Archive & archive) const;
  // template<class Archive>
  // void load(Archive & archive);
  // static std::shared_ptr<Node> makeNode(double xMin, double xMax, double yMin, double yMax, double value, int id, int level);
};




#endif