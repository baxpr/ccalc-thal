function result = compute_PCs(Rthal,densities)

% Computes participation coef for the thalamus regions in an incomplete
% thalamus x schaefer (partial) correlation matrix, at a range of densities

result = table();
ct = 0;
for d = densities
    thisR = table2array(Rthal.R);

    % Zero edges below threshold but retain weights of those above
    %thisR(thisR(:) < quantile(thisR(:),1-d)) = 0;
    
    % Or binarize
    thisR = double(thisR >= quantile(thisR(:),1-d));
    
    PCs = participation_coeff(thisR',Rthal.colinfo.Network);

    for r = 1:size(PCs,2)
        ct = ct + 1;
        result.density(ct,1) = d;
        result.Region{ct,1} = Rthal.rowinfo.Region{r};
        q = strsplit(Rthal.rowinfo.Region{r},'_');
        result.ROI_Set{ct,1} = q{1};
        result.roi_PC(ct,1) = PCs(r);
    end
end

