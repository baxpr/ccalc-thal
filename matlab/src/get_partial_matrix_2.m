function Rstruct = get_partial_matrix_2(schaefer,thal)

warning('off','stats:pca:ColRankDefX');

Rp = nan(width(thal.data),width(schaefer.data));

for s = 1:width(schaefer.data)

    % PCA of the normalized time series, excluding the specific schaefer
    % ROI we are working on. ess contains the PC time series.
    [~,ess,~,~,expl] = pca( ...
        schaefer.data{:,[1:s-1 s+1:end]}, ...
        'Centered',true, ...
        'VariableWeights','variance' ...
        );
    
    % Find the set that explains 95% of the variance
    z_inds = cumsum(expl)<=95;
    z = ess(:,z_inds);
    
    % Compute partial correlation
    Rp(:,s) = partialcorr(thal.data{:,:},schaefer.data{:,s},z);
    
end

Rstruct.Rp = array2table( ...
    Rp, ...
    'VariableNames',schaefer.data.Properties.VariableNames, ...
    'RowNames',thal.data.Properties.VariableNames ...
    );

Rstruct.colinfo = schaefer.info;
Rstruct.rowinfo = thal.info;
