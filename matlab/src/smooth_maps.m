function sfmri_nii = smooth_maps(out_dir,fwhm)

D = dir([out_dir '/connmaps/*Z_*_*gm.nii']);
fmri_niis = strcat([out_dir '/connmaps/'],cellstr(char(D.name)));

for f = 1:length(fmri_niis)
	
	fmri_nii = fmri_niis{f};
	
	% Load the image
	V = spm_vol(fmri_nii);
	Y = spm_read_vols(V);
	sY = zeros(size(Y));
	
	% Smooth
	for v = 1:size(Y,4)
		tmp = Y(:,:,:,v);
		tmp2 = nan(size(tmp));
		spm_smooth(tmp,tmp2,fwhm);
		sY(:,:,:,v) = tmp2;
	end
	
	% Write to file
	[p,n,e] = fileparts(fmri_nii);
	sfmri_nii = fullfile(p,['s' n e]);
	for v = 1:size(Y,4)
		Vout = V(v);
		Vout.fname = sfmri_nii;
		Vout.n(1) = v;
		spm_write_vol(Vout,sY(:,:,:,v));
	end
	
end


