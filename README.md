## ROI sets

### Native space

- THOMAS 12 per hemisphere

### MNI space

- Schaefer 400
- Yeo7 thalamus


## Inputs

        --fmri_niigz
        --wfmri_niigz
        --thomas_left_dir
        --thomas_right_dir
        --roi_dir
        --label_info
        --exclude_rois
        --out_dir
  

## Outputs

All are R and Z.

- 400 Schaefer connectivity maps, MNI space, masked to Yeo7 thalamus to save space
- 400+12 Schaefer+THOMAS matrix
- 400+7 Schaefer+Yeo7 matrix
