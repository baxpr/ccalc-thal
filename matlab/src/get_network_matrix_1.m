function R = get_network_matrix_1(data)

% Pearson correlation matrix for a single set of timeseries, with diagonals
% set to zero for future computations
R = corr(table2array(data));
R = R - R.*eye(size(R));

% Make it a table with var and row names
Rvarnames = data.Properties.VariableNames;
R = array2table(R,'VariableNames',Rvarnames,'RowNames',Rvarnames);
