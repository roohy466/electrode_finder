function create_fslrpaint_from_MNIcoord(ElectNames,elect_xyz)

% this function creats the final paint file from a set of coordinates in
% MNI space. The naes containets the names of electordes and patient names
% like: 'Subje01_D_01', it should be a cell equal to the size of
% coordinates. The coord is a matrix of X, Y , Z for coolumns related to MNI space. 
% each raw of matrix a a coordiantes 
%It will automatically generates the Left and Right hemispher data
% =========detecting the program path and spm path
root_program=which('make_ribbon.m');
prog_address=[fileparts(root_program) '/'];
spm_program=which('spm.m');
MNI_address=[fileparts(spm_program) '/canonical/single_subj_T1.nii'];

% =============check the hemispher of the xyz coorinates
LeftCoord=elect_xyz( elect_xyz(1,:)<0,:); % the 0 considered as right hemispher
RightCoord=elect_xyz( elect_xyz(1,:)>=0,:);
Leftnames=ElectNames{elect_xyz(1,:)<0};
Rightnames=ElectNames{elect_xyz(1,:)>=0};

%==============generating the nearest node number to the Left or right coordinates
% rotation matrix because it is on fsaverage space
% p_orig=spm_vol_nifti(MNI_address);
% unix(['mri_convert -oc 0 0 0 ' MNI_address ' MNI_cent.nii']);
% p_cent=spm_vol_nifti('MNI_cent.nii');
% 
% Offset_free=[(p_orig.mat(1:3,4) - p_cent.mat(1:3,4))' 1];
Offset_free=[-1 -17 19 1];

%Offset=[0 0 0 1];
rot =[1 0 0;0 1 0;0 0 1;0 0 0 ];
xfm_free=[rot Offset_free'];

%-----------------------finding freesurfer path
% the path fof fsaverage surfaces from freesurfer data
[A,subject_path]=unix('echo $FREESURFER_HOME'); %finding freesurfer path
subject_path=strcat(subject_path,'/subjects/fsaverage'); % fsaverage path from freesurfer

%-------------------generating the nearest node number 
node_number_left =nearest_node_finder(LeftCoord,subject_path,'lh',xfm_free);
node_number_right =nearest_node_finder(RightCoord,subject_path,'rh',xfm_free);

%=================   creating FSLR file using the nodes and the name lists 
file_left =paint_creator_from_nodes_FSLR_multisubjects('fsaverage','MNI',Leftnames,node_number_left,'lh');
file_right =paint_creator_from_nodes_FSLR_multisubjects('fsaverage','MNI',Rightnames,node_number_right,'rh');


% ---------------template for delinations--------------
template_topology_f=ls([prog_address '/freesurfer_to_fs_LR/' ...
    'standard_mesh_atlases/*' upper(hemi(1)) '.close*.164k*.topo*']);
template_topology=template_topology_f(1:end-1);
template_sphere_f=ls([prog_address '/freesurfer_to_fs_LR/' ...
    'standard_mesh_atlases/*' upper(hemi(1)) '_LR.spher*.164k*.coord']);
template_sphere=template_sphere_f(1:end-1);

%=================    creating the final paintfiles
% ---------final output file names for left
Left_fslr_paint_file_delinated=[file_left(1:4) '_fsLR_MULTI.paint'];
disp('Create delinating contact point in FSLR space.....');
unix(['caret_command -paint-dilation ' template_sphere ' ' template_topology ' ' ...
    file_left ' '  Left_fslr_paint_file_delinated ' '  num2str(1)]);
caret_file_to_ascii(Left_fslr_paint_file_delinated);

% ---------final output file names for right
Right_fslr_paint_file_delinated=[file_right(1:4) '_fsLR_MULTI.paint'];
disp('Create delinating contact point in FSLR space.....');
unix(['caret_command -paint-dilation ' template_sphere ' ' template_topology ' ' ...
    file_right ' '  Right_fslr_paint_file_delinated ' '  num2str(1)]);
caret_file_to_ascii(Right_fslr_paint_file_delinated);

% cleaning up the delinated file
compressing_caret_paint({Right_fslr_paint_file_delinated})
compressing_caret_paint({Left_fslr_paint_file_delinated})





