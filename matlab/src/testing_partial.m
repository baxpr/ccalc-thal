%% Compute metrics from
%    schaefer-schaefer pearson correlation matrix
%       and
%    schaefer-thalamus partial correlation matrix

out_dir = '../../OUTPUTS';
densities = 0:0.05:0.95;

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
PC_yeo = compute_PCs(Rp_schaefer_yeo,densities);

% Compute WMD

