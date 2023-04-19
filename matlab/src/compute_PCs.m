function compute_PCs(inp,roi_csv1,roi_csv2,row_networks,tag)

% Matrix
[R,~,~,colnames] = compute_connmat( ...
    roi_csv1, ...
    roi_csv2, ...
    inp.out_dir, ...
    tag);

% PC
densities = eval(inp.densities);
PCs = [];
for d = densities
    thisR = table2array(R);
    % Zero edges below threshold but retain weights of those above
    thisR(thisR(:) < prctile(thisR(:),1-d)) = 0;
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
