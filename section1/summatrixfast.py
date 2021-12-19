from mpi4py import MPI
import numpy as np
import sys
import math
comm = MPI.COMM_WORLD
status = MPI.Status()
request= MPI.Request()
numprocs = comm.Get_size()
rank= comm.Get_rank()
size1=int(sys.argv[1])
size2=int(sys.argv[2])
size3=int(sys.argv[3])
size=size1*size2*size3
flag=0
sum=0
localsize=int(size/numprocs);
if size%numprocs!=0:
	localsize=int(math.ceil(size/numprocs))
	flag=1	
	newsize=localsize*numprocs
	
for a in range(5):
	start_time = MPI.Wtime()
	global1=np.random.rand(size1,size2,size3)
	global2=np.random.rand(size1,size2,size3)
	if rank==0:
		if flag==1:
#Padding if necessary
			global1.shape=(size,)
			global2.shape=(size,)
			np.pad(global1, (0, newsize-size), 'constant')
			np.pad(global2, (0, newsize-size), 'constant')

	local1=np.zeros(localsize)	
	local2=np.zeros(localsize)

	if flag==0:
		global3=np.zeros([size1,size2,size3])
	else:
		global3=np.zeros(newsize);
#scatter 
	comm.Scatter([global1, localsize, MPI.DOUBLE], local1, root=0)
	comm.Scatter([global2, localsize, MPI.DOUBLE], local2, root=0)
#sum
	local=np.add(local1,local2)
#
	comm.Gather([local, localsize, MPI.DOUBLE], global3, root=0)
#restore matrix to original size
	if flag==1:
		global3=global3[0:(size)]
		global1=global1[0:(size)]
		global2=global2[0:(size)]
		global3.shape=(size1,size2,size3)
		global2.shape=(size1,size2,size3)
		global1.shape=(size1,size2,size3)	
	end_time = MPI.Wtime()
	sum=sum+end_time-start_time

sum=sum/5	
if rank==0:
	print("{:.2f}".format(sum))



