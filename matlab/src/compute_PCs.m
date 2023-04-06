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

