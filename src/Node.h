#ifndef NODE_H
#define NODE_H

#include "Point.h"

#include <cereal/archives/portable_binary.hpp>
#include <cereal/types/vector.hpp>

#include <memory>
#include <vector>
#include <string>

class Node 
{ 
public:
    double xMin{0}; // x and y limits of the node
    double xMax{0};
    double yMin{0};
    double yMax{0};

    double value{0}; 
    int id{0};
    int level{0}; // this is equivalent to the 'depth' of a node in a tree - i.e. how far down is it?
    double smallestChildSideLength{0}; // side length of smallest descendant
    bool hasChildren{false};                                                                                           // 2 3
    std::vector<std::shared_ptr<Node>> children;// first element is lower left corner. Indexing then proceeds by row -->  0 1 
    std::vector<std::weak_ptr<Node>> neighbors; // pointers to the neighboring cells. 'weak_ptr' is used because neighbors will contain references to each other - if 'shared_ptr' is used, then they'll never get deleted because the reference count of the pointers will never reach 0. I was originally using 'shared_ptr' and it was causing a really bad memory leak - switching to 'weak_ptr' fixed it.  

    Node();
    Node(double _xMin, double _xMax, double _yMin, double _yMax, double _value, int _id, int _level);
    Node(double _xMin, double _xMax, double _yMin, double _yMax, double _value, int _id, int _level, double _smallestChildSideLength, bool _hasChildren);

    int getChildIndex(const Point pt) const;
    std::string toString() const;

    template<class Archive> 
    void serialize(Archive & archive){ // couldn't get serialization to work unless I defined 'serialize' in the header rather than in 'Node.cpp'
        archive(xMin, xMax, yMin, yMax, value, id, level, smallestChildSideLength, hasChildren, children);
    }
};
#endif