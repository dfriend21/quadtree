#include "Matrix.h"
#include "Quadtree.h"
#include "Node.h"
//#include <Rcpp.h>
#include <iostream>
#include <fstream>
#include <vector>
#include <memory>
#include <cassert>
#include <string>
#include <algorithm>
#include <limits>
#include <cereal/archives/json.hpp>
#include <cereal/archives/portable_binary.hpp>
#include <cereal/archives/binary.hpp>
#include <cereal/types/memory.hpp>

// void destroyNode(std::shared_ptr<Node> node){
//     if(node->hasChildren){

//     }
// }
////////////////////////////////////////////////////////////////////////////////////////////////////////

Quadtree::Quadtree() 
    : Quadtree{0,0,0,0,0,0,0,0,0,0,0,""}{
    // std::cout << "Quadtree::Quadtree()\n";
    //: rangeLim{0}, nNodes{0}{
    //root = Node::makeNode(0,0,0,0,0,0,0)->ptr;
}

Quadtree::Quadtree(double _rangeLim, double _maxXCellLength, double _maxYCellLength) 
    : Quadtree{0,0,0,0,_rangeLim,0,0,0,0,0,0, "", _maxXCellLength, _maxYCellLength}{
    // std::cout << "Quadtree::Quadtree(double _rangeLim, double _maxXCellLength, double _maxYCellLength)\n";
    //: rangeLim{_rangeLim}, nNodes{0}{
    //root = Node::makeNode(0,0,0,0,0,0,0)->ptr;
}

Quadtree::Quadtree(double xMin, double xMax, double yMin, double yMax, double _rangeLim, double _maxXCellLength, double _maxYCellLength) 
    : Quadtree {xMin, xMax, yMin, yMax, _rangeLim, xMin, xMax, yMin, yMax, 0, 0, "", _maxXCellLength, _maxYCellLength}{
    // std::cout << "Quadtree::Quadtree(double xMin, double xMax, double yMin, double yMax, double _rangeLim, double _maxXCellLength, double _maxYCellLength)\n";
    // : rangeLim{_rangeLim}, nNodes{0}{
    //root = Node::makeNode(xMin, xMax, yMin, yMax, 0, 0, 0)->ptr;
}


//maxXLength -> the maximum cell size in the x-dimension. This means that any cell
//      that's bigger than this will be divided no matter what (unless ALL of the
//      values in the cell are NaN)
//maxYLength -> same as 'maxXLength', but for y
Quadtree::Quadtree(double xMin, double xMax, double yMin, double yMax, double _rangeLim, double _originalXMin, double _originalXMax, double _originalYMin, double _originalYMax, double _originalNX, double _originalNY, std::string _proj4string, double _maxXCellLength, double _maxYCellLength)
    : rangeLim{_rangeLim}, nNodes{0}, originalXMin{_originalXMin}, originalXMax{_originalXMax}, originalYMin{_originalYMin}, originalYMax{_originalYMax}, originalNX{_originalNX}, originalNY{_originalNY}, maxXCellLength{_maxXCellLength}, maxYCellLength{_maxYCellLength}, proj4string{_proj4string} {
    // std::cout << "Quadtree::Quadtree(double xMin, double xMax, double yMin, double yMax, double _rangeLim, double _originalXMin, double _originalXMax, double _originalYMin, double _originalYMax, double _originalNX, double _originalNY, std::string _proj4string, double _maxXCellLength, double _maxYCellLength)\n";
    root = std::make_shared<Node>(xMin,xMax,yMin,yMax,0,0,0);
    //root = Node::makeNode(xMin, xMax, yMin, yMax, 0, 0, 0)->ptr;
}

