#include "LcpFinder.h"

#include <cmath>
#include <algorithm>

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

// there's a lot of repetition in these constructors... 
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

LcpFinder::LcpFinder(std::shared_ptr<Quadtree> _quadtree, int startNodeID, double _xMin, double _xMax, double _yMin, double _yMax, std::map<int, Point> _nodePointMap, bool _includeNodesByCentroid)
    : quadtree{_quadtree}, xMin{_xMin}, xMax{_xMax}, yMin{_yMin}, yMax{_yMax}, nodePointMap{_nodePointMap}, includeNodesByCentroid{_includeNodesByCentroid} {
    init(startNodeID);
}

LcpFinder::LcpFinder(std::shared_ptr<Quadtree> _quadtree, Point startPoint, double _xMin, double _xMax, double _yMin, double _yMax, std::map<int, Point> _nodePointMap, bool _includeNodesByCentroid)
    : quadtree{_quadtree}, xMin{_xMin}, xMax{_xMax}, yMin{_yMin}, yMax{_yMax}, nodePointMap{_nodePointMap}, includeNodesByCentroid{_includeNodesByCentroid} {
    std::shared_ptr<Node> startNode = quadtree->getNode(startPoint);
    if(startNode){ // only continue if the point falls in the quadtree
        init(startNode->id);
    }
}

LcpFinder::LcpFinder(std::shared_ptr<Quadtree> _quadtree, int startNodeID, double _xMin, double _xMax, double _yMin, double _yMax, std::vector<Point> newPoints, bool _includeNodesByCentroid)
    : quadtree{_quadtree}, xMin{_xMin}, xMax{_xMax}, yMin{_yMin}, yMax{_yMax}, includeNodesByCentroid{_includeNodesByCentroid} {
    makeNodePointMap(newPoints);
    init(startNodeID);

}
LcpFinder::LcpFinder(std::shared_ptr<Quadtree> _quadtree, Point startPoint, double _xMin, double _xMax, double _yMin, double _yMax, std::vector<Point> newPoints, bool _includeNodesByCentroid)
    : quadtree{_quadtree}, xMin{_xMin}, xMax{_xMax}, yMin{_yMin}, yMax{_yMax}, includeNodesByCentroid{_includeNodesByCentroid} {
    makeNodePointMap(newPoints);
    std::shared_ptr<Node> startNode = quadtree->getNode(startPoint);
    if(startNode){ // only continue if the point falls in the quadtree
        init(startNode->id);
    }
}

void LcpFinder::makeNodePointMap(std::vector<Point> newPoints){
    nodePointMap = std::map<int, Point>();
    for(int i = 0; i < newPoints.size(); ++i){
        std::shared_ptr<Node> node = quadtree->getNode(newPoints.at(i));
        if(node){
            if(nodePointMap.find(node->id) == nodePointMap.end()){
                nodePointMap[node->id] = newPoints.at(i);
            }
        }
    }
}

// ------- init -------
// sets up the empty network we'll use when finding LCPs. Creates a 'NodeEdge' for each node, but
// leaves the parent, dist, cost, and nNodesFromOrigin fields blank, to be filled in when the 
// algorithm runs.
void LcpFinder::init(int startNodeID){
    std::list<std::shared_ptr<Node>> nodes = quadtree->getNodesInBox(xMin, xMax, yMin, yMax, includeNodesByCentroid); // get all nodes in the search area
    nodeEdges = std::vector<std::shared_ptr<NodeEdge>>(nodes.size());
    
    dict = std::map<int, int>(); // dictionary with Node ID's as the key and the index of the corresponding 'NodeEdge' in 'nodeEdges'
    possibleEdges = std::multiset<std::tuple<int,int,double,double>, cmp>();
    if(nodes.size() > 0){ // only continue if there's at least one node in the search area
        int i{0};
        for(auto iNode : nodes){ // loop over each node and create a 'NodeEdge' for each node
            Point pt((iNode->xMin + iNode->xMax)/2, (iNode->yMin + iNode->yMax)/2);
            NodeEdge *ne = new NodeEdge{i, std::weak_ptr<Node>(iNode), pt, std::weak_ptr<NodeEdge>(),0,0,0};
            nodeEdges.at(i) = std::shared_ptr<NodeEdge>(ne);
            dict[nodeEdges.at(i)->node.lock()->id] = i; 
            if(iNode->id == startNodeID){ // check if this node is the same as 'startNode'
                if(!std::isnan(iNode->value)){ // if the starting node is NA, don't add it
                    possibleEdges.insert(std::make_tuple(i, i, 0, 0)); // initialize our set with the start node
                }
            }
            i++;
        }
        // if specified by the user, associate nodes with the user-provided points
        for(auto const& x : nodePointMap){
            if(dict.find(x.first) != dict.end()){
                nodeEdges[dict[x.first]]->pt = x.second;
            }
        }
    }
}


