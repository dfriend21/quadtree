#ifndef POINT_H
#define POINT_H

#include <string>

class Point { 
public:
    double x;
    double y;

    Point();
    Point(double _x, double _y);

    std::string toString() const;
};

#endif