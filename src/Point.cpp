#include "Point.h"
#include <string>
#include <fstream>
#include <sstream>
#include <iostream>
#include <stdexcept> // std::runtime_error

Point::Point() : x{0}, y{0}, hasCoordinates{false} {}
Point::Point(double _x, double _y) : x{_x}, y{_y}, hasCoordinates{true} {}

double Point::getX() const { return x; }
double Point::getY() const { return y; }
bool Point::hasCoords() const { return hasCoordinates; }

void Point::setCoords(double _x, double _y) {
    x = _x;
    y = _y;
    hasCoordinates = true;
}

std::string Point::toString() const{
    std::string str = "x: " + std::to_string(x) + " | y: " + std::to_string(y);
    return str;
}

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
    while(std::getline(fin, line)){
        std::string value;
        std::stringstream ss(line);
        int colIdx{0};
        std::vector<double> tempRow(2);
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
