#!/bin/bash
#
# How the combined ROI image was created using FSL.

# Combine R and L BNST ROIs into single image
fslmaths BNST_3T_L -bin -mul 1          tmp
fslmaths BNST_3T_R -bin -mul 2 -add tmp BNST_LR

# Make label file
cat > BNST_LR-labels.csv <<HERE
1,BNST_L
2,BNST_R
HERE
