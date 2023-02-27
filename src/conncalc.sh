#!/usr/bin/env bash
#
# Main entrypoint for conncalc. Parses arguments and calls the sub-pieces

# Initialize defaults for any input parameters where that seems useful
export connmaps_out=no
export mask_niigz=none
export fwhm=8
export label_info=
export roidefinv_niigz=none
export out_dir=/OUTPUTS

# Parse input options
while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in      
        --t1_niigz)        export t1_niigz="$2";        shift; shift ;;
        --mask_niigz)      export mask_niigz="$2";      shift; shift ;;
        --roi_niigz)       export roi_niigz="$2";       shift; shift ;;
        --roilabel_csv)    export roilabel_csv="$2";    shift; shift ;;
        --roidefinv_niigz) export roidefinv_niigz="$2"; shift; shift ;;
        --removegm_niigz)  export removegm_niigz="$2";  shift; shift ;;
        --keepgm_niigz)    export keepgm_niigz="$2";    shift; shift ;;
        --meanfmri_niigz)  export meanfmri_niigz="$2";  shift; shift ;;
        --fwhm)            export fwhm="$2";            shift; shift ;;
        --connmaps_out)    export connmaps_out="$2";    shift; shift ;;
        --label_info)      export label_info="$2";      shift; shift ;;
        --out_dir)         export out_dir="$2";         shift; shift ;;
        *) echo "Input ${1} not recognized"; shift ;;
    esac
done

# Copy and unzip images

# 


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

