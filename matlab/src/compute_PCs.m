function compute_PCs(inp,roi1_csv,roi2_csv,roi1_labels,tag)

% Compute connectivity matrix
[R,rownames,colnames] = compute_connmat( ...
    roi1_csv, ...
    roi2_csv, ...
    inp.connmetric, ...
    inp.out_dir, ...
    tag);

% Verify labels and data match for roi1
if ~all(strcmp(rownames',roi1_labels.Region))
    error('Mismatch in region labels')
end

% If the two ROI files are the same, zero the diagonal to prevent
% self-connections interfering with PC calculation
Rmat = table2array(R);
if strcmp(roi1_csv,roi2_csv)
    disp('Zeroing connmat diagonal for matching ROI sets')
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
    
    PCs = [PCs; participation_coeff(thisR,roi1_labels.Network)];
end

% Organize and write to file
result = array2table(densities','VariableNames',{'density'});
result = [result array2table(PCs,'VariableNames',colnames)];
writetable(result,fullfile(inp.out_dir,['PC_' tag '.csv']));

meanresult = table({inp.densities}, ...
    'VariableNames',{'densities'});
meanresult = [meanresult array2table(mean(PCs),'VariableNames',colnames)];
writetable(meanresult,fullfile(inp.out_dir,['meanPC_' tag '.csv']));
