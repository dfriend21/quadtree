#include <Rcpp.h>
#include <math.h>
#include <tuple>
#include <vector>
#include <limits>
#include <random>
#include <memory>
#include <cassert>
#include <thread> //for debugging
#include <chrono> //for debugging
#include "quadtree.hpp"
#include "quadtreewrapper.hpp"
#include "node.hpp"
#include "nodewrapper.hpp"
#include "abm2.hpp"

using namespace Rcpp;
bool debug = false;
int waitTime = 0;

struct Point{
  double x{0};
  double y{0};
  int extraVal{0};
  bool isEmpty{false}; //this is to signal when we have an "NA" type value
};


double sqDistBtwPoints_2(const Point& point1, const Point& point2){
  double dist = pow(point1.x - point2.x,2) + pow(point1.y - point2.y,2);
  return dist;
}

//gets the angle between two points in radians
double getAngle_2(const Point& point1, const Point& point2){
  //double angle{std::numeric_limits<double>::quiet_NaN()};
  double angle = atan2(point2.y - point1.y, point2.x - point1.x); //http://www.cplusplus.com/reference/cmath/atan2/
  return angle;
}

//given a point, generates 'n' evenly spaced points around the point at distance 'radius'. First point will always be at 0 radians.
std::vector<Point> getPointsAroundPoint_2(const Point& point, int n, double radius){
  std::vector<Point> points(n);
  for(int i = 0; i < n; ++i){
    double angle = (2.0*M_PI/static_cast<double>(n)) * i; //given that we want 'n' points, to make them evenly spaced we'll increment the angles by 2*pi/n
    points[i].x = cos(angle)*radius + point.x; //do I need to instantiate (or construct or whatever the term is) a Point object before? It seems like it's working, though
    points[i].y = sin(angle)*radius + point.y;
  }
  return points;
}

//take a point, an angle (relative to the x-axis), and another point. The first point is considered the 
//'current point', the second point is the point we're considering moving to,
//and the angle is the direction in which we want to bias the movement. This
//function will return a value that is low if the angle from 'point' to 
//'optionPoint' is not similar to 'angle' (say, in the opposite direction) and
//high if this angle is close to 'angle'
double getAngleOffsetVal_2(const Point& point, double angle, const Point& optionPoint){
  double optAngle = getAngle_2(point, optionPoint);
  double offset = cos(optAngle-angle) + 1; //'cos' produces a wave-like line with y ranging from -1 to 1. By subtracting 'angle' from 'optAngle', we're essentially centering the wave on 'angle'. If optAngle == angle, then optAngle-angle will be 0. And cos(0) is the highest possible value of cos.
  return offset;
}


//give a point (center) and a distance (radius), outputs a random point that is distance
//'radius' away from 'center'.
Point getRandomPointOnCircle_2(Point& center, double radius){
  //set up random number generation - got these lines from https://en.cppreference.com/w/cpp/numeric/random/uniform_real_distribution
  std::random_device rd;  //Will be used to obtain a seed for the random number engine
  std::mt19937 gen(rd()); //Standard mersenne_twister_engine seeded with rd()
  std::uniform_real_distribution<> dis(0, 2*M_PI); 
  
  double angle = dis(gen);//generate a random number between 0 and 2*pi
  Point point;
  //using the angle we randomly generated, find out what the x coordinates are of a point at angle 'angle' and distance 'radius' from the center point
  point.x = cos(angle)*radius;
  point.y = sin(angle)*radius;
  return point;
}

