#ifndef QUADTREEWRAPPER_H
#define QUADTREEWRAPPER_H

#include "LcpFinderWrapper.h"
#include "Node.h"
#include "NodeWrapper.h"
#include "Quadtree.h"

#include <cereal/archives/portable_binary.hpp>
#include <cereal/types/memory.hpp>
#include <Rcpp.h>

#include <memory>
#include <vector>
#include <string>

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
    
    void setOriginalValues(double xmin, double xmax, double ymin, double ymax, double nX, double nY);
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
    NodeWrapper getCell(Rcpp::NumericVector pt) const;
    Rcpp::List getCells(Rcpp::NumericVector x, Rcpp::NumericVector y) const;
    Rcpp::NumericMatrix getCellsDetails(Rcpp::NumericVector x, Rcpp::NumericVector y) const;

    void createTree(Rcpp::NumericMatrix &mat, std::string splitMethod, double splitThreshold, std::string combineMethod, Rcpp::Function splitFun, Rcpp::List splitArgs, Rcpp::Function combineFun, Rcpp::List combineArgs, QuadtreeWrapper templateQuadtree);
    std::string print() const;
    void makeList(std::shared_ptr<Node> node, Rcpp::List &list, int parentID) const;
    Rcpp::List asList();
    
    std::vector<double> asVector(bool terminalOnly) const;
    void makeNeighborList(std::shared_ptr<Node> node, Rcpp::List &list) const;
    Rcpp::List getNeighborList();
    
    // LcpFinderWrapper getLcpFinder(Rcpp::NumericVector startPoint, Rcpp::NumericVector xlims, Rcpp::NumericVector ylims, bool searchByCentroid) const;
    LcpFinderWrapper getLcpFinder(Rcpp::NumericVector startPoint, Rcpp::NumericVector xlims, Rcpp::NumericVector ylims, Rcpp::NumericMatrix newPoints, bool searchByCentroid) const;
    
    QuadtreeWrapper copy() const;
    
    static void writeQuadtree(QuadtreeWrapper qw, std::string filePath);
    static QuadtreeWrapper readQuadtree(std::string filePath);
    static void writeQuadtreePtr(QuadtreeWrapper qw, std::string filePath);
    
    template<class Archive>
    void serialize(Archive & archive){ //couldn't get serialization to work unless I defined 'serialize' in the header rather than in 'Quadtree.cpp'
      archive(quadtree, proj4String, originalXMin, originalXMax,originalYMin,originalYMax,originalNX,originalNY);
    }
    
    
};

RCPP_EXPOSED_CLASS(QuadtreeWrapper);

#endif