//wrapper for makeTree(Matrix, std::shared_ptr<Node>, int, int)
//this is the "outward-facing" function for creating a quadtree from a matrix - 
//it leaves out the last three parameters that are needed in the recursive 
//version so that users only need to give the matrix to the 'makeTree' function
//mat -> matrix used to build the quadtree. Should be divisible by 2 - ideally
//      the dimensions will be a result of 2^x. And it should be square. If
//      a matrix with dimensions not divisible by 2 is provided, the result
//      will be a quadtree with one node.
void Quadtree::makeTree(const Matrix &mat){
    // std::cout << "Quadtree::makeTree(const Matrix &mat)\n";
    originalNX = mat.nCol();
    originalNY = mat.nRow();
    // if the value for max length is less than 0 (default is -1) then set the max length for both dimensions to be the user-defined dimensions. This essentially sets no restriction on the cell size
    if(maxXCellLength < 0) maxXCellLength = root->xMax - root->xMin; 
    if(maxYCellLength < 0) maxYCellLength = root->yMax - root->yMin;
    nNodes = makeTree(mat, root, 0, 0) + 1; //the ID that is returned from 'makeTree' also corresponds to the number of nodes created. Add 1 to get the count (since the ID starts at 0)
    assignNeighbors(); //assign neighbors for the cells    
}

//recursive function for creating a tree
//checks a single node and decides whether or not to split this node
//mat -> matrix used to build the quadtree
//node -> pointer to the node we want to try splitting into 4
//id -> current ID
//level -> the 'level' of this node
int Quadtree::makeTree(const Matrix &mat, const std::shared_ptr<Node> node, int id, int level){
    // std::cout << "Quadtree::makeTree(const Matrix &mat, const std::shared_ptr<Node> node, int id, int level)\n";
    // std::cout << "---- CHECK 0 ----\n";
    //Matrix mat = mat.flipRows();
    //mat.flipRows();
    //assign values to our node
    node->value = mat.mean();
    node->level = level;
    node->id = id;
    
    //level = _level;
    //smallestChildSideLength = sideLength; // this will get changed if it ends up having children
    //root = _root;
    double dif = mat.max() - mat.min(); // get the difference between the max and min cells in this node
    //Rcpp::Rcout << dif << std::endl;
    int newid{id};// ? - not sure if this is necessary - can I just use 'id'?
    //decide whether or not to split on two conditions - whether the cell can be divided evenly into four children, and whether the difference between the min and max exceeds the user-specified threshold
    //if(mat.nRow()%2 == 0 && mat.nCol()%2 == 0 && dif >= rangeLim){ 
    double x_length = node->xMax - node->xMin;
    double y_length = node->yMax - node->yMin;
    int nNans = mat.countNans();
    // std::cout << "---- CHECK 1 ----\n";
    //to split the cell, the following conditions must be met:
    if((mat.nRow()%2 == 0 && mat.nCol()%2 == 0) // the # of cells in both dimensions must be divisible by two AND
        && nNans != mat.size() // there is at least one non-Nan value in the matrix AND at least one of the following four conditions is true:
        && (dif >= rangeLim // { the difference between the max and min values exceeds the user-defined threshold OR
            || x_length > maxXCellLength // the x side length is greater than the user-defined maximum length OR
            || y_length > maxYCellLength //the y side length is greater than the user-defined maximum length OR
            || nNans > 0 )){ // there is at least one Nan }
        node->hasChildren = true;
        double cell_x_len = (node->xMax - node->xMin)/2;//get the side length of the cells
        double cell_y_len = (node->yMax - node->yMin)/2;
        // std::cout << "---- CHECK 2 ----\n";
        //loop over each child and create a node for each one - and, if the conditions are met, split the children
        for(int r = 0; r < 2; ++r){
            for(int c = 0; c < 2; ++c){
                // std::cout << "---- CHECK 3 ----\n";
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
                
                // std::cout << "---- CHECK 4 ----\n";
                int child_index = (1-r)*2 + c; //get the index (from 0 to 3) of this child in the parent's 'children' vector
                Matrix sub = mat.subset(r_beg,r_end,c_beg,c_end); //get the matrix of values that this cell contains
                
                // std::cout << "---- CHECK 5 ----\n";
                // std::cout << child_index << "\n";
                // std::cout << node->children.size() << "\n";
                //node->children[child_index] = Node::makeNode(x_min, x_max, y_min, y_max, mat.mean(), id, level); //create the node
                node->children.at(child_index) = std::make_shared<Node>(x_min, x_max, y_min, y_max, mat.mean(), id, level); //create the node
                // std::cout << "---- CHECK 6 ----\n";
                newid = makeTree(sub, node->children[child_index], newid+1, level+1); //recursively call 'makeTree' on this node, making sure to increment the 'id' and the 'level'
                // std::cout << "---- CHECK 7 ----\n";
            }
            // std::cout << "---- CHECK 8 ----\n";
        }
        // std::cout << "---- CHECK 9 ----\n";
        //check its children to get the smallest child side length
        for(size_t i = 0; i < node->children.size(); ++i){
            if(node->children[i]->smallestChildSideLength < node->smallestChildSideLength){
                // std::cout << "---- CHECK 10 ----\n";
                node->smallestChildSideLength = node->children[i]->smallestChildSideLength;
                // std::cout << "---- CHECK 11 ----\n";
            }
            // std::cout << "---- CHECK 12 ----\n";
        }
        // std::cout << "---- CHECK 13 ----\n";
    }
    // std::cout << "---- CHECK 14 ----\n";
    return newid;
}