//implements a single step of a movement algorithm
//operates on a quadtree representing a resistance surface, where low values
//represent areas that are easier to travel through. Given a point, an
//'attraction' point, and (optionally) the previous location of the agent, moves
//the tortoise to a new location.
//The algorithm operates as follows:
//'nPoints' points are generated, evenly spaced around 'currentPt' at distance
//'dist'. ('dist' can be though of as the step size). Each of these points is
//considered as a potential point to move to. The probability of moving to any
//one point is calculated by two or three different components:
//1) Habitat quality (inverse of resistance) - agents are assumed to prefer to 
//   move to areas with lower resistance (or higher quality habitat). For each
//   point, this value is calculated by 1-resistance, where 'resistance' is the 
//   value of the resistance surface at that point location.
//2) Attraction point - agents are assumed to be biased to traveling towards a
//   predetermined attraction point. The angle (relative to the x-axis) between
//   the current point and the attraction point is calculated - this can be
//   considered the 'reference angle'. Then the angle between each option point
//   and the current point is also calculated. The difference between this angle
//   is subtracted from the reference angle, and the cosine of this value is
//   then taken. The cosine of an angle produces a 'wave' that varies between -1
//   and 1 where the highest value (1) occurs at 0 and the lowest values (-1)
//   occurs at -pi and pi. Thus, if the difference between the option point
//   angle and the reference angle is 0 (that is, the option point lies
//   directly between the current point and the attraction point) then the
//   resulting value is 1 (the maximum possible value). Conversely, if the
//   option point is directly opposite the attraction point (that is, the
//   current point lies directly between the option point and the attraction
//   point - the resulting difference in angles would be either pi or -pi) the
//   value is -1 (the minimum possible value). After these calculations have
//   been made, 1 is added so that all values fall between 0 and 2.
//3) Directional correlation based on previous location - if a previous location
//   is provided, then the agent is assumed to be more likely to travel in the
//   the direction that it had already been travelling. This is done using the
//   same process described in 2). But instead of using the angle from the 
//   current point to the attraction point as the 'reference angle', the angle
//   from the previous point to the current point is used.
//Each of the three of the above components are scaled so that they sum to 1.
//The product of these three components for each point is the final 'score' for
//each point, and the scores are scaled to sum to 1. However, prior to being
//multiplied together, each of the components is exponentiated by a user-provided
//value. The exponent serves as a way to adjust the weight given to each component.
//Taking the exponent of a number between 0 and 1 will always result is a lower
//number, but smaller numbers will be affected more than larger numbers. For example
//if the numbers .4 and .5 are exponentiated by 3, the resulting values are 
//.064 and .125, respectively. The ratio between .4 and .5 is .8, while the ratio
//between the resulting exponentiated values is .512. This serves to essentially
//exacerbate the differences between high and low values, making low values less
//likely to be selected while making high values more likely to be selected.
//
//After all of this has been performed, we end up with a probability of moving to
//each of the option points, where the probabilities sum to 1. The next point
//to move to is then randomly selected, using the probability of each point as
//its probability of being selected.
//
//Some justification for decisions made-
//
//Why take the product of the three scores instead of the sum?
//The product is used because we want to allow for impermeable barriers. If the
//sum is taken, then even if the resistance of a barrier is 1 (meaning the agent
//can't move through it), it would still have some probability of moving to that
//point because of the 'attraction' and 'direction' scores. However, if the
//product is taken, then if any one of the scores is 0, then the probability of
//moving to that point becomes 0. Thus, if the resistance is 1 (and thus the
//resulting 'habitat quality' score is 0, then the probability of moving to that
//point will always be zero.) Note that this has the side affect that agents
//will never move in the exact opposite direction of the attraciton point or the
//exact opposite direction of the direction travelled in the previous step. This
//could be adjusted by scaling the values so that rather than the lowest value
//being one, the lowest value could be some non-zero value.
//
//Why use exponentiation as the weighting method? 
//Because the product of the components is taken and not the sum, multiplication
//(a common method used in weighting schemes) cannot be used. This is because
//(10x)yz is the same as 10(xyz). Multiplying a component by a constant is the same
//as multiplying the final score by that constant. This means the ratio between the 
//scores is the same, and since the final scores are scaled to sum to one, multilpying
//by a constant has no impact. However, exponentiation serves to alter the ratio
//between two numbers, which is why it works even though we're taking the product
//of the components.
//That being said there could be implications of using the exponent method that
//I haven't fully considered. This line of R code is useful for exploring the 
//effects of exponentiation: plot(seq(0,1,.01), seq(0,1,.01)^8, pch=16, cex=2)
//
//Other thoughts
//
Point getNextPoint_2(const Quadtree& qt, const Point& currentPt, const Point& prevPt, const Point& attrPt,int nPoints, double dist, double valExp, double attrExp, double corExp){
  std::vector<Point> circlePoints = getPointsAroundPoint_2(currentPt, nPoints, dist); //get 'nPoints' around 'currentPt' with radius = 'dist'
  
  bool debug=false;
  //DEBUGGING {
  //if(debug){
  //   Rcout << "=================================" << std::endl;
  //   Rcout << "CIRCLE POINTS:" << std::endl;
  //   for(int i = 0; i < circlePoints.size(); ++i){
  //     Rcout << i << ": " << "(" << circlePoints[i].x << ", " << circlePoints[i].y << ")" << std::endl;
  //   }
  // }
  //DEBUGGING }
  std::vector<std::tuple<double, double, double, Point>> pointVals(circlePoints.size()); //create a vector where we'll store the info on each point - the three doubles store the resistance value, angle value, and correlation value, respectively
  int nNotNan{0}; //there's a good possibility that we'll be checking values outside of the quadtree's extent, in which case we'll get NaNs. When we get an NaN we don't add anything to the vector, so we'll increment this when the value isn't NaN, and this will tell us the length of resulting vector
  for(int i = 0; i < circlePoints.size(); ++i){ 
    double val = 1-qt.getValue(circlePoints[i].x, circlePoints[i].y); //the value of the quadtree at this point - subtract one becaue the value is the resistance - and in this case we want higher values to represent better values
    if(!isnan(val)){ //if it's not NaN, then add it to our vector of tuples
      
      double angleVal = getAngleOffsetVal_2(currentPt, getAngle_2(currentPt, attrPt), circlePoints[i]); //get the angle value (based on the start pt and the attraction point - basically returns a value where the closer the point is to being directly on the line between the two, the closer the value is 1)
      //double corVal{std::numeric_limits<double>::quiet_NaN()}; //initialize our correlation as NaN, as if this is the first point there won't be a previous point
      double corVal{1}; //this fixes the problem I was having with points near the left and bottom jumping to 0,0... but why?
      if(!prevPt.isEmpty){
        //Rcout << "has prev" << std::endl;
        
        corVal = getAngleOffsetVal_2(currentPt, getAngle_2(prevPt, currentPt), circlePoints[i]); //get the correlation value
        //if(debug){
        //   Rcout << "Cor calculation:" << std::endl;
        //   Rcout << "currentPt: (" << currentPt.x << "," << currentPt.y << ")" << std::endl;
        //   Rcout << "prevPt: (" << prevPt.x << "," << prevPt.y << ")" << std::endl;
        //   Rcout << "circlePoints[i]: (" << circlePoints[i].x << "," << circlePoints[i].y << ")" << std::endl;
        //   Rcout << "corVal: " << corVal << std::endl;
        // }
      } //else{
      //   corVal = 1;
      //   //Rcout << "no prev" << std::endl;
      // }
      pointVals[nNotNan] = std::make_tuple(val, angleVal, corVal, circlePoints[i]); //make a tuple for the values and the point
      ++nNotNan; //keep track of how many 'not NaNs' we have.
    }
  }
  
  //DEBUGGING {
  //if(debug){
  //   Rcout << "filtered points with component vals:" << std::endl;
  //   for(int i = 0; i < nNotNan; ++i){
  //     Rcout << i << ": " << "(" << std::get<3>(pointVals[i]).x << ", " << std::get<3>(pointVals[i]).y << ") | hab: " << std::get<0>(pointVals[i]) << " |  attr: " << std::get<1>(pointVals[i]) << " | cor: " << std::get<2>(pointVals[i]) << std::endl;
  //   }
  // }
  //DEBUGGING }
  std::tuple<double, double, double> sums(std::make_tuple(0,0,0)); //get the sums of the values we calculated above
  for(int i = 0; i < nNotNan; ++i){
    std::get<0>(sums) = std::get<0>(sums) + std::get<0>(pointVals[i]);
    std::get<1>(sums) = std::get<1>(sums) + std::get<1>(pointVals[i]);
    std::get<2>(sums) = std::get<2>(sums) + std::get<2>(pointVals[i]);
    // if(!isnan(std::get<2>(pointVals[i]))){
    //   std::get<2>(sums) = std::get<2>(sums) + std::get<2>(pointVals[i]);
    // }
  }
  
  //if(debug){
    // Rcout << "val sum: " << std::get<0>(sums) << std::endl;
    // Rcout << "attr sum: " << std::get<1>(sums) << std::endl;
    // Rcout << "cor sum: " << std::get<2>(sums) << std::endl;
  // }
  //DEBUGGING {
  // Rcout << "=================================" << std::endl;
  // Rcout << "Resistance vals:" << std::endl;
  // for(int i = 0; i < nNotNan; ++i){
  //   Rcout << i <<": " << std::get<0>(pointVals[i])/std::get<0>(sums) << std::endl;
  // }
  // 
  // Rcout << "=================================" << std::endl;
  // Rcout << "Attr vals:" << std::endl;
  // for(int i = 0; i < nNotNan; ++i){
  //   Rcout << i <<": " << std::get<1>(pointVals[i])/std::get<1>(sums) << std::endl;
  // }
  // 
  // Rcout << "=================================" << std::endl;
  // Rcout << "Cor vals:" << std::endl;
  // for(int i = 0; i < nNotNan; ++i){
  //   Rcout << i <<": " << std::get<2>(pointVals[i])/std::get<2>(sums) << std::endl;
  // }
  //DEBUGGING }
  
  std::vector<double> probs(nNotNan);
  double probSum{0};
  for(int i = 0; i < nNotNan; ++i){
    // double prob = pow(std::get<0>(pointVals[i])/std::get<0>(sums), valExp) * pow(std::get<1>(pointVals[i])/std::get<1>(sums), attrExp);
    // if(!isnan(std::get<2>(pointVals[i]))){
    //   prob *= pow(std::get<2>(pointVals[i])/std::get<2>(sums), corExp); 
    // }
    double prob = pow(std::get<0>(pointVals[i])/std::get<0>(sums), valExp) * 
                  pow(std::get<1>(pointVals[i])/std::get<1>(sums), attrExp) *
                  pow(std::get<2>(pointVals[i])/std::get<2>(sums), corExp); ;
    
    probs[i] = prob;
    probSum += prob;
  }
  
  //if(debug){
  //   Rcout << "raw probs: ";
  //   for(int i = 0; i < probs.size(); ++i){
  //     Rcout << probs[i] << " ";
  //   }
  //   Rcout << std::endl;
  // }
  
  for(int i = 0; i < probs.size(); ++i){
    probs[i] = probs[i]/probSum;
  }
  
  //if(debug){
  //   Rcout << "scaled probs: ";
  //   for(int i = 0; i < probs.size(); ++i){
  //     Rcout << probs[i] << " ";
  //   }
  //   Rcout << std::endl;
  // }
  //DEBUGGING {
  // Rcout << "probSum: " << probSum << std::endl;
  // Rcout << "=================================" << std::endl;
  // Rcout << "Final probs:" << std::endl;
  // for(int i = 0; i < probs.size(); ++i){
  //   Rcout << i << ": " <<  probs[i] << std::endl;
  // }
  //DEBUGGING }
  
  std::random_device rd;  //Will be used to obtain a seed for the random number engine
  std::mt19937 gen(rd()); //Standard mersenne_twister_engine seeded with rd()
  std::discrete_distribution<int> distribution(probs.begin(), probs.end());
  int number = distribution(gen);
  
  //if(debug){
  //   Rcout << "random int: " << number << std::endl;
  //   Rcout << "chosen point: (" << std::get<3>(pointVals[number]).x << ", " << std::get<3>(pointVals[number]).y << ")" << std::endl;
  // }
  
  return std::get<3>(pointVals[number]);
}
// 

