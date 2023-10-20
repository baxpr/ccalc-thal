#!/usr/bin/env bash

docker run \
    --mount type=bind,src=$(pwd -P)/INPUTS,dst=/INPUTS \
    --mount type=bind,src=$(pwd -P)/OUTPUTS,dst=/OUTPUTS \
    ccalc-thal:test \
        --fmri_niigz /INPUTS/filtered_removegm_noscrub_nadfmri.nii.gz \
        --wfmri_niigz /INPUTS/filtered_removegm_noscrub_wadfmri.nii.gz \
        --thomas_left_dir /INPUTS/LEFT \
        --thomas_right_dir /INPUTS/RIGHT \
        --roi_dir /opt/ccalc-thal/rois \
        --label_info "TEST LABEL" \
        --exclude_rois "3,5,6" \
        --densities "0.05:0.05:8" \
        --hist_density "0.10" \
        --out_dir /OUTPUTS

