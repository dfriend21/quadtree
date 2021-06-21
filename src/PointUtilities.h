#ifndef POINTUTILITIES_H
#define POINTUTILITIES_H

#include "Point.h"
#include <vector>
#include <random>
#include <list>
#include <memory>

namespace PointUtilities{
    double sqDistBtwPoints(const Point& point1, const Point& point2);
    double distBtwPoints(const Point& point1, const Point& point2);
    double getAngle(const Point& point1, const Point& point2);
    std::vector<Point> getPointsAroundPoint(const Point& point, int n, double radius);
    double getAngleOffsetVal(const Point& point, double angle, const Point& optionPoint);
    Point getRandomPointOnCircle(const Point& center, double radius, std::mt19937& randomGenerator);
    Point getStraightDistEndPoint(const Point& firstPoint, const Point &penultimatePoint, const Point& lastPoint, double maxDistance);
    Point getTotDistEndPoint(const Point &point1, const Point& point2, double distance);
    // Point getPointBtwPointsPct(const Point &point1, const Point& point2, double percent);

    // Raster quadratCount(const std::list<std::shared_ptr<Agent>> &points, const int nX, const int nY, const double xMin, const double xMax, const double yMin, const double yMax);
    // Raster quadratCount(const std::list<std::shared_ptr<Agent>> &points, const double cellSize, const double xMin, const double xMax, const double yMin, const double yMax);
    // Raster quadratCount(const std::list<std::shared_ptr<Agent>> &points, const double cellSize);

    // Raster pointDensity(const std::list<std::shared_ptr<Agent>> &points, const double bandwidth, const int nX, const int nY, const double xMin, const double xMax, const double yMin, const double yMax);
}

#endif
