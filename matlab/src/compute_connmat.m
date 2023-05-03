function [C,rownames,colnames] = compute_connmat( ...
    roi_csv1,roi_csv2,connmetric,out_dir,out_basename)

roi_data1 = readtable(roi_csv1);
roi_data2 = readtable(roi_csv2);

rownames = roi_data1.Properties.VariableNames;
colnames = roi_data2.Properties.VariableNames;

switch connmetric
    
    case 'bivariate_pearson_r'
        C = corr(table2array(roi_data1),table2array(roi_data2));
    case 'bivariate_fisher_z'
        R = corr(table2array(roi_data1),table2array(roi_data2));
        C = atanh(R) .* sqrt(size(roi_data1,1)-3);
    otherwise
        error('Unknown connectivity metric %s',connmetric)
end

C = array2table( ...
    C, ...
    'VariableNames',roi_data2.Properties.VariableNames(:), ...
    'RowNames',roi_data1.Properties.VariableNames(:) ...
    );

writetable(C,fullfile(out_dir,[connmetric '_' out_basename '.csv']), ...
    'WriteRowNames',true)
