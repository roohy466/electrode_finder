function file_out=merging_all_electrodes(WorkDir,subjname)
%================================================================
% adding all electrod to one paint file
cd(WorkDir);
if exist('electrods_image','file')==7
    rootsubj=pwd;
    cd('./electrods_image');
    root=pwd;
    files_to_merge_tmp=dir([root '/*_MULTI.paint']);
    n_file=size(files_to_merge_tmp,1);
    if n_file>0
        for i=1:n_file
            files_to_merge{i}=[root '/' files_to_merge_tmp(i).name];
        end
        %*************** merge the files **********************
        %%% for any merging this function works
        %%%  compressing_caret_paint(files_to_merge,root)
        %%% list of files as a cell, and root folder to save all
        file_out=compressing_caret_paint(files_to_merge,root,subjname);
        disp(file_out);
        %******************************************************
    end
    cd(rootsubj);
end