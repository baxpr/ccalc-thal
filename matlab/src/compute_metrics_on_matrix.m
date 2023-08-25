function result = compute_metrics_on_matrix( ...
    R_csv, ...
    roi_set, ...
    densities, ...
    thresholds ...
    )

% We need
%   R csv -> R, Rvarnames
%   thresholds
%   communities
%   densities
%   roi_set


%% Read R matrix and variable names from file
R = readtable(R_csv,'ReadRowNames',true);
Rvarnames = R.Properties.VariableNames;
R = table2array(R);

% ROIs we will examine are all that don't begin 'schaefer'
test_rois = Rvarnames(~startsWith(Rvarnames,'schaefer'));

% Initialize results to add one row at a time
result = table();
ct = 0;


%% If there are no non-Schaefer ROIs, just compute on the whole matrix
if isempty(test_rois)
    
    for t = 1:numel(thresholds)
        
        R_thresh = R;
        R_thresh(R_thresh(:)<thresholds(t)) = 0;
        
        [~,comp_sizes] = get_components(R_thresh);
        ncomp = numel(comp_sizes);
        density = densities(t);
        degree = degrees_und(R_thresh);
        strength = strengths_und(R_thresh);
        PC = bct_participation_coef_nan(R_thresh,communities);
        nnw = numel(unique(communities));
        maxPC = 1 - (1/nnw)^2*nnw;
        PC = PC ./ maxPC;
        WMD = module_degree_zscore(R_thresh,communities);
        
        % Reshape into table organized by ROI
        for k = 1:numel(PC)
            ct = ct + 1;
            result.threshold(ct,1) = thresholds(t);
            result.ncomponents(ct,1) = ncomp;
            result.density(ct,1) = density;
            result.roi_degree(ct,1) = degree(k);
            result.roi_strength(ct,1) = strength(k);
            result.roi_PC(ct,1) = PC(k);
            result.roi_WMD(ct,1) = WMD(k);
            result.Region{ct,1} = Rvarnames{k};
            result.ROI_Set{ct,1} = roi_set;
        end
        
    end
    
    return
    
end



%% Otherwise, compute metrics for each thalamus ROI separately, at each threshold
for this_index = 1:numel(test_rois)
    
    % Keep all Schaefer but only one thalamus ROI in the matrix. The
    % thalamus ROI will be the last entry.
    keep_schaefer = find(startsWith(Rvarnames,'schaefer'));
    keep_test = find(strcmp(Rvarnames,test_rois{this_index}));
    keeps = [keep_schaefer keep_test];
    R_this = R(keeps,keeps);
    communities_this = communities(keeps);
    roiname_this = test_rois{this_index};
    
    for t = 1:numel(thresholds)
        
        ct = ct + 1;
        
        result.threshold(ct,1) = thresholds(t);
        R_this_thresh = R_this;
        R_this_thresh(R_this_thresh(:)<thresholds(t)) = 0;
        
        [~,comp_sizes] = get_components(R_this_thresh);
        result.ncomponents(ct,1) = numel(comp_sizes);
        result.density(ct,1) = densities(t);
        
        degree = degrees_und(R_this_thresh);
        result.roi_degree(ct,1) = degree(end);
        
        strength = strengths_und(R_this_thresh);
        result.roi_strength(ct,1) = strength(end);
        
        % For PC, we are only capturing the value for the thalamus node, and
        % the thalamus node's community assignment is irrelevant to its
        % computation so we just choose 1 if it's not already specified.
        FIXME
        if isnan(communities_roi(this_index))
            communities_this(end) = 1;
        end
        PC = bct_participation_coef_nan(R_this_thresh,communities_this);
        nnw = numel(unique(communities_this));
        maxPC = 1 - (1/nnw)^2*nnw;
        PC = PC ./ maxPC;
        result.roi_PC(ct,1) = PC(end);
        
        % For WMD, the thalamus node must be assigned to a particular
        % community, so if it's not specified we skip this metric (e.g. for
        % THOMAS ROIs).
        FIXME
        if isnan(communities_roi(this_index))
            result.roi_WMD(ct,1) = nan;
        else
            WMD = module_degree_zscore(R_this_thresh,communities_this);
            result.roi_WMD(ct,1) = WMD(end);
        end
        
        result.Region{ct,1} = roiname_this;
        result.ROI_Set{ct,1} = roi_set;
        
    end  % threshold
    
end  % thalamus ROI

