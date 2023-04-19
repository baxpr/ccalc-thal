function compute_PCs(inp)

%% Get Yeo7 network names for Schaefer400 ROI set
%
% Yeo7 ROIs with labels from Schaefer CSV:
%   1 - Visual            (Vis)
%   2 - Somatomotor       (SomMot)
%   3 - Dorsal Attention  (DorsAttn)
%   4 - Ventral Attention (SalVentAttn)
%   5 - Limbic            (Limbic)
%   6 - Frontoparietal    (Cont)
%   7 - Default           (Default)
netmap = readtable(fullfile(inp.roi_dir,'Schaefer2018', ...
    'Schaefer2018_400Parcels_7Networks_order_FSLMNI152_2mm.Centroid_RAS.csv'), ...
    'Format','%d%q%f%f%f');
for h = 1:height(netmap)
    netmap.TextLabel{h,1} = sprintf('schaefer_%03d',netmap.ROILabel(h));
    q = strsplit(netmap.ROIName{h},'_');
    netmap.Network{h,1} = q{3};
end


%% Schaefer 400 x Yeo 7

% Matrix
disp('Connectivity matrix Schaefer 400 x Yeo 7')
[R,~,~,colnames] = compute_connmat( ...
    inp.schaefer_csv, ...
    inp.yeo_csv, ...
    inp.out_dir, ...
    'schaefer400_yeo7');

% PC
densities = eval(inp.densities);
PCs = [];
for d = densities
    thisR = table2array(R);
    thisR(thisR(:) < prctile(thisR(:),1-d)) = 0;
    PCs = [PCs; participation_coeff(thisR,netmap.Network)];
end

% Organize and write to file
result = array2table(densities','VariableNames',{'density'});
result = [result array2table(PCs,'VariableNames',colnames)];
writetable(result,fullfile(inp.out_dir,'PC_schaefer400_yeo7.csv'));

meanresult = table({inp.densities}, ...
    'VariableNames',{'densities'});
meanresult = [meanresult array2table(mean(PCs),'VariableNames',colnames)];
writetable(meanresult,fullfile(inp.out_dir,'meanPC_schaefer400_yeo7.csv'));
