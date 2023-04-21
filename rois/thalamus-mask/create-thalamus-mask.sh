#!/usr/bin/env bash
#
# Yeo thalamus ROIs are in FSL's MNI152 space

# Thalamus mask created by binarizing Yeo thalamus
# Could add -dilF to dilate
fslmaths ../Yeo-thalamus/1000subjects_TightThalamus_clusters007_ref \
    -bin \
    thalamus-mask
