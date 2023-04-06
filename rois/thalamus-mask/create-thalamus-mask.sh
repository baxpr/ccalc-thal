#!/usr/bin/env bash
#
# Yeo thalamus ROIs are in FSL's MNI152 space

# Thalamus mask created by binarizing, then dilating Yeo thalamus
fslmaths ../Yeo-thalamus/1000subjects_TightThalamus_clusters007_ref \
    -bin -dilF \
    thalamus-mask
