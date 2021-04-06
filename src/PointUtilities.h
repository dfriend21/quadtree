#ifndef POINTUTILITIES_H
#define POINTUTILITIES_H

#include "Point.h"
#include <vector>
#include <random>

namespace PointUtilities{
    double sqDistBtwPoints(const Point& point1, const Point& point2);
    double distBtwPoints(const Point& point1, const Point& point2);
    double getAngle(const Point& point1, const Point& point2);
    std::vector<Point> getPointsAroundPoint(const Point& point, int n, double radius);
    double getAngleOffsetVal(const Point& point, double angle, const Point& optionPoint);
    Point getRandomPointOnCircle(const Point& center, double radius, std::mt19937& randomGenerator);
    Point getStraightDistEndPoint(const Point& firstPoint, const Point &penultimatePoint, const Point& lastPoint, double maxDistance);
    Point getTotDistEndPoint(const Point &point1, const Point& point2, double distance);
}

#endif
