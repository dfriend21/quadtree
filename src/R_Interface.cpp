#include "Quadtree.h"
#include "Node.h"
#include "Point.h"
#include "Matrix.h"
// #include "abm/MovementUtilities.h"
// #include "abm/MathUtilities.h"

#include "QuadtreeWrapper.h"
#include "NodeWrapper.h"

#include <vector>

#include <Rcpp.h>

//#include <math.h>
//#include <tuple>
//#include <limits>
//#include <random>
//#include <memory>
//#include <cassert>
//#include <thread> //for debugging
//#include <chrono> //for debugging


#include "R_Interface.h"
//////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////
//                  R interface code                        //
//////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////
Matrix rInterface::rMatToCppMat(Rcpp::NumericMatrix &mat){
  std::vector<double> vec(mat.nrow()*mat.ncol());
  int counter{0};
  for(int i = 0; i < mat.nrow(); i++){
    Rcpp::NumericVector rowVec = mat.row(i);
    std::vector<double> row = Rcpp::as<std::vector<double>>(rowVec);
    for(int j = 0; j < row.size(); j++){
      vec[counter] = row[j];
      counter++;
    }
  }
  Matrix newMat(vec, mat.nrow(), mat.ncol());
  return newMat;
}

// std::vector<Point> numMatToPointVec(Rcpp::NumericMatrix mat){
//   std::vector<Point> points(mat.nrow());
//   for(int i = 0; i < mat.nrow(); ++i){
//     Point point_i;
//     // point_i.x = mat(i,0);
//     // point_i.y = mat(i,1);
//     point_i.setCoords(mat(i,0), mat(i,1));
//     // point_i.x = mat(i,0);
//     // point_i.y = mat(i,1);
//     points[i] = point_i;
//   }
//   return points;
// }

// //convert a vector of points to a NumericMatrix
// Rcpp::NumericMatrix pointVecToNumMat(std::vector<Point> points){
//   //NumericMatrix mat(points.size(), 2);
//   //TEMPORARY!!!!!!!!!!! {
//   Rcpp::NumericMatrix mat(points.size(), 3);
//   //TEMPORARY!!!!!!!!!!! }
//   for(int i = 0; i < points.size(); ++i){
//     mat(i,0) = points[i].getX();
//     mat(i,1) = points[i].getY();
//     //TEMPORARY!!!!!!!!!!! {
//     //mat(i,2) = points[i].extraVal;
//     //TEMPORARY!!!!!!!!!!! }
//   }
//   return mat;
// }

// Rcpp::NumericVector getRandomPointOnCircle_cpp(Rcpp::NumericVector point, double radius){
//   Point pointCpp = makePoint(point);
//   Point randomPoint = MathUtilities::getRandomPointOnCircle(pointCpp, radius);
//   Rcpp::NumericVector vec = {randomPoint.getX(), randomPoint.getY()};
//   return vec;
// }

// Rcpp::NumericMatrix getMaxDistEndPoint(Rcpp::NumericMatrix firstPoints, Rcpp::NumericMatrix penultimatePoints, Rcpp::NumericMatrix lastPoints, double maxDistance){
//   assert(firstPoints.nrow() == penultimatePoints.nrow() && penultimatePoints.nrow() == lastPoints.nrow());
//   
//   std::vector<Point> firstPointVec = numMatToPointVec(firstPoints);
//   std::vector<Point> penultimatePointsVec = numMatToPointVec(penultimatePoints);
//   std::vector<Point> lastPointsVec = numMatToPointVec(lastPoints);
//   
//   std::vector<Point> newPointsVec(firstPointVec.size());
//   for(int i = 0; i < firstPointVec.size(); ++i){
//     newPointsVec[i] = getMaxDistEndPoint(firstPointVec[i], penultimatePointsVec[i], lastPointsVec[i], maxDistance);
//   }
//   return pointVecToNumMat(newPointsVec);
// }


// //create a Point from a NumericVector (first two elements will be used
// //as the x and y coords, respectively)
// Point makePoint(Rcpp::NumericVector vec){
//   
//   //Rcout << "makePoint" << std::endl;
//   ////if(debug) std::this_thread::sleep_for(std::chrono::milliseconds(waitTime));
//   
//   Point point;
//   if(is_true(any(is_na(vec)))){
//     point.setCoords(-1,-1);
//     // point.x=-1;
//     // point.y=-1;
//     //point.isEmpty=true;
//   }
//   point.setCoords(vec[0], vec[1]);
//   // point.x = vec[0];
//   // point.y = vec[1];
//   return point;
// }

// Rcpp::NumericMatrix moveTort(QuadtreeWrapper &qt,
//                           Rcpp::NumericVector startPoint,
//                           Rcpp::NumericVector attractPoint,
//                           int nCheckPoints,
//                           double stepSize,
//                           double maxTotalDistance,
//                           double maxStraightLineDistance,
//                           double maxTotalDistanceSubStep,
//                           double qualityExp1,
//                           double attractExp1,
//                           double directionExp1,
//                           double qualityExp2,
//                           double attractExp2,
//                           double directionExp2,
//                           bool debug){
//   //bool debug = true;
//   //int waitTime = 100;
//   //Rcout << "moveAgent" << std::endl;
//   ////if(debug) std::this_thread::sleep_for(std::chrono::milliseconds(waitTime));
//   //std::vector<Point> moveAgent(const Quadtree &qt, const Point& startPoint, const Point& attractPoint, int nCheckPoints, double stepSize, double maxTotalDistance, double maxStraightLineDistance, double maxTotalDistanceSubStep, double qualityExp1, double attractExp1, double directionExp1, double qualityExp2, double attractExp2, double directionExp2, bool debug);
//   // std::vector<Point> points = MovementUtilities::moveAgent(qt.quadtree,
//   //                                             makePoint(startPoint),
//   //                                             makePoint(attractPoint),
//   //                                             nCheckPoints,
//   //                                             stepSize,
//   //                                             maxTotalDistance,
//   //                                             maxStraightLineDistance,
//   //                                             maxTotalDistanceSubStep,
//   //                                             qualityExp1,
//   //                                             attractExp1,
//   //                                             directionExp1,
//   //                                             qualityExp2,
//   //                                             attractExp2,
//   //                                             directionExp2,
//   //                                             debug);
//   return pointVecToNumMat(points);
// }
