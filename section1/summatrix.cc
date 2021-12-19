#include <time.h>    
#include <iostream>
#include "mpi.h"
#include <vector>
#include <ctime>
#include <algorithm>
#include <random>
#include <iomanip>


//the matrix class

struct Matrix3D {
	size_t m_x, m_y, m_z;
	std::vector<double> m_data;
	Matrix3D(size_t x, size_t y, size_t z):
		m_x(x), m_y(y), m_z(z),  m_data(x*y*z, 0)
    		{}
	
	double& operator()(size_t x, size_t y, size_t z) {
        	return m_data.at(y*m_z + x * m_y*m_z + z);
    		}
};

//this function fills the matrix with random numbers

void addrandom(Matrix3D& matrix){
	size_t length{(matrix.m_data).size()};
	for (int i=0;i<length;i++) {
    	(matrix.m_data).at(i) = (rand()/(double)RAND_MAX);
	}
}

//this function increases the size of the matrix filling with zero the new elements

void enlarge(Matrix3D& matrix, size_t newsize1, size_t newsize2, size_t newsize3){
	size_t newsize=newsize1*newsize2*newsize3;
	size_t length{(matrix.m_data).size()};
	for (int i=0; i<newsize-length; i++){
		(matrix.m_data).push_back(0);
	}
	matrix.m_x=newsize1;
	matrix.m_y=newsize2;
	matrix.m_z=newsize3;
}

// this function is the inverse of enlarge

void shrinkage(Matrix3D& matrix, size_t newsize1, size_t newsize2, size_t newsize3){
	size_t newsize=newsize1*newsize2*newsize3;
	size_t length{(matrix.m_data).size()};
	for (int i=0; i<length-newsize; i++){
		(matrix.m_data).pop_back();
	}
	matrix.m_x=newsize1;
	matrix.m_y=newsize2;
	matrix.m_z=newsize3;

}

//this function sum two matrix in a third one

void sum(Matrix3D const& matrix1, Matrix3D const& matrix2, Matrix3D& matrix3){
	std::transform ((matrix1.m_data).begin(), (matrix1.m_data).end(), (matrix2.m_data).begin(), (matrix3.m_data).begin(), std::plus<double>());
}



