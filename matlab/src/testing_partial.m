%% Compute metrics from
%    schaefer-schaefer pearson correlation matrix
%       and
%    schaefer-thalamus partial correlation matrix

out_dir = '../../OUTPUTS';
densities = 0:0.005:0.1;

% Get the time series data and ROI info previously created by
% roi_extract.sh
[schaefer,yeo,voxel,thomas] = get_time_series(out_dir);

% Compute Pearson R for Schaefer x Schaefer (cortical) ROIs and save
R_schaefer = get_network_matrix_1(schaefer);

% Compute partial R for Schaefer x Thalamus for each thalamus set and save
Rp_schaefer_yeo = get_partial_matrix_2(schaefer,yeo);
Rp_schaefer_voxel = get_partial_matrix_2(schaefer,voxel);
Rp_schaefer_thomas = get_partial_matrix_2(schaefer,thomas);


%% 
% Compute PC at each density threshold for the Schaefer x Thalamus matrices
result = compute_PCs(Rp_schaefer_yeo,densities);


%% Summary plot for all ROIs
all_density = [];
all_degree = [];
all_scaledPC = [];
for r = unique(result.Region)'
    d = result(strcmp(result.Region,r{1}),:);
    d = sortrows(d,'density');
    all_density(end+1,:) = d.density';
    all_degree(end+1,:) = d.roi_degree';
    all_scaledPC(end+1,:) = d.roi_scaledPC';
end

figure(1); clf

for r = 1:size(all_density,1)
    
    subplot(1,2,1); hold on
    plot(all_density(r,:),all_degree(r,:),'-o')
    xlabel('Density')
    ylabel('ROI Degree')

    subplot(1,2,2); hold on
    plot(all_density(r,:),all_scaledPC(r,:),'-o')
    xlabel('Density')
    ylabel('ROI scaledPC')
    
    
end