// n_points = 16
// points_dist = 4
// max_steps = 30
// max_substeps = 30
// val_exp1 = 3
// attr_exp1 = 3
// cor_exp1 = 1
// val_exp2 = 3
// attr_exp2 = 3
// cor_exp2 = 1

//point -> the point we want the distances from
//node -> the node this point is in
double getNearestNeighborDist_2(Point point, std::shared_ptr<Node> node){
  //std::vector<double> vals(node->neighbors.size());
  double min{0};
  //double xMean{(node->xMin + node->xMax)/2};
  //double yMean{(node->yMin + node->yMax)/2};
  for(int i = 0; i < node->neighbors.size(); ++i){
    double xMeanNb{(node->neighbors[i]->xMin + node->neighbors[i]->xMax)/2};
    double yMeanNb{(node->neighbors[i]->yMin + node->neighbors[i]->yMax)/2};
    double dist = pow(point.x - xMeanNb,2) + pow(point.y - yMeanNb,2);
    if(dist < min | i == 0){
      min = dist;
    }
  }
  return sqrt(min);
}

// std::vector<double> getNeighborDists(std::shared_ptr<Node> node){
//   for(int i = 0; i < node->neighbors.size(); ++i){
//     ((node->xMax + node->xMin)/2)^2 + (node->)
//   }
// }


