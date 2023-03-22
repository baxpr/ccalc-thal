#!/usr/bin/env bash
#
# Main entrypoint for ccalc-thal. Parses arguments and calls the sub-pieces

# Initialize defaults for any input parameters where that seems useful
export thomas_left=/INPUTS/LEFT
export thomas_right=/INPUTS/RIGHT
export roi_dir=/opt/ccalc-thal/rois
export fmri_keepgm_niigz=/INPUTS/filtered_keepgm_noscrub_nadfmri.nii.gz
export wfmri_keepgm_niigz=/INPUTS/filtered_keepgm_noscrub_wadfmri.nii.gz
export fmri_removegm_niigz=/INPUTS/filtered_removegm_noscrub_nadfmri.nii.gz
export wfmri_removegm_niigz=/INPUTS/filtered_removegm_noscrub_wadfmri.nii.gz
export label_info=
export out_dir=/OUTPUTS

# Parse input options
while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
        --fmri_keepgm_niigz)     export fmri_keepgm_niigz="$2";     shift; shift ;;
        --wfmri_keepgm_niigz)    export wfmri_keepgm_niigz="$2";    shift; shift ;;
        --fmri_removegm_niigz)   export fmri_removegm_niigz="$2";   shift; shift ;;
        --wfmri_removegm_niigz)  export wfmri_removegm_niigz="$2";  shift; shift ;;
        --thomas_left)     export thomas_left="$2";    shift; shift ;;
        --thomas_right)    export thomas_right="$2";   shift; shift ;;
        --roi_dir)         export roi_dir="$2";        shift; shift ;;
        --label_info)      export label_info="$2";     shift; shift ;;
        --out_dir)         export out_dir="$2";        shift; shift ;;
        *) echo "Input ${1} not recognized"; shift ;;
    esac
done

# Copy filtered fMRI images
cp "${fmri_keepgm_niigz}" "${out_dir}"/fmri_keepgm.nii.gz
cp "${wfmri_keepgm_niigz}" "${out_dir}"/wfmri_keepgm.nii.gz
cp "${fmri_removegm_niigz}" "${out_dir}"/fmri_removegm.nii.gz
cp "${wfmri_removegm_niigz}" "${out_dir}"/wfmri_removegm.nii.gz

# ROI time series extraction
roi_extract.sh




##############################################################
# draft/previous below here

exit 0

# Most of the work is done in matlab
run_spm12.sh ${MATLAB_RUNTIME} function conncalc \
    t1_niigz "${t1_niigz}" \
    mask_niigz "${mask_niigz}" \
    roi_niigz "${roi_niigz}" \
    roilabel_csv "${roilabel_csv}" \
    removegm_niigz "${removegm_niigz}" \
    keepgm_niigz "${keepgm_niigz}" \
    meanfmri_niigz "${meanfmri_niigz}" \
    roidefinv_niigz "${roidefinv_niigz}" \
    connmaps_out "${connmaps_out}" \
    label_info "${label_info}" \
    fwhm "${fwhm}" \
    out_dir "${out_dir}"


# PDF creation and cleanup is done in bash
. $FREESURFER_HOME/SetUpFreeSurfer.sh
export XDG_RUNTIME_DIR=/tmp

ss_roi.sh

if [[ ${connmaps_out} == "yes" ]]; then
    cd "${out_dir}"
    ss_conn.sh
    convert connmatrix.png page_fmri.png page_t1.png coreg.png page_conn*.png \
        conncalc.pdf
else
    cd "${out_dir}"
    convert connmatrix.png page_fmri.png page_t1.png coreg.png \
        conncalc.pdf
fi

organize_outputs.sh

