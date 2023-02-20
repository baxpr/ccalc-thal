#!/bin/bash
#
# How the combined ROI image was created using FSL.

# Make label file
cat > AABHHIP_LR-labels.csv <<HERE
1,BNST_L
2,BNST_R
3,Amygdala_L_HO50
4,Amygdala_R_HO50
5,Hippocampus_Ant_L_HO
6,Hippocampus_Ant_R_HO
7,Hypothalamus_L
8,Hypothalamus_R
9,Insula_anterior_left
10,Insula_anterior_right
11,vmPFC_L
12,vmPFC_R
13,rACC_L
14,rACC_R
HERE

# First combine the 2mm images in their space to avoid overlap later
fslmaths Amygdala_L_HO50       -bin -mul  3          tmp
fslmaths Amygdala_R_HO50       -bin -mul  4 -add tmp tmp
fslmaths Hippocampus_Ant_L_HO  -bin -mul  5 -add tmp tmp
fslmaths Hippocampus_Ant_R_HO  -bin -mul  6 -add tmp tmp
fslmaths Hypothalamus_L        -bin -mul  7 -add tmp tmp
fslmaths Hypothalamus_R        -bin -mul  8 -add tmp tmp
fslmaths vmPFC_L               -bin -mul 11 -add tmp tmp
fslmaths vmPFC_R               -bin -mul 12 -add tmp tmp

# ACC overlaps by a vew voxels with vmPFC - give vmPFC priority
fslmaths tmp -bin -sub 1 -mul -1 tmpmask
fslmaths ACC_left  -bin -mas tmpmask -mul 13 -add tmp tmp
fslmaths ACC_right -bin -mas tmpmask -mul 14 -add tmp AAHHP_2mm
rm tmp.nii.gz tmpmask.nii.gz

# Resample to the BNST space
for f in AAHHP_2mm Insula_anterior_left Insula_anterior_right ; do
	flirt -in ${f} -ref BNST_LR -applyxfm -usesqform -interp nearestneighbour -out r${f}
done

# Combine into single image. Uses the BNST already made with
# combine_BNST_rois.sh
fslmaths BNST_LR -add rAAHHP_2mm                      tmp
fslmaths rInsula_anterior_left  -bin -mul  9 -add tmp tmp
fslmaths rInsula_anterior_right -bin -mul 10 -add tmp AABHHIP_LR

# Clean up
rm AAHHP_2mm.nii.gz tmp.nii.gz r*.nii.gz

