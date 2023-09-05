function R_csv = save_network_matrix(data,threshold,roi_set,out_dir)

% Prep connectivity matrix for BCT network computations

% Correlation matrix with diagonals set to zero
R = corr(table2array(data));
R = R - R.*eye(size(R));

% Threshold only
R(R<threshold) = 0;

% Additionally, binarize
%R = double(R>=threshold);

% Get variable names
Rvarnames = data.Properties.VariableNames;

% Write table
saveR = array2table(R,'VariableNames',Rvarnames,'RowNames',Rvarnames);
R_csv = fullfile(out_dir,['R_' roi_set '.csv']);
writetable(saveR,R_csv,'WriteRowNames',true);
