#!/bin/bash

a=$1
general=/data/jux/BBL/studies/grmpy/rawData/${a}/*/


for i in $general;do 
	bblIDs=$(echo ${i}|cut -d'/' -f8 |sed s@'/'@' '@g);
	SubDate_and_ID=$(echo ${i}|cut -d'/' -f9|sed s@'/'@' '@g|sed s@'x'@'x'@g)
	Date=$(echo ${SubDate_and_ID}|cut -d',' -f1)
	ID=$(echo ${SubDate_and_ID}|cut -d',' -f2)
	input=/data/jux/BBL/studies/grmpy/rawData/${bblIDs}/${SubDate_and_ID}/
	output=/data/jux/BBL/projects/multishell_diffusion/processedData/multishellPipelineFall2017/${bblIDs}/${SubDate_and_ID}/
	if [ ! -d "${output}/AMICO/NODDI" ]; then

	########################################################
	###                AMICO/NODDI			     ###
	########################################################

	# Generate AMICO scheme (edit paths for files like mask and eddy output in generateamicoM script)
	/data/jux/BBL/projects/multishell_diffusion/multishell_diffusionScripts/amicoSYRP/scripts/generateAmicoM_AP.pl $bblIDs $SubDate_and_ID

	# Run AMICO
	# runAmicoScript=/data/jux/BBL/projects/multishell_diffusion/processedData/multishellPipelineFall2017/${bblIDs}/${SubDate_and_ID}/AMICO/runAMICO.m
	/data/jux/BBL/projects/multishell_diffusion/multishell_diffusionScripts/amicoSYRP/scripts/runAmico.sh /data/jux/BBL/projects/multishell_diffusion/processedData/multishellPipelineFall2017/${bblIDs}/${SubDate_and_ID}/AMICO/runAMICO.m

	#pushd /data/jux/BBL/projects/multishell_diffusion/processedData/multishellPipelineFall2017/${bblIDs}/${SubDate_and_ID}/AMICO/
	#matlab -nosplash -nodesktop -r "runAMICO.m; exit()"
	#popd
	
	# Make NODDI Dir
	NODDIdir=/data/jux/BBL/projects/multishell_diffusion/processedData/multishellPipelineFall2017/${bblIDs}/${SubDate_and_ID}/AMICO/NODDI
	
	# Zip and rename native space NODDI outputs to subejct specific
	gzip $NODDIdir/*.nii
	mv $NODDIdir/FIT_dir.nii.gz $NODDIdir/${bblIDs}_${SubDate_and_ID}_FIT_dir.nii.gz 
	mv $NODDIdir/FIT_ICVF.nii.gz $NODDIdir/${bblIDs}_${SubDate_and_ID}_FIT_ICVF.nii.gz 
	mv $NODDIdir/FIT_ISOVF.nii.gz $NODDIdir/${bblIDs}_${SubDate_and_ID}_FIT_ISOVF.nii.gz 
	mv $NODDIdir/FIT_OD.nii.gz $NODDIdir/${bblIDs}_${SubDate_and_ID}_FIT_OD.nii.gz 
	

	rm $out/AMICO/*.nii*
	rm $out/AMICO/bvals
	rm $out/AMICO/bvecs


fi
done
