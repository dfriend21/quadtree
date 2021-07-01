#include "ShortestPathFinder.h"
#include "PointUtilities.h"


ShortestPathFinder::ShortestPathFinder()
    : quadtree{nullptr}, startNode{nullptr}, isValid{false} {}//, startPoint{-1,-1}{}

ShortestPathFinder::ShortestPathFinder(std::shared_ptr<Quadtree> _quadtree, int startNodeID)
    : quadtree{_quadtree} {
    xMin = quadtree->root->xMin;
    xMax = quadtree->root->xMax;
    yMin = quadtree->root->yMin;
    yMax = quadtree->root->yMax;
    init(startNodeID);
}

ShortestPathFinder::ShortestPathFinder(std::shared_ptr<Quadtree> _quadtree, Point _startPoint)
    : quadtree{_quadtree} {
    xMin = quadtree->root->xMin;
    xMax = quadtree->root->xMax;
    yMin = quadtree->root->yMin;
    yMax = quadtree->root->yMax;
    std::shared_ptr<Node> startNode = quadtree->getNode(_startPoint.x, _startPoint.y);
    if(startNode){
        init(startNode->id);
    }
}


// ShortestPathFinder::ShortestPathFinder(std::shared_ptr<Quadtree> _quadtree, int startNodeID)
//     : ShortestPathFinder(_quadtree, startNodeID, _quadtree->root->xMin, _quadtree->root->xMax, _quadtree->root->yMin, _quadtree->root->yMax){}

ShortestPathFinder::ShortestPathFinder(std::shared_ptr<Quadtree> _quadtree, int startNodeID, double _xMin, double _xMax, double _yMin, double _yMax)
    : quadtree{_quadtree}, xMin{_xMin}, xMax{_xMax}, yMin{_yMin}, yMax{_yMax} {
    init(startNodeID);
}

ShortestPathFinder::ShortestPathFinder(std::shared_ptr<Quadtree> _quadtree, Point _startPoint, double _xMin, double _xMax, double _yMin, double _yMax)
    : quadtree{_quadtree}, xMin{_xMin}, xMax{_xMax}, yMin{_yMin}, yMax{_yMax} {

    std::shared_ptr<Node> startNode = quadtree->getNode(_startPoint.x, _startPoint.y);
    if(startNode){ //only continue if the point falls in the quadtree
        init(startNode->id);
    }
}

void ShortestPathFinder::init(int startNodeID){
    isValid = true; //since we've reached 'init()' we're going to assume that the starting point/node was valid
        //std::shared_ptr<Node> endNode = qt.getNode(endPoint.x, endPoint.y);
    std::list<std::shared_ptr<Node>> nodes = quadtree->getNodesInBox(xMin, xMax, yMin, yMax);
    // std::vector<std::shared_ptr<NodeEdge>> nodeEdges(nodes.size());
    nodeEdges = std::vector<std::shared_ptr<NodeEdge>>(nodes.size());
    //std::list<std::shared_ptr<Node>>::iterator itr = nodes.begin();
    //for(size_t i = 0; i < nodes.size(); ++i){

    int counter{0};
    for(auto iNode : nodes){
        // NodeEdge *ne = new NodeEdge{counter, iNode, nullptr,0,0,0};
        NodeEdge *ne = new NodeEdge{counter, std::weak_ptr<Node>(iNode), std::weak_ptr<NodeEdge>(),0,0,0};
        nodeEdges.at(counter) = std::shared_ptr<NodeEdge>(ne);
        // nodeEdges.at(counter) = std::make_shared<NodeEdge>(counter, std::weak_ptr<Node>(iNode), std::weak_ptr<NodeEdge>(),0,0,0);
        //nodeEdges.emplace_back(makeNodeEdge(iNode, nullptr));
        counter++;
    }
    
    //std::map<int, int> dict; //dictionary with Node ID's as the key and the index of the corresponding 'NodeEdge' in 'nodeEdges'
    //int counter{0};
    dict = std::map<int, int>(); //dictionary with Node ID's as the key and the index of the corresponding 'NodeEdge' in 'nodeEdges'
    for(size_t i = 0; i < nodeEdges.size(); ++i){
        dict[nodeEdges.at(i)->node.lock()->id] = i; // ORIGINAL

        // auto node = nodeEdges.at(i)->node.lock();
        // if(!std::isnan(node->value)){
        //     dict[node->id] = i; 
        // }
    }

    //std::shared_ptr<Node> startNode = quadtree.getNode(startPoint.x, startPoint.y);
    startNode = nodeEdges[dict[startNodeID]]->node.lock();
    //startPoint = Point((startNode->xMin + startNode->xMax)/2, (startNode->yMin + startNode->yMax)/2);
    // std::set<std::tuple<int,int,double>> possibleEdges; //order of tuple is nodeEdge ID 1, nodeEdge ID 2, dist between the nodes
    //https://stackoverflow.com/questions/2620862/using-custom-stdset-comparator
    //auto cmp = [](std::tuple<int,int,double> a, std::tuple<int,int,double> b) { return std::get<2>(a) < std::get<2>(b); };
    possibleEdges = std::multiset<std::tuple<int,int,double,double>, cmp>();
    //auto startNodeShared = startNode.lock();
    possibleEdges.insert(std::make_tuple(dict[startNode->id],dict[startNode->id], 0, 0)); //initialize our set with the start node
}

