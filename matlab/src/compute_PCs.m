function compute_PCs

% We have 400 cortical ROIs from Schaefer, each assigned to one of the 7
% Yeo networks.
%
% "Cortical ROIs" are assumed to be the Schaefer 400 set on the rows (400
% row matrix required to match the ROI info file).
%
% Yeo7 ROIs with labels from Schaefer CSV:
%   1 - Visual            (Vis)
%   2 - Somatomotor       (SomMot)
%   3 - Dorsal Attention  (DorsAttn)
%   4 - Ventral Attention (SalVentAttn)
%   5 - Limbic            (Limbic)
%   6 - Frontoparietal    (Cont)
%   7 - Default           (Default)
%

% Get network names, assuming Schaefer400 ROI set and Yeo7 networks
roimap = readtable(fullfile(roi_dir,'Schaefer2018', ...
    'Schaefer2018_400Parcels_7Networks_order_FSLMNI152_2mm.Centroid_RAS.csv'), ...
    'Format','%d%q%f%f%f');

for h = 1:height(roimap)
    roimap.TextLabel{h,1} = sprintf('schaefer_%03d',roimap.ROILabel(h));
    q = strsplit(roimap.ROIName{h},'_');
    roimap.Network{h,1} = q{3};
end