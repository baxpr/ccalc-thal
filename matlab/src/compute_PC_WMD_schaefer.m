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
    
    % Compute PCs at this density
    [PCs,scaledPCs] = participation_coeff(thisR',Rschaefer.colinfo.Network);

    [~,comp_sizes] = get_components(thisR);
    ncomp = numel(comp_sizes);
    density = densities(t);
    degree = degrees_und(thisR);
    strength = strengths_und(thisR);
    PC = bct_participation_coef_nan(thisR,info.NetworkNum);
    nnw = numel(unique(info.NetworkNum));
    maxPC = 1 - (1/nnw)^2*nnw;
    PC = PC ./ maxPC;
    WMD = module_degree_zscore(thisR,info.NetworkNum);

    % Reshape into table organized by ROI
    for k = 1:numel(PC)
        ct = ct + 1;
        result.ncomponents(ct,1) = ncomp;
        result.density(ct,1) = density;
        result.roi_degree(ct,1) = degree(k);
        result.roi_strength(ct,1) = strength(k);
        result.roi_PC(ct,1) = PC(k);
        result.roi_WMD(ct,1) = WMD(k);
        result.Region{ct,1} = Rschaefer.rowinfo.Network{k};
        result.ROI_Set{ct,1} = 'schaefer';
    end

end
