#ifndef MATRIX_H
#define MATRIX_H

#include <string>
#include <vector>

class Matrix{
private:
    int nrow{0};
    int ncol{0};

    int getIndex(const int row, const int col) const;

public:
    std::vector<double> vec;

    Matrix();
    Matrix(double val, int _nrow, int _ncol);
    Matrix(std::vector<double> _vec, int _nrow, int _ncol);

    int nRow() const;
    int nCol() const;
    int size() const;
    std::vector<double> asVector() const;

    double getValueByIndex(const int index) const;
    double getValue(const int row, const int col) const;
    void setValueByIndex(const double value, const int index);
    void setValue(const double value, const int row, const int col);

    Matrix getRow(const int index) const;
    Matrix getCol(const int index) const;
    Matrix subset(int rMin, int rMax, int cMin, int cMax) const;

    Matrix flipRows() const;
    Matrix getTranspose() const;
    Matrix getMinorsMatrix() const;
    Matrix getCofactorsMatrix() const;
    Matrix getInverse() const;
    
    double mean(bool removeNA = true) const;
    double median(bool removeNA = true) const;
    double min() const;
    double max() const;
    double determinant() const; //gets the determinant

    int countNans() const;
    std::string toString() const;
};

Matrix operator+(const Matrix &lhs, const Matrix &rhs);

Matrix operator+(const Matrix &mat, const int scalar);
Matrix operator+(const int scalar, const Matrix &mat);
Matrix operator+(const Matrix &mat, const double scalar);
Matrix operator+(const double scalar, const Matrix &mat);

Matrix operator*(const Matrix &lhs, const Matrix &rhs);

Matrix operator*(const Matrix &mat, const int scalar);
Matrix operator*(const int scalar, const Matrix &mat);
Matrix operator*(const Matrix &mat, const double scalar);
Matrix operator*(const double scalar, const Matrix &mat);

Matrix cbind(const Matrix &mat1, const Matrix &mat2);
Matrix rbind(const Matrix &mat1, const Matrix &mat2);
#endif