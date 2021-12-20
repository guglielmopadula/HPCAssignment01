#!/bin/bash
cd /fast/dssc/gpadula/2021Assignment01/section1
rm *.csv
rm *.jpeg
rm ring
rm summatrix
module load openmpi-4.1.1+gnu-9.3.0
module load R
echo "Section 1 exercise 1"
mpic++ ring.cc -std=c++11 -o ring

num=2;

echo "numero di processori,tempo di esecuzione">ring.csv
while [ $num -le 24 ]
do
  	pass=$(mpirun -np $num --map-by socket ./ring 2>/dev/null)
        echo "${num},${pass}">>ring.csv
        ((num++))
done

Rscript ring.Rscript

echo "Section 1 exercise 2"
echo "size1 size2 size3 ndim dim1 dim2 dim3 runtime">> summatrix.csv
echo "size1,size2,size3,runtime">> summatrixfast.csv

mpic++ summatrix.cc -std=c++11 -o summatrix

while read -r line
do
	pass=$(mpirun -np 24 ./summatrix $line <</dev/null 2>/dev/null)
        echo "${line} ${pass}">> summatrix.csv
	echo "$line"
done < cases.txt
sed -e 's/\s\+/,/g' summatrix.csv > temp && mv temp summatrix.csv

mpic++ summatrixfast.cc -std=c++11 -o summatrixfast
pass=$(mpirun -np 24 ./summatrixfast 2400 100 100 <</dev/null 2>/dev/null)
echo "2400,100,100,${pass}">> summatrixfast.csv
pass=$(mpirun -np 24 ./summatrixfast 1200 200 100 <</dev/null 2>/dev/null)
echo "1200,200,100,${pass}">> summatrixfast.csv
pass=$(mpirun -np 24 ./summatrixfast 800 300 100 <</dev/null 2>/dev/null)
echo "800,300,100,${pass}">> summatrixfast.csv



rm section1.sh.e*
rm section1.sh.o*
