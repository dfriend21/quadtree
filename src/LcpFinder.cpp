#include "LcpFinder.h"

#include <cmath>

// ------- constructors -------
LcpFinder::LcpFinder()
    : quadtree{nullptr}, startNode{nullptr}{}

LcpFinder::LcpFinder(std::shared_ptr<Quadtree> _quadtree, int startNodeID)
    : quadtree{_quadtree} {
    xMin = quadtree->root->xMin;
    xMax = quadtree->root->xMax;
    yMin = quadtree->root->yMin;
    yMax = quadtree->root->yMax;
    init(startNodeID);
}

LcpFinder::LcpFinder(std::shared_ptr<Quadtree> _quadtree, Point startPoint)
    : quadtree{_quadtree} {
    xMin = quadtree->root->xMin;
    xMax = quadtree->root->xMax;
    yMin = quadtree->root->yMin;
    yMax = quadtree->root->yMax;
    std::shared_ptr<Node> startNode = quadtree->getNode(startPoint);
    if(startNode){
        init(startNode->id);
    }
}

LcpFinder::LcpFinder(std::shared_ptr<Quadtree> _quadtree, int startNodeID, double _xMin, double _xMax, double _yMin, double _yMax, bool _includeNodesByCentroid)
    : quadtree{_quadtree}, xMin{_xMin}, xMax{_xMax}, yMin{_yMin}, yMax{_yMax}, includeNodesByCentroid{_includeNodesByCentroid} {
    init(startNodeID);
}

LcpFinder::LcpFinder(std::shared_ptr<Quadtree> _quadtree, Point startPoint, double _xMin, double _xMax, double _yMin, double _yMax, bool _includeNodesByCentroid)
    : quadtree{_quadtree}, xMin{_xMin}, xMax{_xMax}, yMin{_yMin}, yMax{_yMax}, includeNodesByCentroid{_includeNodesByCentroid} {
    std::shared_ptr<Node> startNode = quadtree->getNode(startPoint);
    if(startNode){ // only continue if the point falls in the quadtree
        init(startNode->id);
    }
}

// ------- init -------
// sets up the empty network we'll use when finding LCPs
void LcpFinder::init(int startNodeID){
    std::list<std::shared_ptr<Node>> nodes = quadtree->getNodesInBox(xMin, xMax, yMin, yMax, includeNodesByCentroid); // get all nodes in the search area
    nodeEdges = std::vector<std::shared_ptr<NodeEdge>>(nodes.size());
    
    dict = std::map<int, int>(); // dictionary with Node ID's as the key and the index of the corresponding 'NodeEdge' in 'nodeEdges'
    possibleEdges = std::multiset<std::tuple<int,int,double,double>, cmp>();
    if(nodes.size() > 0){ // only continue if there's at least one node in the search area
        int counter{0};
        bool hasStartNode{false}; // we'll use this to check if 'nodes' includes the start node
        for(auto iNode : nodes){ // loop over each node and create a 'NodeEdge' for each node
            if(iNode->id == startNodeID){ // check if this node is the same as 'startNode'
                hasStartNode = true;
            }
            NodeEdge *ne = new NodeEdge{counter, std::weak_ptr<Node>(iNode), std::weak_ptr<NodeEdge>(),0,0,0};
            nodeEdges.at(counter) = std::shared_ptr<NodeEdge>(ne);
            counter++;
        }
        if(hasStartNode){ // only continue if 'nodes' includes the start node - otherwise that means the start node falls outside of the specified search area
            dict = std::map<int, int>(); // dictionary with Node ID's as the key and the index of the corresponding 'NodeEdge' in 'nodeEdges'
            for(size_t i = 0; i < nodeEdges.size(); ++i){
                dict[nodeEdges.at(i)->node.lock()->id] = i; 
            }

            startNode = nodeEdges[dict[startNodeID]]->node.lock();
            if(!std::isnan(startNode->value)){ // if the starting node is NA, don't add it
                possibleEdges.insert(std::make_tuple(dict[startNode->id],dict[startNode->id], 0, 0)); // initialize our set with the start node
            }
        }
    }
}