//performs one iteration of the shortest path algorithm
//returns the ID of the most recently added Node (note that it returns the ID of the Node, NOT the NodeEdge)
//returns -1 if no edge was added
int ShortestPathFinder::doNextIteration(){
    auto beginItr = possibleEdges.begin();
    std::shared_ptr<NodeEdge> nodeEdge = nodeEdges.at(std::get<1>(*beginItr)); //get the edge that's at the front of the set
    auto parent = nodeEdge->parent.lock();
    if(parent){
        possibleEdges.erase(beginItr); 
        return -1;
    } else { //if the destination node already has a pointer for parent, it's already been included, so we'll skip this one - otherwise we'll set the 'parent' property of the destination node and then add the additional edge possibilities that result    
        nodeEdge->parent = std::weak_ptr<NodeEdge>(nodeEdges.at(std::get<0>(*beginItr))); //set the parent of the destination node to be the source node
        // nodeEdge->nNodesFromOrigin = nodeEdge->parent->nNodesFromOrigin + 1; //add 1 to the number of nodes from the origin of the parent
        nodeEdge->nNodesFromOrigin = nodeEdges.at(std::get<0>(*beginItr))->nNodesFromOrigin + 1;
        nodeEdge->cost = std::get<2>(*beginItr); //assign the cost-distance to the NodeEdge
        nodeEdge->dist = std::get<3>(*beginItr); //assign the distance to the NodeEdge
        
        possibleEdges.erase(beginItr); //remove this edge from the list of possibilities

        // if(nodeEdge->node->id == endNode->id){ //if the NodeEdge we just modified is the endNode, then we're done, and we can stop
        //     break;
        // }
        //now we'll add the edges corresponding to this node's neighbors
        auto node = nodeEdge->node.lock();
        Point nodePoint = Point((node->xMin + node->xMax)/2, (node->yMin + node->yMax)/2); //make the point for the node by getting its centroid
        for(size_t i = 0; i < node->neighbors.size(); ++i){ //loop over each of its neighbors
            //if(nodeEdge)
            std::map<int,int>::iterator itr = dict.find(node->neighbors.at(i).lock()->id); //see if this neighbor is included in our dictionary - if not, then it must fall outside the extent
            if(itr != dict.end()){
                //int nodeEdgeIndex = itr->second;
                std::shared_ptr<NodeEdge> nodeEdgeNb = nodeEdges.at(itr->second);
                auto nodeNb = nodeEdgeNb->node.lock();
                if(!(nodeEdgeNb->parent.lock()) && !std::isnan(nodeNb->value)){ //check if this node already has a parent assigned i.e. has already been included in the network, or if this node is NAN
                    Point nbPoint = Point((nodeNb->xMin + nodeNb->xMax)/2, (nodeNb->yMin + nodeNb->yMax)/2);
                    //get cost for path - to do that we need to know the length of the segment in each cell

                    //first, figure out which side the two cells are adjacent on - this'll give us one coordinate for the intersection point (whether we know the x or y depends on which side they're adjacent on)
                    double mid{0};
                    bool isX = true; //tells us whether mid coordinate is an x-coordinate or a y-coordinate
                    if(node->xMin == nodeNb->xMax){ //left side
                        mid = node->xMin;
                    } else if(node->xMax == nodeNb->xMin) { //right side
                        mid = node->xMax;
                    } else if(node->yMin == nodeNb->yMax) { //bottom
                        mid = node->yMin;
                        isX = false;
                    } else if(node->yMax == nodeNb->yMin) { //top
                        mid = node->yMax;
                        isX = false;
                    }


                    double dist = PointUtilities::distBtwPoints(nodePoint, nbPoint); //get the distance between the two centroids
                    double ratio{0};
                    //now get the ratio between: {the difference between the known (x or y) mid-coordinate and the (x or y) coordinate of the starting point} and {the difference in the (x or y) coordinates of the two centroids}
                    if(isX){
                        double deltaX = nodePoint.x - nbPoint.x; //get the difference of the x coords
                        ratio = (nodePoint.x-mid)/deltaX;
                    } else {
                        double deltaY = nodePoint.y - nbPoint.y; //get the difference of the y coords
                        ratio = (nodePoint.y-mid)/deltaY;
                    }

                    //use the ratio we just calculated to get the length of the segment in each cell
                    double dist1 = dist * ratio;
                    double dist2 = dist - dist1;

                    //use those distances to get the cost, weighted by the length of the segment in each cell. Add this to the cost to get to 'nodeEdge' to get the total cost from the origin
                    double tot_cost = dist1*(node->value) + dist2*(nodeNb->value) + nodeEdge->cost; 
                    double tot_dist = dist + nodeEdge->dist;

                    possibleEdges.insert(std::make_tuple(nodeEdge->id, nodeEdgeNb->id,tot_cost,tot_dist));
                }
            }
        }
        return node->id;
    }
}


