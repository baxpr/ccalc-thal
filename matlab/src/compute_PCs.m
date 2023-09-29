function result = compute_PCs(Rthal,densities)

% PC
PCs = [];
for d = densities
    thisR = table2array(Rthal.R);

    % Zero edges below threshold but retain weights of those above
    %thisR(thisR(:) < quantile(thisR(:),1-d)) = 0;
    
    % Or binarize
    thisR = double(thisR >= quantile(thisR(:),1-d));
    
    PCs = [PCs; participation_coeff(thisR',Rthal.colinfo.Network)];
end

% Organize and write to file
result = array2table(densities','VariableNames',{'density'});
result = [result array2table(PCs,'VariableNames',Rthal.rowinfo.Region)];
%writetable(result,fullfile(inp.out_dir,['PC_' tag '.csv']));
