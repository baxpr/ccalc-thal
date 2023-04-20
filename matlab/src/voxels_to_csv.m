function voxels_to_csv(fmri_nii,mask_nii,csv_file)

Vfmri = spm_vol(fmri_nii);
Vmask = spm_vol(mask_nii);
spm_check_orientations([Vfmri; Vmask]);

Yfmri = spm_read_vols(Vfmri);
Yfmri = reshape(Yfmri,[],size(Yfmri,4))';

Ymask = spm_read_vols(Vmask);
Ymask = reshape(Ymask,[],1)';

keeps = Ymask>0;

roidata = Yfmri(:,keeps);

csv = array2table(roidata,'VariableNames', ...
    cellfun(@(x) sprintf('v%06d',x),num2cell(1:size(roidata,2)), ...
    'UniformOutput',false));

writetable(csv,csv_file);

return
