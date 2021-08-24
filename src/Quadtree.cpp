#include "Matrix.h"
#include "Quadtree.h"
#include "Node.h"
#include <iostream>
#include <fstream>
#include <vector>
#include <memory>
#include <cassert>
#include <cmath>
#include <string>
#include <algorithm>
#include <limits>
#include <functional>
#include <cstdarg>
#include <cereal/archives/json.hpp>
#include <cereal/archives/portable_binary.hpp>
#include <cereal/archives/binary.hpp>
#include <cereal/types/memory.hpp>

//-------------------------
// constructors
//-------------------------

Quadtree::Quadtree(double xMin, double xMax, double yMin, double yMax, bool _splitAllNAs, bool _splitAnyNAs)
    : splitAllNAs{_splitAllNAs}, splitAnyNAs{_splitAnyNAs}{
    root = std::make_shared<Node>(xMin,xMax,yMin,yMax,0,0,0);
}

Quadtree::Quadtree(double xMin, double xMax, double yMin, double yMax, double _maxXCellLength, double _maxYCellLength, double _minXCellLength, double _minYCellLength, bool _splitAllNAs, bool _splitAnyNAs) 
    : Quadtree{xMin, xMax, yMin, yMax, _splitAllNAs, _splitAnyNAs}{
    maxXCellLength = _maxXCellLength;
    maxYCellLength = _maxYCellLength;
    minXCellLength = _minXCellLength;
    minYCellLength = _minYCellLength;
}

Quadtree::Quadtree(double xMin, double xMax, double yMin, double yMax, int _matNX, int _matNY, std::string _proj4string, double _maxXCellLength, double _maxYCellLength, double _minXCellLength, double _minYCellLength, bool _splitAllNAs, bool _splitAnyNAs)
    : Quadtree{xMin, xMax, yMin, yMax, _maxXCellLength, _maxYCellLength, _minXCellLength, _minYCellLength, _splitAllNAs, _splitAnyNAs}{
    matNX = _matNX;
    matNY = _matNY;
    proj4string = _proj4string;
}

//-------------------------
// split* 
//-------------------------
// these functions are designed to be passed to 'makeTree' and 'makeTreeWithTemplate'.
// They are responsible for determining whether a 'quadrant', which encompasses many 
// cells, should split into smaller cells. They take a matrix and some threshold value
// and return a boolean, where 'true' indicates that the quadrant should be split.
bool Quadtree::splitRange(const Matrix &mat, double limit){
    double dif = mat.max() - mat.min(); // get the difference between the max and min cells in this node
    return dif >= limit; //if 'dif' is greater than or equal to the limit, return true
}

//SD stands for 'standard deviation'
bool Quadtree::splitSD(const Matrix &mat, double limit){
    double mean = mat.mean(true);
    double sum = 0; 
    double n = 0;
    for(int i = 0; i < mat.size(); ++i){
        double val = mat.getValueByIndex(i);
        if(!std::isnan(val)){
            sum += pow(val-mean,2);
            n++;
        }
    }
    double var = sum/n; //use the variance to compare the two so we can avoid taking the square root
    return var >= pow(limit,2); //if the standard deviation is greater than the limit, return true (although I'm actually comparing the variances here)
}

//-------------------------
// combine* 
//-------------------------
// these functions are designed to be passed to 'makeTree' and 'makeTreeWithTemplate'.
// They are responsible for determining the value of a cell in the case where multiple 
// cells are being combined into a single quadtree cell. They simply take a matrix and 
// then return a single value derived from that matrix
double Quadtree::combineMean(const Matrix &mat){
    return mat.mean();
}

double Quadtree::combineMedian(const Matrix &mat){
    return mat.median();
}

double Quadtree::combineMin(const Matrix &mat){
    return mat.min();
}

double Quadtree::combineMax(const Matrix &mat){
    return mat.max();
}

//-------------------------
// makeTree 
//-------------------------
//set of functions used for creating a quadtree

