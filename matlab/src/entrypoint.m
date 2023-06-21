function entrypoint(varargin)

P = inputParser;
addOptional(P,'schaefer_csv','/OUTPUTS/schaefer.csv')
addOptional(P,'thomas_csv','/OUTPUTS/thomas.csv')
addOptional(P,'yeo_csv','/OUTPUTS/yeo.csv')
addOptional(P,'wfmri_nii','/OUTPUTS/wfmri.nii')
addOptional(P,'mask_nii','/OUTPUTS/thalamus-mask.nii')
addOptional(P,'roi_dir','/opt/ccalc-thal/rois')
addOptional(P,'densities','0.10:0.005:0.15')
addOptional(P,'connmetric','bivariate_pearson_r')
addOptional(P,'out_dir','/OUTPUTS')
parse(P,varargin{:});
inp = P.Results;


warning('off','MATLAB:table:ModifiedAndSavedVarnames');


%% Get Yeo7 network names for Schaefer400 ROI set
%
% These are stored in the container along with the ROI image. We use a join
% to reduce the list to ones that are actually present in the data csv, in
% the same order.
%
% Yeo7 ROIs with labels from Schaefer CSV:
%   1 - Visual            (Vis)
%   2 - Somatomotor       (SomMot)
%   3 - Dorsal Attention  (DorsAttn)
%   4 - Ventral Attention (SalVentAttn)
%   5 - Limbic            (Limbic)
%   6 - Frontoparietal    (Cont)
%   7 - Default           (Default)
schaefer_labels_orig = readtable(fullfile(inp.roi_dir,'Schaefer2018', ...
    'Schaefer2018_400Parcels_7Networks_order_FSLMNI152_2mm-labels.csv'), ...
    'Format','%d%q%q');
schaefer_data = readtable(inp.schaefer_csv);
rownames = table(schaefer_data.Properties.VariableNames','VariableNames',{'Region'});
schaefer_labels = outerjoin( ...
    rownames, ...
    schaefer_labels_orig, ...
    'Keys',{'Region'}, ...
    'MergeKeys',true, ...
    'Type','left' ...
    );

% Add numeric network labels for use with BCT functions
schaefer_labels.NetworkNum(strcmp(schaefer_labels.Network,'Vis')) = 1;
schaefer_labels.NetworkNum(strcmp(schaefer_labels.Network,'SomMot')) = 2;
schaefer_labels.NetworkNum(strcmp(schaefer_labels.Network,'DorsAttn')) = 3;
schaefer_labels.NetworkNum(strcmp(schaefer_labels.Network,'SalVentAttn')) = 4;
schaefer_labels.NetworkNum(strcmp(schaefer_labels.Network,'Limbic')) = 5;
schaefer_labels.NetworkNum(strcmp(schaefer_labels.Network,'Cont')) = 6;
schaefer_labels.NetworkNum(strcmp(schaefer_labels.Network,'Default')) = 7;



%% Compute PCs against Schaefer 400 ROIs. Also stores conn matrices
disp('Computing PC on time series')
compute_PCs( ...
    inp, ...
    inp.schaefer_csv, ...
    inp.yeo_csv, ...
    schaefer_labels, ...
    'schaefer400_yeo7' ...
    );
compute_PCs( ...
    inp, ...
    inp.schaefer_csv, ...
    inp.thomas_csv, ...
    schaefer_labels, ...
    'schaefer400_thomas12' ...
    );
compute_PCs( ...
    inp, ...
    inp.schaefer_csv, ...
    inp.schaefer_csv, ...
    schaefer_labels, ...
    'schaefer400_schaefer400' ...
    );


%% Voxelwise PC against Schaefer 400 ROIs, within thalamus mask
% Voxels with no connections will get PC of nan.

% Get voxel time series to csv then use same func as for time series csvs
disp('Computing PC on image')
voxels_csv = fullfile(inp.out_dir,'thalamusvoxels.csv');
voxels_to_csv(inp.wfmri_nii,inp.mask_nii,voxels_csv);
compute_PCs( ...
    inp, ...
    inp.schaefer_csv, ...
    voxels_csv, ...
    schaefer_labels, ...
    'schaefer400_voxels' ...
    );

% Remap to mean PC image inside thalamus mask
meanPC_to_image( ...
    inp.mask_nii, ...
    fullfile(inp.out_dir,'meanPC_schaefer400_voxels.csv'), ...
    fullfile(inp.out_dir,'meanPC_schaefer400_voxels.nii') ...
    );


%% Modularity of the Schaefer cortical ROIs
disp('Modularity')

% Compute connectivity matrix
R = compute_connmat( ...
    inp.schaefer_csv, ...
    inp.schaefer_csv, ...
    'bivariate_pearson_r', ...
    inp.out_dir, ...
    'schaefer400_modularity' ...
    );

% Compute modularity
[Qspec_mst,Nspec_mst,Mspec_mst, ...
    Qopt_mst,Nopt_mst,Mopt_mst, ...
    Qspec_asym,Nspec_asym,Mspec_asym, ...
    Qopt_asym,Nopt_asym,Mopt_asym, ...
    Qoptdefault_mst,Noptdefault_mst,Moptdefault_mst, ...
    Qoptdefault_asym,Noptdefault_asym,Moptdefault_asym] = ...
    modularity_all(table2array(R),schaefer_labels.NetworkNum);

% Additionally compute modularity at specific thresholds


disp('finished')


%% Conn maps for Schaefer 400 ROIs within mask of dilated Yeo7 whole thalamus
%disp('Connectivity maps')
%compute_connmaps(inp.schaefer_csv,inp.wfmri_nii,inp.mask_nii, ...
%    fullfile(inp.out_dir,'connmaps_schaefer400'));



