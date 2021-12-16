#!/bin/bash

#tr -s ' '  '\n'< jacobi-socket-12.txt > temp

cd /fast/dssc/gpadula/2021Assignment01/section3
module load openmpi-4.1.1+gnu-9.3.0
module load R
socket=(4 8 12 24 48)
core=(4 8 12)
L=600
mpirun --map-by core  --mca btl ^openib -np 1 ./jacoby3D.x <input.1   > jacobi-singular-gpu.txt
sed 's/#//g' jacobi-singular-gpu.txt > temp
sed -i '/StartResidual/,$!d' temp
tail -n +2 temp > temp2 && mv temp2 temp
awk 'NF>1{print $NF}' temp > temp2 && mv temp2 temp
mlusing=$(awk '{s+=$1}END{print "" s/NR}' RS=" " temp)

rm section3gpu.csv
echo "N,map,L,latency,band,timesing,k,c,tc,P(L_N) (estimated),P(L_N) real,P(L_1)*n/P(L_N) (estimated),P(L_1)*N/P(L_N) (real)">> section3gpu.csv


for i in 'socket' 'core'
do
	temp=$i[@]
	for j in ${!temp}
	do
		echo "$i|$j"
		mpirun --map-by $i --mca btl ^openib -np $j ./jacoby3D.x <input.$j   > jacobi-$i-$j-gpu.txt
		sed 's/#//g' jacobi-$i-$j-gpu.txt > temp
                sed -i '/StartResidual/,$!d' temp
                tail -n +2 temp > temp2 && mv temp2 temp
                awk 'NF>1{print $NF}' temp > temp2 && mv temp2 temp
                mlu=$(awk '{s+=$1}END{print "" s/NR}' RS=" " temp)
		cp ../section2/openmpi-gnu-gcc-core-ib0-ucx-tcp.csv temp.csv
		lat=$(awk 'NR==3{print substr($0,9,4)}' temp.csv)
		band=$(awk 'NR==3{print substr($0,23,7)}' temp.csv)
		Rscript section3.R $mlu $L $i $j $mlusing $band $lat > test.txt
		cat test.txt
		sed -i 's/"//g' test.txt
		cut -c5- test.txt >temp && mv temp test.txt
		cat test.txt >> section3gpu.csv
		

				
	done
done

#rm *.txt
rm *.dat
rm temp.csv
#mpirun --map-by socket --mca btl ^openib -np 4 ./jacoby3D.x <input.1200   > jacobi-socket-4.txt 
#mpirun --map-by socket --mca btl ^openib -np 8 ./jacoby3D.x <input.1200 > jacobi-socket-8.txt 
#mpirun --map-by  socket --mca btl ^openib -np 12 ./jacoby3D.x <input.1200  > jacobi-socket-12.txt
#mpirun --map-by core --mca  btl ^openib -np 1 ./jacoby3D.x <input.1200  > jacobi-core-1.txt
#mpirun --map-by core --mca  btl ^openib -np 4 ./jacoby3D.x <input.1200  > jacobi-core-4.txt
#mpirun --map-by core --mca btl ^openib -np 8 ./jacoby3D.x <input.1200  > jacobi-core-8.txt
#mpirun --map-by core --mca  btl ^openib -np 12 ./jacoby3D.x <input.1200  > jacobi-core-12.txt
#mpirun --map-by node --mca btl ^openib -np 12 ./jacoby3D.x <input.1200  > jacobi-node-12.txt
#mpirun --map-by node --mca  btl ^openib -np 24 ./jacoby3D.x <input.1200  > jacobi-node-24.txt
#mpirun --map-by node --mca  btl ^openib -np 48 ./jacoby3D.x <input.1200  > jacobi-node-48.txt


rm section3gpu.sh.e*
rm section3gpu.sh.o*