//recursive function for creating a tree
// --DESCRIPTION: checks a single node and decides whether or not to split this node
// --PARAMETERS: 
//   mat -> matrix used to build the quadtree
//   node -> pointer to the node we want to try splitting into 4
//   id -> current ID
//   level -> the 'level' of this node (i.e. the depth of the node in the tree)
// --RETURNS: ID of the most recently created node
int Quadtree::makeTree(const Matrix &mat, const std::shared_ptr<Node> node, int id, int level, std::function<bool (const Matrix&)> splitFun, std::function<double (const Matrix&)> combineFun){
    //assign values to our node
    node->value = combineFun(mat);
    node->level = level;
    node->id = id;

    int newid{id};// ? - not sure if this is necessary - can I just use 'id'?
    
    //get the dimensions of the cell and the number of Nans
    double x_length = node->xMax - node->xMin;
    double y_length = node->yMax - node->yMin;
    int nNans = mat.countNans();
    
    //to split the cell, the following conditions must be met:
    if((mat.nRow()%2 == 0 && mat.nCol()%2 == 0) // the # of cells in both dimensions must be divisible by two AND
        && (splitAllNAs || nNans != mat.size()) // (the splitAllNAs option is TRUE OR not all the values are NA) AND
        && (splitFun(mat) // ( the split function evaluates to TRUE OR
            || x_length > maxXCellLength // the x side length is greater than the user-defined maximum length OR
            || y_length > maxYCellLength // the y side length is greater than the user-defined maximum length OR
            || (splitAnyNAs && nNans > 0) // (the splitAnyNAs option is TRUE AND there is at least one Nan) OR
            || (splitAllNAs && nNans == mat.size())) // (the splitAllNAs option is TRUE AND all the values are Nan) ) AND
        && x_length/2 >= minXCellLength // the x length of the quadrant's children would be greater than the min x length AND
        && y_length/2 >= minYCellLength){ // the y length of the quadrant's children would be greater than the min y length
        
        node->hasChildren = true; 
        double cell_x_len = (node->xMax - node->xMin)/2;//get the side length of the cells
        double cell_y_len = (node->yMax - node->yMin)/2;

        //loop over each child and create a node for each one - and, if the conditions are met, split the children
        for(int r = 0; r < 2; ++r){
            for(int c = 0; c < 2; ++c){
                //retrieve the indices of the matrix that correspond to this node
                int c_beg = (mat.nCol()/2)*c;
                int c_end = (c_beg + mat.nCol()/2)-1;
                int r_beg = (mat.nRow()/2)*r;
                int r_end = (r_beg + mat.nRow()/2)-1;
                
                //get the min and max x and y values
                double x_min = node->xMin + c*cell_x_len;
                double x_max = x_min + cell_x_len;
                double y_min = node->yMin + (1-r)*cell_y_len; //using (1-r) instead of r is because in a matrix the top left corner is y=0. But in space the lower left corner is y=0.
                double y_max = y_min + cell_y_len;
                
                int childIndex = (1-r)*2 + c; //get the index (from 0 to 3) of this child in the parent's 'children' vector
                Matrix sub = mat.subset(r_beg,r_end,c_beg,c_end); //get the matrix of values that this cell contains
                
                node->children.at(childIndex) = std::make_shared<Node>(x_min, x_max, y_min, y_max, -1, -1, -1); //create the node
                newid = makeTree(sub, node->children[childIndex], newid+1, level+1, splitFun, combineFun); //recursively call 'makeTree' on this node, making sure to increment the 'id' and the 'level'
            }
        }
        //check its children to get the smallest child side length
        for(size_t i = 0; i < node->children.size(); ++i){
            if(node->children[i]->smallestChildSideLength < node->smallestChildSideLength){
                node->smallestChildSideLength = node->children[i]->smallestChildSideLength;
            }
        }
    }
    return newid;
}

// wrapper for makeTree(Matrix, std::shared_ptr<Node>, int, int)
// --DESCRIPTION: this is the "outward-facing" function for creating a quadtree from a matrix - 
// it leaves out the last three parameters that are needed in the recursive 
// version so that users only need to give the matrix to the 'makeTree' function
// --PARAMETERS:
//   mat -> matrix used to build the quadtree. Should be divisible by 2 - ideally
//      the dimensions will be a result of 2^x. And it should be square. If
//      a matrix with dimensions not divisible by 2 is provided, the result
//      will be a quadtree with one node.
void Quadtree::makeTree(const Matrix &mat, std::function<bool (const Matrix&)> splitFun, std::function<double (const Matrix&)> combineFun){
    matNX = mat.nCol();
    matNY = mat.nRow();
    // if the value for max length is less than 0 (default is -1) then set the max length for both dimensions to be the user-defined dimensions. This essentially sets no restriction on the cell size
    if(maxXCellLength < 0) maxXCellLength = root->xMax - root->xMin; 
    if(maxYCellLength < 0) maxYCellLength = root->yMax - root->yMin;
    nNodes = makeTree(mat, root, 0, 0, splitFun, combineFun) + 1; //the ID that is returned from 'makeTree' also corresponds to the number of nodes created. Add 1 to get the count (since the ID starts at 0)
    assignNeighbors(); //assign neighbors for the cells    
}


