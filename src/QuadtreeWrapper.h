#ifndef QUADTREEWRAPPER_H
#define QUADTREEWRAPPER_H


#include "Node.h"
#include "Quadtree.h"

#include "NodeWrapper.h"
#include "ShortestPathFinderWrapper.h"

#include <memory>
#include <vector>
#include <string>
#include <Rcpp.h>


class QuadtreeWrapper{
  public:
    std::shared_ptr<Quadtree> quadtree;
    
    std::string proj4String;
    
    // double originalXMin;
    // double originalXMax;
    // double originalYMin;
    // double originalYMax;
    // double originalNX;
    // double originalNY;
    //Quadtree quadtree;
    
    Rcpp::List nodeList;
    Rcpp::List nbList;
    
    QuadtreeWrapper(std::shared_ptr<Quadtree> _quadtree);
    //QuadtreeWrapper(Quadtree _quadtree);
    QuadtreeWrapper(Rcpp::NumericVector xlims, Rcpp::NumericVector ylims, double rangeLim);
    QuadtreeWrapper(Rcpp::NumericMatrix mat, Rcpp::NumericVector xlims, Rcpp::NumericVector ylims, double rangeLim);
    
    int nNodes() const;
    double rangeLim() const;
    NodeWrapper root() const;
    
    void setOriginalValues(double xMin, double xMax, double yMin, double yMax, double nX, double nY);
    void setProjection(std::string proj4string);
    
    Rcpp::NumericVector extent();
    Rcpp::NumericVector originalExtent();
    Rcpp::NumericVector originalDim();
    Rcpp::NumericVector originalRes();
    std::string projection();
    
    //NumericVector getValues(const NumericVector &x, const NumericVector &y);
    std::vector<double> getValues(const std::vector<double> &x, const std::vector<double> &y) const;
    //Rcpp::NumericVector getValues(const Rcpp::NumericVector &x, const Rcpp::NumericVector &y) const;
    //Rcpp::NumericVector getValues(const Rcpp::NumericMatrix &mat) const;
    NodeWrapper getCell(double x, double y) const;
    Rcpp::List getCells(Rcpp::NumericVector x, Rcpp::NumericVector y) const;

    
    void createTree(Rcpp::NumericMatrix &mat);
    std::string print() const;
    void makeList(std::shared_ptr<Node> node, Rcpp::List &list) const;
    Rcpp::List asList();
    
    void makeNbList(std::shared_ptr<Node> node, Rcpp::List &list) const;
    Rcpp::List getNbList();
    
    ShortestPathFinderWrapper getShortestPathFinder(Rcpp::NumericVector startPoint, Rcpp::NumericVector xlims, Rcpp::NumericVector ylims) const;
    
    void writeQuadtree(std::string filePath);
    static QuadtreeWrapper readQuadtree(std::string filePath);
    
    //static Rcpp::NumericVector extract(QuadtreeWrapper &qw, Rcpp::NumericMatrix &mat) const;
    //static 
};


// std::shared_ptr<Quadtree> makeQuadtree(double rangeLim){
//   Quadtree quadtree(rangeLim);
//   return std::make_shared<Quadtree>(quadtree);
// }

RCPP_EXPOSED_CLASS(QuadtreeWrapper);

#endif