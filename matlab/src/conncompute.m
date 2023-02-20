function conncompute(roidata,fmri_nii,out_dir,tag,connmaps_out)

%% Connectivity matrix

% Correlation and Fisher transform
R = corr(table2array(roidata));
Z = atanh(R) * sqrt(size(roidata,1)-3);

R = setnames(R,roidata);
writetable(R,fullfile(out_dir,['R_' tag '.csv']),'WriteRowNames',true);

Z = setnames(Z,roidata);
writetable(Z,fullfile(out_dir,['Z_' tag '.csv']),'WriteRowNames',true);

% Autocorrelation-corrected (https://github.com/asoroosh/xDF)
[Vdf,S] = xDF(table2array(roidata)',size(roidata,1),'truncate','adaptive');
Pdf = S.p;
Zdf = S.z;
Vdf = setnames(Vdf,roidata);
Pdf = setnames(Pdf,roidata);
Zdf = setnames(Zdf,roidata);
writetable(Vdf,fullfile(out_dir,['Vdf_' tag '.csv']),'WriteRowNames',true);
writetable(Pdf,fullfile(out_dir,['Pdf_' tag '.csv']),'WriteRowNames',true);
writetable(Zdf,fullfile(out_dir,['Zdf_' tag '.csv']),'WriteRowNames',true);


%% Connectivity maps

% Don't actually make maps unless requested
if ~strcmp(connmaps_out,'yes'), return, end

connmap_dir = [out_dir '/connmaps'];
if ~exist(connmap_dir,'dir')
	mkdir(connmap_dir);
end

% Load fmri
Vfmri = spm_vol(fmri_nii);
Yfmri = spm_read_vols(Vfmri);
osize = size(Yfmri);
rYfmri = reshape(Yfmri,[],osize(4))';

% Compute connectivity maps
Rmap = corr(table2array(roidata),rYfmri);
Zmap = atanh(Rmap) * sqrt(size(roidata,1)-3);

% Save maps to file, original and smoothed versions
for r = 1:width(roidata)

	Vout = rmfield(Vfmri(1),'pinfo');
	Vout.fname = fullfile(connmap_dir, ...
		['Z_' roidata.Properties.VariableNames{r} '_' tag '.nii']);
	Yout = reshape(Zmap(r,:),osize(1:3));
	Vout = spm_write_vol(Vout,Yout);
	
%	sfname = fullfile(conn_dir, ...
%		['sZ_' roidata.Properties.VariableNames{r} '_' tag '.nii']);
%	spm_smooth(Vout,sfname,str2double(fwhm));
	
end


function M = setnames(M,roidata)
M = array2table(M);
M.Properties.VariableNames = roidata.Properties.VariableNames;
M.Properties.RowNames = roidata.Properties.VariableNames;


