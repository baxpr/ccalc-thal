function meanPC_to_image(mask_nii,meanPC_csv,meanPC_nii)

% Read mean PC from csv and drop the densities column
meanPC = readtable(meanPC_csv);
meanPC = table2array(meanPC(:,2:end));

Vmask = spm_vol(mask_nii);
Ymask = spm_read_vols(Vmask);
keeps = Ymask(:) > 0;

Yout = zeros(size(Ymask));
Yout(keeps) = meanPC;
Vout = rmfield(Vmask,'pinfo');
Vout.fname = meanPC_nii;
spm_write_vol(Vout,Yout);

