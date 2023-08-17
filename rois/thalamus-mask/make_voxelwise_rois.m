% Each Yeo thalamus voxel its own ROI, with numerical labels

% Yeo thalamus binary mask
Vthal = spm_vol('thalamus-mask.nii.gz');
[Ythal,XYZthal] = spm_read_vols(Vthal);

% Yeo network labels
Vnet = spm_vol('../Yeo-thalamus/1000subjects_TightThalamus_clusters007_ref.nii.gz');
Ynet = spm_read_vols(Vnet);
infonet = readtable('../Yeo-thalamus/1000subjects_TightThalamus_clusters007_ref-labels.csv');

% Label voxels as ROIs and save ROI image
voxlist = Ythal(:)>0;
Label = (1:sum(Ythal(:)>0))';
Yvox = zeros(size(Ythal));
Yvox(voxlist) = Label;
Vvox = Vthal;
Vvox.fname = 'thalamus-voxelwise.nii';
spm_write_vol(Vvox,Yvox);
system(['gzip -f thalamus-voxelwise.nii']);

% Make CSV with voxel index, label, and network info
info = table(Label);
info.Region = cellfun(@(x) sprintf('voxel_%06d',x),num2cell(info.Label), ...
    'UniformOutput',false);
info.NetworkNum = Ynet(voxlist);
info.X = XYZthal(1,voxlist)';
info.Y = XYZthal(2,voxlist)';
info.Z = XYZthal(3,voxlist)';
for v = 1:height(info)
    info.Network{v} = infonet.Network{info.NetworkNum(v)==infonet.NetworkNum};
end

    