//THOUGHT: Use getNode, and then just return the value? Then I don't have two nearly identical functions
//recursively finds the value at a given (x,y) location. Checks if this point falls
//within it's boundaries - if it does, and it doesn't have children, returns the
//value of this node. If it does have children, it calls the function on the 
//child that contains the point.
//x -> x coordinate
//y -> y coordinate
//node-> pointer 
double Quadtree::getValue(double x, double y, const std::shared_ptr<Node> node) const{
    // std::cout << "Quadtree::getValue(double x, double y, const std::shared_ptr<Node> node)\n";
    if( (x < node->xMin) | (x > node->xMax) | (y < node->yMin) | (y > node->yMax) ){ //check to make sure the point falls within our extent
        //return -999; //if not, return NULL
        return std::numeric_limits<double>::quiet_NaN(); //if the point doesn't fall within the quadtree, return NaN
    }
    if(node->hasChildren){ //if it has children, then we need to keep going
        int childIndex {node->getChildIndex(x,y)};
        return getValue(x,y,node->children[childIndex]);
    }
    return node->value; //if it doesn't have children, then we're at the bottom "level", so return the value of this node
}

//user-friendly wrapper for quadtree so that 'node' doesn't need to be specified
//(automatically uses the root)
double Quadtree::getValue(double x, double y) const{
    // std::cout << "Quadtree::getValue(double x, double y)\n";
    return getValue(x,y,root);
}

//returns the node at a given (x,y) location
//works exactly the same as 'getValue' except returns a pointer to the node
//instead of the value of the node
std::shared_ptr<Node> Quadtree::getNode(double x, double y, const std::shared_ptr<Node> node) const{
    // std::cout << "Quadtree::getNode(double x, double y, const std::shared_ptr<Node> node)\n";
    if( (x < node->xMin) | (x > node->xMax) | (y < node->yMin) | (y > node->yMax) ){ //check to make sure the point falls within our extent
        return nullptr; //if not, return NULL
    }
    if(node->hasChildren){ //if it has children, then we need to keep going
        int childIndex {node->getChildIndex(x,y)};
        return getNode(x,y,node->children[childIndex]);
    }
    // return node->ptr; //if it doesn't have children, then we're at the bottom "level", so return the value of this Quadtree
    return node; //if it doesn't have children, then we're at the bottom "level", so return the value of this Quadtree
}

std::shared_ptr<Node> Quadtree::getNode(double x, double y) const{
    // std::cout << "Quadtree::getNode(double x, double y)\n";
    return getNode(x,y,root);
}



std::list<std::shared_ptr<Node>> Quadtree::getNodesInBox(double xMin, double xMax, double yMin, double yMax){
    // std::cout << "Quadtree::getNodesInBox(double xMin, double xMax, double yMin, double yMax)\n";
    std::list<std::shared_ptr<Node>> returnNodes;
    getNodesInBox(root, returnNodes, xMin, xMax, yMin, yMax);
    return returnNodes;
}