//one way to optimize would be to just return the final point rather than the
//entire movement path. This would avoid having to use "push_back()" on every
//loop.
std::vector<Point> moveAgent_cpp_2(Quadtree &qt,
                        Point startPoint,
                        Point attractPoint,
                        int nCheckPoints,
                        double stepSize,
                        double maxTotalDistance,
                        double maxStraightLineDistance,
                        double maxTotalDistanceSubStep,
                        //int maxSteps,
                        //int maxSubSteps,
                        double qualityExp1,
                        double attractExp1,
                        double directionExp1,
                        double qualityExp2,
                        double attractExp2,
                        double directionExp2){
  //if(debug) Rcout << "check 0" << std::endl;
  //if(debug) std::this_thread::sleep_for(std::chrono::milliseconds(waitTime));
  
  //bool debug = true;
  //int waitTime = 100;
  
  double sqMaxStraightLineDistance = std::pow(maxStraightLineDistance, 2);
  
  Point currentPoint = startPoint;
  std::shared_ptr<Node> currentNode = qt.getNode(startPoint.x, startPoint.y);
  
  //if(debug) Rcout << "check 1" << std::endl;
  //if(debug) std::this_thread::sleep_for(std::chrono::milliseconds(waitTime));
  
  Point prevPoint1; //initialize the two previous point variables to empty since we have no previous points yet
  prevPoint1.isEmpty = true;
  Point prevPoint2;
  prevPoint2.isEmpty = true;
  
  //if(debug) Rcout << "check 2" << std::endl;
  //if(debug) std::this_thread::sleep_for(std::chrono::milliseconds(waitTime));
  
  double totalDistance = 0; //create vars for keeping track of how far we've come
  //double prevStraightLineDistance = 0;
  double sqStraightLineDistance = 0; //squared distance, because 'sqrt()' is compute intensive and we just as easily compare the squared values
  
  //if(debug) Rcout << "check 3" << std::endl;
  //if(debug) std::this_thread::sleep_for(std::chrono::milliseconds(waitTime));
  
  //std::vector<Point> moveHistory(maxTotalDistance);
  std::vector<Point> moveHistory(1);
  //std::vector<Point> moveHistory(maxSteps*maxSubSteps+1); //this is NOT memory efficient but avoids having to do 'push_back' all the time, which is expensive | add 1 because we're sticking the starting in the vector as well
  moveHistory.at(0) = currentPoint;
  
  //TEMPORARY!!!!!!!!!!! {
  moveHistory.at(0).extraVal=1;
  //TEMPORARY!!!!!!!!!!! }
  bool doFirstLoop = true;
  double nSteps = 0;
  //start the top-level movement process
  //for(int i = 0; i < maxSteps; ++i){
  while(doFirstLoop){
    ////if(debug) Rcout << "i: " << i << std::endl;
    //if(debug) Rcout << "check_i1" << std::endl;
    //if(debug) Rcout << "currentPoint.x: " << currentPoint.x << std::endl;
    //if(debug) Rcout << "currentPoint.y: " << currentPoint.y << std::endl;
    //if(debug) std::this_thread::sleep_for(std::chrono::milliseconds(waitTime));
    
    //get the next point that we'll try to get to
    Point nextPoint1 = getNextPoint_2(qt, currentPoint, prevPoint1, attractPoint, nCheckPoints, stepSize, qualityExp1, attractExp1, directionExp1);
    
    //if(debug) Rcout << "check_i2" << std::endl;
    //if(debug) Rcout << "nextPoint1.x: " << nextPoint1.x << std::endl;
    //if(debug) Rcout << "nextPoint1.y: " << nextPoint1.y << std::endl;
    //if(debug) std::this_thread::sleep_for(std::chrono::milliseconds(waitTime));
    
    std::shared_ptr<Node> nextNode1 = qt.getNode(nextPoint1.x, nextPoint1.y);
    
    //if(debug) Rcout << "check_i3" << std::endl;
    //if(debug) std::this_thread::sleep_for(std::chrono::milliseconds(waitTime));
    
    bool doSecondLoop = true;
    if(nextNode1->id != currentNode->id){ //if the next point is not in the same cell
      
      //if(debug) Rcout << "check_i4" << std::endl;
      //if(debug) std::this_thread::sleep_for(std::chrono::milliseconds(waitTime));
      
      for(int j = 0; j < currentNode->neighbors.size(); j++){ //check if the point chosen falls in a neighbor
        
        //if(debug) Rcout << "check_i5" << std::endl;
        //if(debug) std::this_thread::sleep_for(std::chrono::milliseconds(waitTime));
        
        if(nextNode1->id == currentNode->neighbors[j]->id){ //compare id's to see if the next point falls in this cell
          
          //if(debug) Rcout << "check_i6" << std::endl;
          //if(debug) std::this_thread::sleep_for(std::chrono::milliseconds(waitTime));
          
          doSecondLoop = false;
          break;
        }
      }
    } else { //if the next point we chose is in the current cell, we can move directly there
      doSecondLoop = false;
    }
    if(doSecondLoop){ //begin lower-level movement process
      
      //TEMPORARY!!!!!!!!!!! {
      currentPoint.extraVal = 0;
      //TEMPORARY!!!!!!!!!!! }
      //for(int j = 0; j < maxSubSteps; ++j){
      double totalDistanceSubStep = 0; //keep track of how far we've travelled in this substep
      while(doSecondLoop){
        
        ////if(debug) Rcout << "    j: " << j << std::endl;
        //if(debug) Rcout << "check_j1" << std::endl;
        //if(debug) std::this_thread::sleep_for(std::chrono::milliseconds(waitTime));
        
        double nearestNbDist = getNearestNeighborDist_2(currentPoint, currentNode); //get the closest distance from this point to the centroids of the neighboring cells
        if(nearestNbDist > stepSize){ //if this distance is greater than our step size then make this distance equal the step size
          nearestNbDist = stepSize;
        }
        
        //if(debug) Rcout << "check_j2" << std::endl;
        //if(debug) std::this_thread::sleep_for(std::chrono::milliseconds(waitTime));
        //using the step size we just determined, get our next point
        Point nextPoint2 = getNextPoint_2(qt, currentPoint, prevPoint2, nextPoint1, nCheckPoints, nearestNbDist, qualityExp2, attractExp2, directionExp2);
        
        //if(debug) Rcout << "check_j3" << std::endl;
        //if(debug) std::this_thread::sleep_for(std::chrono::milliseconds(waitTime));
        
        //update prevPoint2, currentPoint and currentNode
        prevPoint2 = currentPoint;
        currentPoint = nextPoint2;
        currentNode = qt.getNode(currentPoint.x, currentPoint.y); //future optimization - get next Node by looking through 'currentNodes' neighbors rather than going through the quadtree
        
        //if(debug) Rcout << "check_j4" << std::endl;
        //if(debug) std::this_thread::sleep_for(std::chrono::milliseconds(waitTime));
        
        // totalDistance += nearestNbDist; //add the distance traveled to our total distance
        // 
        // //if(debug) Rcout << "totalDistance: " << totalDistance << std::endl;
        // //if(debug) std::this_thread::sleep_for(std::chrono::milliseconds(waitTime));
        // 
        // totalDistanceSubStep += nearestNbDist; //add the distance traveled to our total distance
        // straightLineDistance = distanceBetweenPoints_2(startPoint, currentPoint);
        
        //if(debug) Rcout << "check_j5" << std::endl;
        //if(debug) std::this_thread::sleep_for(std::chrono::milliseconds(waitTime));
        
        if(currentNode->id == nextNode1->id){ // check if we're in the same cell as the point chosen in the high level movement process
          
          //if(debug) Rcout << "check_j6" << std::endl;
          //if(debug) std::this_thread::sleep_for(std::chrono::milliseconds(waitTime));
          
          //////NOTE
          //what I'm doing here (automatically making the point chosen in step 1 the current point if we're in the same cell as the point from step 1) might cause problems. I think there's probably an edge case where the distance between 'currentPoint' and 'nextPoint1' is greater than 'stepSize' even though they're in the same cell.
          //totalDistance += sqrt(sqDistBtwPoints_2(currentPoint, nextPoint1)); //add the additional distance to 'totalDistance'
          currentPoint = nextPoint1; //set the current point to be the point chosen in the top-level movement process
          //TEMPORARY!!!!!!!!!!! {
          currentPoint.extraVal = 1;
          //TEMPORARY!!!!!!!!!!! }
          currentNode = qt.getNode(currentPoint.x, currentPoint.y); 
          totalDistance += sqrt(sqDistBtwPoints_2(prevPoint2, currentPoint));
          doSecondLoop = false;
        } else {
          totalDistance += nearestNbDist; //add the distance traveled to our total distance
        }
        //if(debug) Rcout << "totalDistance: " << totalDistance << std::endl;
        //if(debug) std::this_thread::sleep_for(std::chrono::milliseconds(waitTime));
        
        totalDistanceSubStep += nearestNbDist; //add the distance traveled to our total distance
        //straightLineDistance = distanceBetweenPoints_2(startPoint, currentPoint);
        sqStraightLineDistance = sqDistBtwPoints_2(startPoint, currentPoint);
        
        //if(straightLineDistance >= maxStraightLineDistance){ // check if we've exceeded the maximum straight-line distance - if we have, we're done
        if(sqStraightLineDistance >= sqMaxStraightLineDistance){ // check if we've exceeded the maximum straight-line distance - if we have, we're done
          
          //if(debug) Rcout << "check_j7" << std::endl;
          //if(debug) std::this_thread::sleep_for(std::chrono::milliseconds(waitTime));
          
          currentPoint = getMaxDistEndPoint_2(startPoint, prevPoint2, currentPoint, maxStraightLineDistance); // adjust the end point so that we're exactly 'maxStraightLineDistance' away from the starting point
          currentNode = qt.getNode(currentPoint.x, currentPoint.y); 
          doFirstLoop = false;
          doSecondLoop = false;
        } else if(totalDistance >= maxTotalDistance){
          currentPoint = getTotDistEndPoint_2(currentPoint, prevPoint2, totalDistance-maxTotalDistance); // adjust the end point so that we're exactly 'maxTotalDistance' away from the starting point
          currentNode = qt.getNode(currentPoint.x, currentPoint.y); 
          doFirstLoop = false;
          doSecondLoop = false;
        } else if(totalDistanceSubStep >= maxTotalDistanceSubStep){
          
          //if(debug) Rcout << "check_j8" << std::endl;
          //if(debug) std::this_thread::sleep_for(std::chrono::milliseconds(waitTime));
          
          doSecondLoop = false; //should I add code here to adjust the last location so that 'totalDistanceSubStep == maxTotalDistanceSubStep'?
        }
        
        //if(debug) Rcout << "check_j9" << std::endl;
        //if(debug) std::this_thread::sleep_for(std::chrono::milliseconds(waitTime));
        
        moveHistory.push_back(currentPoint);
        nSteps++;
        //moveHistory[++nSteps] = currentPoint;
      }
    } else {

      //if(debug) Rcout << "check_i7" << std::endl;
      //if(debug) std::this_thread::sleep_for(std::chrono::milliseconds(waitTime));
      
      prevPoint2 = currentPoint;//Need to reset the previous point of the second level movement process. Say that we hit a stretch where we don't go into the second loop for a while. If 'prevPoint2' never gets updated, when we do end up going into the second loop prevPoint2 is from a long time ago - and that'll influence the 'direction' component of the movement process
      prevPoint1 = currentPoint;
      currentPoint = nextPoint1;
      currentNode = nextNode1;
      
      //if(debug) Rcout << "check_i8" << std::endl;
      //if(debug) std::this_thread::sleep_for(std::chrono::milliseconds(waitTime));
      
      totalDistance += stepSize;
      //straightLineDistance = distanceBetweenPoints_2(startPoint, currentPoint);
      sqStraightLineDistance = sqDistBtwPoints_2(startPoint, currentPoint);
      
      //if(debug) Rcout << "totalDistance: " << totalDistance << std::endl;
      //if(debug) std::this_thread::sleep_for(std::chrono::milliseconds(waitTime));
      
      
      //if(debug) Rcout << "check_i9" << std::endl;
      //if(debug) std::this_thread::sleep_for(std::chrono::milliseconds(waitTime));
      
      //if(straightLineDistance >= maxStraightLineDistance){ // check if we've exceeded the maximum straight-line distance - if we have, we're done
      if(sqStraightLineDistance >= sqMaxStraightLineDistance){ // check if we've exceeded the maximum straight-line distance - if we have, we're done
        
        //if(debug) Rcout << "check_i10" << std::endl;
        //if(debug) std::this_thread::sleep_for(std::chrono::milliseconds(waitTime));
        if(nSteps == 0){ //if this is the first step, 'getMaxDistEndPoint()' doesn't work because startPoint and prevPoint1 are the same. Not sure exactly why that is, but it's failing when it reaches maxStraighLineDistance in the first iteration. So instead use getTotDistEndPoint().
          currentPoint = getTotDistEndPoint_2(prevPoint1, currentPoint, maxStraightLineDistance);
        } else {
          currentPoint = getMaxDistEndPoint_2(startPoint, prevPoint1, currentPoint, maxStraightLineDistance); // adjust the end point so that we're exactly 'maxDistance' away from the starting point
        }
        //TEMPORARY!!!!!!!!!!! {
        currentPoint.extraVal = 0;
        //TEMPORARY!!!!!!!!!!! }
        doFirstLoop = false;
      } else if(totalDistance >= maxTotalDistance){
        currentPoint = getTotDistEndPoint_2(currentPoint, prevPoint1, totalDistance-maxTotalDistance); // adjust the end point so that we're exactly 'maxTotalDistance' away from the starting point
        currentNode = qt.getNode(currentPoint.x, currentPoint.y);
        //if(debug) Rcout << "check_i11" << std::endl;
        //if(debug) std::this_thread::sleep_for(std::chrono::milliseconds(waitTime));
        
        doFirstLoop = false;
        
        //TEMPORARY!!!!!!!!!!! {
        currentPoint.extraVal = 0;
        //TEMPORARY!!!!!!!!!!! }
      }
      
      //if(debug) Rcout << "check_i12" << std::endl;
      //if(debug) std::this_thread::sleep_for(std::chrono::milliseconds(waitTime));
      //TEMPORARY!!!!!!!!!!! {
      currentPoint.extraVal = 1;
      //TEMPORARY!!!!!!!!!!! }
      moveHistory.push_back(currentPoint);
      nSteps++;
      
      //if(debug) Rcout << "check_i13" << std::endl;
      //if(debug) std::this_thread::sleep_for(std::chrono::milliseconds(waitTime));
      //moveHistory[++nSteps] = currentPoint;
    }
  }
  //return moveHistory(Range(0,nSteps),_);
  moveHistory.resize(nSteps+1);//+1 because we included the starting point
  return moveHistory;
}

