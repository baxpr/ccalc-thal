function make_pdf_pages(out_dir,meanfmri_nii,t1_nii,label_info)


%% Connectivity matrix
connmat = readtable(fullfile(out_dir,'R_removegm.csv'),'ReadRowNames',true);
roinames = connmat.Properties.VariableNames;
roinames = cellfun(@(x) strrep(x,'_',' '),roinames,'UniformOutput',false);
labellen = max(cellfun(@length,roinames));
for r = 1:length(roinames)
	roinames{r} = pad(roinames{r},labellen,'right','.');
end

% Figure out screen size so the figure will fit
ss = get(0,'screensize');
ssw = ss(3);
ssh = ss(4);
ratio = 8.5/11;
if ssw/ssh >= ratio
	dh = ssh;
	dw = ssh * ratio;
else
	dw = ssw;
	dh = ssw / ratio;
end

% Create figure
pdf_figure = openfig('pdf_connmat_figure.fig','new');
set(pdf_figure,'Tag','pdf_connmat');
set(pdf_figure,'Units','pixels','Position',[0 0 dw dh]);
figH = guihandles(pdf_figure);

% Summary
set(figH.summary_text, 'String', 'Remove gray')

% Scan info
set(figH.scan_info, 'String', sprintf('%s',label_info));
set(figH.date,'String',['Report date: ' date]);
set(figH.version,'String',['Matlab version: ' version]);

% Conn matrix
axes(figH.connmatrix)
imagesc(table2array(connmat),[-1 1])
colormap(jet)
axis image
set(gca,'YTick',1:length(roinames),'YTickLabel',roinames)
set(gca,'XTick',1:length(roinames),'XTickLabel',roinames,'XTickLabelRotation',90)
set(gca,'FontName','fixedwidth','FontUnits','normalized', ...
	'FontSizeMode','manual','FontSize',0.015)

% Print to PNG
print(gcf,'-dpng','-r300',fullfile(out_dir,'connmatrix.png'))
close(gcf);


%% Show mean fmri and T1 with TPM overlay
show_coreg(out_dir,meanfmri_nii,t1_nii,label_info);

