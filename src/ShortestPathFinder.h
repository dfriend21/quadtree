#include "Quadtree.h"
#include "Node.h"
#include "Point.h"
#include <memory>
#include <vector>
#include <map>
#include <set>
#include <tuple>

class ShortestPathFinder{
        
        //defines a connection between two nodes
        struct NodeEdge{
            int id;
            std::weak_ptr<Node> node;
            std::weak_ptr<NodeEdge> parent;
            double dist;
            double cost;
            int nNodesFromOrigin;
        };

        //comparator function for the multiset (possibleEdges) - specifies that the elements
        //should be sorted by the third tuple element (i.e. the cost-distance of the edge) 
        struct cmp {
            bool operator() (std::tuple<int,int,double,double> a, std::tuple<int,int,double,double> b) const {
                return std::get<2>(a) < std::get<2>(b);
            }
        };

        void init(int startNodeID);
        std::vector<std::tuple<std::shared_ptr<Node>,double,double>> findShortestPath(int endNodeID);

        public:
            
            std::shared_ptr<Quadtree> quadtree; //the quadtree the ShortestPathFinder operates 'on top' of
            std::shared_ptr<Node> startNode; //the start node - the node from which all LCPs will be found
            std::vector<std::shared_ptr<NodeEdge>> nodeEdges;
            std::map<int, int> dict; //dictionary with Node ID's as the key and the index of the corresponding 'NodeEdge' in 'nodeEdges'
            std::multiset<std::tuple<int,int,double,double>, cmp> possibleEdges; //set that contains info on the possible edges - the items in the tuple represent (in this order): ID of the first node in the edge; ID of the second node in the edge; cost-distance of the edge; cost of the edge

            //the search area - we won't consider nodes that fall outside this box
            double xMin{0};
            double xMax{0};
            double yMin{0};
            double yMax{0};

            ShortestPathFinder();
            ShortestPathFinder(std::shared_ptr<Quadtree> _quadtree, int startNodeID);
            ShortestPathFinder(std::shared_ptr<Quadtree> _quadtree, Point startPoint);
            ShortestPathFinder(std::shared_ptr<Quadtree> _quadtree, int startNodeID, double _xMin, double _xMax, double _yMin, double _yMax);
            ShortestPathFinder(std::shared_ptr<Quadtree> _quadtree, Point startPoint, double _xMin, double _xMax, double _yMin, double _yMax);

            int doNextIteration();

            std::vector<std::tuple<std::shared_ptr<Node>,double,double>> getShortestPath(int endNodeID);
            std::vector<std::tuple<std::shared_ptr<Node>,double,double>> getShortestPath(Point endPoint);

            void makeNetworkAll();
            void makeNetworkCostDist(double constraint);
    };