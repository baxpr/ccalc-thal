function entrypoint(varargin)

%% Compute metrics from
%    schaefer-schaefer pearson correlation matrix
%       and
%    schaefer-thalamus partial correlation matrix

% Quit if requested
if strcmp(varargin{1},'quit')
    exit
end

p = inputParser;
addoptional(p,'out_dir','/OUTPUTS');
addoptional(p,'roi_dir','/opt/ccalc-thal/rois');
addoptional(p,'densities','0.05:0.05:0.8');
addoptional(p,'hist_density','0.10');
parse(p);

out_dir = p.Results.out_dir;
roi_dir = p.Results.roi_dir;
densities = eval(p.Results.densities);
hist_density = eval(p.Results.hist_density);


%% Compute correlation matrices
disp('Computing correlations')

% Get the time series data and ROI info previously created by
% roi_extract.sh
[schaefer,yeo,voxel,thomas] = get_time_series(out_dir);

% Compute Pearson R for Schaefer x Schaefer (cortical) ROIs
R_schaefer = get_network_matrix_1(schaefer);

% Compute partial R for Schaefer x Thalamus for each thalamus set
Rp_schaefer_yeo = get_partial_matrix_2(schaefer,yeo,95);
Rp_schaefer_voxel = get_partial_matrix_2(schaefer,voxel,95);
Rp_schaefer_thomas = get_partial_matrix_2(schaefer,thomas,95);

% Also standard bivariate correlation
R_schaefer_yeo = get_partial_matrix_2(schaefer,yeo,inf);
R_schaefer_voxel = get_partial_matrix_2(schaefer,voxel,inf);
R_schaefer_thomas = get_partial_matrix_2(schaefer,thomas,inf);


%% Save R matrices and associated region info to csv files
mat_dir = fullfile(out_dir,'matrices');
if ~exist(mat_dir,'dir'), mkdir(mat_dir); end
for m = {
        'R_schaefer'
        'R_schaefer_yeo'
        'R_schaefer_thomas'
        'Rp_schaefer_yeo'
        'Rp_schaefer_thomas'
        }'
    eval(['mval = ' m{1} ';']);  % Hack to use var name AND value
    mat_fname = fullfile(mat_dir,[m{1} '.csv']);
    rowinfo_fname = fullfile(mat_dir,[m{1} '-rowinfo.csv']);
    colinfo_fname = fullfile(mat_dir,[m{1} '-colinfo.csv']);
    writetable(mval.R,mat_fname,'WriteRowNames',true);
    writetable(mval.rowinfo,rowinfo_fname);
    writetable(mval.colinfo,colinfo_fname);
end


%% Load matrices and info from file
% Will be needed later for group analysis
%tag = 'R_schaefer';
%R_csv = fullfile(mat_dir,[tag '.csv']);
%rowinfo_csv = fullfile(mat_dir,[tag '-rowinfo.csv']);
%colinfo_csv = fullfile(mat_dir,[tag '-colinfo.csv']);
%loadR = struct();
%loadR.R = readtable(R_csv,'ReadRowNames',true);
%loadR.rowinfo = readtable(rowinfo_csv);
%loadR.colinfo = readtable(colinfo_csv);


%% Modularity for schaefer x schaefer cortico-cortical network
disp('Modularity')
[Q,N] = modularity_schaefer( ...
    table2array(R_schaefer.R), ...
    R_schaefer.rowinfo.NetworkNum ...
    );
result_modularity_schaefer = table();
result_modularity_schaefer.ROI_Set{1,1} = 'schaefer';
result_modularity_schaefer.Modularity(1,1) = Q;
result_modularity_schaefer.NetworkSet{1,1} = 'yeo7';
result_modularity_schaefer.NumNetworks(1,1) = N;
writetable(result_modularity_schaefer,fullfile(out_dir,'modularity_schaefer.csv'));


%% PC, WMD for schaefer ROIs
disp('Schaefer metrics')
result_schaefer = compute_PC_WMD_schaefer(R_schaefer,densities);


%% PC, WMD for the schaefer x thalamus matrices
disp('Thalamus metrics')
PCp_yeo = compute_PCs(Rp_schaefer_yeo,densities);
PCp_thomas = compute_PCs(Rp_schaefer_thomas,densities);
PCp_voxel = compute_PCs(Rp_schaefer_voxel,densities);

PC_yeo = compute_PCs(R_schaefer_yeo,densities);
PC_thomas = compute_PCs(R_schaefer_thomas,densities);
PC_voxel = compute_PCs(R_schaefer_voxel,densities);

