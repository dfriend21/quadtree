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
    
    //Rcpp::List nodeList;
    Rcpp::List nbList;
    
    QuadtreeWrapper();
    QuadtreeWrapper(std::shared_ptr<Quadtree> _quadtree);
    //QuadtreeWrapper(Quadtree _quadtree);
    QuadtreeWrapper(Rcpp::NumericVector xlims, Rcpp::NumericVector ylims, double xMaxCellLength =  -1, double yMaxCellLength = -1);
    // QuadtreeWrapper(Rcpp::NumericVector xlims, Rcpp::NumericVector ylims, double rangeLim, double xMaxCellLength = -1, double yMaxCellLength = -1);
    //QuadtreeWrapper(Rcpp::NumericVector xlims, Rcpp::NumericVector ylims, double xMaxCellLength = -1, double yMaxCellLength = -1);
    // QuadtreeWrapper(Rcpp::NumericMatrix mat, Rcpp::NumericVector xlims, Rcpp::NumericVector ylims, Rcpp::Function splitFun, Rcpp::List splitArgs, Rcpp::Function combineFun, Rcpp::List combineArgs, double xMaxCellLength = -1, double yMaxCellLength = -1);
    // QuadtreeWrapper(Rcpp::NumericMatrix mat, Rcpp::NumericVector xlims, double rangeLim, double xMaxCellLength = -1, double yMaxCellLength = -1);
    
    int nNodes() const;
    //double rangeLim() const;
    NodeWrapper root() const;
    
    void setOriginalValues(double xMin, double xMax, double yMin, double yMax, double nX, double nY);
    void setProjection(std::string proj4string);
    
    Rcpp::NumericVector extent() const;
    Rcpp::NumericVector originalExtent() const;
    Rcpp::NumericVector originalDim() const;
    Rcpp::NumericVector originalRes() const;
    Rcpp::NumericVector maxCellDims() const;
    std::string projection() const;
    //std::vector<double> getValues(const std::vector<double> &x, const std::vector<double> &y) const
    //NumericVector getValues(const NumericVector &x, const NumericVector &y);
    std::vector<double> getValues(const std::vector<double> &x, const std::vector<double> &y) const;
    //Rcpp::NumericVector getValues(const Rcpp::NumericVector &x, const Rcpp::NumericVector &y) const;
    //Rcpp::NumericVector getValues(const Rcpp::NumericMatrix &mat) const;
    
    void setValues(const std::vector<double> &x, const std::vector<double> &y, const std::vector<double> &newVals);
    NodeWrapper getCell(double x, double y) const;
    Rcpp::List getCells(Rcpp::NumericVector x, Rcpp::NumericVector y) const;
    Rcpp::NumericMatrix getCellDetails(Rcpp::NumericVector x, Rcpp::NumericVector y) const;

    // void createTree(Rcpp::NumericMatrix &mat, Rcpp::Function splitFun, Rcpp::List splitArgs, Rcpp::Function combineFun, Rcpp::List combineArgs);
    void createTree(Rcpp::NumericMatrix &mat, std::string splitMethod, double splitThreshold, std::string combineMethod, Rcpp::Function splitFun, Rcpp::List splitArgs, Rcpp::Function combineFun, Rcpp::List combineArgs, QuadtreeWrapper templateQuadtree);
    std::string print() const;
    void makeList(std::shared_ptr<Node> node, Rcpp::List &list, int parentID) const;
    Rcpp::List asList();
    
    void makeNbList(std::shared_ptr<Node> node, Rcpp::List &list) const;
    Rcpp::List getNbList();
    
    ShortestPathFinderWrapper getShortestPathFinder(Rcpp::NumericVector startPoint, Rcpp::NumericVector xlims, Rcpp::NumericVector ylims) const;
    
    QuadtreeWrapper copy();
    
    void writeQuadtree(std::string filePath);
    static QuadtreeWrapper readQuadtree(std::string filePath);
    //static 
};


// std::shared_ptr<Quadtree> makeQuadtree(double rangeLim){
//   Quadtree quadtree(rangeLim);
//   return std::make_shared<Quadtree>(quadtree);
// }

RCPP_EXPOSED_CLASS(QuadtreeWrapper);

#endif