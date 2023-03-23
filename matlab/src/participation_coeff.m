function PC = participation_coeff(K,roi_dir)
% Participation coefficient
%
% Hwang K, Bertolero MA, Liu WB, D'Esposito M. The Human Thalamus Is an
% Integrative Hub for Functional Brain Networks. J Neurosci. 2017 Jun
% 7;37(23):5594-5607. doi: 10.1523/JNEUROSCI.0067-17.2017. Epub 2017 Apr
% 27. PMID: 28450543; PMCID: PMC5469300.
%
% https://www.ncbi.nlm.nih.gov/pmc/articles/PMC5469300/
%
% We have 400 cortical ROIs from Schaefer, each assigned to one of the 7
% Yeo networks.
%
% Yeo7 ROIs with labels from Schaefer CSV:
%   1 - Visual            (Vis)
%   2 - Somatomotor       (SomMot)
%   3 - Dorsal Attention  (DorsAttn)
%   4 - Ventral Attention (SalVentAttn)
%   5 - Limbic            (Limbic)
%   6 - Frontoparietal    (Cont)
%   7 - Default           (Default)

roimap = readtable(fullfile(roi_dir,'Schaefer2018', ...
    'Schaefer2018_400Parcels_7Networks_order_FSLMNI152_2mm.Centroid_RAS.csv'), ...
    'Format','%d%q%f%f%f');

for h = 1:height(roimap)
    roimap.TextLabel{h,1} = sprintf('schaefer_%03d',roimap.ROILabel(h));
    q = strsplit(roimap.ROIName{h},'_');
    roimap.Network{h,1} = q{3};
end

networks = unique(roimap.Network);
nnw = numel(networks);

% Hwang 2017 eqn for PC. i indexes thalamus regions (THOMAS, Yeo, or voxel
% sets). s indexes cortical networks (Yeo7). Our connectivity matrix is 400
% rows of cortical ROIs x 1..i cols of thalamus regions. Rescale based on
% number of networks so that max value of PC is 1.
%
% Threshold needed:
% K = readtable('../../OUTPUTS/R_schaefer400_thomas12.csv','ReadRowNames',true);
% table2array(K).*table2array(K)>0.05
PC = ones(1,size(K,2));
for s = 1:nnw
    PC = PC - ( sum(K .* strcmp(roimap.Network,networks{s})) ./ sum(K) ) .^ 2;
end
maxPC = 1 - (1/nnw)^2*nnw;
PC = PC ./ maxPC;


