function entrypoint(varargin)

P = inputParser;
addOptional(P,'schaefer_csv','/OUTPUTS/schaefer.csv')
addOptional(P,'thomas_csv','/OUTPUTS/thomas.csv')
addOptional(P,'yeo_csv','/OUTPUTS/yeo.csv')
addOptional(P,'wfmri_nii','/OUTPUTS/wfmri.nii')
addOptional(P,'mask_nii','/OUTPUTS/thalamus-mask.nii')
addOptional(P,'roi_dir','/opt/ccalc-thal/rois')
addOptional(P,'densities','0.10:0.005:0.15')
addOptional(P,'out_dir','/OUTPUTS')
parse(P,varargin{:});
inp = P.Results;

% Get Yeo7 network names for Schaefer400 ROI set
%
% Yeo7 ROIs with labels from Schaefer CSV:
%   1 - Visual            (Vis)
%   2 - Somatomotor       (SomMot)
%   3 - Dorsal Attention  (DorsAttn)
%   4 - Ventral Attention (SalVentAttn)
%   5 - Limbic            (Limbic)
%   6 - Frontoparietal    (Cont)
%   7 - Default           (Default)
netmap = readtable(fullfile(inp.roi_dir,'Schaefer2018', ...
    'Schaefer2018_400Parcels_7Networks_order_FSLMNI152_2mm.Centroid_RAS.csv'), ...
    'Format','%d%q%f%f%f');
for h = 1:height(netmap)
    netmap.TextLabel{h,1} = sprintf('schaefer_%03d',netmap.ROILabel(h));
    q = strsplit(netmap.ROIName{h},'_');
    netmap.Network{h,1} = q{3};
end


%% Schaefer 400 x Yeo 7

% Matrix
disp('Connectivity matrix Schaefer 400 x Yeo 7')
[R,~,~,colnames] = compute_connmat( ...
    inp.schaefer_csv, ...
    inp.yeo_csv, ...
    inp.out_dir, ...
    'schaefer400_yeo7');

% PC
densities = eval(inp.densities);
PCs = [];
for d = densities
    thisR = table2array(R);
    thisR(thisR(:) < prctile(thisR(:),1-d)) = 0;
    PCs = [PCs; participation_coeff(thisR,netmap.Network)];
end

result = array2table(densities','VariableNames',{'density'});
result = [result array2table(PCs,'VariableNames',colnames)];

meanresult = table({densities},{inp.densities}, ...
    'VariableNames',{'densities','densitystr'});
meanresult = [meanresult array2table(mean(PCs),'VariableNames',colnames)];

return


%% Matrix, Schaefer 400 x Schaefer 400
disp('Connectivity matrix 1')
R1 = compute_connmat(inp.schaefer_csv,inp.schaefer_csv, ...
    inp.out_dir,'schaefer400_schaefer400');

% Matrix, Schaefer 400 x THOMAS 12
disp('Connectivity matrix 2')
R2 = compute_connmat(inp.schaefer_csv,inp.thomas_csv, ...
    inp.out_dir,'schaefer400_thomas12');


% Maps, Schaefer 400. Only within mask of dilated Yeo7 whole thalamus
disp('Connectivity maps')
R4 = compute_connmaps(inp.schaefer_csv,inp.wfmri_nii,inp.mask_nii, ...
    fullfile(inp.out_dir,'connmaps_schaefer400'));

% Participation coefficient. Compute for Thomas/Yeo/voxel thalamus
% segmentations and Schaefer cortical segmentation. Save to csv for the
% first two. For thalamus voxel we need to save to image though. Would be
% good to save them all to image, but we'd need to map the Thomas ROIs into
% MNI space first to make that work (and map ROI image labels to matrix
% labels correctly). General solution there is to create MNI space ROI
% images in the wfmri space for all ROI sets, with a corresponding
% index-to-label mapping csv that matches the matrix csvs we are putting
% out.
