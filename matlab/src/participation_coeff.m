function participation_coeff(roi_dir,out_dir)
% Participation coefficient
%
% Hwang K, Bertolero MA, Liu WB, D'Esposito M. The Human Thalamus Is an
% Integrative Hub for Functional Brain Networks. J Neurosci. 2017 Jun
% 7;37(23):5594-5607. doi: 10.1523/JNEUROSCI.0067-17.2017. Epub 2017 Apr
% 27. PMID: 28450543; PMCID: PMC5469300.
%
% https://www.ncbi.nlm.nih.gov/pmc/articles/PMC5469300/

% We have 400 cortical ROIs from Schaefer, each assigned to one of the 7
% Yeo networks.
roimap = readtable(fullfile(roi_dir,'Schaefer2018', ...
    'Schaefer2018_400Parcels_7Networks_order_FSLMNI152_2mm.Centroid_RAS.csv'), ...
    'Format','%d%q%f%f%f');
for h = 1:height(roimap)
    roimap.TextLabel{h,1} = sprintf('schaefer_%03d',roimap.ROILabel(h));
    q = strsplit(roimap.ROIName{h},'_');
    roimap.Network{h,1} = q{3};
end

% FIXME - need to map Yeo 1..7 from thalamus map to the labels used above.
% It is probably this, the same order as in the label csv above and also in
% the Yeo paper:
%   1 - Visual            (Vis)
%   2 - Somatomotor       (SomMot)
%   3 - Dorsal Attention  (DorsAttn)
%   4 - Ventral Attention (SalVentAttn)
%   5 - Limbic            (Limbic)
%   6 - Frontoparietal    (Cont)
%   7 - Default           (Default)
%
% But verify visually vs the cortical network maps in the numerically
% indexed nifti at
% https://github.com/ThomasYeoLab/CBIG/tree/master/stable_projects/brain_parcellation/Yeo2011_fcMRI_clustering


