#!/usr/bin/env bash
#
# Main entrypoint for ccalc-thal. Parses arguments and calls the sub-pieces

# Initialize defaults for any input parameters where that seems useful
export thomas_left_dir=/INPUTS/LEFT
export thomas_right_dir=/INPUTS/RIGHT
export roi_dir=/opt/ccalc-thal/rois
export fmri_niigz=/INPUTS/filtered_removegm_noscrub_nadfmri.nii.gz
export wfmri_niigz=/INPUTS/filtered_removegm_noscrub_wadfmri.nii.gz
export label_info=
export exclude_rois=
export densities="0.05:0.05:0.8"
export hist_density="0.10"
export out_dir=/OUTPUTS

# Parse input options
while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
        --fmri_niigz)       export fmri_niigz="$2";       shift; shift ;;
        --wfmri_niigz)      export wfmri_niigz="$2";      shift; shift ;;
        --thomas_left_dir)  export thomas_left_dir="$2";  shift; shift ;;
        --thomas_right_dir) export thomas_right_dir="$2"; shift; shift ;;
        --roi_dir)          export roi_dir="$2";          shift; shift ;;
        --label_info)       export label_info="$2";       shift; shift ;;
        --exclude_rois)     export exclude_rois="$2";     shift; shift ;;
        --densities)        export densities="$2";        shift; shift ;;
        --hist_density)     export hist_density="$2";     shift; shift ;;
        --out_dir)          export out_dir="$2";          shift; shift ;;
        *) echo "Input ${1} not recognized"; shift ;;
    esac
done

# Copy filtered fMRI images
#cp "${fmri_niigz}" "${out_dir}"/fmri.nii.gz
#cp "${wfmri_niigz}" "${out_dir}"/wfmri.nii.gz

# ROI time series extraction
roi_extract.sh

# Matlab part for network computations
run_entrypoint.sh \
    out_dir "${out_dir}" \
    roi_dir "${roi_dir}" \
    densities "${densities}" \
    hist_density "${hist_density}"


