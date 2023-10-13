function results_to_image(result,stat,roi_set,roi_csv,roi_nii,img_dir)

% String tag with density value to label files with
result.dtag = arrayfun(@(x) strrep(sprintf('%0.3f',x),'.','p'), ...
    result.density,'UniformOutput', false);

% Load the ROI labels
roi_info = readtable(roi_csv);

% Load the ROI image
Vroi = spm_vol(roi_nii);
Yroi = spm_read_vols(Vroi);

% Output images
if ~exist(img_dir,'dir'), mkdir(img_dir); end

densities = unique(result.density);

for d = 1:numel(densities)
    
    % Create output image
    Yout = zeros(size(Yroi));
    
    for r = 1:numel(roi_info.Label)
        
        % Find the row of result that matches this ROI and density
        statind = strcmp(result.Region,roi_info.Region{r}) ...
            & strcmp(result.ROI_Set,roi_set) ...
            & result.density == densities(d);
        if sum(statind)~=1
            error('Found %d values for %s at density %f', ...
                sum(statind),roi_info.Region{r},densities(d));
        end
        
        % Find the voxels where we'll insert the stat, and put it in
        vox = abs(Yroi(:)-roi_info.Label(r))<0.1;
        if sum(vox)<1
            warning('No voxels found for ROI %d, %s', ...
                roi_info.Label(r),roi_info.Region{r});
        end
        Yout(vox) = result.(stat)(statind);
    end
    
    % Write output image
    Vout = rmfield(Vroi,'pinfo');
    Vout.fname = fullfile(img_dir,[stat '_' roi_set '_' result.dtag{statind} '.nii']);
    spm_write_vol(Vout,Yout);
    
end

