// Clustering by fast search and find of density peaks
// Science 27 June 2014: 
// Vol. 344 no. 6191 pp. 1492-1496 
// DOI: 10.1126/science.1242072
// http://www.sciencemag.org/content/344/6191/1492.full// 
//
// Code Author: Eric Yuan
// Blog: http://eric-yuan.me
// You are FREE to use the following code for ANY purpose.
//
// Have fun with it
#include <stdlib.h>
#include <stdio.h>
#include <conio.h>
#include "iostream"
#include "vector"
#include "math.h"
using namespace std;

#define DIM 3
#define elif else if

#ifndef bool
    #define bool int
    #define false ((bool)0)
    #define true  ((bool)1)
#endif

struct Point3d {
    double x;
    double y;
    double z;
    Point3d(double xin, double yin, double zin) : x(xin), y(yin), z(zin) {}
};

void dataPro(vector<vector<double> > &src, vector<Point3d> &dst, int dim){
    for(int i = 0; i < src.size(); i++){
		if (dim == 3) {
			Point3d pt(src[i][0], src[i][1], src[i][2]);
		    dst.push_back(pt);
		} else if (dim == 2) {
			Point3d pt(src[i][0], src[i][1], 0);
	        dst.push_back(pt);
		} else {
			return;
		}
    }
}

void saveToTxt(vector<double> &rho, vector<double> &delta){
	if (rho.size() != delta.size()) {
		cout << "size of rho and size of delta is mismatched!" << endl;
		return ;
	}

	FILE *p = fopen("rho_delta.txt", "w");
	for(int i = 0; i < rho.size(); i++){
		printf("%lf %lf\n", rho[i], delta[i]);
		fprintf(p, "%lf %lf\n", rho[i], delta[i]);
	}
	fclose(p);
}

double getDistance(Point3d &pt1, Point3d &pt2){
    double tmp = pow(pt1.x - pt2.x, 2) + pow(pt1.y - pt2.y, 2) + pow(pt1.z - pt2.z, 2);
    return pow(tmp, 0.5);
}

vector<double> getAverageKnnDistance(vector<Point3d> &points){
    double ratio = 0.015;
    int nSamples = points.size();
    int M = nSamples * ratio;
    vector<double> rho(nSamples, 0.0);
    for(int i = 0; i < nSamples; i++){
        vector<double> tmp;
        for(int j = 0; j < nSamples; j++){
            if(i == j) continue;
            double dis = getDistance(points[i], points[j]);
            if(tmp.empty()){
                tmp.push_back(dis);
            }elif(tmp.size() < M){
                if(dis <= tmp[tmp.size() - 1]) tmp.push_back(dis);
                else{
                    for(int k = 0; k < tmp.size(); k++){
                        if(tmp[k] <= dis){
                            tmp.insert(tmp.begin() + k, dis);
                            break;
                        }
                    }
                }
            }else{
                if(dis >= tmp[0]){
                    ; // do nothing
                }elif(dis <= tmp[tmp.size() - 1]){
                    tmp.erase(tmp.begin());
                    tmp.push_back(dis);
                }else{
                    for(int k = 0; k < tmp.size(); k++){
                        if(tmp[k] <= dis){
                            tmp.insert(tmp.begin() + k, dis);
                            tmp.erase(tmp.begin());
                            break;
                        }
                    }
                }
            }
        }
        double res = 0.0;
        for(int m = 0; m < tmp.size(); m++){
            res += tmp[m];
        }
        rho[i] = 0 - res / tmp.size();
    }
    return rho;
}

double getdc(vector<Point3d> &data, double neighborRateLow, double neighborRateHigh){
    int nSamples = data.size();
    int nLow = neighborRateLow * nSamples * nSamples;
    int nHigh = neighborRateHigh * nSamples * nSamples;
    double dc = 0.0;
    int neighbors = 0;
    cout<<"nLow = "<<nLow<<", nHigh = "<<nHigh<<endl;
    while(neighbors < nLow || neighbors > nHigh){
    //while(dc <= 1.0){
        neighbors = 0;
        for(int i = 0; i < nSamples - 1; i++){
            for(int j = i + 1; j < nSamples; j++){
                if(getDistance(data[i], data[j]) <= dc) ++neighbors;
                if(neighbors > nHigh) goto DCPLUS;
            }
        }
DCPLUS: dc += 0.003;
        cout<<"dc = "<<dc<<", neighbors = "<<neighbors<<endl;
    }
	getch();
    return dc;
}

vector<double> getLocalDensity(vector<Point3d> &points, double dc){
	return getAverageKnnDistance(points);

    int nSamples = points.size();
    vector<double> rho(nSamples, 0);
    for(int i = 0; i < nSamples - 1; i++){
        for(int j = i + 1; j < nSamples; j++){
            if(getDistance(points[i], points[j]) < dc){
                ++rho[i];
                ++rho[j];
            }
        }
        //cout<<"getting rho. Processing point No."<<i<<endl;
    }
    return rho;
}

vector<double> getDistanceToHigherDensity(vector<Point3d> &points, vector<double> &rho){
    int nSamples = points.size();
    vector<double> delta(nSamples, 0.0);

    for(int i = 0; i < nSamples; i++){
        double dist = 0.0;
        bool flag = false;
        for(int j = 0; j < nSamples; j++){
            if(i == j) continue;
            if(rho[j] > rho[i]){
                double tmp = getDistance(points[i], points[j]);
                if(!flag){
                    dist = tmp;
                    flag = true;
                }else dist = tmp < dist ? tmp : dist;
            }
        }
        if(!flag){
            for(int j = 0; j < nSamples; j++){
                double tmp = getDistance(points[i], points[j]);
                dist = tmp > dist ? tmp : dist;
            }
        }
        delta[i] = dist;
        //cout<<"getting delta. Processing point No."<<i<<endl;
    }
    return delta;
}

int main(int argc, char** argv)
{
    //long start, end;
    FILE *input;
    input = fopen("..\\data\\jain.txt", "r");
	input = fopen("..\\data\\spiral.txt", "r");
	input = fopen("..\\data\\flame.txt", "r");
	input = fopen("..\\data\\Aggregation.txt", "r");
	input = fopen("..\\data\\fig2_panelB.txt", "r");
	//input = fopen("..\\data\\fig2_panelC.txt", "r");
	if (input <= 0) {
		cout << "open input file failed!" << endl;
		return -1;
	};
    vector<vector<double> > data;
    double tpdouble;
    int counter = 0;
	int dim = 2;
    while(1){
        if(fscanf(input, "%lf", &tpdouble)==EOF) break;
        if(counter / dim >= data.size()){
            vector<double> tpvec;
            data.push_back(tpvec);
        } 
        data[counter / dim].push_back(tpdouble);
        ++ counter;
    }
    fclose(input);
    //random_shuffle(data.begin(), data.end());

    //start = clock();
    cout<<"********dim: " << data.size() << endl;
    vector<Point3d> points;
    dataPro(data, points, dim);
    double dc = getdc(points, 0.016, 0.020);
    //vector<double> rho = getLocalDensity(points, dc);
    vector<double> rho = getAverageKnnDistance(points);

    vector<double> delta = getDistanceToHigherDensity(points, rho);
    saveToTxt(rho, delta);
    // now u get the cluster centers
    //end = clock();
    //cout<<"used time: "<<((double)(end - start)) / CLOCKS_PER_SEC<<endl;
    return 0;
}
