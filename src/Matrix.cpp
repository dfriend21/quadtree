#include <iostream>
#include <vector>
#include <cassert>
#include <string>
#include <cmath>
#include <algorithm>
#include "Matrix.h"

Matrix::Matrix() : nrow{0}, ncol{0}{
    vec = std::vector<double>(0);
}

Matrix::Matrix(double val, int _nrow, int _ncol) : nrow{_nrow}, ncol{_ncol}
{
    vec = std::vector<double>(nrow*ncol, val);
}

Matrix::Matrix(std::vector<double> _vec, int _nrow, int _ncol) 
    : nrow{_nrow}, ncol{_ncol}, vec(_vec)  
{
    assert(_nrow >= 0 && _ncol >= 0);
    assert(vec.size() == (size_t)(nrow*ncol));
}

int Matrix::getIndex(const int row, const int col) const{
    assert(row >= 0 || row < nRow() || col >= 0 || col < nCol());//check to make sure the indices are valid
    int index = row*nCol() + col; 
    return index;
}

int Matrix::nRow() const{ return nrow; }
int Matrix::nCol() const{ return ncol; }
int Matrix::size() const{ return vec.size(); }

std::vector<double> Matrix::asVector() const{ return vec; }

Matrix Matrix::getRow(const int index) const{
    std::vector<double> slice(ncol);
    for(int i = 0; i < ncol; i++){
        slice[i] = vec[index * ncol + i];
    }
    return Matrix(slice, 1, ncol);
}

Matrix Matrix::getCol(const int index) const{
    std::vector<double> slice(nrow);
    for(int i = 0; i < nrow; i++){
        slice[i] = vec[index + ncol*i];
    }
    return Matrix(slice, nrow, 1);
}

Matrix Matrix::subset(int rMin, int rMax, int cMin, int cMax) const{
    int nRow = rMax - rMin + 1;
    int nCol = cMax - cMin + 1;
    std::vector<double> sub(nRow*nCol);
    int counter{0};
    for(int i = rMin; i <=rMax; i++){
        std::vector<double> row_i = getRow(i).asVector();
        for(int j = cMin; j <= cMax; j++){
            sub[counter] = row_i[j];
            counter++;
        }
    }
    Matrix subset = Matrix(sub, nRow, nCol);
    return subset;
}

Matrix Matrix::flipRows() const{
    std::vector<double> newVec(vec.size());
    int counter{0};
    for(int i = nrow-1; i >= 0; i--){
        std::vector<double> sub = getRow(i).asVector();
        for(int j = 0; j < ncol; j++){
            newVec.at(counter) = sub.at(j);
            counter++;
        }
    }
    Matrix newMat = Matrix(newVec, nrow, ncol);
    return newMat;
}

Matrix Matrix::getTranspose() const {
    std::vector<double> newVec(vec.size());
    for(size_t i = 0; i < vec.size(); i++){
        int newIndex = (i%ncol)*nrow + i/ncol;
        newVec.at(newIndex) = vec.at(i);
    }
    return Matrix(newVec, ncol, nrow);
}

// bool inverse(int A[N][N], float inverse[N][N]) 
// { 
//     // Find determinant of A[][] 
//     int det = determinant(A, N); 
//     if (det == 0) 
//     { 
//         cout << "Singular matrix, can't find its inverse"; 
//         return false; 
//     } 
  
//     // Find adjoint 
//     int adj[N][N]; 
//     adjoint(A, adj); 
  
//     // Find Inverse using formula "inverse(A) = adj(A)/det(A)" 
//     for (int i=0; i<N; i++) 
//         for (int j=0; j<N; j++) 
//             inverse[i][j] = adj[i][j]/float(det); 
  
