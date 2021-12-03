#ifndef LCPFINDER_H
#define LCPFINDER_H

#include "Node.h"
#include "Point.h"
#include "Quadtree.h"

#include <map>
#include <memory>
#include <set>
#include <tuple>
#include <vector>

class LcpFinder{
private:

    // comparator function for the multiset (possibleEdges) - specifies that the elements should be
    // sorted by the third tuple element (i.e. the cost-distance of the edge), then by distance,
    // then by ID of node 1, then by ID of node 2. This ensures a consistent (though arbitrary)
    // ordering in the case where two edges have the same cost and distance.
    struct cmp {
        bool operator() (std::tuple<int,int,double,double> a, std::tuple<int,int,double,double> b) const {
            bool is_cost_eq = std::get<2>(a) == std::get<2>(b);
            if(is_cost_eq){
                bool is_dist_eq = std::get<3>(a) == std::get<3>(b);
                if(is_dist_eq){
                    bool is_node1_eq = std::get<0>(a) == std::get<0>(b);
                    if(is_node1_eq){
                        return std::get<1>(a) < std::get<1>(b);   
                    } else {
                        return std::get<0>(a) < std::get<0>(b);    
                    }
                } else {
                    return std::get<3>(a) < std::get<3>(b);
                }
            } else {
                return std::get<2>(a) < std::get<2>(b);
            }
        }
    };

    void init(int startNodeID);
    void makeNodePointMap(std::vector<Point> newPoints);
public:
    // represents a single node. But because the result of the LCP algorithm is a tree, it also
    // contains a field for the 'parent' of the node. This 'parent' field is essential to storing
    // the structure of the LCP tree.
    struct NodeEdge{
        int id{-1};                     // ID of the NodeEdge
        std::weak_ptr<Node> node;       // the node this NodeEdge represents
        Point pt;                       // the point representing this node (assumed to be the centroid unless otherwise specified)
        std::weak_ptr<NodeEdge> parent; // the parent NodeEdge
        double dist{-1};                // the TOTAL distance from the origin to this node
        double cost{-1};                // the TOTAL cost from the origin to this node
        int nNodesFromOrigin{-1};       // the number of "steps" from this node to the origin. (Note that this counts the origin. So if the path to node 3 is 1-2-3, this value will be 3)
    };

    std::shared_ptr<Quadtree> quadtree; // the quadtree the LcpFinder operates 'on top' of the surface represented by this quadtree
    
    // the search area - we won't consider nodes that fall outside this box
    double xMin{0};
    double xMax{0};
    double yMin{0};
    double yMax{0};

    std::shared_ptr<Node> startNode; // the start node - the node from which all LCPs will be found
    std::vector<std::shared_ptr<NodeEdge>> nodeEdges; // this contains the nodes of the LCP tree. there is one NodeEdge per node. When initialized, the 'parent', 'dist', 'cost', and 'nNodesFromOrigin' properties are empty - these get filled in once the node gets added to the LCP tree
    std::map<int, int> dict; // dictionary. Key: Node ID's. Value: index of the corresponding 'NodeEdge' in 'nodeEdges'
    std::multiset<std::tuple<int,int,double,double>, cmp> possibleEdges; // set that contains info on the possible edges - the items in the tuple represent (in this order): ID of the first node in the edge; ID of the second node in the edge; cost-distance of the edge; cost of the edge
    std::map<int, Point> nodePointMap; // maps nodes to points - used to customize the point used to represent the node. Key: node ID. Value: the point to use for that node

    bool includeNodesByCentroid{false}; // should nodes be included if any part of the node overlaps with the search area (false), or only if the *centroid* falls in the search area (true)?

    LcpFinder();
    LcpFinder(std::shared_ptr<Quadtree> _quadtree, int startNodeID);
    LcpFinder(std::shared_ptr<Quadtree> _quadtree, Point startPoint);
    LcpFinder(std::shared_ptr<Quadtree> _quadtree, int startNodeID, double _xMin, double _xMax, double _yMin, double _yMax, bool _includeNodesByCentroid);
    LcpFinder(std::shared_ptr<Quadtree> _quadtree, Point startPoint, double _xMin, double _xMax, double _yMin, double _yMax, bool _includeNodesByCentroid);
    LcpFinder(std::shared_ptr<Quadtree> _quadtree, int startNodeID, double _xMin, double _xMax, double _yMin, double _yMax, std::map<int, Point> _nodePointMap, bool _includeNodesByCentroid);
    LcpFinder(std::shared_ptr<Quadtree> _quadtree, Point startPoint, double _xMin, double _xMax, double _yMin, double _yMax, std::map<int, Point> _nodePointMap, bool _includeNodesByCentroid);
    LcpFinder(std::shared_ptr<Quadtree> _quadtree, int startNodeID, double _xMin, double _xMax, double _yMin, double _yMax, std::vector<Point> newPoints, bool _includeNodesByCentroid);
    LcpFinder(std::shared_ptr<Quadtree> _quadtree, Point startPoint, double _xMin, double _xMax, double _yMin, double _yMax, std::vector<Point> newPoints, bool _includeNodesByCentroid);
    int doNextIteration();

    std::vector<std::shared_ptr<NodeEdge>> findLcp(int endNodeID);
    
    std::vector<std::shared_ptr<NodeEdge>> getLcp(int endNodeID);
    std::vector<std::shared_ptr<NodeEdge>> getLcp(Point endPoint);

    void makeNetworkAll();
    void makeNetworkCostDist(double constraint);
};

#endif