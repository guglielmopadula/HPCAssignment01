#!/bin/bash
cd /fast/dssc/2021Assignment01/gpadula/section2
module load openmpi/4.0.3/gnu/9.3.0
module load R
rm cache.csv
for i in {1..28}
do
#
	perf stat -o out.txt -e cache-references mpirun -np 2 -map-by core ./IMB_gnu-gcc PingPong -msglog $i -iter 100 -iter_policy multiple_np -off_cache -1
	cache=$(awk NR==6'{print $1}' out.txt)
	echo "$i,${cache//,}">>cache.csv
done
Rscript cache.Rscript
echo "argument of -msglog, cache references" >> cache.csv
rm cache.sh.e*
rm cache.sh.o*
rm out.txt
