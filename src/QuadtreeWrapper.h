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
    
    double originalXMin;
    double originalXMax;
    double originalYMin;
    double originalYMax;
    double originalNX;
    double originalNY;
    
    Rcpp::List nbList;
    
    QuadtreeWrapper();
    QuadtreeWrapper(std::shared_ptr<Quadtree> _quadtree);
    QuadtreeWrapper(Rcpp::NumericVector xlims, Rcpp::NumericVector ylims, Rcpp::NumericVector maxCellLength, Rcpp::NumericVector minCellLength, bool splitAllNAs, bool splitAnyNAs);
    
    int nNodes() const;
    NodeWrapper root() const;
    
    void setOriginalValues(double xMin, double xMax, double yMin, double yMax, double nX, double nY);
    void setProjection(std::string proj4string);
    
    Rcpp::NumericVector extent() const;
    Rcpp::NumericVector originalExtent() const;
    Rcpp::NumericVector originalDim() const;
    Rcpp::NumericVector originalRes() const;
    Rcpp::NumericVector minCellDims() const;
    Rcpp::NumericVector maxCellDims() const;
    std::string projection() const;
    std::vector<double> getValues(const std::vector<double> &x, const std::vector<double> &y) const;
    Rcpp::NumericMatrix getNeighbors(Rcpp::NumericVector pt) const;
    
    void setValues(const std::vector<double> &x, const std::vector<double> &y, const std::vector<double> &newVals);
    void transformValues(Rcpp::Function transformFun);
    NodeWrapper getCell(double x, double y) const;
    Rcpp::List getCells(Rcpp::NumericVector x, Rcpp::NumericVector y) const;
    Rcpp::NumericMatrix getCellDetails(Rcpp::NumericVector x, Rcpp::NumericVector y) const;

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
};

RCPP_EXPOSED_CLASS(QuadtreeWrapper);

#endif