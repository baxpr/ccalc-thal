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

q = strsplit(Rthal.rowinfo.Region{1},'_');
roiset = q{1};

% Loop over densities
result = table();
ct = 0;
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
    %
    % Finally, WMD.
    for nw = 1:nnw
        inschaefer = find(strcmp(Rschaefer.colinfo.Network,networks{nw}));
        inthal = find(strcmp(Rthal.rowinfo.Network,networks{nw}));
        thisRschaefer_nw = thisRschaefer(inschaefer,inschaefer);
        thisRthal_nw = thisRthal(inthal,inschaefer);
        schaeferedges = [];
        for node = 1:size(thisRschaefer_nw,2)
            schaeferedges(:,node) = thisRschaefer_nw([1:node-1 node+1:end],node);
        end

        CW = mean(sum(schaeferedges));
        sCW = std(sum(schaeferedges));
        K = sum(thisRthal_nw,2);
        WMD = (K - CW) / sCW;

        for r = 1:size(WMD,1)
            ct = ct + 1;
            result.Region{ct,1} = Rthal.rowinfo.Region{inthal(r)};
            result.ROI_Set{ct,1} = roiset;
            result.density(ct,1) = d;
            result.roi_WMD(ct,1) = WMD(r);
        end

    end

end