//     return true; 
// } 
//https://www.mathsisfun.com/algebra/matrix-inverse-minors-cofactors-adjugate.html
Matrix Matrix::getMinorsMatrix() const {
    Matrix minors(0,nRow(), nCol());
    for(int iRow = 0; iRow < nRow(); ++iRow){
        for(int iCol = 0; iCol < nCol(); ++iCol){
            std::vector<double> subVec((nRow()-1)*(nCol()-1));
            int currentIndex{0};
            for(int jRow = 0; jRow < nRow(); ++jRow){
                for(int jCol = 0; jCol < nCol(); ++jCol){
                    if(jRow != iRow & jCol != iCol){
                        subVec.at(currentIndex) = getValue(jRow, jCol);
                        currentIndex++;
                    }
                }
            }
            Matrix sub(subVec,nRow()-1,nCol()-1);
            minors.setValue(sub.determinant(),iRow,iCol);
        }
    }
    return minors;
}
//https://www.mathsisfun.com/algebra/matrix-inverse-minors-cofactors-adjugate.html
Matrix Matrix::getCofactorsMatrix() const{
    Matrix cofactors(0,nRow(), nCol());
    for(int iRow = 0; iRow < nRow(); ++iRow){
        for(int iCol = 0; iCol < nCol(); ++iCol){
            if((iRow+iCol)%2 == 0){
                cofactors.setValue(getValue(iRow,iCol), iRow, iCol);
            } else{
                cofactors.setValue(getValue(iRow,iCol)*-1, iRow, iCol);
            }
        }
    }
    return cofactors;
}
//https://www.mathsisfun.com/algebra/matrix-inverse-minors-cofactors-adjugate.html
Matrix Matrix::getInverse() const {
    double det = determinant();
    assert(det != 0);

    //definitely not memory efficient
    Matrix minors = getMinorsMatrix();
    Matrix cofactors = minors.getCofactorsMatrix();
    Matrix transpose = cofactors.getTranspose();
    Matrix inverse = (1/det)*transpose;

    return inverse;
}

double Matrix::getValue(const int row, const int col) const {
    return getValueByIndex(getIndex(row, col));
}

double Matrix::getValueByIndex(const int index) const{
    return vec.at(index);
}

void Matrix::setValue(const double value, const int row, const int col){
    vec.at(getIndex(row,col)) = value;
}

void Matrix::setValueByIndex(const double value, const int index){
    vec.at(index) = value;
}

double Matrix::mean() const{
    double sum = 0;
    for(size_t i = 0; i < vec.size(); i++){
        sum += vec[i];
    }
    return sum/vec.size();
}

double Matrix::median() const{
    std::vector<double> vecSort = vec;
    std::sort(vecSort.begin(), vecSort.end());
    if(vecSort.size()%2 == 0){
        return (vecSort[vecSort.size()/2] + vecSort[(vecSort.size()/2)-1]) / 2;
    } else {
        return vecSort[(vecSort.size()-1)/2];
    }
}

double Matrix::min() const{
    double min = vec[0];
    for(size_t i = 1; i < vec.size(); i++){
        if(vec[i] < min){
            min = vec[i];
        }
    }
    return min;
}

double Matrix::max() const{
    double max = vec[0];
    for(size_t i = 1; i < vec.size(); i++){
        if(vec[i] > max){
            max = vec[i];
        }
    }
    return max;
}

double Matrix::determinant() const{
    assert(nRow() == nCol());

    if(nRow() == 2){
        return getValue(0,0)*getValue(1,1) - getValue(0,1)*getValue(1,0);
    }

    double det{0};
    for(int iCol = 0; iCol < nCol(); ++iCol){
        double iValue{0};
        Matrix subMat;
        if(iCol == 0){
            subMat = subset(1,nRow()-1,1,nCol()-1);
        } else if(iCol == nCol()){
            subMat = subset(1,nRow()-1,0,iCol-1);
        } else {
            Matrix mat1 = subset(1,nRow()-1,0,iCol-1);
            Matrix mat2 = subset(1,nRow()-1,iCol+1,nCol()-1);
            subMat = cbind(mat1,mat2);
        }
        iValue = getValue(0,iCol) * subMat.determinant();
        if(iCol % 2 == 0){
            det += iValue;
        } else {
            det -= iValue;
        }
    }
    return det;

}


int Matrix::countNans() const{
    int count = 0;
    for(size_t i = 0; i < vec.size(); i++){
        if(std::isnan(vec[i])){
            count++;
        }
    }
    return count;
}

std::string Matrix::toString() const{
    std::string str = "";
    for(int i = 0; i < nrow; i++){
        for(int j = 0; j < ncol; j++){
            str = str + std::to_string(getValueByIndex(i*ncol + j)) + " ";
        }
        str = str + "\n";
    }
    return(str);
}

Matrix operator+(const Matrix &lhs, const Matrix &rhs){
    assert(lhs.nRow() == rhs.nRow() && lhs.nCol() == rhs.nCol());
    std::vector<double> sum(lhs.asVector().size());
    for(std::size_t i = 0; i<lhs.asVector().size(); i++){
        sum[i] = lhs.getValueByIndex(i) + rhs.getValueByIndex(i);
    }
    return Matrix(sum, lhs.nRow(), lhs.nCol());
}

