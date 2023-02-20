function mask_maps(out_dir,mask_nii)

D = dir([out_dir '/connmaps/*Z_*_*gm.nii']);
fmri_niis = strcat([out_dir '/connmaps/'],cellstr(char(D.name)));

if isempty(mask_nii)
	% Create mask of all 1
	V = spm_vol(fullfile(out_dir,'meanfmri.nii'));
	mask_nii = fullfile(out_dir,'rmask.nii');
	V.fname = mask_nii;
	V.pinfo(1:2) = [1 0];
	V.dt(1) = spm_type('uint8');
	Ymask = ones(V.dim);
	spm_write_vol(V,Ymask);
else
	% Resample mask to fMRI space and load
	flags = struct('mask',true,'mean',false,'interp',0,'which',1, ...
        'wrap',[0 0 0],'prefix','r');
	spm_reslice_quiet({[fmri_niis{1} ',1'],mask_nii},flags);
	[p,n,e] = fileparts(mask_nii);
	rmask_nii = fullfile(p,['r' n e]);
	Vmask = spm_vol(rmask_nii);
	Ymask = spm_read_vols(Vmask);
	
	% Binarize and dilate
	Ymask(:) = 1.0 * Ymask(:)>0;
	Ymask = imdilate(Ymask,strel('sphere',5));
	Vmask.pinfo(1:2) = [1 0];
	Vmask.dt(1) = spm_type('uint8');
	spm_write_vol(Vmask,Ymask);
end


for f = 1:length(fmri_niis)

	fmri_nii = fmri_niis{f};
	
	% Mask fMRI and save, volume by volume
	Vfmri = spm_vol(fmri_nii);
	Yfmri = spm_read_vols(Vfmri);
	for v = 1:size(Yfmri,4)
		tmp = Yfmri(:,:,:,v);
		tmp(Ymask(:)==0) = 0;
		tmp(isnan(tmp(:))) = 0;
		spm_write_vol(Vfmri(v),tmp);
	end	
	
end
