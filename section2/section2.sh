#!/bin/bash
cd /fast/dssc/gpadula/2021Assignment01/section2
sort $PBS_NODEFILE | uniq -d > nodes.txt
node1=$(awk 'NR==1{print $1; exit}' nodes.txt)
node2=$(awk 'NR==2{print $1; exit}' nodes.txt)
rm nodes.txt
rm *.csv
rm *.jpeg
echo "mpi implementation,library-compiler,map,network,pml(opempi)/fabric(intel),btl(openmpi)/ofi(intel),bandwidth,latency">>section2.csv


module purge
module load R
module load openmpi-4.1.1+gnu-9.3.0
#module load openmpi/4.0.3/gnu/9.3.0
c=0;

for comp in  'gnu-gcc'
do
	for map in 'node' 'core' 'socket'
	do  
		for eth in 'br0' 'ib0' 
#'mlx5_0:1'
		do
			for pml in 'ob1' 'ucx'
			do
				if [[ "$pml" == "ob1" ]]
				then
					for btl in 'tcp' 'vader' 
					do
						if [[ ( "$map" != "node" && "$eth" != "br0")  || "$btl" != "vader" ]]
						then	
							
                                        		mpirun -np 2 --mca pml $pml --report-bindings -map-by $map  --mca btl $btl,self --mca btl_$btl_if_include $eth ./IMB_$comp PingPong -msglog 28 -iter 100 -iter_policy multiple_np -off_cache -1 > openmpi-$comp-$map-$eth-$pml-$btl.csv
							sed '/#bytes/,$!d' openmpi-$comp-$map-$eth-$pml-$btl.csv > temp && mv temp openmpi-$comp-$map-$eth-$pml-$btl.csv
							head -n -2 openmpi-$comp-$map-$eth-$pml-$btl.csv > temp && mv temp openmpi-$comp-$map-$eth-$pml-$btl.csv
							sed -e 's/\s\+/,/g' openmpi-$comp-$map-$eth-$pml-$btl.csv > temp && mv temp openmpi-$comp-$map-$eth-$pml-$btl.csv
							cut -c2-  openmpi-$comp-$map-$eth-$pml-$btl.csv >> temp && mv temp openmpi-$comp-$map-$eth-$pml-$btl.csv
							sed 's/#//g' < openmpi-$comp-$map-$eth-$pml-$btl.csv > temp && mv temp openmpi-$comp-$map-$eth-$pml-$btl.csv
							Rscript section2.Rscript openmpi-$comp-$map-$eth-$pml-$btl.csv
							lat=$(awk 'NR==2 {print $3}' openmpi-$comp-$map-$eth-$pml-$btl.csv)
							lat1=$(awk 'NR==24 {print $5}' openmpi-$comp-$map-$eth-$pml-$btl.csv)
							lat2=$(awk 'NR==25 {print $5}' openmpi-$comp-$map-$eth-$pml-$btl.csv) 
                                                        band=$(awk "BEGIN {print 2097152/(($lat2)-($lat1))}")
							sed -e 's/\s\+/,/g' openmpi-$comp-$map-$eth-$pml-$btl.csv > temp && mv temp openmpi-$comp-$map-$eth-$pml-$btl.csv
							cat <(echo "#header_line_3: latency:$lat,bandwith:$band") openmpi-$comp-$map-$eth-$pml-$btl.csv > temp && mv temp openmpi-$comp-$map-$eth-$pml-$btl.csv					
							cat <(echo "#header_line_2: $node1,$node2") openmpi-$comp-$map-$eth-$pml-$btl.csv > temp && mv temp openmpi-$comp-$map-$eth-$pml-$btl.csv
							cat <(echo "#header_line_1: mpirun -np 2 --mca pml $pml --report-bindings -map-by $map  --mca btl $btl,self --mca btl_$btl_if_include $eth ./IMB_$comp PingPong -msglog 28 -iter 100 -iter_policy multiple_np -off_cache -1  ") openmpi-$comp-$map-$eth-$pml-$btl.csv > temp && mv temp openmpi-$comp-$map-$eth-$pml-$btl.csv
							echo "openmpi,$comp,$map,$eth,$pml,$btl,$band,$lat">>section2.csv

						fi
					done
				fi
				if [[ "$pml" == "ucx" ]]
                        	then
                                	for btl in 'tcp' 'vader' 
                                	do
						if [[ "$map" != "node" || "$btl" != "vader" ]]
                                        	then
                                            		mpirun -np 2 --mca pml $pml --report-bindings -map-by $map  --mca btl $btl,self --mca btl_$btl_if_include $eth ./IMB_$comp PingPong -msglog 28 -iter 100 -iter_policy multiple_np -off_cache -1 > openmpi-$comp-$map-$eth-$pml-$btl.csv
							sed '/#bytes/,$!d' openmpi-$comp-$map-$eth-$pml-$btl.csv > temp && mv temp openmpi-$comp-$map-$eth-$pml-$btl.csv
							head -n -2 openmpi-$comp-$map-$eth-$pml-$btl.csv > temp && mv temp openmpi-$comp-$map-$eth-$pml-$btl.csv
							sed -e 's/\s\+/,/g' openmpi-$comp-$map-$eth-$pml-$btl.csv > temp && mv temp openmpi-$comp-$map-$eth-$pml-$btl.csv
							cut -c2-  openmpi-$comp-$map-$eth-$pml-$btl.csv >> temp && mv temp openmpi-$comp-$map-$eth-$pml-$btl.csv
							sed 's/#//g' < openmpi-$comp-$map-$eth-$pml-$btl.csv > temp && mv temp openmpi-$comp-$map-$eth-$pml-$btl.csv
							Rscript section2.Rscript openmpi-$comp-$map-$eth-$pml-$btl.csv
							lat=$(awk 'NR==2 {print $3}' openmpi-$comp-$map-$eth-$pml-$btl.csv)
							lat1=$(awk 'NR==24 {print $5}' openmpi-$comp-$map-$eth-$pml-$btl.csv)
							lat2=$(awk 'NR==25 {print $5}' openmpi-$comp-$map-$eth-$pml-$btl.csv) 
                                                        band=$(awk "BEGIN {print 2097152/(($lat2)-($lat1))}")
							sed -e 's/\s\+/,/g' openmpi-$comp-$map-$eth-$pml-$btl.csv > temp && mv temp openmpi-$comp-$map-$eth-$pml-$btl.csv
							cat <(echo "#header_line_3: latency:$lat,bandwith:$band") openmpi-$comp-$map-$eth-$pml-$btl.csv > temp && mv temp openmpi-$comp-$map-$eth-$pml-$btl.csv					
							cat <(echo "#header_line_2: $node1,$node2") openmpi-$comp-$map-$eth-$pml-$btl.csv > temp && mv temp openmpi-$comp-$map-$eth-$pml-$btl.csv
							cat <(echo "#header_line_1: mpirun -np 2 --mca pml $pml --report-bindings -map-by $map  --mca btl $btl,self --mca btl_$btl_if_include $eth ./IMB_$comp PingPong -msglog 28 -iter 100 -iter_policy multiple_np -off_cache -1  ") openmpi-$comp-$map-$eth-$pml-$btl.csv > temp && mv temp openmpi-$comp-$map-$eth-$pml-$btl.csv
							echo "openmpi,$comp,$map,$eth,$pml,$btl,$band,$lat">>section2.csv

						fi
                                	done
                        	fi

			done
		done
	done
