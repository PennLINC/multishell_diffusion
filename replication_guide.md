Author: Adam Pines | Date: 4/12/19 | Replicator: Matthew Cieslak

Goal: To replicate comparative developmental and head-motion analyses of DTI, NODDI, and MAPL in five subjects

Input data: Initial Data consists of subjects' T1's, topup reference scan, and multi-shell DWI's (b=0, 300, 800, and 2000 in this instance). Pre-calculated transformation matrices are also utilized, as well as study templates.

Path to example input data (BBL INTERNAL ONLY): /data/joy/BBL/tutorials/exampleData/AMICO_NODDI/raw/

[Code Repository](https://github.com/PennBBL/multishell_diffusion)

## **1. Preprocessing (Raw --> Distortion corrected image)**

[Script](https://github.com/PennBBL/multishell_diffusion/blob/master/PreProc/wrap_MultiShell_PreProc.sh)

Syntax: `wrap_MultiShell_PreProc.sh`

This script will:
* Submit separate preprocessing jobs for each subject in its directory ($general)
* Create a log directory for each subject
* Make the directory structure for each subject's diffusion images
* Implement Mark Elliott's QA scripts to calculate image quality metrics and correct b-values
* Run FSL's _topup_ to calculate distortion estimations for phase encoding direction induced distortions
* Feed this correction is fed into FSL 5.0.11's _eddy_, the GPU version of this program can be accessed with a `1` flag (will require editing the wrapper to submit this flag)
* Register subject's T1s to diffusion sequence space using flirt Boundary based registration and ANTs, and use this T1 for masking purposes
* Estimate a DTI fit on the single-shelled scheme (b = 800) and multi shell (all shells) via mrtrix (https://mrtrix.readthedocs.io/en/latest/index.html)
* Estimate the NODDI model via AMICO (https://github.com/daducci/AMICO)

Output: topup, motion, and eddy corrected data with t1 mask. Also includes coregistrations (transforms via .mat files and needed coregistered images) for each subject. NODDI scalars (and their coregs) are also included in preproc - should output to an AMICO/NODDI folder within subject directory.

## **2. MAPL Fitting**

[Script](https://github.com/PennBBL/multishell_diffusion/blob/master/PostProc/wrap_MultiShell_mapl.sh)

Syntax: `wrap_MultiShell_mapl.sh`

This script will:
* Submit separate jobs for each subject in its directory ($general)
* Fit MAPL to the corrected diffusion data using dmipy (https://github.com/AthenaEPI/dmipy)
* Save MAP-MRI scalar outputs, as well as the basis function fits.

Output: RTAP,RTPP, and RTOP for subjects. Also can output basis function fits.

## **3. Tractography**

[Script](https://github.com/PennBBL/multishell_diffusion/blob/master/PostProc/wrap_determTract.sh)

Syntax: `wrap_determTract.sh`

This script will:
* Submit separate jobs for each subject in its directory ($general)
* Fit a diffusion tensor model in Camino (http://camino.cs.ucl.ac.uk/) using the wdt weighted tensor option(Jones & Basser, 2004)
* Utilize various T1 features to guide tractography (CSF as exclusion mask, white matter as inclusion mask)
* Run deterministic tractography on processed diffusion images
* Generate weighted connectivity matrices for diffusion metrics of interest

Output: Scalar weighted connectivity matrices.


## **4. Standard Space Developmental Effects (Mean White matter, voxelwise)**

_Here we have to extract the mean white matter value of each scalar. This is done in standard space using a standardized white matter mask for a basis of equivalence between subjects. First you have to_:

**4a) transform all subject scalar maps to the PNC template using ANTs.**

[Script](https://github.com/PennBBL/multishell_diffusion/blob/master/PostProc/wrap_MultiShell_std_space.sh)

Syntax: `wrap_MultiShell_std_space.sh`

This script will:

* Use previously calculated transforms to bring scalar maps to template space

Output: MAPL, NODDI, and DTI metrics in Standard PNC space in each subjects `/norm/` folder. 

**4b) mean values of all scalars from white matter mask in standard/PNC space**

[Script](https://github.com/PennBBL/multishell_diffusion/blob/master/PostProc/wm_mask_stats.sh)

Syntax: `wm_mask_stats.sh`

This script will:

* Extract the average value of each scalar within the specified mask, and output these values into a .txt file

Output: .txt files with mean scalar values of subjects' white matter

**4c) Voxelwise analyses**

_This step utilizes the voxel package in R (https://cran.r-project.org/web/packages/voxel/voxel.pdf). Example listed is for FA._

[Script](https://github.com/PennBBL/groupAnalysis/blob/master/version2/gam_voxelwise.R)

Syntax: `/data/joy/BBL/applications/R-3.5.1/bin/Rscript /data/jux/BBL/applications-from-joy/groupAnalysis/gam_voxelwise.R -c /data/joy/BBL/tutorials/exampleData/AMICO_NODDI/Voxelwise/rdsFiles/fa_voxelwise.rds -o /data/joy/BBL/tutorials/exampleData/AMICO_NODDI/Voxelwise/voxelwise_fa -p "path.val" -m /data/joy/BBL/tutorials/exampleData/AMICO_NODDI/templates/pnc_wm_prior_bin2mm.nii.gz -i include -u 'bblid' -f '~s(age,k=4)+meanRELrms.x' -n 1 -s 0 -r true -a "fdr" -k 1`

This script will:
* Calculate a generalized additive model at each voxel in standard space using the specified covariates.
* Output calculations (spatial P, P adjusted for multiple comparisons, T, and Z statistics)

For example, to run on ICVF and RTOP, replace fa_voxelwise.rds with icvf_voxelwise.rds and rtop_voxelwise.rds. Additionally, replace the output directory (`Voxelwise/voxelwise_fa` -> `Voxelwise/voxelwise_icvf`), etc.

Output: Voxelwise maps of GAM evaluations of input terms. Map used for manuscript was gamPadjusted_fdr_sage.nii.gz. 

## **5. Edgewise analyses**

_Here we use scalar weighted tractography edges to run analyses. This involves taking the squareform of each matrix (vectorizing), stacking them into one 2-D matrix, making a generalized additive model on each possible edge, and FDR-correcting them_

**5a) Squareforming and stacking**

[Script](https://github.com/PennBBL/multishell_diffusion/blob/master/PostProc/squareform_new.m)

Syntax: `matlab -nodisplay -r 'run squareform_new.m' -r 'exit'`

This script will:
* Vectorize and saves connectivity values to subject directories (in Matlab)

[Script](https://github.com/PennBBL/multishell_diffusion/blob/master/PostProc/SQcombine.sh)

Syntax: `SQcombine.sh`

This script will:
* Combine values from squareform_new.m and print them out concatenated in the user's home directory

**5b) GAM/p-val correction**

[Script](https://github.com/PennBBL/multishell_diffusion/blob/master/PostProc/edge_gams.R)

Syntax: `Rscript edge_gams.R`

This script will:
* Load in QA data for inclusion as a covariate in models
* Utilize the concatenated matrix of all possible structural connections in all subjects to run construct a generalized additive model around each one
* Evaluate the number of edges related to covariates at the p < 0.05 level, after FDR correcting for multiple comparisons