// ------- doNextIteration -------
// performs one iteration of the shortest path algorithm
// returns the ID of the most recently added Node (note that it returns the ID of the Node, NOT the NodeEdge)
// returns -1 if no edge was added
int LcpFinder::doNextIteration(){
    auto beginItr = possibleEdges.begin();
    std::shared_ptr<NodeEdge> nodeEdge = nodeEdges.at(std::get<1>(*beginItr)); // get the edge that's at the front of the set
    auto parent = nodeEdge->parent.lock();
    if(parent){
        possibleEdges.erase(beginItr); 
        return -1;
    } else { // if the destination node already has a pointer for parent, it's already been included, so we'll skip this one - otherwise we'll set the 'parent' property of the destination node and then add the additional edge possibilities that result    
        nodeEdge->parent = std::weak_ptr<NodeEdge>(nodeEdges.at(std::get<0>(*beginItr))); // set the parent of the destination node to be the source node
        nodeEdge->nNodesFromOrigin = nodeEdges.at(std::get<0>(*beginItr))->nNodesFromOrigin + 1; // add 1 to the number of nodes from the origin of the parent
        nodeEdge->cost = std::get<2>(*beginItr); // assign the cost-distance to the NodeEdge
        nodeEdge->dist = std::get<3>(*beginItr); // assign the distance to the NodeEdge
        
        possibleEdges.erase(beginItr); // remove this edge from the list of possibilities

        // now we'll add the edges corresponding to this node's neighbors
        auto node = nodeEdge->node.lock();
        Point nodePoint = Point((node->xMin + node->xMax)/2, (node->yMin + node->yMax)/2); // make the point for the node by getting its centroid
        for(size_t i = 0; i < node->neighbors.size(); ++i){ // loop over each of its neighbors
            std::map<int,int>::iterator itr = dict.find(node->neighbors.at(i).lock()->id); // see if this neighbor is included in our dictionary - if not, then it must fall outside the extent
            if(itr != dict.end()){
                std::shared_ptr<NodeEdge> nodeEdgeNb = nodeEdges.at(itr->second);
                auto nodeNb = nodeEdgeNb->node.lock();
                if(!(nodeEdgeNb->parent.lock()) && !std::isnan(nodeNb->value)){ // check if this node already has a parent assigned i.e. has already been included in the network, or if this node is NAN
                    Point nbPoint = Point((nodeNb->xMin + nodeNb->xMax)/2, (nodeNb->yMin + nodeNb->yMax)/2);
                    
                    // get cost for the path - to do that we need to know the length of the segment in each cell
                    // first, figure out which side the two cells are adjacent on - this'll give us one coordinate for the intersection point (whether we know the x or y depends on which side they're adjacent on)
                    double mid{0};
                    bool isX = true; // tells us whether mid coordinate is an x-coordinate or a y-coordinate
                    if(node->xMin == nodeNb->xMax){ // left side
                        mid = node->xMin;
                    } else if(node->xMax == nodeNb->xMin) { // right side
                        mid = node->xMax;
                    } else if(node->yMin == nodeNb->yMax) { // bottom
                        mid = node->yMin;
                        isX = false;
                    } else if(node->yMax == nodeNb->yMin) { // top
                        mid = node->yMax;
                        isX = false;
                    }

                    double dist = std::sqrt(std::pow(nodePoint.x - nbPoint.x, 2) + std::pow(nodePoint.y - nbPoint.y, 2));
                    double ratio{0};
                    // now get the ratio between: {the difference between the known (x or y) mid-coordinate and the (x or y) coordinate of the starting point} and {the difference in the (x or y) coordinates of the two centroids}
                    if(isX){
                        double deltaX = nodePoint.x - nbPoint.x; // get the difference of the x coords
                        ratio = (nodePoint.x-mid)/deltaX;
                    } else {
                        double deltaY = nodePoint.y - nbPoint.y; // get the difference of the y coords
                        ratio = (nodePoint.y-mid)/deltaY;
                    }

                    // use the ratio we just calculated to get the length of the segment in each cell
                    double dist1 = dist * ratio;
                    double dist2 = dist - dist1;

                    // use those distances to get the cost, weighted by the length of the segment in each cell. Add this to the cost to get to 'nodeEdge' to get the total cost from the origin
                    double tot_cost = dist1*(node->value) + dist2*(nodeNb->value) + nodeEdge->cost; 
                    double tot_dist = dist + nodeEdge->dist;

                    possibleEdges.insert(std::make_tuple(nodeEdge->id, nodeEdgeNb->id,tot_cost,tot_dist));
                }
            }
        }
        return node->id;
    }
}


