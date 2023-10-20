function [rroi_nii,rroi_csv] = resample_roi(roi_nii,roidefinv_nii,meanfmri_nii,roi_csv,out_dir)

%% Resample ROI image

if isempty(roidefinv_nii)
	% ROI and fmri in same space

	% Params. Critically, 0 order (nearest neighbor) interpolation
	flags = struct('mask',true,'mean',false,'interp',0,'which',1, ...
		'wrap',[0 0 0],'prefix','r');
	
	% Use SPM to reslice
	spm_reslice_quiet({meanfmri_nii roi_nii},flags);
	
	% Figure out the new filename
	[p,n,e] = fileparts(roi_nii);
	rroi_nii = fullfile(p,['r' n e]);
	
else
	% Warp ROI from atlas to fmri native space
	clear matlabbatch
	matlabbatch{1}.spm.util.defs.comp{1}.def = {roidefinv_nii};
	matlabbatch{1}.spm.util.defs.comp{2}.id.space = {meanfmri_nii};
	matlabbatch{1}.spm.util.defs.out{1}.pull.fnames = {roi_nii};
	matlabbatch{1}.spm.util.defs.out{1}.pull.savedir.saveusr = {out_dir};
	matlabbatch{1}.spm.util.defs.out{1}.pull.interp = 0;
	matlabbatch{1}.spm.util.defs.out{1}.pull.mask = 0;
	matlabbatch{1}.spm.util.defs.out{1}.pull.fwhm = [0 0 0];
	matlabbatch{1}.spm.util.defs.out{1}.pull.prefix = '';
	spm_jobman('run',matlabbatch);
	[p,n,e] = fileparts(roi_nii);
	rroi_nii = fullfile(p,['r' n e]);
	movefile(fullfile(p,['w' n e]),rroi_nii);
end


%% Convert any NaN values to zero, round values, fix scaling
V = spm_vol(rroi_nii);
Y = spm_read_vols(V);
Y(isnan(Y(:))) = 0;
V.dt(1) = spm_type('uint16');
V.pinfo(1:2) = [1 0];
spm_write_vol(V,Y);


%% Get ROI labels in a standard format

% Load the ROI label file. Label the first two columns as Label and Region
% if matlab detects them as unlabeled.
roi_info = readtable(roi_csv);
if strcmp(roi_info.Properties.VariableNames{1},'Var1')
	roi_info.Properties.VariableNames{'Var1'} = 'Label';
	roi_info.Properties.VariableNames{'Var2'} = 'Region';
end

if height(roi_info)<2
	error('Unable to process a single ROI')
end

% If we got a slant STATS output, rename the appropriate columns
indR = strcmp(roi_info.Properties.VariableNames,'LabelName_BrainCOLOR_');
indL = strcmp(roi_info.Properties.VariableNames,'LabelNumber_BrainCOLOR_');
if sum(indR)==1 && sum(indL)==1
	roi_info.Properties.VariableNames{indR} = 'Region';
	roi_info.Properties.VariableNames{indL} = 'Label';
end

% Normalize ROI names
for h = 1:height(roi_info)
	roi_info.Region{h} = sprintf('r%04d_%s',roi_info.Label(h), ...
		regexprep(roi_info.Region{h},{'[%() ]+','_+$'},{'_', ''}) );
end

% Drop any extra columns and save to file
roi_info = roi_info(:,{'Label','Region'});
[~,n,e] = fileparts(roi_csv);
rroi_csv = fullfile(out_dir,['r' n e]);
writetable(roi_info,rroi_csv)