//-------------------------
// makeTreeWithTemplate
//-------------------------
//recursively creates a tree that has the same structure as another tree
//operates on individual nodes
int Quadtree::makeTreeWithTemplate(const Matrix &mat, const std::shared_ptr<Node> node, const std::shared_ptr<Node> templateNode, std::function<double (const Matrix&)> combineFun){

    node->value = combineFun(mat);
    node->level = templateNode->level;
    node->id = templateNode->id;
    node->smallestChildSideLength = templateNode->smallestChildSideLength;
    node->hasChildren = templateNode->hasChildren;
    
    int newid{node->id};
    if(templateNode->hasChildren){
        for(int r = 0; r < 2; ++r){
            for(int c = 0; c < 2; ++c){
                //retrieve the indices of the matrix that correspond to this node
                int c_beg = (mat.nCol()/2)*c;
                int c_end = (c_beg + mat.nCol()/2)-1;
                int r_beg = (mat.nRow()/2)*r;
                int r_end = (r_beg + mat.nRow()/2)-1;
                
                int childIndex = (1-r)*2 + c; //get the index (from 0 to 3) of this child in the parent's 'children' vector
                std::shared_ptr<Node> templateChild = templateNode->children[childIndex];
                
                Matrix sub = mat.subset(r_beg,r_end,c_beg,c_end); //get the matrix of values that this cell contains
                
                node->children.at(childIndex) = std::make_shared<Node>(templateChild->xMin, templateChild->xMax, templateChild->yMin, templateChild->yMax, -1, -1, -1); //create the node
                newid = makeTreeWithTemplate(sub, node->children[childIndex], templateChild, combineFun); //recursively call 'makeTree' on this node, making sure to increment the 'id' and the 'level'   
            }
        }
    }
    return newid;
}

//entry-point into the 'makeTreeWithTemplate' - calls the other 'makeTreeWithTemplate' function on the root node
void Quadtree::makeTreeWithTemplate(const Matrix &mat, const std::shared_ptr<Quadtree> templateQuadtree, std::function<double (const Matrix&)> combineFun){
    if(mat.nCol() != templateQuadtree->matNX || mat.nRow() != templateQuadtree->matNY){
        throw std::runtime_error("The dimensions of 'mat' (" + std::to_string(mat.nRow()) + " rows, " + std::to_string(mat.nCol()) + " cols) must be identical to the dimensions of the original matrix used to create 'templateQuadtree' (" + std::to_string(templateQuadtree->matNY) + " rows, " + std::to_string(templateQuadtree->matNX) + " cols)");
    }
    matNX = templateQuadtree->matNX;
    matNY = templateQuadtree->matNY;
    maxXCellLength = templateQuadtree->maxXCellLength;
    maxYCellLength = templateQuadtree->maxYCellLength;
    nNodes = templateQuadtree->nNodes;
    proj4string = templateQuadtree->proj4string;

    makeTreeWithTemplate(mat, root, templateQuadtree->root, combineFun);
    assignNeighbors();
}

