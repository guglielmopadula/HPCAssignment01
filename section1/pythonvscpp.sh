#!/bin/bash
cd /fast/dssc/gpadula/2021Assignment01/section1
rm pythonvscpp.csv
module load openmpi-4.1.1+gnu-9.3.0
mpic++ summatrix.cc -o summatrix
mpic++ ring.cc -o ring
mpic++ summatrixfast.cc -o summatrixfast

echo ",cpp,python">>pythonvscpp.csv

ringc=$(mpirun -np 24 ./ring)
rm ring.txt
ringpython=$(mpirun -np 24 python ring.py)
mfastc=$(mpirun -np 24 ./summatrixfast 2400 100 100)
mfastpython=$(mpirun -np 24 python summatrixfast.py 2400 100 100)
mc=$(mpirun -np 24 ./summatrix 2400 100 100 1 24 1 1)
mpython=$(mpirun -np 24 python summatrix.py 2400 100 100 1 24 1 1)

echo "ring (24),$ringc,$ringpython">> pythonvscpp.csv
echo "summatrixfast (2400 100 100),$mfastc,$mfastpython" >> pythonvscpp.csv

echo "summatrix (2400 100 100 1 24 1 1),$mc,$mpython" >> pythonvscpp.csv

