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

out_dir = '../../OUTPUTS';
roi_dir = '../../rois';
densities = 0.05:0.15:0.8;


%% Steps:

% Create time series data matrix with Yeo7 network labels and network label
% number

% Compute connectivity matrix with specific metric e.g. bivariate
% correlation

% Threshold and binarize the matrix as desired

% Compute DC, PC, WMD

warning('off','MATLAB:table:RowsAddedExistingVars')


% Load Schaefer data and network labels
data_schaefer = readtable(fullfile(out_dir,'schaefer.csv'));
info_schaefer = readtable(fullfile(out_dir,'schaefer-networks.csv'));

% Get actual varnames from the data, and re-order network names and labels
% to match
info_schaefer = outerjoin( ...
    table(data_schaefer.Properties.VariableNames','VariableNames',{'Region'}), ...
    info_schaefer, ...
    'Keys',{'Region'}, ...
    'MergeKeys',true, ...
    'Type','left' ...
    );

% Same for Yeo ROIs
data_yeo = readtable(fullfile(out_dir,'yeo.csv'));
info_yeo = readtable(fullfile(out_dir,'yeo-networks.csv'));
info_yeo = outerjoin( ...
    table(data_yeo.Properties.VariableNames','VariableNames',{'Region'}), ...
    info_yeo, ...
    'Keys',{'Region'}, ...
    'MergeKeys',true, ...
    'Type','left' ...
    );

% And Yeo voxels
data_voxel = readtable(fullfile(out_dir,'yeo-voxels.csv'));
info_voxel = readtable(fullfile(out_dir,'yeo-voxels-networks.csv'));
info_voxel = outerjoin( ...
    table(data_voxel.Properties.VariableNames','VariableNames',{'Region'}), ...
    info_voxel, ...
    'Keys',{'Region'}, ...
    'MergeKeys',true, ...
    'Type','left' ...
    );

% And for THOMAS. There are no community assignments so we assign NaN
data_thomas = readtable(fullfile(out_dir,'thomas.csv'));
info_thomas = table( ...
    data_thomas.Properties.VariableNames', ...
    'VariableNames',{'Region'} ...
    );
info_thomas.NetworkNum(:,1) = nan;


%% Computations

% Initialize so we can add to results table a row at a time
result = table();
ct = 0;

for r = [1 2 3]
    
    if r==1
        data_roi = data_yeo;
        info_roi = info_yeo;
        roi_set = 'yeo7';
    elseif r==2
        data_roi = data_thomas;
        info_roi = info_thomas;
        roi_set = 'thom';
    elseif r==3
        data_roi = data_voxel;
        info_roi = info_voxel;
        roi_set = 'voxel';
    end
    
    data_full = [data_schaefer data_roi];
    R_csv = save_network_matrix(data_full,-inf,roi_set,out_dir);
    info_full = [info_schaefer; info_roi];
    info_csv = fullfile(out_dir,['R_' roi_set '-labels.csv']);
    writetable(info_full,info_csv);

    result = compute_metrics_on_matrix( ...
        fullfile(out_dir,['R_' roi_set '.csv']), ...
        fullfile(out_dir,['R_' roi_set '-labels.csv']), ...
        densities ...
        );

end

return


%% PREVIOUS
for t = 1:numel(thresholds)
    
    R_thresh = R_schaefer;
    R_thresh(R_thresh(:)<thresholds(t)) = 0;
            
    [~,comp_sizes] = get_components(R_thresh);
    ncomp = numel(comp_sizes);
    density = densities(t);
    degree = degrees_und(R_thresh);
    strength = strengths_und(R_thresh);
    PC = bct_participation_coef_nan(R_thresh,info_schaefer.NetworkNum);
    nnw = numel(unique(info_schaefer.NetworkNum));
    maxPC = 1 - (1/nnw)^2*nnw;
    PC = PC ./ maxPC;
    WMD = module_degree_zscore(R_thresh,info_schaefer.NetworkNum);
    
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
        result.Region{ct,1} = data_schaefer.Properties.VariableNames{k};
        result.ROI_Set{ct,1} = 'Schaefer400';
    end
    
end

% Thalamus ROIs one by one with Schaefer ROIs
for r = [1 2 3]
    
    if r==1
        data_roi = data_yeo;
        info_roi = info_yeo;
        roi_set = 'Yeo7';
    elseif r==2
        data_roi = data_thomas;
        info_roi = info_thomas;
        roi_set = 'THOMAS';
    elseif r==3
        data_roi = data_voxel;
        info_roi = info_voxel;
        roi_set = 'voxel';
    end
    
    % Compute the full matrix incl Schaefer and save to file
    data_full = [data_schaefer data_roi];
    R_csv = save_network_matrix(data_full,-inf,roi_set,out_dir);
    info_full = [info_schaefer; info_roi];
    info_csv = fullfile(out_dir,['R_' roi_set '-labels.csv']);
    writetable(info_full,info_csv);
    
    % Read R matrix and variable names and community info back from the
    % file
    R = readtable(R_csv,'ReadRowNames',true);
    Rvarnames = R.Properties.VariableNames;
    R = table2array(R);
    info = readtable(info_csv);
    
    % ROIs we will examine are all that don't begin 'schaefer'
    test_rois = Rvarnames(~startsWith(Rvarnames,'schaefer'));
    
    % Compute metrics for each thalamus ROI separately, at each threshold
    for this_index = 1:numel(test_rois)
        
        % Keep all Schaefer but only one thalamus ROI in the matrix. The
        % thalamus ROI will be the last entry.
        keep_schaefer = find(startsWith(Rvarnames,'schaefer'));
        keep_thal = find(strcmp(Rvarnames,test_rois{this_index}));
        keeps = [keep_schaefer keep_thal];
        R_this = R(keeps,keeps);
        communities_this = communities_full(keeps);
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
            
            % For PC, we are only capturing the value for the thalamus
            % node, and the thalamus node's community assignment is
            % irrelevant to its computation so we just choose 1 if it's not
            % already specified. We also rescale P based on the number of
            % communities so it will have a max of 1.
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
    
    % PC of 0 just means no connections, so make it NaN for plotting?
    %result.roi_PC(result.roi_PC==0) = NaN;
    
end  % ROI set


%% Write various outputs to image
results_to_image( ...
    result, ...
    'roi_PC', ...
    'Schaefer400', ...
    fullfile(out_dir,'schaefer-networks.csv'), ...
    fullfile(roi_dir,'Schaefer2018','Schaefer2018_400Parcels_7Networks_order_FSLMNI152_2mm.nii.gz'), ...
    out_dir ...
    );

results_to_image( ...
    result, ...
    'roi_PC', ...
    'Yeo7', ...
    fullfile(out_dir,'yeo-networks.csv'), ...
    fullfile(roi_dir,'thalamus-mask','yeo7_thalamus_lr.nii.gz'), ...
    out_dir ...
    );

results_to_image( ...
    result, ...
    'roi_WMD', ...
    'Schaefer400', ...
    fullfile(out_dir,'schaefer-networks.csv'), ...
    fullfile(roi_dir,'Schaefer2018','Schaefer2018_400Parcels_7Networks_order_FSLMNI152_2mm.nii.gz'), ...
    out_dir ...
    );

results_to_image( ...
    result, ...
    'roi_WMD', ...
    'Yeo7', ...
    fullfile(out_dir,'yeo-networks.csv'), ...
    fullfile(roi_dir,'thalamus-mask','yeo7_thalamus_lr.nii.gz'), ...
    out_dir ...
    );

% Voxelwise takes 35 sec
results_to_image( ...
    result, ...
    'roi_WMD', ...
    'voxel', ...
    fullfile(out_dir,'yeo-voxels-networks.csv'), ...
    fullfile(roi_dir,'thalamus-mask','thalamus-voxelwise.nii.gz'), ...
    out_dir ...
    );

% Voxelwise takes 35 sec
results_to_image( ...
    result, ...
    'roi_PC', ...
    'voxel', ...
    fullfile(out_dir,'yeo-voxels-networks.csv'), ...
    fullfile(roi_dir,'thalamus-mask','thalamus-voxelwise.nii.gz'), ...
    out_dir ...
    );

return



%% Look at histograms
xwmd = -4:0.2:4;
xpc = 0:0.01:1;
dval = 0.35;

k = abs(result.density-dval)<0.001 & strcmp(result.ROI_Set,'Schaefer400');
f_wmd_schaefer = ksdensity(result.roi_WMD(k),xwmd);
pcs = result.roi_PC(k);
pcs = pcs(~isnan(pcs));
f_pc_schaefer = ksdensity(pcs,xpc);

k = abs(result.density-dval)<0.001 & strcmp(result.ROI_Set,'voxel');
f_wmd_voxel = ksdensity(result.roi_WMD(k),xwmd);
pcs = result.roi_PC(k);
pcs = pcs(~isnan(pcs));
f_pc_voxel = ksdensity(pcs,xpc);

figure(1); clf

subplot(1,2,1); hold on
plot(xwmd,f_wmd_schaefer/max(f_wmd_schaefer))
plot(xwmd,f_wmd_voxel/max(f_wmd_voxel))
legend({'Schaefer400 cortical ROIs','Thalamus voxels'},'Location','Best')
xlabel('WMD')
ylabel('Density of occurrence')
title(sprintf('WMD at density %0.2f',dval))

subplot(1,2,2); hold on
plot(xpc,f_pc_schaefer/max(f_pc_schaefer))
plot(xpc,f_pc_voxel/max(f_pc_voxel))
legend({'Schaefer400 cortical ROIs','Thalamus voxels'},'Location','Best')
xlabel('PC')
ylabel('Density of occurrence')
title(sprintf('PC at density %0.2f',dval))



%% Summary plot for all Yeo7 ROIs
resultp = result(strcmp(result.ROI_Set,'Yeo7'),:);
all_threshold = [];
all_density = [];
all_degree = [];
all_strength = [];
all_PC = [];
all_WMD = [];
all_ncomponents = [];
for r = unique(resultp.Region)'
    d = resultp(strcmp(resultp.Region,r{1}),:);
    d = sortrows(d,'density');
    all_threshold(end+1,:) = d.threshold';
    all_density(end+1,:) = d.density';
    all_degree(end+1,:) = d.roi_degree';
    all_strength(end+1,:) = d.roi_strength';
    all_PC(end+1,:) = d.roi_PC';
    all_WMD(end+1,:) = d.roi_WMD';
    all_ncomponents(end+1,:) = d.ncomponents';
end

figure(2); clf

xlim = [0.05 0.50];
xlim = [0.01 0.80];

for r = 1:size(all_density,1)
    
    subplot(3,2,1); hold on
    plot(all_density(r,:),all_degree(r,:),'o-')
    xlabel('Density')
    ylabel('ROI Degree')
    set(gca,'XLim',xlim)
    
    subplot(3,2,2); hold on
    plot(all_density(r,:),all_strength(r,:),'o-')
    xlabel('Density')
    ylabel('ROI Strength')
    set(gca,'XLim',xlim)
    
    subplot(3,2,3); hold on
    plot(all_density(r,:),all_PC(r,:),'o-')
    xlabel('Density')
    ylabel('ROI PC')
    set(gca,'XLim',xlim)
    
    subplot(3,2,4); hold on
    plot(all_density(r,:),all_WMD(r,:),'o-')
    xlabel('Density')
    ylabel('ROI WMD')
    set(gca,'XLim',xlim)
    
    subplot(3,2,5); hold on
    plot(all_density(r,:),all_ncomponents(r,:),'o-')
    xlabel('Density')
    ylabel('Separate components')
    set(gca,'XLim',xlim)

end
