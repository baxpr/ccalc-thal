function compute_WMDs(inp,roi1_csv,roi2_csv,roi1_labels,tag)

% Compute connectivity matrix
[R,rownames,colnames] = compute_connmat( ...
    roi1_csv, ...
    roi2_csv, ...
    inp.connmetric, ...
    inp.out_dir, ...
    tag);

% Verify labels and data match for roi1
if ~all(strcmp(rownames',roi1_labels.Region))
    error('Mismatch in region labels')
end


% FIXME WIP 

% Should only work for same ROI set on both axes of the matrix
%
% Do we zero the diagonal?
%
% Do we need to exclude thalamus ROIs/voxels other than the one we're
% computing WMD for?


% WMD
densities = eval(inp.densities);
WMDs = [];
for d = densities
    thisR = Rmat;

    % Zero edges below threshold but retain weights of those above
    thisR(thisR(:) < quantile(thisR(:),1-d)) = 0;
    
    % Or just binarize
    %thisR = double(thisR >= quantile(thisR(:),1-d));
    
    WMDs = [WMDs; module_degree_zscore(thisR,roi1_labels.Network)];
end

%Z = module_degree_zscore(connmat,networks,0);

