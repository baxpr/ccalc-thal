function result = compute_metrics_on_matrix( ...
    R_csv, ...
    info_csv, ...
    densities ...
    )

% We assume that the R matrix and communities table include at minimum the
% Schaefer400 ROIs.

% Read R matrix and variable names from file
R = readtable(R_csv,'ReadRowNames',true);
Rvarnames = R.Properties.VariableNames;
R = table2array(R);

% Read label info from file and re-order to match R
info = readtable(info_csv);
info = outerjoin( ...
    table(Rvarnames','VariableNames',{'Region'}), ...
    info, ...
    'Keys',{'Region'}, ...
    'MergeKeys',true, ...
    'Type','left' ...
    );

% Find ROI sets, note them, and make sure we can handle what we've got
for h = 1:height(info)
    q = strsplit(info.Region{h},'_');
    info.ROI_Set{h,1} = q{1};
end
roisets = unique(info.ROI_Set);

if numel(roisets)==1 && ~strcmp(roisets{1},'schaefer400')
    error('Only one ROI set found and it is not Schaefer400');
end

if numel(roisets)>2
    error('Found too many ROI sets (%d)',numel(roisets))
end

% Map densities to thresholds based on Schaefer400 cortical network
ind_schaefer = startsWith(Rvarnames,'schaefer');
R_schaefer = R(ind_schaefer,ind_schaefer);
ind = triu(ones(size(R_schaefer)),1);
edges = R_schaefer(logical(ind(:)));
thresholds = quantile(edges,1-densities);

% ROIs we will examine are all that don't begin 'schaefer'
test_roiset = roisets{~strcmp(roisets,'schaefer')};
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
        PC = bct_participation_coef_nan(R_thresh,info.NetworkNum);
        nnw = numel(unique(info.NetworkNum));
        maxPC = 1 - (1/nnw)^2*nnw;
        PC = PC ./ maxPC;
        WMD = module_degree_zscore(R_thresh,info.NetworkNum);
        
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
            result.ROI_Set{ct,1} = 'schaefer400';
        end
        
    end
    
end


%% Otherwise, compute metrics for each thalamus ROI separately, at each threshold
for this_index = 1:numel(test_rois)
    
    % Keep all Schaefer but only one thalamus ROI in the matrix. The
    % thalamus ROI will be the last entry.
    keep_schaefer = find(startsWith(Rvarnames,'schaefer'));
    keep_thal = find(strcmp(Rvarnames,test_rois{this_index}));
    keeps = [keep_schaefer keep_thal];
    R_this = R(keeps,keeps);
    communities_this = info.NetworkNum(keeps);
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
        
        % For PC, we are only capturing the value for the thalamus node,
        % and the thalamus node's community assignment is irrelevant to its
        % computation, so we just assign 1 (it could be unknown/NaN for
        % some ROI sets, e.g. THOMAS). We also rescale P based on the
        % number of communities so it will have a max of 1.
        communities_for_PC = communities_this;
        communities_for_PC(end) = 1;
        PC = bct_participation_coef_nan(R_this_thresh,communities_for_PC);
        nnw = numel(unique(communities_this));
        maxPC = 1 - (1/nnw)^2*nnw;
        PC = PC ./ maxPC;
        result.roi_PC(ct,1) = PC(end);
        
        % For WMD, the thalamus node must be assigned to a particular
        % community, so if any node does not have community specified, we
        % skip this metric (e.g. for THOMAS ROIs).
        if any(isnan(communities_this))
            result.roi_WMD(ct,1) = nan;
        else
            WMD = module_degree_zscore(R_this_thresh,communities_this);
            result.roi_WMD(ct,1) = WMD(end);
        end
        
        result.Region{ct,1} = roiname_this;
        result.ROI_Set{ct,1} = test_roiset;
        
    end  % threshold
    
end  % test_roi