//after the network as been fully or partially constructed using 'makeShortestPathNetwork()' or 'getShortestPath()', 
//finds the path from start node to the end node
//The return value is a vector of tuples representing the steps of the 
//shortest path. Each tuple has three elements, in this order:
//      0 - pointer to the node  
//      1 - cumulative cost to reach this node
//      2 - 
std::vector<std::tuple<std::shared_ptr<Node>,double,double>> ShortestPathFinder::findShortestPath(int endNodeID){
    std::shared_ptr<NodeEdge> currentNodeEdge = nodeEdges.at(dict[endNodeID]); //get the pointer to the nodeEdge that corresponds with the ID provided by the user
    //auto parent = currentNodeEdge->parent.lock();
    if(currentNodeEdge->parent.lock()){ //if this NodeEdge doesn't have a parent then that means it's unreachable
    //if(parent){ //if this NodeEdge doesn't have a parent then that means it's unreachable
        //std::vector<std::shared_ptr<Node>> nodePath(currentNodeEdge->nNodesFromOrigin); //initialize the vector that will store the nodes in the path. Use the 'nNodesFromOrigin' property of the destination NodeEdge to determine the size of the vector
        std::vector<std::tuple<std::shared_ptr<Node>,double,double>> nodePath(currentNodeEdge->nNodesFromOrigin);//initialize the vector that will store the nodes in the path. Use the 'nNodesFromOrigin' property of the destination NodeEdge to determine the size of the vector
        //starting with the end node, trace our way back to the start node
        for(size_t i = 1; i <= nodePath.size(); ++i){
            //nodePath.at(i) = currentNodeEdge->node;
            //nodePath.at(nodePath.size()-i) = currentNodeEdge->node; //add the node to the vector - we'll fill the vector in reverse order so that the first element is the starting node and the last is the ending node
            nodePath.at(nodePath.size()-i) = std::make_tuple(currentNodeEdge->node.lock(), currentNodeEdge->cost, currentNodeEdge->dist); //add the node to the vector - we'll fill the vector in reverse order so that the first element is the starting node and the last is the ending node
            currentNodeEdge = currentNodeEdge->parent.lock(); //set 'currentNodeEdge' to be this node's parent - this is how we'll move up the tree
        }
        return nodePath; //return the vector containing the nodes in the path
    }

    //return std::vector<std::shared_ptr<Node>>(); //return an empty vector if it's not reachable
    //return std::vector<NodeEdge>(); //return an empty vector if it's not reachable
    return std::vector<std::tuple<std::shared_ptr<Node>,double,double>>(); //return an empty vector if it's not reachable
}


