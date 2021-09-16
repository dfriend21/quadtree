#ifndef R_INTERFACE_H
#define R_INTERFACE_H

#include "Matrix.h"

#include <Rcpp.h>

namespace rInterface {
  Matrix rMatToCppMat(Rcpp::NumericMatrix &mat);
}

#endif