Matrix operator+(const Matrix &mat, const int scalar){
    std::vector<double> sum(mat.asVector().size());
    for(size_t i=0; i < mat.asVector().size(); i++){
        sum[i] = mat.getValueByIndex(i) + scalar;
    }
    return Matrix(sum, mat.nRow(), mat.nCol());
}

Matrix operator+(const int scalar, const Matrix &mat){
    return mat+scalar;
}

Matrix operator+(const Matrix &mat, const double scalar){
    std::vector<double> sum(mat.asVector().size());
    for(size_t i=0; i < mat.asVector().size(); i++){
        sum[i] = mat.getValueByIndex(i) + scalar;
    }
    return Matrix(sum, mat.nRow(), mat.nCol());
}

Matrix operator+(const double scalar, const Matrix &mat){
    return mat+scalar;
}

Matrix operator*(const Matrix &lhs, const Matrix &rhs){
    assert(lhs.nCol() == rhs.nRow());
    int nRowNew = lhs.nRow();
    int nColNew = rhs.nCol();
    std::vector<double> prod(nRowNew * nColNew);
    for(int i = 0; i < nRowNew; i++){
        const std::vector<double> &row_l{lhs.getRow(i).asVector()};
        //std::cout << i << std::endl;
        //std::cout << "-------" << std::endl;
        for(int j = 0; j < nColNew; j++){
            const std::vector<double> &col_r{rhs.getCol(j).asVector()};
            double sum{0};
            for(size_t k = 0; k < row_l.size(); k++){ //row_l and col_r should have the same length
                sum += row_l.at(k)*col_r.at(k);
            }
            //std::cout << j << " | " << i*nColNew+j << std::endl;
            prod.at(i*nColNew + j) = sum;
        }
        //std::cout << "-------" << std::endl;
    }
    return Matrix(prod, nRowNew, nColNew);

}

Matrix operator*(const Matrix &mat, const int scalar){
    std::vector<double> prod(mat.asVector().size());
    for(size_t i=0; i < mat.asVector().size(); i++){
        prod[i] = mat.getValueByIndex(i) * scalar;
    }
    return Matrix(prod, mat.nRow(), mat.nCol());
}

Matrix operator*(const int scalar, const Matrix &mat){
    return mat*scalar;
}

Matrix operator*(const Matrix &mat, const double scalar){
    std::vector<double> prod(mat.asVector().size());
    for(size_t i=0; i < mat.asVector().size(); i++){
        prod[i] = mat.getValueByIndex(i) * scalar;
    }
    return Matrix(prod, mat.nRow(), mat.nCol());
}

Matrix operator*(const double scalar, const Matrix &mat){
    return mat*scalar;
}

std::ostream& operator<< (std::ostream &out, const Matrix mat){
    out << mat.toString();
    return out;
}

Matrix rbind(const Matrix &mat1, const Matrix &mat2){
    assert(mat1.nCol() == mat2.nCol());
    
    std::vector<double> newMatVec(mat1.size() + mat2.size());
    Matrix newMat(newMatVec, mat1.nRow()+mat2.nRow(), mat1.nCol());
    for(int iRow = 0; iRow < newMat.nRow(); ++iRow){
        for(int iCol = 0; iCol < newMat.nCol(); ++iCol){
            if(iRow < mat1.nRow()){
                newMat.setValue(mat1.getValue(iRow,iCol),iRow,iCol);
            } else {
                newMat.setValue(mat2.getValue(iRow - mat1.nRow(),iCol),iRow,iCol);
            }
        }
    }
    return newMat;
}

Matrix cbind(const Matrix &mat1, const Matrix &mat2){
    assert(mat1.nRow() == mat2.nRow());
    
    std::vector<double> newMatVec(mat1.size() + mat2.size());
    Matrix newMat(newMatVec, mat1.nRow(), mat1.nCol()+mat2.nCol());

    for(int iRow = 0; iRow < newMat.nRow(); ++iRow){
        for(int iCol = 0; iCol < newMat.nCol(); ++iCol){
            if(iCol < mat1.nCol()){
                newMat.setValue(mat1.getValue(iRow,iCol),iRow,iCol);
            } else {
                newMat.setValue(mat2.getValue(iRow,iCol - mat1.nCol()),iRow,iCol);
            }
        }
    }
    return newMat;
}
