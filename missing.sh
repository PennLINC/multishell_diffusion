#!/bin/bash


general=/data/jux/BBL/studies/grmpy/rawData/*/*/


for i in $general;do 
	bblIDs=$(echo ${i}|cut -d'/' -f8 |sed s@'/'@' '@g);
	SubDate_and_ID=$(echo ${i}|cut -d'/' -f9|sed s@'/'@' '@g|sed s@'x'@'x'@g)
	Date=$(echo ${SubDate_and_ID}|cut -d',' -f1)
	ID=$(echo ${SubDate_and_ID}|cut -d',' -f2)
	input=/data/jux/BBL/studies/grmpy/rawData/${bblIDs}/${SubDate_and_ID}/
	output=/data/jux/BBL/projects/multishell_diffusion/processedData/multishellPipelineFall2017/${bblIDs}/${SubDate_and_ID}/
	if [ ! -d "${output}/tractography/*sc.csv" ] && [ -d "${input}/DTI_MultiShell_117dir" ]; then
	echo $bblIDs >> ~/MissingTract.txt
fi
done
