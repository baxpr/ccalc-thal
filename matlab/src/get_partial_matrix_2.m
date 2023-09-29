function Rstruct = get_partial_matrix_2(schaefer,thal,pctvar)

warning('off','stats:pca:ColRankDefX');

R = nan(width(thal.data),width(schaefer.data));

for s = 1:width(schaefer.data)

    if isfinite(pctvar)

        % PCA of the normalized time series, excluding the specific schaefer
        % ROI we are working on. ess contains the PC time series.
        [~,ess,~,~,expl] = pca( ...
            schaefer.data{:,[1:s-1 s+1:end]}, ...
            'Centered',true, ...
            'VariableWeights','variance' ...
            );

        % Find the set that explains pctvar% of the variance
        z_inds = cumsum(expl)<=pctvar;
        z = ess(:,z_inds);

        % Compute partial correlation
        R(:,s) = partialcorr(thal.data{:,:},schaefer.data{:,s},z);

    else

        % Standard correlation, if percent variance threshold was inf
        R(:,s) = corr(thal.data{:,:},schaefer.data{:,s});

    end

end

Rstruct.R = array2table( ...
    R, ...
    'VariableNames',schaefer.data.Properties.VariableNames, ...
    'RowNames',thal.data.Properties.VariableNames ...
    );

Rstruct.colinfo = schaefer.info;
Rstruct.rowinfo = thal.info;
