#include <time.h>    
#include <iostream>
#include "mpi.h"
#include <vector>
#include <ctime>
#include <algorithm>
#include <random>
#include <iomanip>



int main(int argc, char **argv) {
	std::srand(unsigned(std::time(nullptr)));
	MPI_Status status;
	MPI_Request request;
	int period{1};
	int reorder{1};
	int numprocs;
	int rank;
	double sum=0;
	MPI_Init(&argc, &argv);
	double start_time, end_time;
	MPI_Comm_size(MPI_COMM_WORLD,&numprocs);
	MPI_Comm_rank(MPI_COMM_WORLD, &rank);
	int size1=std::atoi(argv[1]);
	int size2=std::atoi(argv[2]);
	int size3=std::atoi(argv[3]);
	int size=size1*size2*size3;
	int localsize=size/numprocs;
	if (size % numprocs !=  0){
	size=numprocs*ceil((double) size/numprocs);
	}	

	double global1[size];
	double global2[size];
	double global[size];
//randomizing the two matrices
for(int a=0; a<10; a++){
	start_time=MPI_Wtime();
	for (int i=0; i<size1; i++){
		for (int j=0; j<size2; j++){
			for (int k=0; k<size3; k++){
				global1[k+j*size3+i*size3*size2]=rand()%100;
			}
		}
	}
	
	for (int i=0; i<size1; i++){
                for (int j=0; j<size2; j++){
                        for (int k=0; k<size3; k++){
                        	global2[k+j*size3+i*size3*size2]=rand()%100;
                        }
                }
        }


	double local1[localsize];
	double local2[localsize];
	double local[localsize];
//Scatter
	MPI_Scatter(global1, localsize, MPI_DOUBLE, local1, localsize, MPI_DOUBLE, 0, MPI_COMM_WORLD);
	MPI_Scatter(global2, localsize, MPI_DOUBLE, local2, localsize, MPI_DOUBLE, 0, MPI_COMM_WORLD);
	
//sum of the submatrices
	for (int i=0; i<localsize; i++){
		local[i]=local1[i]+local2[i];
	}


	//gather
	MPI_Gather(local, localsize, MPI_DOUBLE, global, localsize, MPI_DOUBLE, 0, MPI_COMM_WORLD);
	
	end_time=MPI_Wtime();
	sum=sum+end_time-start_time;
}
	sum=sum/10;
	if(rank==0){
		std::cout<<std::fixed<<std::setprecision(2)<<end_time-start_time<<std::endl;
        }

	
	MPI_Finalize();
	return 0;
}

