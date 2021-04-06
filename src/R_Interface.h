#include <Rcpp.h>
#include <math.h>
#include <tuple>
#include <vector>
#include <limits>
#include <random>
#include <memory>
#include <cassert>
#include "Quadtree.h"
#include "Node.h"


#include "QuadtreeWrapper.h"
#include "NodeWrapper.h"

#include <thread> //for debugging
#include <chrono> //for debugging


//////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////
//                  R interface code                        //
//////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////
namespace rInterface {
  Matrix rMatToCppMat(Rcpp::NumericMatrix &mat);
}
// std::vector<Point> numMatToPointVec(Rcpp::NumericMatrix mat);

//convert a vector of points to a NumericMatrix
// Rcpp::NumericMatrix pointVecToNumMat(std::vector<Point> points);

// Rcpp::NumericMatrix getMaxDistEndPoint(Rcpp::NumericMatrix firstPoints, Rcpp::NumericMatrix penultimatePoints, Rcpp::NumericMatrix lastPoints, double maxDistance);
// Rcpp::NumericVector getRandomPointOnCircle_cpp(Rcpp::NumericVector point, double radius);
//create a Point from a NumericVector (first two elements will be used
//as the x and y coords, respectively)
// Point makePoint(Rcpp::NumericVector vec);

// Rcpp::NumericMatrix moveTort(QuadtreeWrapper &qt,
//                         Rcpp::NumericVector startPoint,
//                         Rcpp::NumericVector attractPoint,
//                         int nCheckPoints,
//                         double stepSize,
//                         double maxTotalDistance,
//                         double maxStraightLineDistance,
//                         double maxTotalDistanceSubStep,
//                         double qualityExp1,
//                         double attractExp1,
//                         double directionExp1,
//                         double qualityExp2,
//                         double attractExp2,
//                         double directionExp2,
//                         bool debug);