//-------------------------
// findNeighbors
//-------------------------
// finds which nodes are adjacent to this node
// --DESCRIPTION: operates by creating a set of points just outside the boundary of the node 
// (the distance between each point, and thus the number of points, is determined
// by the smallest child side length). Essentially, using our knowledge of the 
// size of the smallest child, checks around the node in every possible place 
// a neighbor would be if the surrounding cells were the size of the smallest 
// cell in the quadtree. Then it removes duplicates to get the list of neighbors.
// note that this function is a member function of 'Quadtree' and not 'Node' 
// because to do this we need knowledge of the *whole* tree, including a node's 
// parents
// --PARAMETERS:
//   node -> pointer to the node for which we want to find neighbors
//   searchSideLength -> the distance between the points that we'll use to check
//      for neighbors
// --RETURNS: returns a vector of pointers to the neighboring nodes
std::vector<std::shared_ptr<Node>> Quadtree::findNeighbors(const std::shared_ptr<Node> node, double searchSideLength) const{
    int nCheckPerSide = (node->xMax - node->xMin)/searchSideLength + 2; //based on our knowledge of the side length of the smallest child, figure out how many points on each side we need to chekc - plus two so that we get the "diagonal" neighbors as well
    std::vector<std::shared_ptr<Node>> nb(4*(nCheckPerSide-1),nullptr); //create a vector to store the nodes we get
    int counter{0}; //keeps track of how many nodes we've added to the list so far - used to index the list
    
    //essentially what we're doing here is checking a grid of points based on the number of points we're checking. Most of the points in this grid will fall inside the cell - so we'll only check the points that border the cell
    for(int x = -1; x < nCheckPerSide-1; ++x){
        for(int y = -1; y < nCheckPerSide-1; ++y){
            if( (x == -1) | (x == nCheckPerSide-2) | (y == -1) | (y == nCheckPerSide-2)){ //we only want to check the cells that fall outside this cell - this means ignoring the "interior points" - the ones that fall inside this cell.
                //get the x and y coordinates to check
                double x_temp{node->xMin + x*searchSideLength + searchSideLength/2};
                double y_temp{node->yMin + y*searchSideLength + searchSideLength/2};

                nb.at(counter) = getNode(x_temp, y_temp, root); //add the pointer of the node we retrieved to our vector
                ++counter; //since we added a node to our vector, increment the counter
                
            }
        }
    }

    nb.erase(std::remove(std::begin(nb), std::end(nb), nullptr),std::end(nb)); //delete null pointers - this will happen if the cell is on the edge of the quadtree, as it'll end up checking points that fall outside of the quadtree.
    std::sort( nb.begin(), nb.end() ); //this line and the next remove duplicates - https://stackoverflow.com/questions/1041620/whats-the-most-efficient-way-to-erase-duplicates-and-sort-a-vector
    nb.erase( unique( nb.begin(), nb.end() ), nb.end() );
    return nb;
}

//-------------------------
// assignNeighbors
//-------------------------
// these functions use 'findNeighbors' to find the neighbors and then assign
// the neighbors to the 'neighbors' vector

// wrapper function for 'findNeighbors' that travels recursively through the tree
// and uses 'findNeighbors' on each node to find its neighbors. Populates the 
// 'neighbors' vector of each Node
void Quadtree::assignNeighbors(const std::shared_ptr<Node> node){
    if(node->hasChildren){
        for(size_t i = 0; i < node->children.size(); i++){
            assignNeighbors(node->children[i]);
        }
    }
    auto neighbors = findNeighbors(node, root->smallestChildSideLength);
    node->neighbors = std::vector<std::weak_ptr<Node>>(neighbors.size());
    for(size_t i = 0; i < neighbors.size(); i++){
        node->neighbors[i] = std::weak_ptr<Node>(neighbors[i]);
    }
}

// user-friendly wrapper function for 'assignNeighbors' where no arguments are 
// needed - automatically uses 'assignNeighbors' on the root
void Quadtree::assignNeighbors(){
    assignNeighbors(root);
}

//-------------------------
// getNode
//-------------------------
// set of two functions for retrieving a node - one is a recursive algorithm that searches the
// the tree, the other is essentially the 'entry point' into that function

//returns the node at a given (x,y) location
//works exactly the same as 'getValue' except returns a pointer to the node
//instead of the value of the node
std::shared_ptr<Node> Quadtree::getNode(double x, double y, const std::shared_ptr<Node> node) const{
    if( (x < node->xMin) | (x > node->xMax) | (y < node->yMin) | (y > node->yMax) | std::isnan(x) | std::isnan(y)){ //check to make sure the point falls within our extent
        return nullptr; //if not, return NULL
    }
    if(node->hasChildren){ //if it has children, then we need to keep going
        int childIndex {node->getChildIndex(x,y)};
        return getNode(x,y,node->children[childIndex]);
    }
    return node; //if it doesn't have children, then we're at the bottom "level", so return the value of this Quadtree
}