// NOTE: this is the old doNextIteration() (before I added the ability to customize the points used
// to represent the nodes). Leaving this here until I'm more confident that the new version is
// stable.
// ------- doNextIteration -------
// performs one iteration of the shortest path algorithm
// returns the ID of the most recently added Node (note that it returns the ID of the Node, NOT the NodeEdge)
// returns -1 if no edge was added
// int LcpFinder::doNextIteration(){
//     auto beginItr = possibleEdges.begin();
//     std::shared_ptr<NodeEdge> nodeEdge = nodeEdges.at(std::get<1>(*beginItr)); // get the edge that's at the front of the set
//     auto parent = nodeEdge->parent.lock();
//     if(parent){// if the destination node already has a pointer for parent, it's already been included, so we'll skip this one 
//         possibleEdges.erase(beginItr); 
//         return -1;
//     } else { // otherwise we'll set the 'parent' property of the destination node and then add the additional edge possibilities that result    
//         nodeEdge->parent = std::weak_ptr<NodeEdge>(nodeEdges.at(std::get<0>(*beginItr))); // set the parent of the destination node to be the source node
//         nodeEdge->nNodesFromOrigin = nodeEdges.at(std::get<0>(*beginItr))->nNodesFromOrigin + 1; // add 1 to the number of nodes from the origin of the parent
//         nodeEdge->cost = std::get<2>(*beginItr); // assign the cost-distance to the NodeEdge
//         nodeEdge->dist = std::get<3>(*beginItr); // assign the distance to the NodeEdge
        
//         possibleEdges.erase(beginItr); // remove this edge from the list of possibilities

//         // now we'll add the edges corresponding to this node's neighbors
//         auto node = nodeEdge->node.lock();
//         for(size_t i = 0; i < node->neighbors.size(); ++i){ // loop over each of its neighbors
//             std::map<int,int>::iterator itr = dict.find(node->neighbors.at(i).lock()->id); // see if this neighbor is included in our dictionary - if not, then it must fall outside the extent
//             if(itr != dict.end()){
//                 std::shared_ptr<NodeEdge> nodeEdgeNb = nodeEdges.at(itr->second);
//                 auto nodeNb = nodeEdgeNb->node.lock();
//                 if(!(nodeEdgeNb->parent.lock()) && !std::isnan(nodeNb->value)){ // check if this node already has a parent assigned i.e. has already been included in the network, or if this node is NAN
//                     // get cost for the path - to do that we need to know the length of the segment in each cell
//                     // first, figure out which side the two cells are adjacent on - this'll give us one coordinate for the intersection point (whether we know the x or y depends on which side they're adjacent on)
//                     // note that I was previously checking for equality between the x and y limits - but this was causing problems because we're comparing doubles, so in rare cases none of the equality checks were true. Instead, I'm now looking for the lowest difference between the sides 
//                     std::vector<double> difs{
//                         std::abs(node->xMin - nodeNb->xMax), // left side
//                         std::abs(node->xMax - nodeNb->xMin), // right side
//                         std::abs(node->yMin - nodeNb->yMax), // bottom
//                         std::abs(node->yMax - nodeNb->yMin) // top
//                     }; 
//                     int minIndex = 0;
//                     for(int i = 1; i < 4; ++i){
//                         if(difs[i] < difs[minIndex]){
//                             minIndex = i;
//                         }
//                     }

//                     double mid{0};
//                     bool isX = true; // tells us whether mid coordinate is an x-coordinate or a y-coordinate

//                     if(minIndex == 0){ // left side
//                         mid = node->xMin;
//                     } else if(minIndex == 1) { // right side
//                         mid = node->xMax;
//                     } else if(minIndex == 2) { // bottom
//                         mid = node->yMin;
//                         isX = false;
//                     } else if(minIndex == 3) { // top
//                         mid = node->yMax;
//                         isX = false;
//                     }

//                     double dist = std::sqrt(std::pow(nodeEdge->pt.x - nodeEdgeNb->pt.x, 2) + std::pow(nodeEdge->pt.y - nodeEdgeNb->pt.y, 2));
//                     double ratio{0};
//                     // now get the ratio between: {the difference between the known (x or y) mid-coordinate and the (x or y) coordinate of the starting point} and {the difference in the (x or y) coordinates of the two centroids}
//                     if(isX){
//                         double deltaX = nodeEdge->pt.x - nodeEdgeNb->pt.x; // get the difference of the x coords
//                         ratio = (nodeEdge->pt.x - mid) / deltaX;
//                     } else {
//                         double deltaY = nodeEdge->pt.y - nodeEdgeNb->pt.y; // get the difference of the y coords
//                         ratio = (nodeEdge->pt.y - mid) / deltaY;
//                     }

