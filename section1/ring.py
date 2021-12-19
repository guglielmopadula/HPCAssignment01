from mpi4py import MPI
import numpy as np
import os

comm = MPI.COMM_WORLD
status = MPI.Status()
request= MPI.Request()
size = comm.Get_size()
ring = comm.Create_cart(dims = [size],periods =[True],reorder=False)
rank= ring.Get_rank()
leftneig,rightneig = ring.Shift(direction = 0,disp=1)
sum=0.0
for i in range(10000):
	start_time = MPI.Wtime()
	sendleft=np.array(0,dtype='i')-rank
	sendright=np.array(0,dtype='i')+rank
	smg=0
	for i in range(size):
		receiveright=np.empty(1,dtype='i');
		receiveleft=np.empty(1,dtype='i');
		ring.Send([sendleft, 1, MPI.INT], dest=leftneig, tag=10*(rank+i+size)%size)
		ring.Recv([receiveright, 1, MPI.INT],source=rightneig, tag=10*(rank+i+1+size)%size)
		ring.Send([sendright, 1, MPI.INT]  , dest=rightneig, tag=10*(rank+i+size)%size)
		ring.Recv([receiveleft, 1, MPI.INT]  ,source=leftneig, tag=10*(rank+i-1+size)%size)
		sendleft=receiveright-rank;
		sendright=receiveleft+rank;
		smg=smg+2;
	sendleft=sendleft+rank;
	sendright=sendright-rank;
	end_time= MPI.Wtime()
	sum=sum+(end_time-start_time)

sum=sum/10000;
if rank==0:
	print("{:.6f}".format(sum))

filew = open("ring.txt", "a")
print('I am process '+str(rank)+' and i have received '+str(smg)+' messages. My final messages have tag '+str(10*rank)+' and value '+str(sendleft[0])+','+str(sendright[0]),file=filew)
filew.close()	


