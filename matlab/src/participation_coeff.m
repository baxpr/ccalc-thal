function [PC,scaledPC] = participation_coeff(K,Network)
% Participation coefficient.
%
% Hwang K, Bertolero MA, Liu WB, D'Esposito M. The Human Thalamus Is an
% Integrative Hub for Functional Brain Networks. J Neurosci. 2017 Jun
% 7;37(23):5594-5607. doi: 10.1523/JNEUROSCI.0067-17.2017. Epub 2017 Apr
% 27. PMID: 28450543; PMCID: PMC5469300.
%
% https://www.ncbi.nlm.nih.gov/pmc/articles/PMC5469300/
%
% K must be the preprocessed (thresholded, binarized, etc) connectivity
% matrix / graph. Edge weights must be non-negative. If row and column ROI
% sets are the same, the diagonal should be zeroed to avoid affecting the
% computation with self-correlations.

% Verify sizes
if size(K,1)~=numel(Network)
    error('Rows of K and Network labels do not match')
end

% Unique network names
networks = unique(Network);
nnw = numel(networks);

% Hwang 2017 eqn for PC. i indexes target regions (e.g. THOMAS, Yeo, or
% voxel sets; cols of K). s indexes cortical networks (e.g. Yeo7; rows of
% K). Rescale based on number of networks so that max value of PC is 1.
PC = ones(1,size(K,2));
for s = 1:nnw
    PC = PC - ( sum(K .* strcmp(Network,networks{s})) ./ sum(K) ) .^ 2;
end
maxPC = 1 - (1/nnw)^2*nnw;
scaledPC = PC ./ maxPC;

