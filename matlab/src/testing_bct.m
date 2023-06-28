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

% Load Schaefer data and network labels
data_schaefer = readtable('../../OUTPUTS/schaefer.csv');
info_schaefer = readtable('../../OUTPUTS/schaefer-networks.csv');

% Get actual varnames from the data, and re-order network names and labels
% to match
info_schaefer = outerjoin( ...
    table(data_schaefer.Properties.VariableNames','VariableNames',{'Region'}), ...
    info_schaefer, ...
    'Keys',{'Region'}, ...
    'MergeKeys',true, ...
    'Type','left' ...
    );
communities_schaefer = info_schaefer.NetworkNum;

% Same for Yeo ROIs
data_yeo = readtable('../../OUTPUTS/yeo.csv');
info_yeo = readtable('../../OUTPUTS/yeo-networks.csv');
info_yeo = outerjoin( ...
    table(data_yeo.Properties.VariableNames','VariableNames',{'Region'}), ...
    info_yeo, ...
    'Keys',{'Region'}, ...
    'MergeKeys',true, ...
    'Type','left' ...
    );
communities_yeo = info_yeo.NetworkNum;


% Combine data for a single Yeo thalamus ROI
data_roi = data_yeo;
communities_roi = communities_yeo;
this_index = 1;
data_this = [data_schaefer data_roi(:,this_index)];
communities_this = [communities_schaefer; communities_roi(this_index)];


% Correlation matrix with diagonals set to zero
R = corr(table2array(data_this));
R = R - R.*eye(size(R));

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


% We will assume our ROI of interest is the final entry in the matrix
thresholds = 0:0.02:1;

result = table();
for t = 1:numel(thresholds)

    result.threshold(t,1) = thresholds(t);
    
    % Threshold only
    %Cw = R;
    %Cw(R<threshold) = 0;
    
    % Threshold and binarize
    C = double(R>=thresholds(t));
    
    [~,comp_sizes] = get_components(C);
    result.ncomponents(t,1) = numel(comp_sizes);
    result.density(t,1) = density_und(C);
    degree = degrees_und(C);
    result.degree(t,1) = degree(end);
    
    % For PC, we are only capturing the value for the thalamus node, and
    % the thalamus node's community assignment is irrelevant to its
    % computation so we just choose 1 if it's not already specified.
    PC = participation_coef(C,communities_this);
    result.PC(t,1) = PC(end);
    
    % For WMD, the thalamus node must be assigned to a particular
    % community, so if it's not specified we skip this metric (e.g. for
    % THOMAS ROIs).
    WMD = module_degree_zscore(C,communities_this);
    result.WMD(t,1) = WMD(end);
    
end


figure(1); clf

subplot(3,1,1)
plot(result.density,result.degree)
xlabel('Density')
ylabel('Degree')

subplot(3,1,2)
plot(result.density,result.PC)
xlabel('Density')
ylabel('PC')

subplot(3,1,3)
plot(result.density,result.WMD)
xlabel('Density')
ylabel('WMD')