double distanceBetweenPoints_2(const Point& point1, const Point& point2){
  double distance = std::sqrt(std::pow(point1.x - point2.x, 2) + std::pow(point1.y - point2.y, 2));
  return distance;
}

Point getMaxDistEndPoint_2(const Point& firstPoint, const Point &penultimatePoint, const Point& lastPoint, double maxDistance){
  //notation: note that 'x' in variable names refers to the unknown point location I'm trying to find
  //get distances between all points
  double dist_fp = distanceBetweenPoints_2(firstPoint, penultimatePoint); // 'dist_f_p' is for 'distance from First point to Penultimate point. Same pattern is used for other distance variables
  double dist_fl = distanceBetweenPoints_2(firstPoint, lastPoint);
  double dist_pl = distanceBetweenPoints_2(penultimatePoint, lastPoint);
  
  double angle_fpl = std::acos((std::pow(dist_fp,2) + std::pow(dist_pl,2) - std::pow(dist_fl,2))/(2*dist_fp*dist_pl)); //use the law of cosines to find the angle formed by (firstPoint-penultimatePoint-lastPoint)
  double angle_fxp = std::asin((std::sin(angle_fpl)*dist_fp)/maxDistance); //use the law of sines to find the angle formed by (firstPoint-x-penultimatePoint) - this triangle is ASS so there COULD be two solutions - but I think the properties of this triangle mean there will always be one solution. see: https://mathbitsnotebook.com/Geometry/TrigApps/TAUsingLawSines.html - in our situation I think the angle will always be acute and S2 will always be longer than S1. I've tested this out (originally I tried both possible angles) and the one I'm using now was always the correct one, and the other angle was always wrong. Also I tested this function with 100000 random points (where pt1 was always less than max_dist away from first_pt, and pt2 was always more than max_dist away from first_pt) and there were no errors. So I'm fairly confident this is correct.
  double angle_pfx = M_PI - angle_fpl - angle_fxp; //get the angle formed by (penultimatePoint-firstPoint-x)
  
  double dist_1x = (std::sin(angle_pfx)*maxDistance)/std::sin(angle_fpl); //get the distance between penultimatePoint and x
  double angle_12 = std::atan2((lastPoint.y - penultimatePoint.y), (lastPoint.x - penultimatePoint.x)); //get angle between penultimatePoint and lastPoint, relative to the x axis
  
  Point newPoint;
  newPoint.x = penultimatePoint.x + dist_1x*std::cos(angle_12); //use the angle and the distance to get the coordinates of the new point
  newPoint.y = penultimatePoint.y + dist_1x*std::sin(angle_12);
  return newPoint;
}

