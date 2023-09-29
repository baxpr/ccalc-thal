function result = compute_PCs(Rthal,densities)

% Computes participation coef for the thalamus regions in an incomplete
% thalamus x schaefer (partial) correlation matrix, at a range of densities

result = table();
ct = 0;
for d = densities
    thisR = table2array(Rthal.R);

    % Threshold and binarize the correlation matrix
    thisR = double(thisR >= quantile(thisR(:),1-d));
    
    % Compute PCs at this density
    [PCs,scaledPCs] = participation_coeff(thisR',Rthal.colinfo.Network);

    % Organize results into table
    for r = 1:size(PCs,2)
        ct = ct + 1;
        result.density(ct,1) = d;
        result.Region{ct,1} = Rthal.rowinfo.Region{r};
        q = strsplit(Rthal.rowinfo.Region{r},'_');
        result.ROI_Set{ct,1} = q{1};
        result.roi_PC(ct,1) = PCs(r);
        result.roi_scaledPC(ct,1) = scaledPCs(r);

        % Degree is the sum of edges for a binarized matrix
        result.roi_degree(ct,1) = sum(thisR(r,:));
        result.roi_fractionaldegree(ct,1) = result.roi_degree(ct,1) / size(thisR,2);
    end
end

