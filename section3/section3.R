#!/usr/bin/env Rscript
args = commandArgs(trailingOnly=TRUE)
mlu=as.double(args[1]) 
L=as.integer(args[2])
map=args[3]  
n=as.integer(args[4])  
mlu1=as.double(args[5])
latency=as.double(args[7])
band=as.double(args[6])

timesing=L^3/(1024^2*mlu1)
k=1
c=L^2*2*k*8/(1024)^2
tc=c/band+k*latency*10^(-6)
mluest=L^3*n/((timesing+tc)*1024^2)

inveff=mlu1*n/mlu
inveffest=mlu1*n/mluest

str=paste(n,map,L,round(latency, digits=4),round(band,digits=4),round(timesing,digits=4),k,round(c,digits=4),round(tc,digits=4),round(mluest,digits=4),round(mlu, digits=4),round(inveffest, digits=4),round(inveff, digits=4),sep=",")
str
