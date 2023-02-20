#!/usr/bin/env bash

echo Organize outputs

cd "${out_dir}"

mkdir PDF
mv conncalc.pdf PDF

mkdir T1
mv t1.nii T1
gzip T1/t1.nii

if [[ "${connmaps_out}" == "yes" ]] ; then

    mkdir ZMAPS_KEEPGM
    mv connmaps/Z_*_keepgm.nii connmaps/sZ_*_keepgm.nii ZMAPS_KEEPGM
    gzip ZMAPS_KEEPGM/*.nii

    mkdir ZMAPS_REMOVEGM
    mv connmaps/Z_*_removegm.nii connmaps/sZ_*_removegm.nii ZMAPS_REMOVEGM
    gzip ZMAPS_REMOVEGM/*.nii

    mkdir MASK
    mv rmask.nii MASK/rmask.nii
    gzip MASK/rmask.nii

fi

mkdir RMATRIX
mv R_*.csv RMATRIX

mkdir ZMATRIX
mv Z_*.csv ZMATRIX
 
mkdir DFMATRIX
mv ?df_*.csv DFMATRIX

mkdir ROIS
mv rroi.nii ROIS/rroi.nii
gzip ROIS/rroi.nii

mkdir ROILABELS
mv rroi-labels.csv ROILABELS

mkdir ROIDATA
mv roidata_*.csv ROIDATA
