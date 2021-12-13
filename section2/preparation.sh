module load openmpi/4.0.3/gnu/9.3.0
mkdir temp
cd temp
git clone https://github.com/intel/mpi-benchmarks
cd mpi-benchmarks/src_c
make
mv IMB-MPI1 ../../../IMB_gnu-gcc  
make clean
module unload openmpi/4.0.3/gnu/9.3.0
module load intel/20.1
make
mv IMB-MPI1 ../../../IMB_intel-gcc
make clean
cd ../../../
rm -rf temp 
module unload intel/20.1
