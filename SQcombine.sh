#!/bin/bash

#Combine Squareforms into csv

# Subject locations and loop
general=$(cat ~/torun.txt)

for i in $general;do 
	bblIDs=$(echo ${i}|cut -d'/' -f8 |sed s@'/'@' '@g);
	SubDate_and_ID=$(echo ${i}|cut -d'/' -f9|sed s@'/'@' '@g|sed s@'x'@'x'@g)
	Date=$(echo ${SubDate_and_ID}|cut -d',' -f1)
	ID=$(echo ${SubDate_and_ID}|cut -d',' -f2)
	output=$(cat /data/jux/BBL/projects/multishell_diffusion/processedData/multishellPipelineFall2017/${bblIDs}/*/tractography/${bblIDs}*SCcon_ind_nets.csv)
	##meanRELrms=$(echo ${output}|cut -d' ' -f 7)
	##meanABSrms=$(echo ${output}|cut -d' ' -f 6)
	##tsnr0=$(echo ${output}|cut -d' ' -f 10)	
	##tsnr300=$(echo ${output}|cut -d' ' -f 22)
	##tsnr800=$(echo ${output}|cut -d' ' -f 34)
	##tsnr2000=$(echo ${output}|cut -d' ' -f 46)		
	regurg=$(echo ${bblIDs}, ${output})
	echo $regurg >> ~/grmpy/10_1/SCcon_ind_nets.csv
done

