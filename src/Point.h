#ifndef POINT_H
#define POINT_H

#include <string>
#include <vector>

class Point { 
public: //TEMPORARY!!!!!!!!!!!!!!!!!!!!!!
  //big reason for making these private is so that when someone sets the coordinates we can set 'isEmpty' to false (otherwise the user would have to do it manually)
  //int id;
  double x;
  double y;
  bool hasCoordinates;

//public: //TEMPORARY!!!!!!!!!!!!!!!!!!!!!!
  Point();
  //Point(int _id);
  Point(double _x, double _y);
  //Point(int _id, double _x, double _y);
  
  //int getId() const;
  double getX() const;
  double getY() const;
  bool hasCoords() const;

  //void Point::setX(double _x);
  //void Point::setY(double _y);
  void setCoords(double _x, double _y);

  // virtual std::string toString() const;
  std::string toString() const;
};

//std::shared_ptr<Point> makePoint(double x, double y, int id);
std::vector<Point> readPoints(std::string filePath);

#endif