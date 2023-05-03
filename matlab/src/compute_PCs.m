function compute_PCs(inp,roi_csv1,roi_csv2,row_networks,tag)

% Compute connectivity matrix
[R,~,colnames] = compute_connmat( ...
    roi_csv1, ...
    roi_csv2, ...
    inp.connmetric, ...
    inp.out_dir, ...
    tag);

% If the two ROI files are the same, zero the diagonal to prevent
% self-connections interfering with PC calculation
Rmat = table2array(R);
if strcmp(roi_csv1,roi_csv2)
    Rmat = Rmat - eye(size(Rmat)) .* Rmat;
end
    
% PC
densities = eval(inp.densities);
PCs = [];
for d = densities
    thisR = Rmat;

    % Zero edges below threshold but retain weights of those above
    thisR(thisR(:) < quantile(thisR(:),1-d)) = 0;
    
    % Or just binarize
    %thisR = double(thisR >= quantile(thisR(:),1-d));
    
    PCs = [PCs; participation_coeff(thisR,row_networks)];
end

% Organize and write to file
result = array2table(densities','VariableNames',{'density'});
result = [result array2table(PCs,'VariableNames',colnames)];
writetable(result,fullfile(inp.out_dir,['PC_' tag '.csv']));

meanresult = table({inp.densities}, ...
    'VariableNames',{'densities'});
meanresult = [meanresult array2table(mean(PCs),'VariableNames',colnames)];
writetable(meanresult,fullfile(inp.out_dir,['meanPC_' tag '.csv']));