//finds the point on the segment between point1 and point2 that is 'distance' away 
//from point1 (assumption is that 'distance' is less than the distance between
//point1 and point2)
Point getTotDistEndPoint_2(const Point &point1, const Point& point2, double distance){
  double angle_12 = std::atan2((point2.y - point1.y), (point2.x - point1.x)); //get angle between penultimatePoint and lastPoint, relative to the x axis
  
  Point newPoint;
  newPoint.x = point1.x + distance*std::cos(angle_12); //use the angle and the distance to get the coordinates of the new point
  newPoint.y = point1.y + distance*std::sin(angle_12);
  return newPoint;
}

//////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////
//                  R interface code                        //
//////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////
std::vector<Point> numMatToPointVec_2(NumericMatrix mat){
  std::vector<Point> points(mat.nrow());
  for(int i = 0; i < mat.nrow(); ++i){
    Point point_i;
    point_i.x = mat(i,0);
    point_i.y = mat(i,1);
    points[i] = point_i;
  }
  return points;
}

//convert a vector of points to a NumericMatrix
NumericMatrix pointVecToNumMat_2(std::vector<Point> points){
  //NumericMatrix mat(points.size(), 2);
  //TEMPORARY!!!!!!!!!!! {
  NumericMatrix mat(points.size(), 3);
  //TEMPORARY!!!!!!!!!!! }
  for(int i = 0; i < points.size(); ++i){
    mat(i,0) = points[i].x;
    mat(i,1) = points[i].y;
    //TEMPORARY!!!!!!!!!!! {
    mat(i,2) = points[i].extraVal;
    //TEMPORARY!!!!!!!!!!! }
  }
  return mat;
}


