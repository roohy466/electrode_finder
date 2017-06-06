function zipping_all_data(WorkDir)
%================================================================
cd(WorkDir);
% saving the figures
disp('Zipping all Data');
% zipping all the created nifti files to decrese the space usage
nii_files=dir('*.nii');
for i=1:size(nii_files,1)
    unix(['gzip -fq ' nii_files(i).name]);
end
cd('./electrods_image/')
nii_files=dir('*.nii');
for i=1:size(nii_files,1)
    unix(['gzip -fq ' nii_files(i).name]);
end
cd('..');
delete('./electrods_image/*.nii');
delete('./electrods_image/*.asc');
delete('./electrods_image/*.w');

