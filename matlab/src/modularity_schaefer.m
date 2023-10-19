function [Q,N,M] = modularity_schaefer(W,M0)

%% Verify and adjust the input correlation matrix
%
% From the BCT documentation:
%
%     "The network matrices may be binary or weighted, directed or
%     undirected. Each function specifies the network type for which it is
%     suitable."
%
%     "The network matrices should not contain self-self
%     connections. In other words, all values on the main diagonal of these
%     matrices should be set to 0."
%
% Additionally, we are working with correlation matrices only, i.e. [-1,1]

% Symmetrize and check how much we changed it
dW = W - W.';
if any(dW(:)~=0)
	fprintf('Symmetrizing correlation matrix. Max asym = %0.2e\n', ...
		max(abs(dW(:))));
	if max(abs(dW(:))) > 1e-6
		warning('Check correlation matrix. Asymmetry unexpectedly high')
	end
end
W = (W + W.') / 2;

% Check for wrong values
if any( abs(W(:)) > 1.0 )
	error('Not a correlation matrix: found value out of range [-1,1]')
end

% Set diagonal to zero in accord with BCT expectations
W = W - diag(diag(W));


%% Compute modularity 
% Applying a specific community structure using the threshold-independent
% 'negative_asym' method of
%
%     https://www.ncbi.nlm.nih.gov/pubmed/21459148
%     https://doi.org/10.1016/j.neuroimage.2011.03.069
%
%     Rubinov M, Sporns O. Weight-conserving characterization of complex
%     functional brain networks. Neuroimage. 2011 Jun 15;56(4):2068-79.
%     doi: 10.1016/j.neuroimage.2011.03.069. Epub 2011 Apr 1. PubMed PMID:
%     21459148.
%
% Code adapted from the community_louvain.m function in the Brain
% Connectivity Toolbox 2017-01-05 release:
%
%     https://www.nitrc.org/projects/bct/
%     http://dx.doi.org/10.1016/j.neuroimage.2009.10.003
%
%     Complex network measures of brain connectivity: Uses and
%     interpretations. Rubinov M, Sporns O (2010) NeuroImage 52:1059-69.
%
%
% Inputs, following BCT notation:
%
%     W     Correlation matrix
%     M0    Community structure

% Fix the gamma resolution parameter to standard value
gamma = 1;

% Modularity matrix for positive weights
W0 = W .* (W>0);                                  % positive wts matrix
s0 = sum(sum(W0));                                % wt of positive links
B0 = W0 - gamma * (sum(W0,2)*sum(W0,1)) / s0;     % positive modularity

% Modularity matrix for negative weights
W1 = -W .* (W<0);                                  % negative wts matrix
s1 = sum(sum(W1));                                 % wt of negative links
if s1                                              % negative modularity
	B1 = W1 - gamma * (sum(W1,2)*sum(W1,1)) / s1;
else
	B1 = 0;
end

% Combine positive and negative portions into the 'asym' modularity matrix
% and symmetrize it
B = B0/s0 - B1/(s0+s1);
B = (B + B.') / 2;

% Compute modularity by summing the terms of B from node pairs that are in
% the same community. This step relies on having set the diagonal of W to
% zero as done above.
Q = sum( B(bsxfun(@eq,M0,M0.')) );
N = length(unique(M0));
M = M0;