//this function runs the shortest path algorithm exhaustively, meaning it finds all shortest paths to all nodes
//this creates a 'network' of NodeEdges, which we can query with 'getShortestPath()' to get any single shortest
//path. This function and 'getShortestPath()' are designed to work together. 'getShortestPath()' stops when it reaches
//a certain node. But because the state of the algorithm is saved in 'possibleEdges', this algorithm can simply pick 
//up where 'getShortestPath()' left off, rather than recalculating everything. This is why I implemented the shortest
//functionality as a class - it lets me save the state of the algorithm in a way that I couldn't do with just a function.
// void ShortestPathFinder::makeShortestPathNetwork(){
void ShortestPathFinder::makeNetworkAll(){
    while(possibleEdges.size() != 0){ //if possibleEdges is 0 then we've added all the edges possible and we're done
        doNextIteration();
    }
}

// //'ConstDist' is short for "constrained by distance"
// void ShortestPathFinder::makeShortestPathNetworkConstDist(double maxResistance){
//     while(possibleEdges.size() != 0){ //if possibleEdges is 0 then we've added all the edges possible and we're done
//         int currentID = doNextIteration();
//         //std::shared_ptr<NodeEdge> ne = nodeEdges.at(dict[currentID]);
//         if(nodeEdges.at(dict[currentID])->cost > maxResistance){ //check if we've exceed the max resistance value - if so, remove the most recently added edge (since it exceeds the limit) and then break out of the loop
//             nodeEdges.at(dict[currentID])->parent = std::weak_ptr<NodeEdge>();
//             nodeEdges.at(dict[currentID])->dist = 0;
//             nodeEdges.at(dict[currentID])->cost = 0;
//             nodeEdges.at(dict[currentID])->nNodesFromOrigin = 0;
//             break;
//         }
//     }
// }

// void ShortestPathFinder::makeNetworkDist(double constraint){
//     while(possibleEdges.size() != 0){ //if possibleEdges is 0 then we've added all the edges possible and we're done
//         int currentID = doNextIteration();
//         //std::shared_ptr<NodeEdge> ne = nodeEdges.at(dict[currentID]);
//         int dictID = dict[currentID];
//         if(nodeEdges[dictID]->dist > constraint){ //check if we've exceed the max resistance value - if so, remove the most recently added edge (since it exceeds the limit) and then break out of the loop
            
//             //PROBLEM!!!!!!!!!! Doing this messes things up for the future. In 'doNextIteration()' we've already removed the 
//             //front-most edge from 'possibleEdges'. Now we're taking this edge out of 'nodeEdges' BUT we're not putting the 
//             //option back into 'possibleEdges' - so that edge won't be re-added if we run the algorithm again. This problem 
//             //goes for 'makeNetworkCost' and 'makeNetworkCostDist' too.

//             //reinsert the most recent edge that was just removed from 'possibleEdges'
//             possibleEdges.insert(std::make_tuple(nodeEdges[dictID]->parent.lock()->id, nodeEdges[dictID]->id,nodeEdges[dictID]->cost,nodeEdges[dictID]->dist));
            
