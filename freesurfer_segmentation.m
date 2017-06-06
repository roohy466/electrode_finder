function message=freesurfer_segmentation(folder,subject)
%This function needs the path of the subject and subject name also  
% like
%    freesurfer_segmentation('/data/mydata','SUB01')
% the basic need is the ref.nii.gz image
if exist([folder '/' subject '/ref.nii.gz'],'file')==2;
else
    clear message
    message='ERROR, needs a reference image';
    disp(message);
    return;
end

orig_folder=[ folder '/' subject '/mri/orig'];
if exist(orig_folder,'dir')==0
    mkdir([folder '/' subject '/mri/orig']);
end
copyfile([folder '/' subject '/ref.nii.gz'],[orig_folder '/orig.nii.gz']);
unix(['mri_convert ' orig_folder '/orig.nii.gz ' orig_folder '/001.mgz']);
unix(['recon-all -all  -no-isrunning -subjid ' subject]);