int main(int argc, char **argv) {
	std::srand(unsigned(std::time(nullptr)));
	MPI_Status status;
	MPI_Request request;
	int period{1};
	int reorder{1};
	int numprocs;
	int rank;
	int size;
	MPI_Init(&argc, &argv);
	double start_time, end_time;
	MPI_Comm cart_comm;
	MPI_Comm_size(MPI_COMM_WORLD,&numprocs);
	MPI_Comm_size(MPI_COMM_WORLD, &size);
	MPI_Comm_rank(MPI_COMM_WORLD, &rank);
	int numprocsx,numprocsy,numprocsz;

	//SETTING THE VIRTUAL TOPOLOGY
	const int ndim{std::atoi(argv[4])};;

	int dim[ndim];
	if (ndim==1){
 		dim[0]=std::atoi(argv[5]);
 		numprocsz=1;
 		numprocsx=std::atoi(argv[5]);
 		numprocsy=1;
	}
	
	if(ndim==2){
 	dim[0]=std::atoi(argv[5]); 
 	dim[1]=std::atoi(argv[6]);
 	numprocsy=std::atoi(argv[6]); 
 	numprocsz=1;
 	numprocsx=std::atoi(argv[5]);
 	}

	if (ndim==3){
 		dim[0]=std::atoi(argv[5]); 
 		dim[1]=std::atoi(argv[6]);
 		dim[2]=std::atoi(argv[7]);
 		numprocsx=std::atoi(argv[5]); 
 		numprocsy=std::atoi(argv[6]);
 		numprocsz=std::atoi(argv[7]);
	}
	MPI_Cart_create(MPI_COMM_WORLD,ndim,dim,&period,reorder,&cart_comm);
	MPI_Comm_rank(cart_comm, &rank);
	double meantime=0;
for(int a=0; a<5; a++){
	start_time=MPI_Wtime();
	// Matrix inizialization
	Matrix3D global1(std::atoi(argv[1]),std::atoi(argv[2]),std::atoi(argv[3]));
	Matrix3D global2(std::atoi(argv[1]),std::atoi(argv[2]),std::atoi(argv[3]));
	Matrix3D global(std::atoi(argv[1]),std::atoi(argv[2]),std::atoi(argv[3]));
	if (rank==0){
		addrandom(global1);
		addrandom(global2);
		}	
	
 	//number of process checking
	const int numprocs2=numprocsx*numprocsy*numprocsz;
	if (numprocs2!=numprocs){
			if(rank==0){
			std::cout<<"distribution-of-processor-does-not-match-totalnumber "<<std::endl;}
			MPI_Finalize();
			exit(0);
	}


	// checking that every dimension of the matrix is multiple of the corresponding dimension of the topology, if not matrix is enlarged
	int flag=0;
	int gridsize[3];
	if (std::atoi(argv[1])%numprocsx!=0){
	gridsize[0]=ceil((double)std::atoi(argv[1])/std::atoi(argv[4]))*numprocsx;
	flag=1;
	}
	else{
	gridsize[0]=std::atoi(argv[1]);
	}
	if (std::atoi(argv[2])%numprocsy!=0){
	gridsize[1]=ceil((double)std::atoi(argv[2])/numprocsy)*numprocsy;
	flag=1;
	}
	else{
	gridsize[1]=std::atoi(argv[2]);
	}
	if (std::atoi(argv[3])%numprocsz!=0){
	gridsize[2]=ceil((double)std::atoi(argv[3])/numprocsz)*numprocsz;
	flag=1;
	}
	else{
	gridsize[2]=std::atoi(argv[3]);
	}
	
	
	const int gridsizetot=gridsize[0]*gridsize[1]*gridsize[2];
	if (flag==1){
	enlarge(global1, gridsize[0],gridsize[1],gridsize[2]);
	enlarge(global2, gridsize[0],gridsize[1],gridsize[2]);
	enlarge(global, gridsize[0],gridsize[1],gridsize[2]);
	}
	
	//setting up useful variables and creating the matrix datatype	

	const int localsize[3]={gridsize[0]/numprocsx,gridsize[1]/numprocsy,gridsize[2]/numprocsz};
	const int localsizetot=localsize[0]*localsize[1]*localsize[2];
	
	
	Matrix3D local1(localsize[0],localsize[1],localsize[2]);
	Matrix3D local2(localsize[0],localsize[1],localsize[2]);
	Matrix3D local(localsize[0],localsize[1],localsize[2]);
    	int starts[3]   = {0,0,0};
    	MPI_Datatype type, subarrtype;
    	MPI_Type_create_subarray(3, gridsize, localsize, starts, MPI_ORDER_C, MPI_DOUBLE, &type);
    	MPI_Type_create_resized(type, 0, sizeof(double), &subarrtype);
    	MPI_Type_commit(&subarrtype);
    	int sendcounts[numprocs2];
    	int displs[numprocs2];
	
	//setting up variables for scatterV
		
    	if (rank == 0) {
		
        	for (int i=0; i<numprocs2; i++) {sendcounts[i] = 1;}
		int counter=0;
        	for (int i=0; i<gridsize[0]; i=i+localsize[0]) {
            		for (int j=0; j<gridsize[1]; j=j+localsize[1]) {
				for (int k=0; k<gridsize[2]; k=k+localsize[2]){
                			displs[counter] = j*gridsize[2] + i * gridsize[1]*gridsize[2] + k;
					counter++;
            			}
			}
        	}
	}
	
	//distribution of matrix

	MPI_Scatterv(&(global1.m_data[0]), sendcounts, displs, subarrtype, &(local1.m_data[0]), localsizetot, MPI_DOUBLE, 0, cart_comm);
	MPI_Scatterv(&(global2.m_data[0]), sendcounts, displs, subarrtype, &(local2.m_data[0]), localsizetot, MPI_DOUBLE, 0, cart_comm);
	
	//calculation of the sum
	sum(local1,local2,local);

	//gather
	MPI_Gatherv(&(local.m_data[0]), localsizetot, MPI_DOUBLE, &(global.m_data[0]), sendcounts, displs, subarrtype, 0, cart_comm);
		
	MPI_Type_free(&subarrtype);
	     	
	//if the matrix were enlarged now the final matrix is shrinked to the original dimensionm
	if (flag==1){
		shrinkage(global,std::atoi(argv[1]),std::atoi(argv[2]),std::atoi(argv[3]));
	}
	end_time=MPI_Wtime();
	meantime=meantime+end_time-start_time;

}
	meantime=meantime/5;
	if(rank==0){
		std::cout<<std::fixed<<std::setprecision(2)<<meantime<<std::endl;
	}
	MPI_Finalize();
	return 0;
}
