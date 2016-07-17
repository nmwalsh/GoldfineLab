%cofl_anal_auto_demo.m
% runs cofl_anal_demo; uses a file list kept in cofl_anal_data.mat,
% made with cofl_anal_data_make.m
%
anal_opts.ipca_list=[3 4 5 9 10 11]; %which kind of pca's to show
anal_opts.quantiles=[0.025 0.05 0.10 0.50 0.90 0.95 0.975];
anal_opts.headmap_infix='basic'; % infix for plot and stat output files
anal_opts.cell_choice=1; %first segment in each data file
anal_opts.plot_anal_choice=2; %headmap
%
if ~exist('file_list')
    s=load('cofl_anal_data.mat');
    file_list=s.file_list;
    dirstring=s.dirstring;
    clear s;
end
%
%check that all files are present
have_files=[];
for ifile=1:length(file_list)
    auto.filename=cat(2,dirstring,file_list{ifile},'.mat');
    if_found=exist(auto.filename);
    if (if_found==2)
        disp(sprintf('%3.0f->     found: %s',ifile,auto.filename));
        have_files=[have_files,ifile];
    else
        disp(sprintf('%3.0f-> not found: %s',ifile,auto.filename));
    end
end
have_files=getinp('files to process','d',[1 length(file_list)],have_files);
%
for ifile_ptr=1:length(have_files)
    ifile=have_files(ifile_ptr);
    auto=anal_opts;
    auto.filename=cat(2,dirstring,file_list{ifile},'.mat');
    diary_filename=cat(2,file_list{ifile},'_',anal_opts.headmap_infix,'_stats.txt');
    diary(diary_filename);
    disp(sprintf('analyzing %s with diary written %s',auto.filename,diary_filename));
    disp(datestr(now));
    disp('analysis options');
    disp(anal_opts);
    %do the analysis
    %
    cofl_anal_demo;
    %
    disp('analysis complete.');
    close all;
    diary off;
end