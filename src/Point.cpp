#include "Point.h"

Point::Point() : x{0}, y{0} {}
Point::Point(double _x, double _y) : x{_x}, y{_y}{}

std::string Point::toString() const{
    std::string str = "x: " + std::to_string(x) + " | y: " + std::to_string(y);
    return str;
}
