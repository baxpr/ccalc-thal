#!/usr/bin/env bash
#
# Extract time series from pre-filtered fMRI for thalamus connectivity analyses
#
# Native space:
#   thomas.nii.gz
#
# MNI space:
#   Schaefer2018_400Parcels_7Networks_order_FSLMNI152_2mm.nii.gz
#   1000subjects_TightThalamus_clusters007_ref.nii.gz
#
# Filtered data e.g.:
#   filtered_removegm_noscrub_nadfmri.nii.gz
#   filtered_removegm_noscrub_wadfmri.nii.gz


echo Extracting ROI signals
cd "${out_dir}"


## THOMAS ROIs (native space)

# Resample fMRI to THOMAS ROI space
echo THOMAS resample
flirt -usesqform -applyxfm \
    -in fmri \
    -ref "${thomas_left}"/crop_t1 \
    -out thomas_left
flirt -usesqform -applyxfm \
    -in fmri \
    -ref "${thomas_right}"/crop_t1 \
    -out thomas_right

# Extract signals
echo THOMAS extract
fslmeants -i thomas_left -o thomas_left.txt --label="${thomas_left}"/thomas
fslmeants -i thomas_right -o thomas_right.txt --label="${thomas_right}"/thomasr

# Convert to CSV and label appropriately
echo THOMAS reformat
thomas_to_csv.py


## Schaefer cortical ROIs (MNI space)
# Exclude some ROIs if requested

roi_img="${roi_dir}"/Schaefer2018/Schaefer2018_400Parcels_7Networks_order_FSLMNI152_2mm
networks_csv="${roi_dir}"/Schaefer2018/Schaefer2018_400Parcels_7Networks_order_FSLMNI152_2mm.Centroid_RAS.csv

# Resample fMRI to ROI space
echo Schaefer resample
flirt -usesqform -applyxfm \
    -in wfmri \
    -ref "${roi_img}" \
    -out schaefer

# Extract signals
echo Schaefer extract
fslmeants -i schaefer -o schaefer.txt --label="${roi_img}"

# Convert to CSV and label appropriately
echo Schaefer reformat
roi_to_csv.py "${roi_img}-labels.csv" schaefer.txt

# Add network labels to ROI list
add_networks.py "${networks_csv}" "${out_dir}"

# Exclude some ROIs if requested
if [[ -n "${exclude_rois}" ]]; then
    mv schaefer.csv schaefer_orig.csv
    mv schaefer-networks.csv schaefer-networks_orig.csv
    exclude_rois.py \
        schaefer_orig.csv schaefer.csv \
        schaefer-networks_orig.csv schaefer-networks.csv \
        "${exclude_rois}"
fi


## Yeo thalamus ROIs (MNI space)

# Hemispheres joined
#roi_img="${roi_dir}"/Yeo-thalamus/1000subjects_TightThalamus_clusters007_ref

# Hemispheres split
roi_img="${roi_dir}"/thalamus-mask/yeo7_thalamus_lr

# Resample fMRI to ROI space
echo Yeo resample
flirt -usesqform -applyxfm \
    -in wfmri \
    -ref "${roi_img}" \
    -out yeo

# Extract signals
echo Yeo extract
fslmeants -i yeo -o yeo.txt --label="${roi_img}"

# Convert to CSV and label appropriately
echo Yeo reformat
roi_to_csv.py "${roi_img}-labels.csv" yeo.txt
