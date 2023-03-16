#!/usr/bin/env bash
#
# Extract time series from pre-filtered fMRI for thalamus connectivity analyses
#
# Native space:
#   thomas.nii.gz
#
# MNI space:
#   Schaefer2018_400Parcels_7Networks_order_FSLMNI152_1mm.nii.gz
#   1000subjects_TightThalamus_clusters007_ref.nii.gz
#
# Filtered data:
#   filtered_keepgm_noscrub_nadfmri.nii.gz
#   filtered_keepgm_noscrub_wadfmri.nii.gz
#   filtered_removegm_noscrub_nadfmri.nii.gz
#   filtered_removegm_noscrub_wadfmri.nii.gz

echo Extracting ROI signals
cd "${out_dir}"


## THOMAS ROIs (native space)

# Resample fMRI to THOMAS ROI space
echo THOMAS resample
for gm in keepgm removegm; do
    flirt -usesqform -applyxfm \
        -in filtered_${gm}_noscrub_nadfmri \
        -ref "${thomas_left}"/crop_t1 \
        -out thomas_left_${gm}
    flirt -usesqform -applyxfm \
        -in filtered_${gm}_noscrub_nadfmri \
        -ref "${thomas_right}"/crop_t1 \
        -out thomas_right_${gm}
done

# Extract signals
echo THOMAS extract
for gm in keepgm removegm; do
    fslmeants -i thomas_left_${gm} -o thomas_left_${gm}.txt --label="${thomas_left}"/thomas
    fslmeants -i thomas_right_${gm} -o thomas_right_${gm}.txt --label="${thomas_right}"/thomasr
done

# Convert to CSV and label appropriately
echo THOMAS reformat
thomas_to_csv.py


## Schaefer cortical ROIs (MNI space)

roi_img="${roi_dir}"/Schaefer2018/Schaefer2018_400Parcels_7Networks_order_FSLMNI152_2mm

# Resample fMRI to ROI space
echo Schaefer resample
for gm in keepgm removegm; do
    flirt -usesqform -applyxfm \
        -in filtered_${gm}_noscrub_nadfmri \
        -ref "${roi_img}" \
        -out schaefer_${gm}
done

# Extract signals
echo Schaefer extract
for gm in keepgm removegm; do
    fslmeants -i schaefer_${gm} -o schaefer_${gm}.txt --label="${roi_img}"
done

# Convert to CSV and label appropriately
echo Schaefer reformat
schaefer_to_csv.py



## Yeo thalamus ROIs (MNI space)

