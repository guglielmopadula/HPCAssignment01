from mpi4py import MPI
import os
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
#setting up topology and matrix division based on input
if int(sys.argv[4])==1:
	numprocsizex=int(sys.argv[5])
	numprocsizey=1
	numprocsizez=1
	topology = comm.Create_cart(dims = [numprocsizex] , periods = [False], reorder=False)

	
if int(sys.argv[4])==2:
	numprocsizex=int(sys.argv[5])
	numprocsizey=int(sys.argv[6])
	numprocsizez=1
	topology = comm.Create_cart(dims = [numprocsizex, numprocsizey],periods =[False, False], reorder=False)

if int(sys.argv[4])==3:
	numprocsizex=int(sys.argv[5])
	numprocsizey=int(sys.argv[6])
	numprocsizez=int(sys.argv[7])
	topology = comm.Create_cart(dims = [numprocsizex, numprocsizey, numprocsizez],periods =[False, False, False], reorder=False)

numprocsize=numprocsizex*numprocsizey*numprocsizez
newsize1=size1
newsize2=size2
newsize3=size3
#prepare padding if necessary
if size1%numprocsizex!=0:
	flag=1	
	newsize1=math.ceil(size1/numprocsizex)*numprocsizex
	
if size2%numprocsizey!=0:
	flag=1
	newsize2=math.ceil(size2/numprocsizey)*numprocsizex 

if size3%numprocsizez!=0:
	flag=1
	newsize3=math.ceil(size3/numprocsizez)*numprocsizez

localsize1=int(size1/numprocsizex)
localsize2=int(size2/numprocsizey)
localsize3=int(size3/numprocsizez)
localsize=localsize1*localsize2*localsize3
#randominzing and padding if necessary
for a in range(5):
	start_time = MPI.Wtime()
	global1=np.random.rand(size1,size2,size3)
	global2=np.random.rand(size1,size2,size3)

	if rank==0:
		if flag==1:
			newsize=newsize1*newsize2*newsize3	
			global1.shape=(size,)
			global2.shape=(size,)
			np.pad(global1, (0, newsize-size), 'constant')
			np.pad(global2, (0, newsize-size), 'constant')
			global1.shape=(newsize1,newsize2,newsize3)
			global2.shape=(newsize1,newsize2,newsize3)

#prepare local subarrays
	local1=np.zeros([localsize1,localsize2,localsize3])	
	local2=np.zeros([localsize1,localsize2,localsize3])
	global3=np.zeros([newsize1,newsize2,newsize3])
 #prepare scatterv
	tempType = MPI.DOUBLE.Create_subarray([newsize1,newsize2,newsize3], [localsize1,localsize2,localsize3], [0,0,0], order =    MPI.ORDER_C)
	tempType.Commit()
	submatrixType=tempType.Create_resized(0,8)
	submatrixType.Commit()
	counts=np.ones(numprocsize);
	displs=np.zeros(numprocsize);

	if rank == 0:
		counter=0
		for i in range(0,size1,localsize1):
			for j in range(0,size2,localsize2):
				for k in range(0,size3,localsize3):
					displs[counter]=j*size3+i*size2*size3+k

#scatterv					counter=counter+1	
	topology.Scatterv([global1, counts, displs, submatrixType], [local1, localsize, MPI.DOUBLE], root = 0)
#scatterv
	topology.Scatterv([global2, counts, displs, submatrixType], [local2, localsize, MPI.DOUBLE], root = 0)

#sum
	local=np.add(local1,local2)
#gatherv
	topology.Gatherv([local, localsize, MPI.DOUBLE], [global3, counts, displs, submatrixType], root=0)
#adjust size if nedded
	if flag==1:
		global1.shape=(newsize,)
		global2.shape=(newsize,)
		global3.shape=(newsize,)
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




