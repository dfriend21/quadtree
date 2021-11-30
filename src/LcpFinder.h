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
    // defines a connection between two nodes
    struct NodeEdge{
        int id{-1};
        std::weak_ptr<Node> node;
        Point pt;
        std::weak_ptr<NodeEdge> parent;
        double dist{-1};
        double cost{-1};
        int nNodesFromOrigin{-1};
    };

    // comparator function for the multiset (possibleEdges) - specifies that the elements
    // should be sorted by the third tuple element (i.e. the cost-distance of the edge), then by distance, then by ID of node 1, then by ID of node 2
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
    std::vector<std::tuple<std::shared_ptr<Node>,double,double>> findLcp(int endNodeID);

public:
    std::shared_ptr<Quadtree> quadtree; // the quadtree the LcpFinder operates 'on top' of
    std::shared_ptr<Node> startNode; // the start node - the node from which all LCPs will be found
    std::vector<std::shared_ptr<NodeEdge>> nodeEdges; // this contains the nodes of the LCP tree. there is one NodeEdge per node. When initialized, the 'parent', 'dist', 'cost', and 'nNodesFromOrigin' properties are empty - these get filled in once the node gets added to the LCP tree
    std::map<int, int> dict; // dictionary with Node ID's as the key and the index of the corresponding 'NodeEdge' in 'nodeEdges'
    std::multiset<std::tuple<int,int,double,double>, cmp> possibleEdges; // set that contains info on the possible edges - the items in the tuple represent (in this order): ID of the first node in the edge; ID of the second node in the edge; cost-distance of the edge; cost of the edge

    // the search area - we won't consider nodes that fall outside this box
    double xMin{0};
    double xMax{0};
    double yMin{0};
    double yMax{0};

    bool includeNodesByCentroid{false}; // should nodes be included if any part of the node overlaps with the search area (false), or only if the *centroid* falls in the search area (true)?

    LcpFinder();
    LcpFinder(std::shared_ptr<Quadtree> _quadtree, int startNodeID);
    LcpFinder(std::shared_ptr<Quadtree> _quadtree, Point startPoint);
    LcpFinder(std::shared_ptr<Quadtree> _quadtree, int startNodeID, double _xMin, double _xMax, double _yMin, double _yMax, bool _includeNodesByCentroid);
    LcpFinder(std::shared_ptr<Quadtree> _quadtree, Point startPoint, double _xMin, double _xMax, double _yMin, double _yMax, bool _includeNodesByCentroid);

    int doNextIteration();

    std::vector<std::tuple<std::shared_ptr<Node>,double,double>> getLcp(int endNodeID);
    std::vector<std::tuple<std::shared_ptr<Node>,double,double>> getLcp(Point endPoint);

    void makeNetworkAll();
    void makeNetworkCostDist(double constraint);
};

#endif