//user-friendly wrapper for 'getNode' so that 'node' doesn't need to be specified
//(automatically uses the root)
std::shared_ptr<Node> Quadtree::getNode(double x, double y) const{
    return getNode(x,y,root);
}

//-------------------------
// getValue
//-------------------------
//THOUGHT: Use getNode, and then just return the value? Then I don't have two nearly identical functions.

//recursively finds the value at a given (x,y) location. Checks if this point falls
//within it's boundaries - if it does, and it doesn't have children, returns the
//value of this node. If it does have children, it calls the function on the 
//child that contains the point.
//x -> x coordinate
//y -> y coordinate
//node-> pointer 
double Quadtree::getValue(double x, double y, const std::shared_ptr<Node> node) const{
    if( (x < node->xMin) | (x > node->xMax) | (y < node->yMin) | (y > node->yMax) | std::isnan(x) | std::isnan(y)){ //check to make sure the point falls within our extent and that x and y aren't NaN
        return std::numeric_limits<double>::quiet_NaN(); //if the point doesn't fall within the quadtree, return NaN
    }
    if(node->hasChildren){ //if it has children, then we need to keep going
        int childIndex {node->getChildIndex(x,y)};
        return getValue(x,y,node->children[childIndex]);
    }
    return node->value; //if it doesn't have children, then we're at the bottom "level", so return the value of this node
}

//user-friendly wrapper for 'getValue' so that 'node' doesn't need to be specified
//(automatically uses the root)
double Quadtree::getValue(double x, double y) const{
    return getValue(x,y,root);
}

//-------------------------
// getNodesInBox
//-------------------------
void Quadtree::getNodesInBox(std::shared_ptr<Node> node, std::list<std::shared_ptr<Node>> &returnNodes, double xMin, double xMax, double yMin, double yMax){
    //if(node->children.size() > 0){
        for(size_t i = 0; i < node->children.size(); ++i){
            std::shared_ptr<Node> child = node->children.at(i);
            bool isXValid = !(xMax < child->xMin || xMin > child->xMax);
            bool isYValid = !(yMax < child->yMin || yMin > child->yMax);
            if(isXValid && isYValid){
                if(child->hasChildren){
                    getNodesInBox(child, returnNodes, xMin, xMax, yMin, yMax);
                } else {
                    returnNodes.push_back(child);
                }
            }
        }
    //}
}

std::list<std::shared_ptr<Node>> Quadtree::getNodesInBox(double xMin, double xMax, double yMin, double yMax){
    std::list<std::shared_ptr<Node>> returnNodes;
    getNodesInBox(root, returnNodes, xMin, xMax, yMin, yMax);
    return returnNodes;
}

//-------------------------
// setValue
//-------------------------
//given a point and a value, change the value of the node that the point falls in
void Quadtree::setValue(double x, double y, double newValue){
    std::shared_ptr<Node> node = getNode(x,y,root);
    if(node){
        node->value = newValue;
    }
}

//-------------------------
// transformValues
//-------------------------
void Quadtree::transformValues(std::shared_ptr<Node> node, std::function<double (const double)> &transformFun){
    node->value = transformFun(node->value);
    if(node->hasChildren){
        for(size_t i = 0; i < node->children.size(); ++i){
            transformValues(node->children[i],transformFun);
        }
    }
}
void Quadtree::transformValues(std::function<double (const double)> &transformFun){
    transformValues(root, transformFun);
}

//-------------------------
// copyNode
//-------------------------
// --DESCRIPTION: creates a deep copy of a node
// I feel like this is probably out of place here... should this be a member function of 'Node' instead?
int Quadtree::copyNode(std::shared_ptr<Node> nodeCopy, const std::shared_ptr<Node> nodeOrig) const{
    nodeCopy->xMin = nodeOrig->xMin;
    nodeCopy->xMax = nodeOrig->xMax;
    nodeCopy->yMin = nodeOrig->yMin;
    nodeCopy->yMax = nodeOrig->yMax;
    nodeCopy->value = nodeOrig->value;
    nodeCopy->id = nodeOrig->id;
    nodeCopy->level = nodeOrig->level;
    nodeCopy->smallestChildSideLength = nodeOrig->smallestChildSideLength;
    nodeCopy->hasChildren = nodeOrig->hasChildren;

    int newid{nodeOrig->id};
    if(nodeOrig->hasChildren){
        for(int r = 0; r < 2; ++r){
            for(int c = 0; c < 2; ++c){
                int childIndex = (1-r)*2 + c; //get the index (from 0 to 3) of this child 
                nodeCopy->children.at(childIndex) = std::make_shared<Node>(); //create the node
                newid = copyNode(nodeCopy->children[childIndex],nodeOrig->children[childIndex]);
            }
        }
    }
    return newid;
}