//             nodeEdges[dictID]->parent = std::weak_ptr<NodeEdge>();
//             nodeEdges[dictID]->dist = 0;
//             nodeEdges[dictID]->cost = 0;
//             nodeEdges[dictID]->nNodesFromOrigin = 0;
//             break;
//         }
//     }
// }
void ShortestPathFinder::makeNetworkCost(double constraint){
    while(possibleEdges.size() != 0){ //if possibleEdges is 0 then we've added all the edges possible and we're done
        int currentID = doNextIteration();
        //std::shared_ptr<NodeEdge> ne = nodeEdges.at(dict[currentID]);
        int dictID = dict[currentID];
        if(nodeEdges[dictID]->cost > constraint){ //check if we've exceed the max resistance value - if so, remove the most recently added edge (since it exceeds the limit) and then break out of the loop
            
            //reinsert the most recent edge that was just removed from 'possibleEdges'
            possibleEdges.insert(std::make_tuple(nodeEdges[dictID]->parent.lock()->id, nodeEdges[dictID]->id,nodeEdges[dictID]->cost,nodeEdges[dictID]->dist));
            
            nodeEdges[dictID]->parent = std::weak_ptr<NodeEdge>();
            nodeEdges[dictID]->dist = 0;
            nodeEdges[dictID]->cost = 0;
            nodeEdges[dictID]->nNodesFromOrigin = 0;
            break;
        }
    }
}

void ShortestPathFinder::makeNetworkCostDist(double constraint){
    while(possibleEdges.size() != 0){ //if possibleEdges is 0 then we've added all the edges possible and we're done
        int currentID = doNextIteration();
        //std::shared_ptr<NodeEdge> ne = nodeEdges.at(dict[currentID]);
        int dictID = dict[currentID];
        if((nodeEdges[dictID]->cost + nodeEdges[dictID]->dist) > constraint){ //check if we've exceed the max resistance value - if so, remove the most recently added edge (since it exceeds the limit) and then break out of the loop
            
            //reinsert the most recent edge that was just removed from 'possibleEdges'
            possibleEdges.insert(std::make_tuple(nodeEdges[dictID]->parent.lock()->id, nodeEdges[dictID]->id,nodeEdges[dictID]->cost,nodeEdges[dictID]->dist));
            
            nodeEdges[dictID]->parent = std::weak_ptr<NodeEdge>();
            nodeEdges[dictID]->dist = 0;
            nodeEdges[dictID]->cost = 0;
            nodeEdges[dictID]->nNodesFromOrigin = 0;
            break;
        }
    }
}

//this function finds the shortest path to a specific node. As mentioned in the
//comments for 'makeShortestPathNetwork()', the two functions are designed to work together. If the full network
//has already been calculated, then this function doesn't do any further calculation - it simply calls 
//'findShortestPath()' to get the shortest path. If the full path hasn't been calculated, however, then it 
//runs the algorithm until it finds the desired shortest path.
//std::vector<std::shared_ptr<Node>> ShortestPathFinder::getShortestPath(int endNodeID){
std::vector<std::tuple<std::shared_ptr<Node>,double,double>> ShortestPathFinder::getShortestPath(int endNodeID){
    if(!nodeEdges.at(dict[endNodeID])->parent.lock()){ // check if we've already found the path to this node
        while(possibleEdges.size() != 0){ //if possibleEdges is 0 then we've added all the edges possible and we're done
            int currentID = doNextIteration();
            if(currentID == endNodeID){
                break;
            }
        }
    }
    return findShortestPath(endNodeID);
}

//std::vector<std::shared_ptr<Node>> ShortestPathFinder::getShortestPath(Point endPoint){
std::vector<std::tuple<std::shared_ptr<Node>,double,double>> ShortestPathFinder::getShortestPath(Point endPoint){
    std::shared_ptr<Node> node = quadtree->getNode(endPoint.x, endPoint.y);
    if(node && !std::isnan(node->value)){ //only try to find the shortest path if the point falls in the quadtree and the value of the node isn't NA
        return getShortestPath(node->id);
    } else {
        return std::vector<std::tuple<std::shared_ptr<Node>,double,double>>();
    }
}