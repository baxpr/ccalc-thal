function result = compute_PC_WMD_schaefer( ...
    Rschaefer, ...
    densities ...
    )

result = table();
ct = 0;
for d = densities

    thisR = table2array(Rschaefer.R);

    % Threshold and binarize the correlation matrix
    thisR = double(thisR >= quantile(thisR(:),1-d));
    
    % Compute PC, WMD at this density
    [~,comp_sizes] = get_components(thisR);
    ncomp = numel(comp_sizes);
    density = d;
    degree = degrees_und(thisR);
    %strength = strengths_und(thisR);
    [PC,scaledPC] = bct_participation_coef_nan(thisR,Rschaefer.rowinfo.NetworkNum);
    WMD = module_degree_zscore(thisR,Rschaefer.rowinfo.NetworkNum);

    % Reshape into table organized by ROI
    for k = 1:numel(PC)
        ct = ct + 1;
        result.ncomponents(ct,1) = ncomp;
        result.density(ct,1) = density;
        result.roi_degree(ct,1) = degree(k);
        %result.roi_strength(ct,1) = strength(k);
        result.roi_PC(ct,1) = PC(k);
        result.roi_scaledPC(ct,1) = scaledPC(k);
        result.roi_WMD(ct,1) = WMD(k);
        result.Region{ct,1} = Rschaefer.rowinfo.Network{k};
        result.ROI_Set{ct,1} = 'schaefer';
    end

end
