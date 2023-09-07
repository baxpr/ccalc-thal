function Rp = get_partial_matrix_2(schaefer,thal)

warning('off','stats:pca:ColRankDefX');

Rp = nan(width(thal),width(schaefer));

for s = 1:width(schaefer)
    for t = 1:width(thal)
        
        % Get normalized time series for all but this specific schaefer ROI
        z_all = schaefer;
        z_all(:,s) = [];
        z_all = zscore(table2array(z_all));

        % PCA of the normalized time series. ess contains the PC time
        % series
        [~,ess,~,~,expl] = pca(z_all);
        
        % Find the set that explains 95% of the variance
        z_inds = cumsum(expl)<=95;
        z = ess(:,z_inds);
        
        % Compute partial correlation
        Rp(t,s) = partialcorr(thal{:,t},schaefer{:,s},z);
        
    end
end

Rp = array2table( ...
    Rp, ...
    'VariableNames',schaefer.Properties.VariableNames, ...
    'RowNames',thal.Properties.VariableNames ...
    );

