#ifndef QUADTREE_H
#define QUADTREE_H

#include "Matrix.h"
#include "Node.h"

#include <cereal/archives/portable_binary.hpp>
#include <cereal/types/memory.hpp>

#include <functional>
#include <list>
#include <memory>
#include <string>
#include <vector>

class Quadtree
{
public:
    std::shared_ptr<Node> root; // the root node of the tree
    int nNodes {0}; // total number of nodes in the tree

    // the dimensions of the matrix used to create the quadtree
    int matNX{0};
    int matNY{0};

    // the largest allowable x and y lengths of a cell
    double maxXCellLength{-1};
    double maxYCellLength{-1};
    // the smallest allowable x and y lengths of a cell
    double minXCellLength{-1};
    double minYCellLength{-1};

    bool splitAllNAs{false}; // should we split a quadrant if it contains all NAs?
    bool splitAnyNAs{true}; // should we split a quadrant if it contains any NAs?

    std::string projection{""}; // the projection string of the quadtree

    Quadtree(double xMin = 0, double xMax = 0, double yMin = 0, double yMax = 0, bool _splitAllNAs = false, bool _splitAnyNAs = true);
    Quadtree(double xMin, double xMax, double yMin, double yMax, double _maxXCellLength, double _maxYCellLength, double _minXCellLength, double _minYCellLength, bool _splitAllNAs, bool _splitAnyNAs);
    Quadtree(double xMin, double xMax, double yMin, double yMax, int _matNX, int _matNY, std::string _projection, double _maxXCellLength, double _maxYCellLength, double _minXCellLength, double _minYCellLength, bool _splitAllNAs, bool _splitAnyNAs);

    static bool splitRange(const Matrix &mat, double limit);
    static bool splitSD(const Matrix &mat, double limit);
    static bool splitCV(const Matrix &mat, double limit);
    static double combineMean(const Matrix &mat);
    static double combineMedian(const Matrix &mat);
    static double combineMin(const Matrix &mat);
    static double combineMax(const Matrix &mat);

    int makeTree(const Matrix &mat, const std::shared_ptr<Node> node, int id, int level, std::function<bool (const Matrix&)> splitFun, std::function<double (const Matrix&)> combineFun);
    void makeTree(const Matrix &mat, std::function<bool (const Matrix&)> splitFun, std::function<double (const Matrix&)> combineFun);
    int makeTreeWithTemplate(const Matrix &mat, const std::shared_ptr<Node> node, const std::shared_ptr<Node> templateNode, std::function<double (const Matrix&)> combineFun);
    void makeTreeWithTemplate(const Matrix &mat, const std::shared_ptr<Quadtree> templateQuadtree, std::function<double (const Matrix&)> combineFun);
    std::vector<std::shared_ptr<Node> > findNeighbors(const std::shared_ptr<Node> node, double searchSideLength) const;
    void assignNeighbors(const std::shared_ptr<Node> node);
    void assignNeighbors();

    std::shared_ptr<Node> getNode(const Point pt, const std::shared_ptr<Node> node) const;
    std::shared_ptr<Node> getNode(const Point pt) const;
    double getValue(const Point pt) const;
    void getNodesInBox(std::shared_ptr<Node> node, std::list<std::shared_ptr<Node>> &returnNodes, double xMin, double xMax, double yMin, double yMax, bool byCentroid);
    std::list<std::shared_ptr<Node>> getNodesInBox(double xMin, double xMax, double yMin, double yMax, bool byCentroid = false);

    void setValue(const Point pt, double newValue);
    void transformValues(std::shared_ptr<Node> node, std::function<double (const double)> &transformFun);
    void transformValues(std::function<double (const double)> &transformFun);

    int copyNode(std::shared_ptr<Node> nodeCopy, const std::shared_ptr<Node> nodeOrig) const;
    std::shared_ptr<Quadtree> copy() const;

    int toVector(std::shared_ptr<Node> node, std::vector<double> &vals, int i, bool terminalOnly) const;
    std::vector<double> toVector(bool terminalOnly) const;

    std::string toString(const std::shared_ptr<Node> node, const std::string prefix) const;
    std::string toString() const;

    template<class Archive>
    void serialize(Archive & archive){ // couldn't get serialization to work unless I defined 'serialize' in the header rather than in 'Quadtree.cpp'
        archive(root, nNodes, matNX, matNY, maxXCellLength, maxYCellLength, minXCellLength, minYCellLength, splitAllNAs, splitAnyNAs, projection);
    }

    static void writeQuadtree(std::shared_ptr<Quadtree> quadtree, std::string filePath);
    static std::shared_ptr<Quadtree> readQuadtree(std::string filePath);
};



#endif