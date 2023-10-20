function conncalc(varargin)
% Thalamus specific ROI sets and connectivity computation


%% Parse inputs
P = inputParser;

% Preprocessed fMRI, outputs from connprep. Same space as the ROI image.
addOptional(P,'removegm_niigz','');
addOptional(P,'keepgm_niigz','');
addOptional(P,'meanfmri_niigz','');
addOptional(P,'wremovegm_niigz','');
addOptional(P,'wkeepgm_niigz','');
addOptional(P,'wmeanfmri_niigz','');

% THOMAS native space ROI image
addOptional(P,'thomas_niigz','');

% T1, e.g. bias corrected T1 from cat12 (native space and atlas space)
addOptional(P,'t1_niigz','');
addOptional(P,'wt1_niigz','');

% Smoothing to apply to connectivity maps
addOptional(P,'fwhm','4');

% Subject info if on XNAT
addOptional(P,'label_info','');

% Where to store outputs
addOptional(P,'out_dir','/OUTPUTS');

% Parse
parse(P,varargin{:});
disp(P.Results)


%% Process
conncalc_main(P.Results);


%% Exit
if isdeployed
	exit
end

