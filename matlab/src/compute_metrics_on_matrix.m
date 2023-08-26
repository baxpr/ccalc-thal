function result = compute_metrics_on_matrix( ...
    R_csv, ...
    labels_csv, ...
    densities ...
    )

% We assume that the R matrix and communities table include at minimum the
% Schaefer400 ROIs.


% Read R matrix and variable names from file
R = readtable(R_csv,'ReadRowNames',true);
Rvarnames = R.Properties.VariableNames;
R = table2array(R);

% Read label info from file and re-order to match R. Verify we have
% matching info.
% FIXME we need to actually create this (concat source info)
labels = readtable(labels_csv);


% Error out if we're missing Schaefer ROIs or have more than one additional
% ROI set
roisets = % FIXME extract the pre-underscore parts of Region and find unique

% Map densities to thresholds based on Schaefer400 cortical network
R_schaefer = get_network_matrix(data_schaefer,-inf);
ind = triu(ones(size(R_schaefer)),1);
edges = R_schaefer(logical(ind(:)));
thresholds = quantile(edges,1-densities);

% ROIs we will examine are all that don't begin 'schaefer'
test_rois = Rvarnames(~startsWith(Rvarnames,'schaefer'));

% Initialize results to add one row at a time
result = table();
ct = 0;


%% If there are no non-Schaefer ROIs, just compute on the whole matrix
if isempty(test_rois)

    return
    
end



%% Otherwise, compute metrics for each thalamus ROI separately, at each threshold
for this_index = 1:numel(test_rois)
    
end  % thalamus ROI

