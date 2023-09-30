function compute_WMDs(Rschaefer,Rthal,densities)

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
if ~all(strcmp(networks,Rthal.colinfo.Network))
    error('Network name mismatch')
end


% Loop over densities

% Separately threshold and binarize the correlation matrices at density d
thisRschaefer = table2array(Rschaefer.R);
thisRschaefer = double(thisRschaefer >= quantile(thisRschaefer(:),1-d));
thisRthal = table2array(Rthal.R);
thisRthal = double(thisRthal >= quantile(thisRthal(:),1-d));

% Compute normalizing factor (mean and SD of edge count for each network).
% FIXME need to remove self-connections from the computations.
CW = nan(nnw,1);
sCW = nan(nnw,1);
for n = 1:nnw
    innetwork = strcmp(Rschaefer.colinfo.Network,networks{n});
    edgecounts = sum(thisRschaefer(innetwork,innetwork));
    CW(n) = mean(edgecounts);
    sCW(n) = std(edgecounts);
end