% WMD
WMD_yeo = compute_WMDs(R_schaefer,R_schaefer_yeo,densities);
WMD_voxel = compute_WMDs(R_schaefer,R_schaefer_voxel,densities);
WMDp_yeo = compute_WMDs(R_schaefer,Rp_schaefer_yeo,densities);
WMDp_voxel = compute_WMDs(R_schaefer,Rp_schaefer_voxel,densities);


% Merge WMD into PC table
result_yeo = outerjoin( ...
    PC_yeo, ...
    WMD_yeo, ...
    'MergeKeys',true, ...
    'Keys',{'Region','ROI_Set','density'}, ...
    'Type','full' ...
    );
resultp_yeo = outerjoin( ...
    PCp_yeo, ...
    WMDp_yeo, ...
    'MergeKeys',true, ...
    'Keys',{'Region','ROI_Set','density'}, ...
    'Type','full' ...
    );
result_voxel = outerjoin( ...
    PC_voxel, ...
    WMD_voxel, ...
    'MergeKeys',true, ...
    'Keys',{'Region','ROI_Set','density'}, ...
    'Type','full' ...
    );
resultp_voxel = outerjoin( ...
    PCp_voxel, ...
    WMDp_voxel, ...
    'MergeKeys',true, ...
    'Keys',{'Region','ROI_Set','density'}, ...
    'Type','full' ...
    );


%% Results to image

disp('Store to image')

% Partial correlation
results_to_image( ...
    resultp_yeo, ...
    'roi_scaledPC', ...
    'yeo7', ...
    fullfile(out_dir,'yeo-networks.csv'), ...
    fullfile(roi_dir,'thalamus-mask','yeo7_thalamus_lr.nii.gz'), ...
    fullfile(out_dir,'statimgs_partial') ...
    );
results_to_image( ...
    resultp_voxel, ...
    'roi_scaledPC', ...
    'voxel', ...
    fullfile(out_dir,'yeo-voxels-networks.csv'), ...
    fullfile(roi_dir,'thalamus-mask','thalamus-voxelwise.nii.gz'), ...
    fullfile(out_dir,'statimgs_partial') ...
    );

results_to_image( ...
    resultp_yeo, ...
    'roi_WMD', ...
    'yeo7', ...
    fullfile(out_dir,'yeo-networks.csv'), ...
    fullfile(roi_dir,'thalamus-mask','yeo7_thalamus_lr.nii.gz'), ...
    fullfile(out_dir,'statimgs_partial') ...
    );
results_to_image( ...
    resultp_voxel, ...
    'roi_WMD', ...
    'voxel', ...
    fullfile(out_dir,'yeo-voxels-networks.csv'), ...
    fullfile(roi_dir,'thalamus-mask','thalamus-voxelwise.nii.gz'), ...
    fullfile(out_dir,'statimgs_partial') ...
    );

% Bivariate correlation
results_to_image( ...
    result_yeo, ...
    'roi_scaledPC', ...
    'yeo7', ...
    fullfile(out_dir,'yeo-networks.csv'), ...
    fullfile(roi_dir,'thalamus-mask','yeo7_thalamus_lr.nii.gz'), ...
    fullfile(out_dir,'statimgs') ...
    );
results_to_image( ...
    result_voxel, ...
    'roi_scaledPC', ...
    'voxel', ...
    fullfile(out_dir,'yeo-voxels-networks.csv'), ...
    fullfile(roi_dir,'thalamus-mask','thalamus-voxelwise.nii.gz'), ...
    fullfile(out_dir,'statimgs') ...
    );

results_to_image( ...
    result_yeo, ...
    'roi_WMD', ...
    'yeo7', ...
    fullfile(out_dir,'yeo-networks.csv'), ...
    fullfile(roi_dir,'thalamus-mask','yeo7_thalamus_lr.nii.gz'), ...
    fullfile(out_dir,'statimgs') ...
    );
results_to_image( ...
    result_voxel, ...
    'roi_WMD', ...
    'voxel', ...
    fullfile(out_dir,'yeo-voxels-networks.csv'), ...
    fullfile(roi_dir,'thalamus-mask','thalamus-voxelwise.nii.gz'), ...
    fullfile(out_dir,'statimgs') ...
    );

% Schaefer PC, WMD
results_to_image( ...
    result_schaefer, ...
    'roi_scaledPC', ...
    'schaefer', ...
    fullfile(out_dir,'schaefer-networks.csv'), ...
    fullfile(roi_dir,'Schaefer2018','Schaefer2018_400Parcels_7Networks_order_FSLMNI152_2mm.nii.gz'), ...
    fullfile(out_dir,'statimgs') ...
    );
