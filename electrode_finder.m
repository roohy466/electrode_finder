

% Before running the program you need to install following software

% su
% apt-get update
% apt-get install gnumeric

% FSL should be installed
% Freesurfer should be installed
% CARET should be installed
% the SUBJECTS_DIR should be defined before running MATLAB

%**************************************************************************
%
% these files must be there:
%
%                SEEGlist.fcsv , seeg_leeds.XLS ,
%
%==========================================================================
% the three important files to have for program are LIST_Electrods (*.fcsv) and
% NUMBER_of_LEEDS ('seeg_leeds.txt')
% the file of transformation.txt is a two line coorinate that you get from
% centered and original r_oarm_seeg_cleaned.nii.
%========================================================================

%_____________________________________________________________________________
% if your matlab has problem in running libc and libesdc64++ run following
% commands
% 64 bits linux >>  sudo ln -s /lib/x86_64-linux-gnu/libc.so.6 /lib64/libc.so.6
% 32 bits linux >>  sudo ln -s /lib/i386-linux-gnu/libc.so.6 /lib/libc.so.6
% cd /MATLAB/bin
%     Backup original soft link by issuing: ???sudo mv libstdc++.so.6 ORIGINAL_libstdc++.so.6???
%     Create a link by issuing: ???sudo ln -s /usr/lib/libstdc++.so.6 libstdc++.so.6???


% ######################################################################
% list of electrods that used in the patients
% first you shoud go the subjects folder.

%%% electrode_finder(SUBJName,varagin)

%%% function variables is SUBJName can be 'Subj01',

%%%      electrode_finder('Subj01')

%%% varagin is the electrode that you want to exclude from processing 
%%% for example: you want to exclude the electrodes 2 and 4 from further
%%%  processing:

%%%      electrode_finder('Subj01',[2 4])

%%%  if you want to delete all previous analysis then add the "delete' like
%%%  this:
%%%         electrode_finder('Subj01','delete')

%%% or skip some electrodes also
%%%          
%%%        electrode_finder('Subj01','delete',[2:4])

%%% It will be behave as if the subject is newly added and create
%%% everything from scracth
%%% also it will check if the segmentaion data from freesurfer are
%%% available or not. if you want to do the segmentation directly you can
%%% add the freesurfer str in the electrode_finder as follow

%%%         electrode_finder('Subj01','freesurfer')


%%% Created by Rouhollah 11 May 2015

function message=electrode_finder(SUBJName,varargin)
root=pwd;
% testing prequisite software and data
[out_answer,WorkDir]=check_requirements(SUBJName);
if strcmp(out_answer,'yes')==1
    % Creating segmented electrodes
    message= electrode_extracter(SUBJName,varargin);
    disp(message)
    if size(strfind(message,'fine'),1)==1
        % Creating mereged version
        merged_file=merging_all_electrodes(WorkDir,SUBJName);
        [DirR,merged_fileName,suffix]=fileparts(merged_file);
        
        % creating single column paint file  
        single_column_merging_caret_paints([merged_fileName suffix],DirR,SUBJName)
        
        % creating EXCEL report file
        create_excel_reportfile(WorkDir);
        
        % Zipping all the Data
        zipping_all_data(WorkDir);
        message='All done without any problem';
        disp('');
        disp(message);
        disp('#################################################')
    else
        message='Error Happened....!';
        disp(message);
    end
end
cd(root);



% adding all electrod to one paint file for all subjects
% run it where all subjects FS_LRs gathered!
function merging_all_electrodes_all_subjects
%================================================================
% adding all electrod to one paint file
root=pwd;
files_to_merge_tmp=dir([root '/*_fsLR.paint']);
n_file=size(files_to_merge_tmp,1);
if n_file>0
    for i=1:n_file
        files_to_merge{i}=[root '/' files_to_merge_tmp(i).name];
    end
    %*************** merge the files **********************
    %%% for any merging this function works
    %%%  compressing_caret_paint(files_to_merge,root)
    %%% list of files as a cell, and root folder to save all
    CompressedFile=compressing_caret_paint(files_to_merge,root);
    %******************************************************
    
    %%% single column paint file
    [DirR,merged_fileName,suffix]=fileparts(CompressedFile);
    single_column_merging_caret_paints([merged_fileName suffix],DirR);
end









