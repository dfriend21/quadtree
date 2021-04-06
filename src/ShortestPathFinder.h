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
            std::shared_ptr<Node> node;
            std::shared_ptr<NodeEdge> parent;
            //std::shared_ptr<NodeEdge> self;
            double cost;
            int nNodesFromOrigin;
            //std::vector<std::shared_ptr<NodeEdge>> possibleEdges;
        };

        //comparator function for the multiset
        struct cmp {
            bool operator() (std::tuple<int,int,double> a, std::tuple<int,int,double> b) const {
                return std::get<2>(a) < std::get<2>(b);
            }
        };

        void init(int startNodeID);
        std::vector<std::shared_ptr<Node>> findShortestPath(int endNodeID);
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
            std::multiset<std::tuple<int,int,double>, cmp> possibleEdges;
            // std::multiset<std::tuple<int,int,double>> possibleEdges;

            double xMin;
            double xMax;
            double yMin;
            double yMax;

            ShortestPathFinder();
            ShortestPathFinder(std::shared_ptr<Quadtree> _quadtree, int startNodeID);
            ShortestPathFinder(std::shared_ptr<Quadtree> _quadtree, Point startPoint);
            ShortestPathFinder(std::shared_ptr<Quadtree> _quadtree, int startNodeID, double _xMin, double _xMax, double _yMin, double _yMax);
            ShortestPathFinder(std::shared_ptr<Quadtree> _quadtree, Point startPoint, double _xMin, double _xMax, double _yMin, double _yMax);

            
            void makeShortestPathNetwork();
            std::vector<std::shared_ptr<Node>> getShortestPath(int endNodeID);
            std::vector<std::shared_ptr<Node>> getShortestPath(Point endPoint);

            int doNextIteration();
    };