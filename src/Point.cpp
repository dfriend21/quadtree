#include "Point.h"
#include <string>
#include <fstream>
#include <sstream>
#include <iostream>
#include <stdexcept> // std::runtime_error

//Point::Point() : x{0}, y{0}, id{0}{}
Point::Point() : x{0}, y{0}, hasCoordinates{false} {}
//Point::Point(int _id) : id{_id}, x{0}, y{0}, empty{true} {}
//Point::Point(double _x, double _y) : id{0}, x{_x}, y{_y}, empty{false} {}
Point::Point(double _x, double _y) : x{_x}, y{_y}, hasCoordinates{true} {}
//Point::Point(int _id, double _x, double _y) : id{_id}, x{_x}, y{_y}, empty{false} {}

//Point::Point(double _x, double _y, int _id) : x{_x}, y{_y}, id{_id}{}

//int Point::getId() const { return id; }
double Point::getX() const { return x; }
double Point::getY() const { return y; }
bool Point::hasCoords() const { return hasCoordinates; }

//void Point::setX(double _x) { x = _x; }
//void Point::setY(double _y) { y = _y; }
void Point::setCoords(double _x, double _y) {
    x = _x;
    y = _y;
    hasCoordinates = true;
}



std::string Point::toString() const{
    //std::string str = "x: " + std::to_string(x) + " | y: " + std::to_string(y) + " | id: " + std::to_string(id);
    std::string str = "x: " + std::to_string(x) + " | y: " + std::to_string(y);
    return str;
}

// std::shared_ptr<Point> makePoint(double x, double y, int id){
//     Point* point = new Point(x, y, id);
//     point->ptr = std::shared_ptr<Point>(point);
//     return point->ptr;
// }

//CSV must have two-columns - first for x, second for y. MUST NOT HAVE COLUMN NAMES!!
std::vector<Point> readPoints(std::string filePath){
        //https://www.gormanalysis.com/blog/reading-and-writing-csv-files-with-cpp/
    std::fstream fin;
    fin.open(filePath, std::fstream::in);

    if(!fin.is_open()) throw std::runtime_error("Could not open file");

    std::string line;

    //create a vector of vectors for reading in the data
    std::vector<Point> points;
    int rowIdx{0};
    //std::cout << "first while" << "\n";
    while(std::getline(fin, line)){
        //std::cout << rowIdx << "\n";
        std::string value;
        std::stringstream ss(line);
        int colIdx{0};
        std::vector<double> tempRow(2);
        //rows.push_back(std::vector<double>(2));
        //while(ss >> val){
        while(std::getline(ss,value, ',')){
            if(colIdx >= 2){
                throw std::runtime_error("CSV must only have 2 columns");
            }
            tempRow.at(colIdx) = std::stod(value);
            colIdx++;
        }
        points.push_back(Point(tempRow.at(0), tempRow.at(1)));
        rowIdx++;
    }

    fin.close();
    return points;
}