//                     // use the ratio we just calculated to get the length of the segment in each cell
//                     double dist1 = dist * ratio;
//                     double dist2 = dist - dist1;

//                     // use those distances to get the cost, weighted by the length of the segment in each cell. Add this to the cost to get to 'nodeEdge' to get the total cost from the origin
//                     double tot_cost = dist1 * (node->value) + dist2 * (nodeNb->value) + nodeEdge->cost; 
//                     double tot_dist = dist + nodeEdge->dist;

//                     possibleEdges.insert(std::make_tuple(nodeEdge->id, nodeEdgeNb->id, tot_cost, tot_dist));
//                 }
//             }
//         }
//         return node->id;
//     }
// }

// ------- doNextIteration -------
// performs one iteration of the shortest path algorithm
// NOTE: 
// If the centroids where always used to represent the nodes, then it'd be guaranteed that every
// edge would only cross through two nodes. However, I'm allowing for users to manually specify
// certain points to use as the points rather than the centroids (I added this so you can use
// certain points as the start and end points of the desired path, which helps reduce some of the
// bias caused by larger cells). This introduces the possibility that a straight line between two
// neighbors may cross another cell. This complicates things - in particular, the calculation of the
// cost of edge gets more complicated. One option would be to figure out the other cells it crosses
// and then add up all the pieces to get the total cost. The problem with this is that the line
// could cut across the corner of an NA cell. Then the cost of the edge is undefined. To avoid this,
// I added code to check whether or not an edge travels outside of the bounds of the two nodes. If
// so, rather than using a straight line, the path is taken to be the shortest possible path that
// only crosses between the two nodes. More specifically, this means that rather than using a
// straight line for the edge, the edge travels from the first point to the "corner" where the two
// cells meet, and then from that corner to the second point. 
//
// returns the ID of the most recently added Node (note that it returns the ID of the Node, NOT the NodeEdge)
// returns -1 if no edge was added
int LcpFinder::doNextIteration(){
    auto beginItr = possibleEdges.begin();
    std::shared_ptr<NodeEdge> nodeEdge = nodeEdges.at(std::get<1>(*beginItr)); // get the edge that's at the front of the set
    auto parent = nodeEdge->parent.lock();
    if(parent){ // if the destination node already has a pointer for parent, it's already been included, so we'll skip this one 
        possibleEdges.erase(beginItr); 
        return -1;
    } else { // otherwise we'll set the 'parent' property of the destination node and then add the additional edge possibilities that result    
        nodeEdge->parent = std::weak_ptr<NodeEdge>(nodeEdges.at(std::get<0>(*beginItr))); // set the parent of the destination node to be the source node
        nodeEdge->nNodesFromOrigin = nodeEdges.at(std::get<0>(*beginItr))->nNodesFromOrigin + 1; // add 1 to the number of nodes from the origin of the parent
        nodeEdge->cost = std::get<2>(*beginItr); // assign the cost-distance to the NodeEdge
        nodeEdge->dist = std::get<3>(*beginItr); // assign the distance to the NodeEdge
        
        possibleEdges.erase(beginItr); // remove this edge from the list of possibilities

        // now we'll add the edges corresponding to this node's neighbors
        auto node = nodeEdge->node.lock();
        for(size_t i = 0; i < node->neighbors.size(); ++i){ // loop over each of its neighbors
            std::map<int,int>::iterator itr = dict.find(node->neighbors.at(i).lock()->id); // see if this neighbor is included in our dictionary - if not, then it must fall outside the extent
            if(itr != dict.end()){
                std::shared_ptr<NodeEdge> nodeEdgeNb = nodeEdges.at(itr->second);
                auto nodeNb = nodeEdgeNb->node.lock();
                if(!(nodeEdgeNb->parent.lock()) && !std::isnan(nodeNb->value)){ // check if this node already has a parent assigned i.e. has already been included in the network, or if this node is NAN
                    // get cost for the path - to do that we need to know the length of the segment in each cell
                    // first, figure out which side the two cells are adjacent on - this'll give us one coordinate for the intersection point (whether we know the x or y depends on which side they're adjacent on)
                    // note that I was previously checking for equality between the x and y limits - but this was causing problems because we're comparing doubles, so in rare cases none of the equality checks were true. Instead, I'm now looking for the lowest difference between the sides 
                    std::vector<double> difs{
                        std::abs(node->xMin - nodeNb->xMax), // left side
                        std::abs(node->xMax - nodeNb->xMin), // right side
                        std::abs(node->yMin - nodeNb->yMax), // bottom
                        std::abs(node->yMax - nodeNb->yMin) // top
                    }; 
                    int minIndex = 0;
                    for(int i = 1; i < 4; ++i){
                        if(difs[i] < difs[minIndex]){
                            minIndex = i;
                        }
                    }

                    // NOTE: my guess is that there is a much more concise way of doing these calculations (probably using matrices or something). Right now it's kind of cumbersome - there's a lot of code replication going on. But now that I finally got it working I'm not feeling especially inspired to make it as elegant as possible - I doubt it would improve performance at all. So I'm not going to. Maybe someday (let's be honest, that means never).
                    double mid{0}; // this is the coordinate (x or y, depending on which side they are adjacent on) that represents the line along which the two nodes are adjacent
                    bool isX = true; // tells us whether mid coordinate is an x-coordinate or a y-coordinate

                    if(minIndex == 0){ // left side
                        mid = node->xMin;
                    } else if(minIndex == 1) { // right side
                        mid = node->xMax;
                    } else if(minIndex == 2) { // bottom
                        mid = node->yMin;
                        isX = false;
                    } else if(minIndex == 3) { // top
                        mid = node->yMax;
                        isX = false;
                    }
                    
                    // get the two "corners" where the two rectangles meet - these two coordinates define the segment of the "shared edge"
                    Point corner1(std::max(node->xMin, nodeNb->xMin), std::max(node->yMin, node->yMin));
                    Point corner2(std::min(node->xMax, nodeNb->xMax), std::min(node->yMax, nodeNb->yMax));
                    
                    // get the difference in the x and y coordinates
                    double deltaX = nodeEdgeNb->pt.x - nodeEdge->pt.x;
                    double deltaY = nodeEdgeNb->pt.y - nodeEdge->pt.y;
                    double ratio{0}; // this will be the proportion of the line that falls in the first node (as long as the line falls entirely within the two nodes)
                    Point midPoint; // this'll be point at which the line intersects the (vertical or horizontal) line represented by 'mid'
                    bool inside = true; // tells us whether the segment lies entirely within the two neighboring cells
                    // now get the ratio between: {the difference between the known (x or y) mid-coordinate and the (x or y) coordinate of the starting point} and {the difference in the (x or y) coordinates of the two centroids}
                    if(isX){
                        double x = mid;
                        ratio = (x - nodeEdge->pt.x) / deltaX;
                        double y = nodeEdge->pt.y + ratio * deltaY; // get the y coordinate of the intersection point
                        // x and y now define the place where the line intersects 'mid'. Now check if this intersection point lies on the 'shared edge' of the two nodes represented by the two 'corner' points. If not, set the new midpoint to be the closest corner point
                        if(y < corner1.y){
                            inside = false;
                            midPoint = Point(x, corner1.y);
                        } else if(y > corner2.y){
                            inside = false;
                            midPoint = Point(x, corner2.y);
                        }
                    } else {
                        double y = mid;
                        ratio = (y - nodeEdge->pt.y) / deltaY;
                        double x = nodeEdge->pt.x + ratio * deltaX;
                        if(x < corner1.x){
                            inside = false;
                            midPoint = Point(corner1.x, y);
                        } else if (x > corner2.x){
                            inside = false;
                            midPoint = Point(corner2.x, y);
                        }
                    }

                    // calculate the length of the segment in each node
                    double dist1;
                    double dist2;
                    if(inside){
                        // if the line falls w/in the two nodes, use the ratio we calculated to get the length of the segment in each cell
                        double dist = std::sqrt(std::pow(nodeEdge->pt.x - nodeEdgeNb->pt.x, 2) + std::pow(nodeEdge->pt.y - nodeEdgeNb->pt.y, 2));
                        dist1 = dist * ratio;
                        dist2 = dist - dist1;
                    } else {
                        // if the line goes outside the two nodes, calculate the distance from point 1 to the midpoint, and from the midpoint to point 2
                        dist1 = std::sqrt(std::pow(nodeEdge->pt.x - midPoint.x, 2) + std::pow(nodeEdge->pt.y - midPoint.y, 2));
                        dist2 = std::sqrt(std::pow(nodeEdgeNb->pt.x - midPoint.x, 2) + std::pow(nodeEdgeNb->pt.y - midPoint.y, 2));
                    }

                    // use those distances to get the cost, weighted by the length of the segment in each cell. Add this to the cost to get to 'nodeEdge' to get the total cost from the origin
                    double tot_cost = dist1 * (node->value) + dist2 * (nodeNb->value) + nodeEdge->cost; 
                    double tot_dist = dist1 + dist2 + nodeEdge->dist;
                    possibleEdges.insert(std::make_tuple(nodeEdge->id, nodeEdgeNb->id, tot_cost, tot_dist));
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
// RETURNS:  a vector of NodeEdges that represent the path to the end node
std::vector<std::shared_ptr<LcpFinder::NodeEdge>> LcpFinder::findLcp(int endNodeID){
    std::map<int,int>::iterator itr = dict.find(endNodeID); //see if this node is included in our dictionary - if not, then it must fall outside our search extent
    if(itr != dict.end()){
        std::shared_ptr<NodeEdge> currentNodeEdge = nodeEdges.at(itr->second); //get the pointer to the nodeEdge that corresponds with the ID provided by the user
        
        if(currentNodeEdge->parent.lock()){ //if this NodeEdge doesn't have a parent then that means it's unreachable
            std::vector<std::shared_ptr<NodeEdge>> nodePath(currentNodeEdge->nNodesFromOrigin); //initialize the vector that will store the nodes in the path. Use the 'nNodesFromOrigin' property of the destination NodeEdge to determine the size of the vector

            //starting with the end node, trace our way back to the start node
            for(size_t i = 1; i <= nodePath.size(); ++i){
                //WARNING - potential problems here from subtracting an int from a 'size_t' (which is unsigned)? But pretty sure in this case I'm guaranteed to be fine since i is explicitly set to be less than or equal to the size.
                nodePath.at(nodePath.size()-i) = currentNodeEdge; //add the node to the vector - we'll fill the vector in reverse order so that the first element is the starting node and the last is the ending node
                currentNodeEdge = currentNodeEdge->parent.lock(); //set 'currentNodeEdge' to be this node's parent - this is how we'll move up the tree
            }
            return nodePath; //return the vector containing the nodes in the path
        }
    }
    return std::vector<std::shared_ptr<NodeEdge>>(); //return an empty vector if it's not reachable
}

// ------- getLcp -------
// this function finds the shortest path to a specific node. As mentioned in the
// comments for 'makeNetworkAll()', the two functions are designed to work together. If the full network
// has already been calculated, then this function doesn't do any further calculation - it simply calls 
// 'findLcp()' to get the shortest path. If the full path hasn't been calculated, however, then it 
// runs the algorithm until it finds the desired shortest path.
// PARAMETERS: same as 'findLcp()'
// RETURNS: same as 'findLcp()'
std::vector<std::shared_ptr<LcpFinder::NodeEdge>> LcpFinder::getLcp(int endNodeID){
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
        return std::vector<std::shared_ptr<NodeEdge>>();
    }
}

// this is just a wrapper around getLcp(int) that accepts a point instead of a node ID
std::vector<std::shared_ptr<LcpFinder::NodeEdge>> LcpFinder::getLcp(Point endPoint){
    std::shared_ptr<Node> node = quadtree->getNode(endPoint);
    if(node && !std::isnan(node->value)){ // only try to find the shortest path if the point falls in the quadtree and the value of the node isn't NA
        return getLcp(node->id);
    } else {
        return std::vector<std::shared_ptr<NodeEdge>>();
    }
}

// ------- makeNetworkAll -------
// This function runs the shortest path algorithm exhaustively, meaning it finds all shortest paths
// to all nodes. This creates a 'network' of NodeEdges, which we can query with 'getLcp()' to get
// any single shortest path. This function and 'getLcp()' are designed to work together. 'getLcp()'
// stops when it reaches a certain node. But because the state of the algorithm is saved in
// 'possibleEdges', this algorithm can simply pick up where 'getLcp()' left off, rather than
// recalculating everything. This is why I implemented the LCP functionality as a class - it
// lets me save the state of the algorithm in a way that I couldn't do with just a function.
void LcpFinder::makeNetworkAll(){
    while(possibleEdges.size() != 0){ //if possibleEdges is 0 then we've added all the edges possible and we're done
        doNextIteration();
    }
}

// ------- makeNetworkCostDist -------
// finds all LCPs below a given cost-distance value
// NOTE: this is a bit cumbersome, because there's some extra maintenance we have to do -
// we don't know we've reached the limit until we've added an edge that exceeds the limit. 
// But then we need to remove that edge since it exceeds the limit.
// constraint: the maximum cost value allowed. All edges found will have a cost equal to
//             or less than this value
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
