function entrypoint(varargin)

P = inputParser;
addOptional(P,'schaefer_csv','/OUTPUTS/schaefer.csv')
addOptional(P,'thomas_csv','/OUTPUTS/thomas.csv')
addOptional(P,'yeo_csv','/OUTPUTS/yeo.csv')
addOptional(P,'wfmri_nii','/OUTPUTS/wfmri.nii')
addOptional(P,'mask_nii','/OUTPUTS/thalamus-mask.nii')
addOptional(P,'out_dir','/OUTPUTS')
parse(P,varargin{:});


% Matrix, Schaefer 400 x THOMAS 12
compute_connmat(schaefer_csv,thomas_csv,'schaefer400_thomas12');

% Matrix, Schaefer 400 x Yeo 7
compute_connmat(schaefer_csv,yeo_csv,'schaefer400_yeo7');

% Maps, Schaefer 400. Only within mask of dilated Yeo7 whole thalamus
compute_connmaps(schaefer_csv,wfmri_nii,mask_nii, ...
    fullfile(out_dir,'connmaps_schaefer400'));
