#include "Quadtree.h"
#include "Node.h"
#include "Point.h"
#include <memory>
#include <vector>
#include <map>
#include <set>
#include <tuple>


class ShortestPathFinder{

        struct NodeEdge{
            int id;
            std::weak_ptr<Node> node;
            std::weak_ptr<NodeEdge> parent;
            //std::shared_ptr<NodeEdge> self;
            double dist;
            double cost;
            int nNodesFromOrigin;
            //std::vector<std::shared_ptr<NodeEdge>> possibleEdges;
        };

        //comparator function for the multiset
        struct cmp {
            bool operator() (std::tuple<int,int,double,double> a, std::tuple<int,int,double,double> b) const {
                return std::get<2>(a) < std::get<2>(b);
            }
        };

        void init(int startNodeID);
        //std::vector<std::shared_ptr<Node>> findShortestPath(int endNodeID);
        //std::vector<NodeEdge> findShortestPath(int endNodeID);
        std::vector<std::tuple<std::shared_ptr<Node>,double,double>> findShortestPath(int endNodeID);
        //bool cmp(std::tuple<int,int,double> a, std::tuple<int,int,double> b);
        public:
            
            std::shared_ptr<Quadtree> quadtree;
            //Point startPoint;
            std::shared_ptr<Node> startNode;
            std::vector<std::shared_ptr<NodeEdge>> nodeEdges;
            std::map<int, int> dict; //dictionary with Node ID's as the key and the index of the corresponding 'NodeEdge' in 'nodeEdges'
            //std::multiset<std::tuple<int,int,double>, decltype(cmp)> possibleEdges(cmp);
            //auto cmp = [](std::tuple<int,int,double> a, std::tuple<int,int,double> b) { return std::get<2>(a) < std::get<2>(b); };
            //std::multiset<std::tuple<int,int,double>, decltype(cmp)*> possibleEdges;
            std::multiset<std::tuple<int,int,double,double>, cmp> possibleEdges; //set that contains info on the possible edges - the items in the tuple represent (in this order): ID of the first node in the edge; ID of the second node in the edge; cost-distance of the edge; cost of the edge
            // std::multiset<std::tuple<int,int,double>> possibleEdges;

            double xMin;
            double xMax;
            double yMin;
            double yMax;
            bool isValid; //the ShortestPathFinder NEEDS a valid start point. If the start point/node isn't valid (i.e. not in the quadtree), then we'll set this flag to false.

            ShortestPathFinder();
            ShortestPathFinder(std::shared_ptr<Quadtree> _quadtree, int startNodeID);
            ShortestPathFinder(std::shared_ptr<Quadtree> _quadtree, Point startPoint);
            ShortestPathFinder(std::shared_ptr<Quadtree> _quadtree, int startNodeID, double _xMin, double _xMax, double _yMin, double _yMax);
            ShortestPathFinder(std::shared_ptr<Quadtree> _quadtree, Point startPoint, double _xMin, double _xMax, double _yMin, double _yMax);

            
            void makeShortestPathNetwork();
            // std::vector<std::shared_ptr<Node>> getShortestPath(int endNodeID);
            // std::vector<std::shared_ptr<Node>> getShortestPath(Point endPoint);
            // std::vector<NodeEdge> getShortestPath(int endNodeID);
            // std::vector<NodeEdge> getShortestPath(Point endPoint);
            std::vector<std::tuple<std::shared_ptr<Node>,double,double>> getShortestPath(int endNodeID);
            std::vector<std::tuple<std::shared_ptr<Node>,double,double>> getShortestPath(Point endPoint);

            int doNextIteration();
    };