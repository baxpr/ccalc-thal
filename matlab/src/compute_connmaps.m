function compute_connmaps(roi_csv,fmri_nii,mask_nii,connmap_dir)

% Load ROI signals
roi_data = readtable(roi_csv);

% Load fmri
Vfmri = spm_vol(fmri_nii);
Yfmri = spm_read_vols(Vfmri);
osize = size(Yfmri);
rYfmri = reshape(Yfmri,[],osize(4))';

% Load mask
Vmask = spm_vol(mask_nii);
spm_check_orientations([Vfmri;Vmask]);
Ymask = spm_read_vols(Vmask);

% Which voxels to compute for?
keeps = Ymask(:)>0;

% Compute connectivity maps
Rmap = zeros(size(roi_data,2),size(Ymask(:),1));
Zmap = zeros(size(roi_data,2),size(Ymask(:),1));
Rmap(:,keeps) = corr(table2array(roi_data),rYfmri(:,keeps));
Zmap(:,keeps) = atanh(Rmap(:,keeps)) * sqrt(size(roi_data,1)-3);

% Save maps to file, original and smoothed versions
if ~exist(connmap_dir,'dir')
    mkdir(connmap_dir);
end
[~,tag] = fileparts(roi_csv);
for r = 1:width(roi_data)

	Vout = rmfield(Vfmri(1),'pinfo');
	Vout.fname = fullfile(connmap_dir, ...
		['R_' tag '_' roi_data.Properties.VariableNames{r} '.nii']);
	Yout = reshape(Rmap(r,:),osize(1:3));
	spm_write_vol(Vout,Yout);

    Vout = rmfield(Vfmri(1),'pinfo');
	Vout.fname = fullfile(connmap_dir, ...
		['Z_' tag '_' roi_data.Properties.VariableNames{r} '.nii']);
	Yout = reshape(Zmap(r,:),osize(1:3));
	spm_write_vol(Vout,Yout);
	
%	sfname = fullfile(conn_dir, ...
%		['sZ_' roidata.Properties.VariableNames{r} '_' tag '.nii']);
%	spm_smooth(Vout,sfname,str2double(fwhm));
	
end
