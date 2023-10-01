function result = compute_WMDs(Rschaefer,Rthal,densities)

% Computes within-module degree for the thalamus regions for an incomplete
% thalamus x schaefer (partial) correlation matrix, at a range of
% densities. Normalized using the schaefer x schaefer correlation matrix.
% Matrices are binarized.

% Check that matrices are in the same order on the schaefer axes
if ~all(strcmp(Rschaefer.rowinfo.Region,Rschaefer.colinfo.Region))
    error('Schaefer rows/cols not matching')
end
if ~all(strcmp(Rthal.colinfo.Region,Rschaefer.colinfo.Region))
    error('Schaefer/thalamus cols not matching')
end

% Identify networks
networks = unique(Rschaefer.colinfo.Network);
nnw = numel(networks);
if ~all(strcmp(networks,unique(Rthal.colinfo.Network)))
    error('Network name mismatch')
end


% Loop over densities
for d = densities

    % Separately threshold and binarize the correlation matrices at density d
    thisRschaefer = table2array(Rschaefer.R);
    thisRschaefer = double(thisRschaefer >= quantile(thisRschaefer(:),1-d));
    thisRthal = table2array(Rthal.R);
    thisRthal = double(thisRthal >= quantile(thisRthal(:),1-d));

    % Compute normalizing factor (mean and SD of edge counts for each network).
    % Some gymnastics to remove self-connections.
    % 
    % Also compute K, the count (sum) of within-network edges for each
    % thalamus ROI, each network.
    CW = nan(1,nnw);
    sCW = nan(1,nnw);
    K = nan(size(thisRthal,1),nnw);
    for nw = 1:nnw
        innetwork = strcmp(Rschaefer.colinfo.Network,networks{nw});
        Rinnetwork = thisRschaefer(innetwork,innetwork);
        edgevals = [];
        for node = 1:size(Rinnetwork,2)
            edgevals(:,node) = Rinnetwork([1:node-1 node+1:end],node);
        end
        CW(nw) = mean(sum(edgevals));
        sCW(nw) = std(sum(edgevals));

        K(:,nw) = sum(thisRthal(:,innetwork),2);
    end

end

% Compute WMDs. Using recent matlab's ability to broadcast (replicate)
% across a dimension with size 1.
WMDs = (K - CW) ./ sCW;

% Reformat result
result = WMDs;


