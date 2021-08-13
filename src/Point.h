#ifndef POINT_H
#define POINT_H

#include <string>
#include <vector>

class Point { 
public:
  double x;
  double y;
  bool hasCoordinates;

  Point();
  Point(double _x, double _y);
  
  double getX() const;
  double getY() const;
  bool hasCoords() const;

  void setCoords(double _x, double _y);

  std::string toString() const;
};

std::vector<Point> readPoints(std::string filePath);

#endif