function voxels_to_csv(fmri_nii,mask_nii,networks_nii,data_csv,network_csv)

Vfmri = spm_vol(fmri_nii);
Vmask = spm_vol(mask_nii);
Vnetworks = spm_vol(networks_nii);
spm_check_orientations([Vfmri; Vmask; Vnetworks]);

Yfmri = spm_read_vols(Vfmri);
Yfmri = reshape(Yfmri,[],size(Yfmri,4))';

Ymask = spm_read_vols(Vmask);
Ymask = reshape(Ymask,[],1)';

Ynetworks = spm_read_vols(Vnetworks);
Ynetworks = reshape(Ynetworks,[],1)';

keeps = Ymask>0;

roidata = Yfmri(:,keeps);
networks = Ynetworks(:,keeps)';

regions = cellfun(@(x) sprintf('voxel_%06d',x),num2cell(1:size(roidata,2)), ...
    'UniformOutput',false);

datacsv = array2table(roidata,'VariableNames',regions);
writetable(datacsv,data_csv);

networkcsv = table(regions',networks,'VariableNames',{'Region','Network'});
writetable(networkcsv,network_csv);

return