results_to_image( ...
    result_schaefer, ...
    'roi_WMD', ...
    'schaefer', ...
    fullfile(out_dir,'schaefer-networks.csv'), ...
    fullfile(roi_dir,'Schaefer2018','Schaefer2018_400Parcels_7Networks_order_FSLMNI152_2mm.nii.gz'), ...
    fullfile(out_dir,'statimgs') ...
    );


%% Summary plots for all ROIs
for F = [1 2]

    figure(F); clf
    set(gcf,'Position',[100 100 1200 300]);

    if F==1
        result = result_yeo;
        thistitle = sprintf('%s ROI set, bivariate corr',result.ROI_Set{1});
        figfile = fullfile(out_dir,'yeo7_bivariate.png');

    elseif F==2
        result = resultp_yeo;
        thistitle = sprintf('%s ROI set, partial corr',result.ROI_Set{1});
        figfile = fullfile(out_dir,'yeo7_partial.png');
    end

    all_density = [];
    all_degree = [];
    all_scaledPC = [];
    all_WMD = [];
    for r = unique(result.Region)'
        d = result(strcmp(result.Region,r{1}),:);
        d = sortrows(d,'density');
        all_density(end+1,:) = d.density';
        all_degree(end+1,:) = d.roi_degree';
        all_scaledPC(end+1,:) = d.roi_scaledPC';
        all_WMD(end+1,:) = d.roi_WMD';
    end

    xlim = [min(densities)-0.05 max(densities)+0.05];

    for r = 1:size(all_density,1)

        subplot(1,3,1); hold on
        plot(all_density(r,:),all_degree(r,:),'-')
        xlabel('Density')
        ylabel('ROI Degree')
        set(gca,'XLim',xlim)

        subplot(1,3,2); hold on
        plot(all_density(r,:),all_scaledPC(r,:),'-')
        xlabel('Density')
        ylabel('ROI scaledPC')
        title(thistitle)
        set(gca,'XLim',xlim)

        subplot(1,3,3); hold on
        plot(all_density(r,:),all_WMD(r,:),'-')
        xlabel('Density')
        ylabel('ROI WMD')
        set(gca,'XLim',xlim)

    end

    saveas(F,figfile);

end


%% Histograms
for F = [3 4]

    figure(F); clf
    set(gcf,'Position',[100 100 900 300]);

    if F==3
        result = result_voxel;
        thistitle = sprintf('Histograms, bivariate corr');
        figfile = fullfile(out_dir,'hist_bivariate.png');

    elseif F==4
        result = resultp_voxel;
        thistitle = sprintf('Histograms, partial corr');
        figfile = fullfile(out_dir,'hist_partial.png');
    end

    inds = abs(result_schaefer.density-hist_density)<0.001;
    pc_schaefer = result_schaefer.roi_scaledPC(inds);
    wmd_schaefer = result_schaefer.roi_WMD(inds);

    inds = abs(result.density-hist_density)<0.001;
    pc_voxel = result.roi_scaledPC(inds);
    wmd_voxel = result.roi_WMD(inds);

    subplot(1,2,1); hold on
    bins = 0:0.05:1 + 0.05/2;
    h_pc_schaefer = hist(pc_schaefer,bins);
    h_pc_voxel = hist(pc_voxel,bins);
    plot(bins,h_pc_schaefer/sum(h_pc_schaefer))
    plot(bins,h_pc_voxel/sum(h_pc_voxel))
    xlabel(sprintf('Scaled PC at density %0.2f',hist_density))
    ylabel('Fraction of ROIs')
    legend({'Cortex (Schaefer)','Thalamus (Voxels)'},'Location','Best')
    title(thistitle)

    subplot(1,2,2); hold on
    bins = -3:0.25:3 + 0.05/2;
    h_wmd_schaefer = hist(wmd_schaefer,bins);
    h_wmd_voxel = hist(wmd_voxel,bins);
    plot(bins,h_wmd_schaefer/sum(h_wmd_schaefer))
    plot(bins,h_wmd_voxel/sum(h_wmd_voxel))
    xlabel(sprintf('WMD at density %0.2f',hist_density))
    ylabel('Fraction of ROIs')
    legend({'Cortex (Schaefer)','Thalamus (Voxels)'},'Location','Best')

    saveas(F,figfile);

end


if isdeployed
    exit
end

