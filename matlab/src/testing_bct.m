% Testing use of BCT for incomplete matrix analysis

% We will need Yeo7 network labels for Yeo thalamus ROIs and thalamus voxels

% Add a single thalamus ROI or voxel time series to the Schaefer time
% series data. Combine the network labels info to match.

% Compute the conn matrix and threshold, zero diag, etc. Compute PC and WMD
% for the matrix using BCT functions. Extract the specific value for the
% thalamus ROI.

% Repeat over thresholds and average. Repeat over thalamus ROIs.

% Inputs:
%    Schaefer cortical ROI time series with network labels
%    Single thalamus ROI or voxel time series with network label



% Metrics:
%    Degree centrality
%    Participation coefficient
%    Within-module degree
%    Modularity



%% Steps:

% Create time series data matrix with Yeo7 network labels and network label
% number

% Compute connectivity matrix with specific metric e.g. bivariate
% correlation

% Threshold and binarize the matrix as desired

% Compute DC, PC, WMD



% As a function of threshold 0..1:

% For info:
%  Density (percent non-zero edges)   density_und
%  Number of disconnected components in graph   get_components
%
% For thalamus node specifically:
%            Number of non-zero edges (this is just degree)
%  Degree    degrees_und
%  Strength  strengths_und, strengths_und_sign
%  PC        participation_coef, participation_coef_sign
%  WMD       module_degree_zscore



for threshold = 0:0.02:1

    % For PC, we are only capturing the value for the thalamus node, and
    % the thalamus node's community assignment is irrelevant to its
    % computation so we just choose 1 if it's not already specified.
    
    % For WMD, the thalamus node must be assigned to a particular
    % community, so if it's not specified we skip this metric (e.g. for
    % THOMAS ROIs).
    
    
end

