function [PCs,scaledPCs] = bct_participation_coef_nan(W,Ci,flag)
%PARTICIPATION_COEF     Participation coefficient
%
%   P = participation_coef(W,Ci);
%
%   Participation coefficient is a measure of diversity of intermodular
%   connections of individual nodes.
%
%   Inputs:     W,      binary/weighted, directed/undirected connection matrix
%               Ci,     community affiliation vector
%               flag,   0, undirected graph (default)
%                       1, directed graph: out-degree
%                       2, directed graph: in-degree
%
%   Output:     P,      participation coefficient
%
%   Reference: Guimera R, Amaral L. Nature (2005) 433:895-900.
%
%
%   2008-2015
%   Mika Rubinov, UNSW/U Cambridge
%   Alex Fornito, University of Melbourne

%   Modification History:
%   Jul 2008: Original (Mika Rubinov)
%   Mar 2011: Weighted-network bug fixes (Alex Fornito)
%   Jan 2015: Generalized for in- and out-degree (Mika Rubinov)

if ~exist('flag','var')
    flag=0;
end

switch flag
    case 0 % no action required
    case 1 % no action required
    case 2; W=W.';
end

n=length(W);                        %number of vertices
Ko=sum(W,2);                        %degree
Gc=(W~=0)*diag(Ci);                 %neighbor community affiliation
Kc2=zeros(n,1);                     %community-specific neighbors

for i=1:max(Ci)
   Kc2=Kc2+(sum(W.*(Gc==i),2).^2);
end

PCs = ones(n,1)-Kc2./(Ko.^2);

% Scale by max possible value
nnw = numel(unique(Ci));
maxPC = 1 - (1/nnw)^2*nnw;
scaledPCs = PCs ./ maxPC;

% Removed this line to allow NaNs through when no connections
%P(~Ko)=0;                           %P=0 if for nodes with no (out)neighbors

