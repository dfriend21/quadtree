#include "Quadtree.h"
#include "Node.h"
#include "Point.h"
#include "Matrix.h"
#include "QuadtreeWrapper.h"
#include "NodeWrapper.h"
#include "R_Interface.h"
#include <vector>
#include <Rcpp.h>
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
    for(size_t j = 0; j < row.size(); j++){
      vec[counter] = row[j];
      counter++;
    }
  }
  Matrix newMat(vec, mat.nrow(), mat.ncol());
  return newMat;
}