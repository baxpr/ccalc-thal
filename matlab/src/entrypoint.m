function entrypoint(varargin)

P = inputParser;
addOptional(P,'schaefer_csv','/OUTPUTS/schaefer.csv')
addOptional(P,'thomas_csv','/OUTPUTS/thomas.csv')
addOptional(P,'yeo_csv','/OUTPUTS/yeo.csv')
addOptional(P,'wfmri_nii','/OUTPUTS/wfmri.nii')
addOptional(P,'mask_nii','/OUTPUTS/thalamus-mask.nii')
addOptional(P,'roi_dir','/opt/ccalc-thal/rois')
addOptional(P,'out_dir','/OUTPUTS')
parse(P,varargin{:});
inp = P.Results;

% Matrix, Schaefer 400 x THOMAS 12
disp('Connectivity matrix 1')
compute_connmat(inp.schaefer_csv,inp.thomas_csv, ...
    inp.out_dir,'schaefer400_thomas12');

% Matrix, Schaefer 400 x Yeo 7
disp('Connectivity matrix 2')
compute_connmat(inp.schaefer_csv,inp.yeo_csv, ...
    inp.out_dir,'schaefer400_yeo7');

% Maps, Schaefer 400. Only within mask of dilated Yeo7 whole thalamus
disp('Connectivity maps')
compute_connmaps(inp.schaefer_csv,inp.wfmri_nii,inp.mask_nii, ...
    fullfile(inp.out_dir,'connmaps_schaefer400'));