void Quadtree::getNodesInBox(std::shared_ptr<Node> node, std::list<std::shared_ptr<Node>> &returnNodes, double xMin, double xMax, double yMin, double yMax){
    // std::cout << "Quadtree::getNodesInBox(std::shared_ptr<Node> node, std::list<std::shared_ptr<Node>> &returnNodes, double xMin, double xMax, double yMin, double yMax)\n";
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

//finds which nodes are adjacent to this node
//operates by creating a set of points just outside the boundary of the node 
//(the distance between each point, and thus the number of points, is determined
//by the smallest child side length). Essentially, using our knowledge of the 
//size of the smallest child, checks around the node in every possible place 
//a neighbor would be if the surrounding cells were the size of the smallest 
//cell in the quadtree. Then it removes duplicates to get the list of neighbors.
//note that this function is a member function of 'Quadtree' and not 'Node' 
//because to do this we need knowledge of the *whole* tree, including a node's 
//parents
//node -> pointer to the node for which we want to find neighbors
//searchSideLength -> the distance between the points that we'll use to check
//  for neighbors
//returns a vector of pointers to the neighboring nodes
//std::vector<std::weak_ptr<Node>> Quadtree::findNeighbors(const std::shared_ptr<Node> node, double searchSideLength) const{
std::vector<std::shared_ptr<Node>> Quadtree::findNeighbors(const std::shared_ptr<Node> node, double searchSideLength) const{
    // std::cout << "Quadtree::findNeighbors(const std::shared_ptr<Node> node, double searchSideLength)\n";
    // std::cout << "++++ CHECK 0 ++++\n";
    //std::cout << node->toString() << std::endl;
    int nCheckPerSide = (node->xMax - node->xMin)/searchSideLength + 2; //based on our knowledge of the side length of the smallest child, figure out how many points on each side we need to chekc - plus two so that we get the "diagonal" neighbors as well
    //std::cout << nCheckPerSide << std::endl;
    // std::cout << "++++ CHECK 1 ++++\n";
    // std::cout << "node->xMax: " << node->xMax << " | node->xMin: " << node->xMin << " | searchSideLength: " << searchSideLength << "\n";
    // std::cout << nCheckPerSide << "\n";
    std::vector<std::shared_ptr<Node>> nb(4*(nCheckPerSide-1),nullptr); //create a vector to store the nodes we get
    //std::vector<std::weak_ptr<Node>> nb(4*(nCheckPerSide-1)); //create a vector to store the nodes we get
    //std::vector<std::shared_ptr<Node>> nb; //create a vector to store the nodes we get
    // std::cout << "++++ CHECK 2 ++++\n";
    int counter{0}; //keeps track of how many nodes we've added to the list so far - used to index the list
    //essentially what we're doing here is checking a grid of points based on the number of points we're checking. Most of the points in this grid will fall inside the cell - so we'll only check the points that border the cell
    for(int x = -1; x < nCheckPerSide-1; ++x){
        // std::cout << "++++ CHECK 3 ++++\n";
        for(int y = -1; y < nCheckPerSide-1; ++y){
            // std::cout << "++++ CHECK 4 ++++\n";
            if( (x == -1) | (x == nCheckPerSide-2) | (y == -1) | (y == nCheckPerSide-2)){ //we only want to check the cells that fall outside this cell - this means ignoring the "interior points" - the ones that fall inside this cell.
                //get the x and y coordinates to check
                // std::cout << "++++ CHECK 5 ++++\n";
                double x_temp{node->xMin + x*searchSideLength + searchSideLength/2};
                double y_temp{node->yMin + y*searchSideLength + searchSideLength/2};
                //std::cout << "(" << x_temp << "," << y_temp << ")" << std::endl;
                // std::cout << "++++ CHECK 6 ++++\n";
                nb.at(counter) = getNode(x_temp, y_temp, root); //add the pointer of the node we retrieved to our vector
                //nb.emplace_back(getNode(x_temp, y_temp, root));
                // std::cout << "++++ CHECK 7 ++++\n";
                ++counter; //since we added a node to our vector, increment the counter
                // std::cout << "++++ CHECK 8 ++++\n";
            }
            // std::cout << "++++ CHECK 9 ++++\n";
        }
        // std::cout << "++++ CHECK 10 ++++\n";
    }
    // std::cout << "++++ CHECK 11 ++++\n";

    // !!!!!!!!!! MEMORY LEAK !!!!!!!!!!! I'm pretty sure one of the next three lines is causing a memory leak. - UPDATE - I'm actually not so sure about this anymore
    nb.erase(std::remove(std::begin(nb), std::end(nb), nullptr),std::end(nb)); //delete null pointers - this will happen if the cell is on the edge of the quadtree, as it'll end up checking points that fall outside of the quadtree.
    // std::cout << "++++ CHECK 12 ++++\n";
    std::sort( nb.begin(), nb.end() ); //this line and the next remove duplicates - https://stackoverflow.com/questions/1041620/whats-the-most-efficient-way-to-erase-duplicates-and-sort-a-vector
    // std::cout << "++++ CHECK 13 ++++\n";
    nb.erase( unique( nb.begin(), nb.end() ), nb.end() );
    // std::cout << "++++ CHECK 14 ++++\n";
    return nb;
}

//wrapper function for 'findNeighbors' that travels recursively through the tree
//and uses 'findNeighbors' on each node to find its neighbors. Populates the 
//'neighbors' vector of each Node
void Quadtree::assignNeighbors(const std::shared_ptr<Node> node){
    // std::cout << "Quadtree::assignNeighbors(const std::shared_ptr<Node> node)\n";
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

    //node->neighbors = findNeighbors(node, root->smallestChildSideLength);
}

//user-friendly wrapper function for 'assignNeighbors' where no arguments are 
//needed - automatically uses 'assignNeighbors' on the root
void Quadtree::assignNeighbors(){
    // std::cout << "Quadtree::assignNeighbors\n";
    assignNeighbors(root);
}




// std::vector<std::shared_ptr<Node>> getSubset(double xMin, double xMax, double yMin, double yMax) const{
    
// }
// std::vector<std::shared_ptr<Node>> getSubset(std::shared_ptr<Node> node, double xMin, double xMax, double yMin, double yMax) const{
//     //check if the "square" we want to retrieve intersects with this node
//     bool isXMinValid = xMin > node->xMin && xMin < node->xMax;
//     bool isXMaxValid = xMax > node->xMin && xMax < node->xMax;
//     bool isYMinValid = yMin > node->yMin && yMin < node->yMax;
//     bool isYMaxValid = yMax > node->yMin && yMax < node->yMax;
//     if(isInX && isInY){
//         if(node->hasChildren){
//             for(size_t i = 0; i < node->children.size(); i++){
//                 getSubset(node->children[i])
//             }
//         }
//     }

//     if(isXMinValid && isXMaxValid && isYMinValid && isYMaxValid){ //in this case the "box" is fully contained within this node
        
//     }
// }


// //bool isReachable(Point startPoint, point endPoint, double distance) const{
// bool Quadtree::isReachable(double x1, double y1, double x2, double y2, double distance) const{
//     std::shared_ptr<Node> startNode = getNode(x1, y1);
//     std::shared_ptr<Node> endNode = getNode(x2, y2);
//     if(!(startNode && endNode)){ //if either of the pointers are null, return false
//         return false;
//     }
//     if(MathUtilities)
//     if(startNode->id == endNode->id){ //in this case they're in the same cell
//         return true;
//     } else { //otherwise check if they're neighbors
//         for(size_t i = 0; i < endNode->neighbors.size(); ++i){ //so long as the neighbors have been assigned correctly I could do this for either startNode or endNode
//             if(endNode->neighbors.at(i)->id == startNode->id){
//                 return true;
//             }
//         }
//     } else { // otherwise we've got some work to do - we'll recursively start checking the neighbors to see if there's a valid path between the two points - starting at the end point
//         std::list<int> prevIds;
//         return doesPathExist(endNode, startNode->id, x1-distance, x1+distance, y1-distance, y1+distance, prevIds) //I think this should be a separate function since we don't want to do the checks I did above each time. It should recursively traverse over all the valid neighbors
//     }
// }

// bool Quadtree::doesPathExist(std::shared_ptr<Node> node, int endNodeId, double xMin, double xMax, double yMin, double yMax, std::list<int> &prevIds){
//     //bool foundNode = false;
//     if(node->neighbors.size() > 0){
//         for(size_t i = 0; i < node->neighbors.size(); ++i){
//             if(std::find(prevIds.begin(), prevIds.end(), node->neighbors.at(i)->id) == prevIds.end()){ //check if we've already iterated over this node - https://www.techiedelight.com/check-vector-contains-given-element-cpp
//                 prevIds.push_back(node->neighbors.at(i)->id); //add this ID to our list of IDs we've checked
//                 if(node->neighbors.at(i)->id == endNodeId){ //if this is the end node, we're done.
//                     return true;
//                 } else { //otherwise check this nodes neighbors
//                     //make sure this cell overlaps with the square defined by our min and max coords
//                     bool isXValid = !(xMax < node->xMin || xMin > node->xMax);
//                     bool isYValid = !(yMax < node->yMin || yMin > node->yMax);
//                     if(isXValid && isYValid){
//                         //return doesPathExist(node->neighbors.at(i), endNodeId, xMin, xMax, yMin, yMax, prevIds);
//                         bool foundNode = doesPathExist(node->neighbors.at(i), endNodeId, xMin, xMax, yMin, yMax, prevIds);
//                         if(foundNode) return true;
//                     }
//                 }
//             } 
//         }
//         return false;
//     } else {
//         return false;
//     }

// }
//creates a string representation of the tree
//recursive travels the tree and returns a string for each node, indented so
//that it resembles a tree structure
//node -> the node we want to make a string for
//prefix -> characters that will precede the node information
std::string Quadtree::toString(const std::shared_ptr<Node> node, const std::string prefix) const{
    // std::cout << "Quadtree::toString(const std::shared_ptr<Node> node, const std::string prefix)\n";
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
    // std::cout << "Quadtree::toString()\n";
    std::string str("");
    str = str + 
        "rangeLim: " + std::to_string(rangeLim) + "\n" +
        "nNodes: " + std::to_string(nNodes) + "\n" +
        toString(root, "") + "\n";
    return str;
}

//function used to serialize the a Quadtree (via 'cereal')
// template<class Archive>
// void Quadtree::serialize(Archive & archive){
//     archive(rangeLim,nNodes,root);
// }

void Quadtree::writeQuadtree(std::shared_ptr<Quadtree> quadtree, std::string filePath){
    // std::cout << "Quadtree::writeQuadtree(std::shared_ptr<Quadtree> quadtree, std::string filePath)\n";
    std::ofstream os(filePath, std::ios::binary);
    cereal::PortableBinaryOutputArchive oarchive(os);
    oarchive(quadtree);
}

// void Quadtree::writeQuadtree(Quadtree &quadtree, std::string filePath){
//     std::ofstream os(filePath, std::ios::binary);
//     cereal::PortableBinaryOutputArchive oarchive(os);
//     // cereal::BinaryOutputArchive oarchive(os);
//     // cereal::JSONOutputArchive oarchive(os);
//     oarchive(quadtree);
// }

std::shared_ptr<Quadtree> Quadtree::readQuadtree(std::string filePath){
    // std::cout << "Quadtree::readQuadtree(std::string filePath)\n";
    std::ifstream is(filePath, std::ios::binary);
    cereal::PortableBinaryInputArchive iarchive(is);
    Quadtree *quadtree = new Quadtree();
    std::shared_ptr<Quadtree> quadtreePtr(quadtree);
    iarchive(quadtreePtr);
    quadtreePtr->assignNeighbors(); //since we're not storing the neighbor relationships in the file we need to recalculate those.
    return(quadtreePtr);
}

// Quadtree Quadtree::readQuadtree(std::string filePath){
//     std::cout << "check0\n";
//     std::ifstream is(filePath, std::ios::binary);
//     std::cout << "check1\n";
//     cereal::PortableBinaryInputArchive iarchive(is);
//     std::cout << "check2\n";
//     // cereal::BinaryInputArchive iarchive(is);
//     // cereal::JSONInputArchive iarchive(is);
//     Quadtree quadtree = Quadtree();
//     std::cout << "check3\n";
//     //std::shared_ptr<Quadtree> quadtreePtr(quadtree);
//     iarchive(quadtree);
//     std::cout << "check4\n";
//     return(quadtree);
//     // std::shared_ptr<Quadtree> quadtreePtr(quadtree);
//     // return(quadtreePtr);
// }