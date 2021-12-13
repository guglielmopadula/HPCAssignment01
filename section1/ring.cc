#include <iostream>
#include <mpi.h>
#define USE MPI
#include <fstream>
#include <cstdlib>
int main(int argc , char *argv[ ]  ){

MPI_Status status;
MPI_Request request;
int dim{1};
int period{1};
int reorder{0};
int numprocs;
int rank;
double start_time, end_time;

MPI_Init(&argc,&argv);
MPI_Comm cart_comm;
MPI_Comm_size(MPI_COMM_WORLD,&numprocs);
const int numprocs2{numprocs};
MPI_Cart_create(MPI_COMM_WORLD,1,&numprocs2,&period,reorder,&cart_comm);
MPI_Comm_rank(cart_comm, &rank);
double sum=0;
if(rank==0){
std::remove("ring.txt");
}

int leftneig;
int rightneig;
int receiveleft{0};
int receiveright{0};
int sendleft{-rank};
int sendright{+rank};
int smg{0};
MPI_Cart_shift(cart_comm, 0, 1, &leftneig, &rightneig );
for (int j=0; j<10000; j++){
start_time=MPI_Wtime();
receiveleft=0;
receiveright=0;
sendleft=-rank;
sendright=rank;
smg=0;
start_time=MPI_Wtime();
for(int i=0; i<numprocs; i++){
MPI_Send(&sendleft, 1, MPI_INT,  leftneig, 10*(rank+i+numprocs)%numprocs, cart_comm);
MPI_Recv(&receiveright, 1, MPI_INT  ,rightneig, 10*(rank+i+1+numprocs)%numprocs, cart_comm, &status);
MPI_Send(&sendright, 1, MPI_INT  , rightneig, 10*(rank+i+numprocs)%numprocs, cart_comm);
MPI_Recv(&receiveleft, 1,MPI_INT  ,leftneig, 10*(rank+i-1+numprocs)%numprocs, cart_comm, &status);
receiveright=receiveright-rank;
receiveleft=receiveleft+rank;
sendleft=receiveright;
sendright=receiveleft;
smg=smg+2;
}

sendleft+=rank;
sendright-=rank;

end_time=MPI_Wtime();
sum=sum+end_time-start_time;
}
sum=sum/10000;

std::ofstream file;
file.open("ring.txt", std::ios_base::app);
file<<" I am processor "<<rank<<" and i have received " <<smg<< " messages. My final messages have tag "<<10*rank<<" and have value "<<sendleft<<" and "<<sendright<<" and my worktime is "<<end_time-start_time<<std::endl;
file.close();
if (rank==0){
std::cout<<std::fixed<<sum<<std::endl;
}
MPI_Finalize();

}