NumericMatrix getMaxDistEndPoint_2(NumericMatrix firstPoints, NumericMatrix penultimatePoints, NumericMatrix lastPoints, double maxDistance){
  assert(firstPoints.nrow() == penultimatePoints.nrow() && penultimatePoints.nrow() == lastPoints.nrow());
  
  std::vector<Point> firstPointVec = numMatToPointVec_2(firstPoints);
  std::vector<Point> penultimatePointsVec = numMatToPointVec_2(penultimatePoints);
  std::vector<Point> lastPointsVec = numMatToPointVec_2(lastPoints);
  
  std::vector<Point> newPointsVec(firstPointVec.size());
  for(int i = 0; i < firstPointVec.size(); ++i){
    newPointsVec[i] = getMaxDistEndPoint_2(firstPointVec[i], penultimatePointsVec[i], lastPointsVec[i], maxDistance);
  }
  return pointVecToNumMat_2(newPointsVec);
}
  

//create a Point from a NumericVector (first two elements will be used
//as the x and y coords, respectively)
Point makePoint_2(NumericVector vec){
  
  //Rcout << "makePoint_2" << std::endl;
  ////if(debug) std::this_thread::sleep_for(std::chrono::milliseconds(waitTime));
  
  Point point;
  if(is_true(any(is_na(vec)))){
    point.x=-1;
    point.y=-1;
    point.isEmpty=true;
  }
  point.x = vec[0];
  point.y = vec[1];
  return point;
}

NumericMatrix moveAgent_2(QuadtreeWrapper &qt,
                           NumericVector startPoint,
                           NumericVector attractPoint,
                           int nCheckPoints,
                           double stepSize,
                           double maxTotalDistance,
                           double maxStraightLineDistance,
                           double maxTotalDistanceSubStep,
                           double qualityExp1,
                           double attractExp1,
                           double directionExp1,
                           double qualityExp2,
                           double attractExp2,
                           double directionExp2){
  //bool debug = true;
  //int waitTime = 100;
  //Rcout << "moveAgent_2" << std::endl;
  ////if(debug) std::this_thread::sleep_for(std::chrono::milliseconds(waitTime));
  
  std::vector<Point> points = moveAgent_cpp_2(qt.quadtree,
                                              makePoint_2(startPoint),
                                              makePoint_2(attractPoint),
                                              nCheckPoints,
                                              stepSize,
                                              maxTotalDistance,
                                              maxStraightLineDistance,
                                              maxTotalDistanceSubStep,
                                              qualityExp1,
                                              attractExp1,
                                              directionExp1,
                                              qualityExp2,
                                              attractExp2,
                                              directionExp2);
  return pointVecToNumMat_2(points);
}















