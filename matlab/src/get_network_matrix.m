function [C,varnames] = get_network_matrix(data,threshold)

% Prep connectivity matrix for BCT network computations

% Correlation matrix with diagonals set to zero
R = corr(table2array(data));
R = R - R.*eye(size(R));

% Threshold only
C = R;
C(R<threshold) = 0;

% Threshold and binarize
%C = double(R>=threshold);

% Get variable names
varnames = data.Properties.VariableNames;

