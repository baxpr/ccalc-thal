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
    -out fmri_thomas_left
flirt -usesqform -applyxfm \
    -in fmri \
    -ref "${thomas_right}"/crop_t1 \
    -out fmri_thomas_right

# Extract signals
echo THOMAS extract
fslmeants -i fmri_thomas_left -o thomas_left.txt --label="${thomas_left}"/thomas
fslmeants -i fmri_thomas_right -o thomas_right.txt --label="${thomas_right}"/thomasr

# Convert to CSV and label appropriately
echo THOMAS reformat
thomas_to_csv.py


## Schaefer cortical ROIs (MNI space)
# Exclude some ROIs if requested

roi_img="${roi_dir}"/Schaefer2018/Schaefer2018_400Parcels_7Networks_order_FSLMNI152_2mm

# Resample fMRI to ROI space
echo Schaefer resample
flirt -usesqform -applyxfm \
    -in wfmri \
    -ref "${roi_img}" \
    -out wfmri_schaefer

# Extract signals
echo Schaefer extract
fslmeants -i wfmri_schaefer -o schaefer.txt --label="${roi_img}"

# Copy community info
cp "${roi_img}-labels.csv" schaefer-networks.csv

# Convert to CSV and label appropriately
echo Schaefer reformat
roi_to_csv.py schaefer-networks.csv schaefer.txt

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
    -out wfmri_yeo

# Extract signals
echo Yeo extract
fslmeants -i wfmri_yeo -o yeo.txt --label="${roi_img}"

# Copy community info
cp "${roi_img}-labels.csv" yeo-networks.csv

# Convert to CSV and label appropriately
echo Yeo reformat
roi_to_csv.py yeo-networks.csv yeo.txt


## Yeo thalamus voxelwise ROIs (MNI space)

# Hemispheres split
roi_img="${roi_dir}"/thalamus-mask/thalamus-voxelwise

# Resample fMRI to ROI space is not needed (already done above)

# Extract signals
echo Yeo voxelwise extract
fslmeants -i wfmri_yeo -o yeo-voxels.txt --label="${roi_img}"

# Copy community info
cp "${roi_img}-labels.csv" yeo-voxels-networks.csv

# Convert to CSV and label appropriately
echo Yeo voxelwise reformat
roi_to_csv.py yeo-voxels-networks.csv yeo-voxels.txt
