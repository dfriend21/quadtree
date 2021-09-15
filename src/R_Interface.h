#include <Rcpp.h>
#include "Matrix.h"

namespace rInterface {
  Matrix rMatToCppMat(Rcpp::NumericMatrix &mat);
}