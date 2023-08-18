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
wfmri_nii = fullfile(out_dir,'wfmri.nii');
mask_nii = fullfile(out_dir,'thalamus-mask.nii');
networks_nii = fullfile(out_dir,'1000subjects_TightThalamus_clusters007_ref.nii');
%thresholds = 0.01:0.01:0.9;
densities = 0.05:0.15:0.8;
density_range_for_avg = [0.05 0.20];



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
communities_schaefer = info_schaefer.NetworkNum;

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
communities_yeo = info_yeo.NetworkNum;

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
communities_voxel = info_voxel.NetworkNum;

% And for THOMAS. There are no community assignments so we assign NaN
data_thomas = readtable(fullfile(out_dir,'thomas.csv'));
info_thomas = table( ...
    data_thomas.Properties.VariableNames', ...
    'VariableNames',{'Region'} ...
    );
communities_thomas = nan(height(info_thomas),1);


%% Computations

% Map densities to thresholds based on Schaefer400 cortical network
R = get_network_matrix(data_schaefer,-inf);
ind = triu(ones(size(R)),1);
edges = R(logical(ind(:)));
thresholds = quantile(edges,1-densities);

% Add to results table a row at a time
result = table();
ct = 0;

% Which ROIs we will run on
for r = [1 2]% 3]
    
    if r==1
        data_roi = data_yeo;
        communities_roi = communities_yeo;
        roi_set = 'Yeo7';
    elseif r==2
        data_roi = data_thomas;
        communities_roi = communities_thomas;
        roi_set = 'THOMAS';
    elseif r==3
        data_roi = data_voxel;
        communities_roi = communities_voxel;
        roi_set = 'voxel';
    end
    
    data_full = [data_schaefer data_roi];
    communities_full = [communities_schaefer; communities_roi];
    thal_labels = data_roi.Properties.VariableNames;
    [R,Rvarnames] = get_network_matrix(data_full,-inf);

    for this_index = 1:numel(thal_labels)
        
        % Keep all Schaefer but only one thalamus ROI in the matrix. The
        % thalamus ROI will be the last entry.
        keep_schaefer = find(startsWith(Rvarnames,'schaefer'));
        keep_thal = find(strcmp(Rvarnames,thal_labels{this_index}));
        keeps = [keep_schaefer keep_thal];
        R_this = R(keeps,keeps);
        communities_this = communities_full(keeps);
        roiname_this = thal_labels{this_index};

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
            if isnan(communities_roi(this_index))
                communities_this(end) = 1;
            end
            PC = participation_coef(R_this_thresh,communities_this);
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


%% Schaefer-only metrics
FIXME % Update to work from R not time series data
% No extra tricks, just straightforward BCT computations. Add to same
% results table
for t = 1:numel(thresholds)
    
    C = get_network_matrix(table2array(data_schaefer),thresholds(t));
    [~,comp_sizes] = get_components(C);
    ncomp = numel(comp_sizes);
    %density = density_und(C);
    density = densities(t);
    degree = degrees_und(C);
    strength = strengths_und(C);
    PC = participation_coef(C,communities_schaefer);
    WMD = module_degree_zscore(C,communities_schaefer);
    
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


%% FIXME Convert voxel results back to images and remove from results table
% But show or capture histogram first
vind = strcmp(result.ROI_Set,'voxel');
result_voxel = result(vind,:);
result = result(~vind,:);

return

% Limit voxelwise results to the density range we'll average over
dkeeps = result_voxel.density >= min(density_range_for_avg) & ...
    result_voxel.density <= max(density_range_for_avg);
result_voxel_trimmed = result_voxel(dkeeps,:);

% Average over densities for the stats of interest
q = varfun(@mean,result_voxel_trimmed, ...
    'InputVariables',{'roi_degree','roi_strength','roi_PC','roi_WMD'}, ...
    'GroupingVariables','Region');


%% Look at WMD distribution for cortical ROIs
k = abs(result.threshold-0.5)<0.001 & strcmp(result.ROI_Set,'Schaefer400');
ksdensity(result.roi_WMD(k));


%% Plots for a single ROI
figure(1); clf

%xlim = [0.01 0.20];
%xlim = [0.05 0.50];

subplot(3,2,1)
plot(result_this.density,result_this.threshold,'-o')
xlabel('Density')
ylabel('Threshold')
set(gca,'XLim',xlim)

subplot(3,2,2)
plot(result_this.density,result_this.ncomponents,'-o')
xlabel('Density')
ylabel('Connected components')
set(gca,'XLim',xlim)

subplot(3,2,3)
plot(result_this.density,result_this.roi_degree,'-o')
xlabel('Density')
ylabel('ROI Degree')
set(gca,'XLim',xlim)

subplot(3,2,4)
plot(result_this.density,result_this.roi_strength,'-o')
xlabel('Density')
ylabel('ROI Strength')
set(gca,'XLim',xlim)

subplot(3,2,5)
plot(result_this.density,result_this.roi_PC,'-o')
xlabel('Density')
ylabel('ROI PC')
set(gca,'XLim',xlim)

subplot(3,2,6)
plot(result_this.density,result_this.roi_WMD,'-o')
xlabel('Density')
ylabel('ROI WMD')
set(gca,'XLim',xlim)


%% Summary plot for all ROIs
all_threshold = [];
all_density = [];
all_degree = [];
all_strength = [];
all_PC = [];
all_WMD = [];
for r = unique(result.Region)'
    d = result(strcmp(result.Region,r{1}),:);
    d = sortrows(d,'threshold');
    all_threshold(end+1,:) = d.threshold';
    all_density(end+1,:) = d.density';
    all_degree(end+1,:) = d.roi_degree';
    all_strength(end+1,:) = d.roi_strength';
    all_PC(end+1,:) = d.roi_PC';
    all_WMD(end+1,:) = d.roi_WMD';
end

figure(2); clf

xlim = [0.05 0.50];
xlim = [0.01 0.80];

for r = 1:size(all_density,1)
    
    subplot(2,2,1); hold on
    plot(all_density(r,:),all_degree(r,:))
    xlabel('Density')
    ylabel('ROI Degree')
    set(gca,'XLim',xlim)
    
    subplot(2,2,2); hold on
    plot(all_density(r,:),all_strength(r,:))
    xlabel('Density')
    ylabel('ROI Strength')
    set(gca,'XLim',xlim)
    
    subplot(2,2,3); hold on
    plot(all_density(r,:),all_PC(r,:))
    xlabel('Density')
    ylabel('ROI PC')
    set(gca,'XLim',xlim)
    
    subplot(2,2,4); hold on
    plot(all_density(r,:),all_WMD(r,:))
    xlabel('Density')
    ylabel('ROI WMD')
    set(gca,'XLim',xlim)
    
end
