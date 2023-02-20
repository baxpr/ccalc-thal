#!/usr/bin/env bash

# ROIs on t1 and mean fmri, axial slices +x / -y mm from center of mass of mean fmri

echo Screenshots ROI

thedate=$(date)

# Work in output directory
cd ${out_dir}

# Find center of mass of mean fmri
run_spm12.sh ${MATLAB_RUNTIME} function ctr_of_mass meanfmri.nii 0 ${out_dir}/com.txt
com=$(cat com.txt)
#rm com.txt
XYZ=(${com// / })

# Axial slices to show, relative to COM in mm
for sl in -040 -030 -020 -010 000 010 020 030 040 050 060; do

    Z=$(echo "${XYZ[2]} + ${sl}" | bc -l)
    echo "    Slice ${sl} at ${XYZ[0]} ${XYZ[1]} ${Z}"

    freeview \
        -v meanfmri.nii \
        -v rroi.nii:colormap=lut:outline=yes \
        -viewsize 800 800 --layout 1 --zoom 1.2 --viewport axial \
        -ras ${XYZ[0]} ${XYZ[1]} ${Z} \
        -ss slice_fmri_${sl}.png      
    
	freeview \
        -v t1.nii \
        -v rroi.nii:colormap=lut:outline=yes \
        -viewsize 800 800 --layout 1 --zoom 1.2 --viewport axial \
        -ras ${XYZ[0]} ${XYZ[1]} ${Z} \
        -ss slice_t1_${sl}.png

done

# Combine into single page
montage -mode concatenate slice_fmri_-0{4,3,2,1}*.png slice_fmri_0*.png \
    -tile 3x4 -quality 100 -background black -gravity center \
    -border 20 -bordercolor black page_fmri.png

convert \
    -size 2250x3000 xc:white -density 300 \
    -gravity center \( page_fmri.png -resize 2000x \) -composite \
    -gravity North -pointsize 12 -annotate +0+100 \
    "ROIs on mean fMRI" \
    -gravity SouthEast -pointsize 12 -annotate +100+100 "${thedate}" \
    -gravity NorthWest -pointsize 12 -annotate +100+200 "${label_info}" \
    page_fmri.png

montage -mode concatenate slice_t1_-0{4,3,2,1}*.png slice_t1_0*.png \
    -tile 3x4 -quality 100 -background black -gravity center \
    -border 20 -bordercolor black page_t1.png

convert \
    -size 2250x3000 xc:white -density 300 \
    -gravity center \( page_t1.png -resize 2000x \) -composite \
    -gravity North -pointsize 12 -annotate +0+100 \
    "ROIs on T1" \
    -gravity SouthEast -pointsize 12 -annotate +100+100 "${thedate}" \
    -gravity NorthWest -pointsize 12 -annotate +100+200 "${label_info}" \
    page_t1.png

# Clean up
rm slice_*.png
