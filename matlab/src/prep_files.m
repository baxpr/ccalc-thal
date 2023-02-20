function outfnames = prep_files(inp)

outfnames = struct();

% Copy files to out_dir and unzip. mask is optional, return empty if 'none'
% passed
for tag = {'removegm','keepgm','meanfmri','t1','mask','roidefinv'}

	inputfile = inp.([tag{1} '_niigz']);

	if strcmp(tag{1},'mask') && strcmp(inputfile,'none')
		outfnames.([tag{1} '_nii']) = '';
		continue
	end
	if strcmp(tag{1},'roidefinv') && strcmp(inputfile,'none')
		outfnames.([tag{1} '_nii']) = '';
		continue
	end
	
	outputfile = fullfile(inp.out_dir,[tag{1} '.nii.gz']);
	if strcmp(tag{1},'roidefinv')
		outputfile = fullfile(inp.out_dir,'iy_roi.nii.gz');
	end

	disp(['Copying ' inputfile ' to ' outputfile])
	copyfile(inputfile,outputfile);
	system(['gunzip -f ' outputfile]);
	outputfile = strrep(outputfile,'.nii.gz','.nii');
	outfnames.([tag{1} '_nii']) = outputfile;
end

% And we'll grab the ROI file separately so we can handle the in/out of
% container logic

if isempty(fileparts(inp.roi_niigz))
	% Use an ROI file from container if no path provided
	roitag = strrep(inp.roi_niigz,'.nii.gz','');
	roi_niigz = fullfile(inp.out_dir,'roi.nii.gz');
	copyfile(which(inp.roi_niigz),roi_niigz);
	system(['gunzip -f ' roi_niigz]);
	outfnames.roi_nii = strrep(roi_niigz,'.nii.gz','.nii');
	outfnames.roi_csv = fullfile(inp.out_dir,'roi-labels.csv');
	copyfile(which([roitag '-labels.csv']),outfnames.roi_csv);
else
	% Otherwise use externally supplied ROI file
	roi_niigz = fullfile(inp.out_dir,'roi.nii.gz');
	copyfile(inp.roi_niigz,roi_niigz);
	system(['gunzip -f ' roi_niigz]);
	outfnames.roi_nii = strrep(roi_niigz,'.nii.gz','.nii');
	outfnames.roi_csv = fullfile(inp.out_dir,'roi-labels.csv');
	copyfile(inp.roilabel_csv,outfnames.roi_csv);
end