//-------------------------
// copy
//-------------------------
// uses 'copy' to create a deep copy of a Quadtree object
std::shared_ptr<Quadtree> Quadtree::copy() const{
    std::shared_ptr<Quadtree> qtCopy = std::make_shared<Quadtree>(root->xMin, root->xMax, root->yMin, root->yMax, matNX, matNY, proj4string, maxXCellLength, maxYCellLength, minXCellLength, minYCellLength, splitAllNAs, splitAnyNAs);
    
    qtCopy->nNodes = nNodes;
    copyNode(qtCopy->root, root);
    qtCopy->assignNeighbors();
    return(qtCopy);
}


//-------------------------
// toVector
//-------------------------
// puts all the cell values into a vector
std::vector<double> Quadtree::toVector() const{
    int nLeaves = (floor(nNodes/4)*3)+1;
    std::vector<double> vals(nLeaves);
    toVector(root, vals, 0);
    return vals;
}

int Quadtree::toVector(std::shared_ptr<Node> node, std::vector<double> &vals, int index) const{
    if(node->hasChildren){
        for(size_t i = 0; i < node->children.size(); ++i){
            index = toVector(node->children[i], vals, index);
        }
        return index;
    } else {
        vals.at(index) = node->value;
        return index+1;
    }
}

//-------------------------
// toString
//-------------------------
// creates a string representation of the tree

// --DESCRIPTION: recursively travels the tree and returns a string for each node, indented so
// that it resembles a tree structure
// --PARAMETERS: 
//   node -> the node we want to make a string for
//   prefix -> characters that will precede the node information - this is used for the indentation
// --RETURNS: a string
std::string Quadtree::toString(const std::shared_ptr<Node> node, const std::string prefix) const{
    std::string str = prefix + "--" + node->toString() + "\n";
    if(node->hasChildren){
        std::string newPrefix = prefix + "   |"; //add an indent to the prefix so that the children are indented under the parent
        for(size_t i = 0; i < node->children.size(); i++){ //call 'toString()' on its children, if it has any
            str = str + toString(node->children[i], newPrefix);
        }
    }
    return str;
}

//user-friendly wrapper function for 'toString()' where no arguments are needed
// - automatically calls 'toString()' on 'root'
std::string Quadtree::toString() const{
  std::string proj4string;
    std::string str("");
    str = str + 
        "nNodes: " + std::to_string(nNodes) + "\n" +
        "maxXCellLength: " + std::to_string(maxXCellLength) + "\n" +
        "maxYCellLength: " + std::to_string(maxYCellLength) + "\n" +
        toString(root, "") + "\n";
    return str;
}

//-------------------------
// writeQuadtree
//-------------------------
// writes a quadtree to a file
void Quadtree::writeQuadtree(std::shared_ptr<Quadtree> quadtree, std::string filePath){
    std::ofstream os(filePath, std::ios::binary);
    cereal::PortableBinaryOutputArchive oarchive(os);
    oarchive(quadtree);
}

//-------------------------
// readQuadtree
//-------------------------
// reads a quadtree to a file
std::shared_ptr<Quadtree> Quadtree::readQuadtree(std::string filePath){
    std::ifstream is(filePath, std::ios::binary);
    cereal::PortableBinaryInputArchive iarchive(is);
    Quadtree *quadtree = new Quadtree(-1,-1);
    std::shared_ptr<Quadtree> quadtreePtr(quadtree);
    iarchive(quadtreePtr);
    quadtreePtr->assignNeighbors(); //since we're not storing the neighbor relationships in the file we need to recalculate those.
    return(quadtreePtr);
}