done

mpirun -np 2  --report-bindings ./IMB_gnu-gcc PingPong -msglog 28 -iter 100 -iter_policy multiple_np > ucxnoflag.csv
sed '/#bytes/,$!d' ucxnoflag.csv > temp && mv temp ucxnoflag.csv
head -n -2 ucxnoflag.csv > temp && mv temp ucxnoflag.csv
sed -e 's/\s\+/,/g' ucxnoflag.csv > temp && mv temp ucxnoflag.csv
cut -c2-  ucxnoflag.csv >> temp && mv temp ucxnoflag.csv
sed 's/#//g' < ucxnoflag.csv > temp && mv temp ucxnoflag.csv
Rscript section2.Rscript ucxnoflag.csv
rm ucxnoflag.csv
rm graph-time-ucxnoflag.jpeg
			

module purge
module load intel
module load R


for i in 1 2
do 
	if [[ "$i" == "1"  ]]
        then
        	a='contiguos'
        fi
        if [[ "$i" == "2"  ]]
        then
                a='socket'
        fi	
	echo "intel|$i|shm"
	mpirun -np 2  -env I_MPI_DEBUG 5 -env I_MPI_FABRICS shm  -genv I_MPI_PIN_PROCESSOR_LIST  0,$i ./IMB_intel-gcc PingPong -msglog 28 -iter 100 -iter_policy multiple_np -off_cache -1 > intel-shm-shm-$a.csv
	sed '/#bytes/,$!d' intel-shm-shm-$a.csv > temp && mv temp intel-shm-shm-$a.csv
	head -n -2 intel-shm-shm-$a.csv > temp && mv temp intel-shm-shm-$a.csv
	lat=$(awk 'NR==2 {print $3}' intel-shm-shm-$a.csv)
	band=$(awk 'NR==25 {print $4}' intel-shm-shm-$a.csv) 
	sed -e 's/\s\+/,/g' intel-shm-shm-$a.csv > temp && mv temp intel-shm-shm-$a.csv
	cut -c2-  intel-shm-shm-$a.csv > temp && mv temp intel-shm-shm-$a.csv
        sed 's/#//g' < intel-shm-shm-$a.csv > temp && mv temp intel-shm-shm-$a.csv
        Rscript section2.Rscript intel-shm-shm-$a.csv
        lat1=$(awk 'NR==24 {print $5}' intel-shm-shm-$a.csv)
        lat2=$(awk 'NR==25 {print $5}' intel-shm-shm-$a.csv)
        band=$(awk "BEGIN {print 2097152/(($lat2)-($lat1))}")
        sed -e 's/\s\+/,/g' intel-shm-shm-$a.csv > temp && mv temp intel-shm-shm-$a.csv
	cat <(echo "#header_line_3: latency:$lat,bandwith:$band") intel-shm-shm-$a.csv > temp && mv temp intel-shm-shm-$a.csv				
	cat <(echo "#header_line_2: $node1,$node2") intel-shm-shm-$a.csv > temp && mv temp intel-shm-shm-$a.csv
	cat <(echo "#header_line_1: mpirun -np 2  -env I_MPI_DEBUG 5 -env I_MPI_FABRICS shm  -genv I_MPI_PIN_PROCESSOR_LIST 0,i  ./IMB_intel-gcc PingPong -msglog 28 -iter 100 -iter_policy multiple_np -off_cache -1 ") intel-shm-shm-$a.csv > temp && mv temp intel-shm-shm-$a.csv
	echo "intelmpi,intel,$a,none,shm,none,$band,$lat">> section2.csv
	for b in 'shm' 'sockets' 'tcp' 'mlx'       
	do
		if [[ "$b" == "shm"  ]]
                then
                    	eth='none'
               	fi
                if [[ "$b" == "sockets"  ]]
                then
                    	eth='br0'
                fi
		if [[ "$b" == "tcp"  ]]
                then
                   	eth='br0'
                fi
		if [[ "$b" == "mlx"  ]]
                then
                  	eth='ib0'
                fi
		echo "intel|$i|ofi|$b"
		mpirun -np 2  -env I_MPI_DEBUG 5 -env I_MPI_FABRICS ofi -env I_MPI_OFI_PROVIDER $b -genv I_MPI_PIN_PROCESSOR_LIST 0,$i ./IMB_intel-gcc PingPong -msglog 28 -iter 100 -iter_policy multiple_np -off_cache -1 > intel-ofi-$b-$a.csv
		sed '/#bytes/,$!d' intel-ofi-$b-$a.csv > temp && mv temp intel-ofi-$b-$a.csv
       		head -n -2 intel-ofi-$b-$a.csv > temp && mv temp intel-ofi-$b-$a.csv
        	lat=$(awk 'NR==2 {print $3}' intel-ofi-$b-$a.csv)
        	band=$(awk 'NR==25 {print $4}' intel-ofi-$b-$a.csv)
        	sed -e 's/\s\+/,/g' intel-ofi-$b-$a.csv > temp && mv temp intel-ofi-$b-$a.csv
        	cut -c2- intel-ofi-$b-$a.csv > temp && mv temp intel-ofi-$b-$a.csv
		sed 's/#//g' < intel-ofi-$b-$a.csv > temp && mv temp intel-ofi-$b-$a.csv
		Rscript section2.Rscript intel-ofi-$b-$a.csv
                lat1=$(awk 'NR==24 {print $5}' intel-ofi-$b-$a.csv)
                lat2=$(awk 'NR==25 {print $5}' intel-ofi-$b-$a.csv)
                band=$(awk "BEGIN {print 2097152/(($lat2)-($lat1))}")
                sed -e 's/\s\+/,/g' intel-ofi-$b-$a.csv > temp && mv temp intel-ofi-$b-$a.csv
        	cat <(echo "#header_line_3: latency:$lat,bandwith:$band") intel-ofi-$b-$a.csv > temp && mv temp intel-ofi-$b-$a.csv
        	cat <(echo "#header_line_2: $node1,$node2") intel-ofi-$b-$a.csv > temp && mv temp intel-ofi-$b-$a.csv
		cat <(echo "#header_line_1: mpirun -np 2  -env I_MPI_DEBUG 5 -env I_MPI_FABRICS ofi -env I_MPI_OFI_PROVIDER $b  -genv I_MPI_PIN_PROCESSOR_LIST 0,$i ./IMB_intel-gcc -msglog 28 -iter 100 -iter_policy multiple_np -off_cache -1 ") intel-ofi-$b-$a.csv > temp && mv temp intel-ofi-$b-$a.csv 
		echo "intelmpi,intel,$a,$eth,ofi,$b,$band,$lat">> section2.csv
	done
done

