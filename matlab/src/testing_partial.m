%% Compute metrics from
%    schaefer-schaefer pearson correlation matrix
%       and
%    schaefer-thalamus partial correlation matrix

out_dir = '../../OUTPUTS';
densities = 0.05:0.05:0.8;

% Get the time series data and ROI info previously created by
% roi_extract.sh
[schaefer,yeo,voxel,thomas] = get_time_series(out_dir);

% Compute Pearson R for Schaefer x Schaefer (cortical) ROIs and save
R_schaefer = get_network_matrix_1(schaefer);

% Compute partial R for Schaefer x Thalamus for each thalamus set and save
Rp_schaefer_yeo = get_partial_matrix_2(schaefer,yeo,95);
Rp_schaefer_voxel = get_partial_matrix_2(schaefer,voxel,95);
Rp_schaefer_thomas = get_partial_matrix_2(schaefer,thomas,95);

% Also standard bivariate correlation
R_schaefer_yeo = get_partial_matrix_2(schaefer,yeo,inf);
R_schaefer_voxel = get_partial_matrix_2(schaefer,voxel,inf);
R_schaefer_thomas = get_partial_matrix_2(schaefer,thomas,inf);


%% 
% Compute PC at each density threshold for the Schaefer x Thalamus matrices
PCp_yeo = compute_PCs(Rp_schaefer_yeo,densities);
PCp_thomas = compute_PCs(Rp_schaefer_thomas,densities);
%PCp_voxel = compute_PCs(Rp_schaefer_voxel,densities);  % 33 dens 3 min 

PC_yeo = compute_PCs(R_schaefer_yeo,densities);
PC_thomas = compute_PCs(R_schaefer_thomas,densities);
%PC_voxel = compute_PCs(R_schaefer_voxel,densities);


% WMD
WMD_yeo = compute_WMDs(R_schaefer,R_schaefer_yeo,densities);
WMDp_yeo = compute_WMDs(R_schaefer,Rp_schaefer_yeo,densities);



% Summary plot for all ROIs
PCresult = PCp_yeo;
all_density = [];
all_degree = [];
all_scaledPC = [];
for r = unique(PCresult.Region)'
    d = PCresult(strcmp(PCresult.Region,r{1}),:);
    d = sortrows(d,'density');
    all_density(end+1,:) = d.density';
    all_degree(end+1,:) = d.roi_degree';
    all_scaledPC(end+1,:) = d.roi_scaledPC';
end

figure(1); clf

for r = 1:size(all_density,1)
    
    subplot(1,2,1); hold on
    plot(all_density(r,:),all_degree(r,:),'-')
    xlabel('Density')
    ylabel('ROI Degree')

    subplot(1,2,2); hold on
    plot(all_density(r,:),all_scaledPC(r,:),'-')
    xlabel('Density')
    ylabel('ROI scaledPC')
    
end


WMDresult = WMD_yeo;
all_density = [];
all_WMD = [];
for r = unique(WMDresult.Region)'
    d = WMDresult(strcmp(WMDresult.Region,r{1}),:);
    d = sortrows(d,'density');
    all_density(end+1,:) = d.density';
    all_WMD(end+1,:) = d.roi_WMD';
end

figure(2); clf

for r = 1:size(all_density,1)
    
    subplot(1,1,1); hold on
    plot(all_density(r,:),all_WMD(r,:),'-')
    xlabel('Density')
    ylabel('ROI WMD')
    title(sprintf('%s ROI set',WMDresult.ROI_Set{1}))

end