// ------- findLcp -------
// after the network as been fully or partially constructed using 'getLcp()' or  
// 'makeNetwork*()', finds the path from start node to the end node
// PAREMTERS:
//   endNodeID: the ID of the node we want to find a path to
// RETURNS:  a vector of tuples representing the steps of the shortest path. Each 
// tuple has three elements, in this order:
//    0 - pointer to the node  
//    1 - cumulative cost to reach this node
//    2 - cumulative distance to reach this node
std::vector<std::tuple<std::shared_ptr<Node>,double,double>> LcpFinder::findLcp(int endNodeID){
    std::map<int,int>::iterator itr = dict.find(endNodeID); //see if this node is included in our dictionary - if not, then it must fall outside our search extent
    if(itr != dict.end()){
        std::shared_ptr<NodeEdge> currentNodeEdge = nodeEdges.at(itr->second); //get the pointer to the nodeEdge that corresponds with the ID provided by the user
        
        if(currentNodeEdge->parent.lock()){ //if this NodeEdge doesn't have a parent then that means it's unreachable
            std::vector<std::tuple<std::shared_ptr<Node>,double,double>> nodePath(currentNodeEdge->nNodesFromOrigin); //initialize the vector that will store the nodes in the path. Use the 'nNodesFromOrigin' property of the destination NodeEdge to determine the size of the vector
            
            //starting with the end node, trace our way back to the start node
            for(size_t i = 1; i <= nodePath.size(); ++i){
                nodePath.at(nodePath.size()-i) = std::make_tuple(currentNodeEdge->node.lock(), currentNodeEdge->cost, currentNodeEdge->dist); //add the node to the vector - we'll fill the vector in reverse order so that the first element is the starting node and the last is the ending node
                currentNodeEdge = currentNodeEdge->parent.lock(); //set 'currentNodeEdge' to be this node's parent - this is how we'll move up the tree
            }
            return nodePath; //return the vector containing the nodes in the path
        }
    }
    return std::vector<std::tuple<std::shared_ptr<Node>,double,double>>(); //return an empty vector if it's not reachable
}

// ------- getLcp -------
// this function finds the shortest path to a specific node. As mentioned in the
// comments for 'makeNetworkAll()', the two functions are designed to work together. If the full network
// has already been calculated, then this function doesn't do any further calculation - it simply calls 
// 'findLcp()' to get the shortest path. If the full path hasn't been calculated, however, then it 
// runs the algorithm until it finds the desired shortest path.
// PARAMETERS: same as 'findLcp()'
// RETURNS: same as 'findLcp()'
std::vector<std::tuple<std::shared_ptr<Node>,double,double>> LcpFinder::getLcp(int endNodeID){
    std::map<int,int>::iterator itr = dict.find(endNodeID); // see if this node is included in our dictionary - if not, then it must fall outside our search extent
    if(itr != dict.end()){
        if(!nodeEdges.at(itr->second)->parent.lock()){ // check if we've already found the path to this node
            while(possibleEdges.size() != 0){ // if possibleEdges is 0 then we've added all the edges possible and we're done
                int currentID = doNextIteration();
                if(currentID == endNodeID){
                    break;
                }
            }
        }
        return findLcp(endNodeID);
    } else {
        return std::vector<std::tuple<std::shared_ptr<Node>,double,double>>();
    }
}

// this is just a wrapper around getLcp(int) that accepts a point instead of a node ID
std::vector<std::tuple<std::shared_ptr<Node>,double,double>> LcpFinder::getLcp(Point endPoint){
    std::shared_ptr<Node> node = quadtree->getNode(endPoint);
    if(node && !std::isnan(node->value)){ // only try to find the shortest path if the point falls in the quadtree and the value of the node isn't NA
        return getLcp(node->id);
    } else {
        return std::vector<std::tuple<std::shared_ptr<Node>,double,double>>();
    }
}

// ------- makeNetworkAll -------
// This function runs the shortest path algorithm exhaustively, meaning it finds all shortest paths to all nodes.
// This creates a 'network' of NodeEdges, which we can query with 'getLcp()' to get any single shortest
// path. This function and 'getLcp()' are designed to work together. 'getLcp()' stops when it reaches
// a certain node. But because the state of the algorithm is saved in 'possibleEdges', this algorithm can simply pick 
// up where 'getLcp()' left off, rather than recalculating everything. This is why I implemented the shortest
// functionality as a class - it lets me save the state of the algorithm in a way that I couldn't do with just a function.
void LcpFinder::makeNetworkAll(){
    while(possibleEdges.size() != 0){ //if possibleEdges is 0 then we've added all the edges possible and we're done
        doNextIteration();
    }
}

// ------- makeNetworkCostDist -------
// finds all LCPs below a given cost-distance value
void LcpFinder::makeNetworkCostDist(double constraint){
    while(possibleEdges.size() != 0){ // if possibleEdges is 0 then we've added all the edges possible and we're done
        int currentID = doNextIteration();
        int dictID = dict[currentID];
        if(nodeEdges[dictID]->cost > constraint){ // check if we've exceed the max resistance value - if so, remove the most recently added edge (since it exceeds the limit) and then break out of the loop
            
            // reinsert the most recent edge that was just removed from 'possibleEdges' back into 'possibleEdges'
            possibleEdges.insert(std::make_tuple(nodeEdges[dictID]->parent.lock()->id, nodeEdges[dictID]->id,nodeEdges[dictID]->cost,nodeEdges[dictID]->dist));
            
            // remove the most recently added edge from 'nodeEdges'
            nodeEdges[dictID]->parent = std::weak_ptr<NodeEdge>();
            nodeEdges[dictID]->dist = 0;
            nodeEdges[dictID]->cost = 0;
            nodeEdges[dictID]->nNodesFromOrigin = 0;
            break;
        }
    }
}
