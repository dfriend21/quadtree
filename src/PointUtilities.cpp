#include "PointUtilities.h"
#include <math.h>
#include <list>
#include <memory>
#include <vector>
#include <complex>
#include <string>

double PointUtilities::sqDistBtwPoints(const Point& point1, const Point& point2){
    double dist = pow(point1.getX() - point2.getX(),2) + pow(point1.getY() - point2.getY(),2);
    return dist;
}

double PointUtilities::distBtwPoints(const Point& point1, const Point& point2){
    double dist = std::sqrt(std::pow(point1.getX() - point2.getX(), 2) + std::pow(point1.getY() - point2.getY(), 2));
    return dist;
}

//gets the angle between two points in radians
double PointUtilities::getAngle(const Point& point1, const Point& point2){
    //double angle{std::numeric_limits<double>::quiet_NaN()};
    double angle = std::atan2(point2.getY() - point1.getY(), point2.getX() - point1.getX()); //http://www.cplusplus.com/reference/cmath/atan2/
    return angle;
}

//given a point, generates 'n' evenly spaced points around the point at distance 'radius'. First point will always be at 0 radians.
std::vector<Point> PointUtilities::getPointsAroundPoint(const Point& point, int n, double radius){
    std::vector<Point> points(n);
    for(int i = 0; i < n; ++i){
        double angle = (2.0*M_PI/static_cast<double>(n)) * i; //given that we want 'n' points, to make them evenly spaced we'll increment the angles by 2*pi/n
        points[i].setCoords(std::cos(angle)*radius + point.getX(), std::sin(angle)*radius + point.getY()); //do I need to instantiate (or construct or whatever the term is) a Point object before? It seems like it's working, though
    }
return points;
}

//take a point, an angle (relative to the x-axis), and another point. The first point is considered the 
//'current point', the second point is the point we're considering moving to,
//and the angle is the direction in which we want to bias the movement. This
//function will return a value that is low if the angle from 'point' to 
//'optionPoint' is not similar to 'angle' (say, in the opposite direction) and
//high if this angle is close to 'angle'
double PointUtilities::getAngleOffsetVal(const Point& point, double angle, const Point& optionPoint){
    double optAngle = getAngle(point, optionPoint);
    double offset = std::cos(optAngle-angle) + 1; //'cos' produces a wave-like line with y ranging from -1 to 1. By subtracting 'angle' from 'optAngle', we're essentially centering the wave on 'angle'. If optAngle == angle, then optAngle-angle will be 0. And cos(0) is the highest possible value of cos.
    return offset;
}


//give a point (center) and a distance (radius), outputs a random point that is distance
//'radius' away from 'center'.
Point PointUtilities::getRandomPointOnCircle(const Point& center, double radius, std::mt19937& randomGenerator){
    //set up random number generation - got these lines from https://en.cppreference.com/w/cpp/numeric/random/uniform_real_distribution
    
    //std::mt19937 gen(seed); //Standard mersenne_twister_engine seeded with rd()
    //<old method>
    // std::random_device rd;  //Will be used to obtain a seed for the random number engine
    // std::mt19937 gen(rd()); //Standard mersenne_twister_engine seeded with rd()
    // std::uniform_real_distribution<> dis(0, 2*M_PI); 
    // double angle = dis(gen);//generate a random number between 0 and 2*pi
    // //</old method>
    
    
    
    //<new method>
    std::uniform_real_distribution<> dis(0, 2*M_PI); 
    double angle = dis(randomGenerator);//generate a random number between 0 and 2*pi
    //</new method>

    // std::cout << "angle: " << angle << std::endl;
    //std::cout << angle << ",";
    Point point;
    //using the angle we randomly generated, find out what the x coordinates are of a point at angle 'angle' and distance 'radius' from the center point
    point.setCoords(center.getX() + cos(angle)*radius, center.getY() + sin(angle)*radius);
    //std::cout << "point: " << point.getX() << "," << point.getY() << std::endl;
    return point;
}

// Point PointUtilities::getPointBtwPointsPct(const Point &point1, const Point& point2, double percent){
//     double dist = PointUtilities::distBtwPoints(*iAgent,destPt);
//     double cost = dist + dist*quadtree->getValue(iAgent->x, iAgent->y);
//     if(cost > dist){ //probably don't need this check. cost will always be greater than dist unless the cost of the cell is 0
//         double pct = dist/cost; //get the ratio of dist and cost

//         //now find the point along the line between these two points where we hit the maximum cost
//         double x = iAgent->x + (destPt.x - iAgent->x)*pct;
//         double y = iAgent->y + (destPt.y - iAgent->y)*pct;
        
//         iAgent->setCoords(x, y); //set the coordinates of the agent to the new point // 2/19/2021 d
//     }
// }
