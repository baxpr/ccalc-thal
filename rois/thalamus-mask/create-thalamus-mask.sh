#!/usr/bin/env bash
#
# Thalamus mask created by binarizing, then dilating Yeo thalamus

fslmaths ../Yeo-thalamus/1000subjects_TightThalamus_clusters007_ref \
    -bin -dilF \
    thalamus-mask
