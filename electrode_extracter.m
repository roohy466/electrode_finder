function message=electrode_extracter(subj_name,varargin)
% Which hemisphere you want to proces

% #######################################################################
% if you want to skip any electrods put the numbers like: [ 1 3]
electrod_to_skip=[];
RemoveCheck='No';
message='OK';
FreesurferCheck=1; % check the freesurfer data

inputData=varargin{1};

% chekcing the input
if size(inputData,2)==0
else
    for i=1:size(inputData,2)
        inputDataType(i)=ischar(inputData{i});
    end
    if sum(inputDataType==0)==1
        electrod_to_skip=inputData{inputDataType==0};
    end
    strinput=char(inputData{inputDataType==1});
    
    if size(strinput,1)>0
        for i=1:size(strinput,1)
            if strfind(lower(strinput(i,:)),'delete')==1
                % deleteing all the previous analyzed data
                RemoveCheck='yes';
            end
            if strfind(lower(strinput(i,:)),'freesurfer')==1
                % deleteing all the previous analyzed data
                FreesurferCheck=0;
            end
        end
    end
end

[txt_tmp ,root_subj]=unix('echo $SUBJECTS_DIR');
root_subj=root_subj(1:end-1);

% checking freesurfer data
if FreesurferCheck==1
    message=check_freesurfer(root_subj,subj_name);
    if strfind(message,'ERROR')>0
        return;
    end
else
    message=freesurfer_segmentation(root_subj,subj_name);
    if strfind(message,'ERROR')>0
        return;
    end
end
folder=[root_subj subj_name];
cd(folder);


%  before runining matlab you should apply $SUBJECT_DIR for freesurfer to
%  know where the subject forders?!
% you should run the command in terminal: SUBJECT_DIR = /data/....
% then after that you run matlab in the same terminal
% creating caret data template in fs_LR template for flat map\
% check your program if you have two make_ribbon.m
root_program=which('make_ribbon.m');
caret_data=[root_subj subj_name '/fs_LR_output/'];
prog_address=[fileparts(root_program) '/'];


if strcmp(RemoveCheck,'yes')==1
    if exist(caret_data,'dir')>0
        rmdir('./fs_LR_output','s');
    end
    if   exist('electrod_report','dir')>0
        rmdir('./electrod_report','s');
    end
    if   exist('electrods_image','dir')>0
        rmdir('./electrods_image','s');
    end
    if   exist('electrods.fig','file')>0
        delete('electrods.fig');
    end
    if   exist('r_oarm_seeg_cleaned_copy.nii','file')>0
        delete('r_oarm_seeg_cleaned_copy.nii');
    end
    delete RF*
end

if isdir( 'electrods_image')==0  % if this directory isnot exist create it
    mkdir('electrods_image');
end
fid_log_gen=fopen([folder '/electrods_image/General_electrodes_log.txt'],'w');

% >>>>>>>>>>>>>>>> critical <<<<<<<<<<<<<<<<<<<
% load a centered and orig in slicer and find the differences and put it
% here
% if exist('transformation.txt')==0
%     disp('no tranformation.txt , please create one!!!');
%     break;
% end
clear electod_leeds elect_names electrod_coordiantes_tmp
if size(dir('*acsv'),1)==0
    electod=dir('SEEG*.fcsv');
    try
        electod.name;
    catch
        disp('ERROR, no SEEGlist.fcsv , please create one!');
        message='NOFILE';
        return;
    end
    % reading the eletrod list
    electod=dir('*.fcsv');
    if size(electod,1)>1
        message='ERROR,Too many files of electrodes list, remove one';
        electod.name
        return;
    end
    % make sure your electrod lists are either right or left
    [elect_names,electrod_coordiantes_tmp,leads,version_file ]= read_electrod_list(electod.name);
    if version_file>4 || size(dir('*.XLS'),1)>0 || size(dir('*.xls'),1)>0
        if size(dir('*.XLS'),1)>0
            leed_file_tmp=dir('*.XLS');
        elseif size(dir('*.xls'),1)>0
            leed_file_tmp=dir('*.xls');
        end
        
        if size(dir([ '*.csv']),1)==0
            unix(['ssconvert ' leed_file_tmp.name ' ' leed_file_tmp.name(1:end-3) 'csv'])
        end
        leed_file_tmp=dir([ '*.csv']);
        electod_leeds_tmp=importdata([leed_file_tmp.name(1:end-3) 'csv'],',',1);
        for i=1:size(electod_leeds_tmp.data,1)
            if electod_leeds_tmp.data(i,3)==1
                electod_leeds.data(i,:)=[electod_leeds_tmp.data(i,5) NaN NaN];
            else
                electod_leeds.data(i,:)=[electod_leeds_tmp.data(i,5) 1 electod_leeds_tmp.data(i,3)];
            end
            electod_leeds.textdata{i,1}=electod_leeds_tmp.textdata{i+1,2}(1);
        end
    else
        
        if exist('seeg_leeds.txt','file')==0
            disp('ERROR,  no seeg_leeds.fcsv , please create one!!!');
            message='NOFILE';
            return;
        end
        %Offset_free =[transformation_offset('freesurfer_transformation.txt')  1];
        electod_leeds=importdata('seeg_leeds.txt');
        if  size(electod_leeds.data,2)==1
            electod_leeds.data=[electod_leeds.data repmat([NaN NaN],size(electod_leeds.data,1),1)];
        end
    end
    
else
    % reading csv files of data
    files_acsv=dir('*.acsv');
    for f=1:size(files_acsv,1)
        [elect_names(f,:),electrod_coordiantes_tmp(f,:)]= read_electrod_list_acvs(files_acsv(f).name);
    end
    x1=electrod_coordiantes_tmp(:,1);
    y1=electrod_coordiantes_tmp(:,2);
    z1=electrod_coordiantes_tmp(:,3);
    electrods_lenght=zeros(size(x1));
    for i=1:size(files_acsv,1)/2;
        electrods_lenght(i)=sqrt((x1(2*i-1)-x1(2*i))^2+(y1(2*i-1)-y1(2*i))^2+(z1(2*i-1)-z1(2*i))^2);
    end
    leads=round((electrods_lenght+1.5)/3.5);
    leed_file_tmp=dir('*.XLS');
    if exist([leed_file_tmp.name(1:end-3) 'csv'])==0
        unix(['ssconvert ' leed_file_tmp.name ' ' leed_file_tmp.name(1:end-3) 'csv'])
    end
    electod_leeds_tmp=importdata([leed_file_tmp.name(1:end-3) 'csv'],',',1);
    for i=1:size(electod_leeds_tmp.data,1)
        if electod_leeds_tmp.data(i,3)==1
            electod_leeds.data(i,:)=[electod_leeds_tmp.data(i,5) NaN NaN];
        else
            electod_leeds.data(i,:)=[electod_leeds_tmp.data(i,5) 1 electod_leeds_tmp.data(i,3)];
        end
        electod_leeds.textdata{i,1}=electod_leeds_tmp.textdata{i+1,2}(1);
    end
end
if exist('electrod_report','file')==0
    disp('Creating Report Folder');
    mkdir('electrod_report')
end

%%%#####################################################
%%% matching the  electod_leeds data and SEEGlist data

[ message, electod_leeds]=matching_electfile_seegfile(elect_names,electrod_coordiantes_tmp, electod_leeds);

if size(strfind(message,'ERROR'),2)==1
    return;
end
%>>>>>>>
% finding the centerd version of r_cleaned
% making a centered version of refrence file

if exist('RF_r_oarm_seeg_cleaned_cent.nii','file')==0 || exist('r_oarm_seeg_cleaned_copy.nii','file')==0
    if exist('RF_r_oarm_seeg_cleaned_cent.nii.gz','file')==0 || exist('r_oarm_seeg_cleaned_copy.nii.gz','file')==0
        unix('mri_convert -oc 0 0 0 r_oarm_seeg_cleaned.nii.gz RF_r_oarm_seeg_cleaned_cent.nii');
        unix('cp r_oarm_seeg_cleaned.nii.gz r_oarm_seeg_cleaned_copy.nii.gz');
    end
end
unix('gzip -dfq r_oarm_seeg_cleaned_copy.nii.gz');
%p_orig=spm_vol('r_oarm_seeg_cleaned_copy.nii');
%p_cent=spm_vol('RF_r_oarm_seeg_cleaned_cent.nii');



%Offset =[transformation_offset('transformation.txt')  1];
clear p_orig p_cent
% finding the center of image and creating freesurfer_transformation
% making a centered version of refrence file


try
    p_orig=spm_vol_nifti('RF_ref.nii');
catch
    unix('cp ref.nii.gz RF_ref.nii.gz');
    unix('gzip -dfq RF_ref.nii.gz');
    disp('Creating a copy of data');
    p_orig=spm_vol_nifti('RF_ref.nii');
end

try
    p_cent=spm_vol_nifti('RF_ref_cent.nii');
catch
    unix('mri_convert -oc 0 0 0 ref.nii.gz RF_ref_cent.nii');
    p_cent=spm_vol_nifti('RF_ref_cent.nii');
end


%unix('fslmaths RF_ref_cent.nii -add RF_r_oarm_seeg_cleaned_cent.nii RF_seeg_plus_ref_cent.nii');
%delete RF_ref.nii
Offset_free=[(p_orig.mat(1:3,4) - p_cent.mat(1:3,4))' 1];


if mean(electrod_coordiantes_tmp(:,1))<0
    hemi='lh';
    disp('************************************')
    disp('        Left Hemisphere             ');
    disp('************************************')
elseif mean(electrod_coordiantes_tmp(:,1))>0
    hemi='rh';
    disp('************************************')
    disp('        Right Hemisphere             ');
    disp('************************************')
else
    disp('Something is wrong with your data');
    
end

% >>>>>>>>>>>>><<<<<<<<<<<<<<<<<<<<<<<<<<

% check if there is more ribbon.m registerded to matlab
try
    size(root_program,1);
catch message
    message='ERRO in program path';
    disp (['error in program path, you should remove the' ...
        'extra program that you have saved in matlab path']);
    return
end

if exist([ folder '/fs_LR_output/164k_fs_164k_fs_LR_to_initial_mesh.' upper(hemi(1)) '.deform_map'],'file')~=2
    message=caret_FS_LR_maker(prog_address,root_subj,subj_name,hemi);
end
fs_lr_mid_thichness=ls([caret_data '*.midthickness_mni.164k_fs_LR.coord.gii']);
caret_file_to_ascii(fs_lr_mid_thichness(1:end-1));
fs_lr_mid_thichness_tmpelate=ls([prog_address '/freesurfer_to_fs_LR/' ...
    'standard_mesh_atlases/*' upper(hemi(1)) '*.midthickness*.coord']);
flat_map_template= ls([prog_address '/freesurfer_to_fs_LR/' ...
    'standard_mesh_atlases/*' upper(hemi(1)) '*.cartesian-std*.coord']);
template_topology_f=ls([prog_address '/freesurfer_to_fs_LR/' ...
    'standard_mesh_atlases/*' upper(hemi(1)) '.close*.164k*.topo*']);
template_topology=template_topology_f(1:end-1);
template_sphere_f=ls([prog_address '/freesurfer_to_fs_LR/' ...
    'standard_mesh_atlases/*' upper(hemi(1)) '_LR.spher*.164k*.coord']);
template_sphere=template_sphere_f(1:end-1);
% finding broadman areas in native space
out_put_broadman=ls([caret_data 'InitialMesh/*'  ...
    '.' upper(hemi(1)) '.Brodman.initial.label.paint']);
out_put_broadman=out_put_broadman(1:end-1);
caret_file_to_ascii(out_put_broadman);

medial_wall_tmp=importdata(out_put_broadman,' ',58);
medialwall=find(medial_wall_tmp.data(:,2)==1);

%Loading boradman areas to comapre with them
%
[broad_data, map_braod]=load_broadman(hemi,prog_address);

shifted_version='RF_shifted_RF_r_oarm_seeg_cleaned.nii';
if exist([shifted_version '.gz'],'file')==2
    unix(['gzip -dfq ' shifted_version '.gz']);
end
% make a ribbons and hi resoultion electrod registration files

if exist('RF_seeg_in_ribbon_surface.w','file')~=2
    disp('Making ribbon file and registration dat');
    make_ribbon_v2(subj_name, hemi); % this part is very critical for the rest of analysis
end
unix('gzip -dfq RF*.gz');
delete *.filled*
%make_ribbon(subj_name, hemi);
% read original electrods
disp('reading the images after making rebon');
[coord_i_0, coord_spm_orig_0, transformation_matrix_0 ]=...
    image_reader_vox_spm('RF_r_oarm_seeg_cleaned.nii');
%  [coord_i_00 coord_ras_orig_00 transformation_matrix_00 ]=...
% image_reader_vox_freesurfer('RF_r_oarm_seeg_cleaned.nii');


[coord_i, coord_spm_orig, transformation_matrix ]=image_reader_vox_spm(shifted_version);
%plot3(coord_i_0(1,:),coord_i_0(2,:),coord_i_0(3,:),'r.');hold
%plot3(coord_i(1,:),coord_i(2,:),coord_i(3,:),'b.');
%%% checking if the shifted version has been created
if size(coord_spm_orig,2)==0
    message=['ERROR,  The ' shifted_version ' has a error'];
    disp(message);
    return;
end;

% to check you can run freeview and open seeg_in_ribbon with ribbon.nii
if exist('RF_masked_shifted_seeg.nii')==0
    disp(['your hemisphere is wrong===>', hemi]);
end
%[coord_i2 coord_spm_orig2 transformation_matrix2 image_size]...
% =image_reader_vox_spm('seeg_in_ribbon.nii');
[coord_i2, coord_spm_orig2, transformation_matrix2, ...
    image_size]=image_reader_vox_spm('RF_masked_shifted_seeg.nii');
%[coord_i2 coord_spm_orig2 transformation_matrix image_size]=...
%    image_reader_vox_spm('r_oarm_seeg_cleaned_low_density.nii');
close all;

%   plot3(coord_spm_orig_0(1,:),coord_spm_orig_0(2,:),coord_spm_orig_0(3,:),'b.');
%   plot3(coord_ras_orig_00(1,:),coord_ras_orig_00(2,:),coord_ras_orig_00(3,:),'r.');
%  % reading r_oarm to use the information file to create new electrod files
%  seeg_file=spm_vol('r_oarm_seeg_cleaned.nii');

OffsetCENTERED=[(p_orig.mat(1:3,4) - p_cent.mat(1:3,4))' 1];

Offset=[0 0 0 1];

rot =[1 0 0;0 1 0;0 0 1;0 0 0 ];
xfm_free=[rot Offset_free'];

% shifting the electord tip and tails
xfm=[rot Offset'];
electrod_coordiantes_non_center=(xfm*...
    ([electrod_coordiantes_tmp ones(size(electrod_coordiantes_tmp(:,3)))])');
voxspace_coords=transformation_matrix_0^-1*electrod_coordiantes_non_center;
electrod_coordiantes=(transformation_matrix*voxspace_coords)';
x1=electrod_coordiantes(:,1);
y1=electrod_coordiantes(:,2);
z1=electrod_coordiantes(:,3);

%%% plotting the original data
h2=figure;
h1=figure;

figure(h1);
hold on
% plot the eletrod and recording sites
plot3(coord_spm_orig(1,:),coord_spm_orig(2,:),coord_spm_orig(3,:),'g.');
plot3(coord_spm_orig2(1,:),coord_spm_orig2(2,:),coord_spm_orig2(3,:),'r.');
axis image
for i=1:size(x1)/2
    plot3(x1(2*i-1:2*i),y1(2*i-1:2*i),z1(2*i-1:2*i),'b-','LineWidth',5);
    if strcmp(hemi,'lh')==1
        text(x1(2*i)+2,y1(2*i)+1,z1(2*i)+1,elect_names(2*i),'HorizontalAlignment','left','FontSize',18)
    else
        text(x1(2*i)-2,y1(2*i)+1,z1(2*i)+1,elect_names(2*i),'HorizontalAlignment','left','FontSize',18)
    end
end
hold off

clf(h1);
hold on
% checking the OLD or NEW type (Centered or NOT)
DATATYPE=NewOld_type_check(x1,y1,z1,coord_spm_orig,0);
if strcmp(DATATYPE,'new')==1
    xfm=[rot OffsetCENTERED'];
    electrod_coordiantes_non_center=(xfm*...
        ([electrod_coordiantes_tmp ones(size(electrod_coordiantes_tmp(:,3)))])');
    voxspace_coords=transformation_matrix_0^-1*electrod_coordiantes_non_center;
    electrod_coordiantes=(transformation_matrix*voxspace_coords)';
    x1=electrod_coordiantes(:,1);
    y1=electrod_coordiantes(:,2);
    z1=electrod_coordiantes(:,3);
end
% checking again
[DATATYPE_notused,message,electrode_to_ignore]=NewOld_type_check(x1,y1,z1,coord_spm_orig,2);
if size(strfind(message,'ERROR'),2)>0
    return
end


%subplot(8,2,e);
if size(electrod_to_skip,2)==0
    if size(find(electrode_to_ignore==0),2)>0
        electrod_to_skip=find(electrode_to_ignore==0);
        for i=electrod_to_skip
            fprintf(fid_log_gen,[ 'Electrode ' elect_names(2*i)  ' was skipped from processing \n'])
        end
    end
end


% plot the eletrod and recording sites
plot3(coord_spm_orig(1,:),coord_spm_orig(2,:),coord_spm_orig(3,:),'g.');
plot3(coord_spm_orig2(1,:),coord_spm_orig2(2,:),coord_spm_orig2(3,:),'r.');
axis image
for i=1:size(x1)/2
    plot3(x1(2*i-1:2*i),y1(2*i-1:2*i),z1(2*i-1:2*i),'b-','LineWidth',5);
    if strcmp(hemi,'lh')==1
        text(x1(2*i)+2,y1(2*i)+1,z1(2*i)+1,elect_names(2*i),'HorizontalAlignment','left','FontSize',18)
    else
        text(x1(2*i)-2,y1(2*i)+1,z1(2*i)+1,elect_names(2*i),'HorizontalAlignment','left','FontSize',18)
    end
end
hold off
%plot3(elect_vox_space(1,:),elect_vox_space(2,:),elect_vox_space(3,:),'r*');
% type of electrods is 8, 10, 12, 15, 18 or 5 x 5 x 5
% distances between leeds 1.5 mm and each leas is 2 mm

disp('If the image are OK! ')

hgsave(h1,[root_subj subj_name '/electrods.fig']);
%%%  reply is always yes
reply='y';



electrod_to_process=1:size(x1,1)/2;
save reply_check reply
% reply_girl = input('Do you want showgirl? (default is no) y/n: ', 's');

% creating the line between two points for all leads by using end and head
for e=setdiff(electrod_to_process,electrod_to_skip);
    
    disp(['./electrods_image/_' elect_names(2*e) '_electrod_log.txt'])
    fid_log=fopen(['./electrods_image/_' elect_names(2*e) '_electrod_log.txt'],'w');
    
    %subplot(8,2,e);
    fprintf(fid_log,[ '##############################################################'  '\n']);
    fprintf(fid_log,[ '' '\n']);
    disp(['Electrod number ' elect_names(2*e) ' the ' num2str(e) 'th is processing...'])
    fprintf(fid_log,[ ['Electrod number ' elect_names(2*e) ' the ' num2str(e) 'th is processing...'] '\n']);
    fprintf(fid_log,[ '##############################################################'  '\n']);
    clear node_existance_rotated_zy extracted_electrod elect_line_coordinates_spm tip_tmp_spm
    clear node_existance_rotated_zy reverse_rotation reverse_shift_matrix extracted_electrod_tmp
    clear final_model electrod_voxes zero_elect point
    disp(['doing          ' electod_leeds.textdata{e} '  **********      '   elect_names(2*e)])
    leeds_number=electod_leeds.data(e,1);
    electrod_type=electod_leeds.data(e,2:3);
    
    
    x_inter=min(x1(2*e-1:2*e)):(max(x1(2*e-1:2*e))-min(x1(2*e-1:2*e)))/leads(e):max(x1(2*e-1:2*e));
    x_tmp=min(x1(2*e-1:2*e)):(max(x1(2*e-1:2*e))-min(x1(2*e-1:2*e)))/150:max(x1(2*e-1:2*e));
    for j=1:size(x_tmp,2)
        cc=find(abs(coord_spm_orig(1,:)-x_tmp(j))==min(abs(coord_spm_orig(1,:)-x_tmp(j))));
        if length(cc)==1
            x_line(j)=coord_i(1,cc);
        else
            x_line(j)=coord_i(1,cc(1));
        end
    end
    x_line_set=setdiff(x_line,[]); % x in voxel space
    nearest_x_tmp=coord_spm_orig(1,:);
    x1_out=x1(2*e-1:2*e);
    y1_out=y1(2*e-1:2*e);
    z1_out=z1(2*e-1:2*e);
    [elect_line_coordinates_spm, tip_tmp_spm,orderXYZ]=model_line_between_tip_tail(x1_out,y1_out,z1_out,0);
    % cheking the electrod lenght with data and eaxtracting line
    if sum(isnan(electrod_type))==2
        electrod_lenght=leeds_number*2+(leeds_number-1)*1.5;
    else
        number_of_leedsTot=leeds_number*electrod_type(1)*electrod_type(2);
        electrod_lenght= number_of_leedsTot*2+( number_of_leedsTot-3)*1.5+(max(electrod_type)-1)*11+1;
    end
    length_tip_tail=sqrt(sum((tip_tmp_spm(1,:)-tip_tmp_spm(2,:)).^2));
    
    n=1;
    disp(['               checking the real distance ' num2str(length_tip_tail)]);
    if length_tip_tail>=electrod_lenght
        n=6;
        % here send an error
        disp('####################################################');
        disp('It may effect on processing and you may face a error!')
        disp('check the xyz again.')
        disp('####################################################');
    end
    
    
    
    while n<5 && length_tip_tail<electrod_lenght
        if  length_tip_tail<electrod_lenght
            n=n+1;
        end
        %  disp(['               checking the real distance ' num2str(length_tip_tail)]);
        error_dist=electrod_lenght-length_tip_tail;
        [elect_line_coordinates_spm, tip_tmp_spm]=...
            model_line_between_tip_tail(tip_tmp_spm(:,1),tip_tmp_spm(:,2),tip_tmp_spm(:,3),error_dist);
        length_tip_tail=sqrt(sum((tip_tmp_spm(1,:)-tip_tmp_spm(2,:)).^2));
        
        if n>5
            disp('program is stock here!!! I ll break it!')
        end
    end
    
    
    % plot3(x_tmp,y_tmp,z_tmp,'g')
    disp('Reading the maked electrod .....');
    [node_existance_rotated_zy, reverse_rotation, ...
        reverse_shift_matrix,extracted_electrod_tmp,num_mat_extracted]=...
        electrod_masking_general(coord_spm_orig,elect_line_coordinates_spm);
    %node_existance_rotated_zy=coord_spm_orig(:,num_mat_extracted);
    %    hold
    
    %    plot3(elect_line_coordinates_spm(:,1),elect_line_coordinates_spm(:,2),elect_line_coordinates_spm(:,3),'r.');
    %    plot3(extracted_electrod_tmp(1,:),extracted_electrod_tmp(2,:),extracted_electrod_tmp(3,:),'b.');
    %subplot(14,1,e)
    
    %%% clearing the extracted electrode from the main coord spm
    coord_spm_orig=removing_extracted_from_maincoord(coord_spm_orig,num_mat_extracted);
    
    %%% updating the h1 figure
    
    % plot the eletrod and recording sites
    
    clf(h1);
    hold on;
    plot3(coord_spm_orig(1,:),coord_spm_orig(2,:),coord_spm_orig(3,:),'g.');
    plot3(coord_spm_orig2(1,:),coord_spm_orig2(2,:),coord_spm_orig2(3,:),'r.');
    axis image
    for i=1:size(x1)/2
        plot3(x1(2*i-1:2*i),y1(2*i-1:2*i),z1(2*i-1:2*i),'b-','LineWidth',5);
        if strcmp(hemi,'lh')==1
            text(x1(2*i)+2,y1(2*i)+1,z1(2*i)+1,elect_names(2*i),'HorizontalAlignment','left','FontSize',18)
        else
            text(x1(2*i)-2,y1(2*i)+1,z1(2*i)+1,elect_names(2*i),'HorizontalAlignment','left','FontSize',18)
        end
    end
    hold off
    
    clf(h2);
    figure(h2);hold on;
    plot3(node_existance_rotated_zy(1,:),node_existance_rotated_zy(2,:),node_existance_rotated_zy(3,:),'g.');
    % plot(node_existance_rotated_zy(1,:),ones(size(node_existance_rotated_zy(1,:))))
    check_orientation=sign(node_existance_rotated_zy(abs(node_existance_rotated_zy(:))...
        ==max(abs(node_existance_rotated_zy(:)))))==-1;
    axis image
    if check_orientation==1
        view(30,40)
    else
        view(-30,40)
    end
    
    title(elect_names(2*e));
    
    % mask with voxel type of extracted electrod
    disp('Reading the overlap leeds from maked image .....');
    %     extracted_electrod_vox=transformation_matrix^-1*extracted_electrod_tmp;
    %     ribbon_vox=transformation_matrix^-1*coord_spm_orig2;
    ribbon_extracted=matching_ribbon_electrod(extracted_electrod_tmp,coord_spm_orig2) ;
    node_existance_rotated_zy_ribbon_ple=apply_shift_rotation_matrices(ribbon_extracted,reverse_shift_matrix,reverse_rotation^-1);
    node_existance_rotated_zy_ribbon=clean_coordinates(node_existance_rotated_zy_ribbon_ple);
    
    %     [node_existance_rotated_zy_ribbon_tmp,reverse_rotation_tmp, ...
    %         reverse_shift_matrix_tmp]=electrod_masking_general(coord_spm_orig2,elect_line_coordinates_spm);
    %     node_existance_rotated_zy_ribbon=matching_ribbon_electrod(node_existance_rotated_zy,...
    %         node_existance_rotated_zy_ribbon_tmp);
    %   plot3(node_existance_rotated_zy(1,:),node_existance_rotated_zy(2,:),node_existance_rotated_zy(3,:),'g.');
    plot3(node_existance_rotated_zy_ribbon(1,:),...
        node_existance_rotated_zy_ribbon(2,:),node_existance_rotated_zy_ribbon(3,:),'r.');
    disp(['Modelling the electrod .....' elect_names(2*e)  ' with ' num2str(leeds_number) ' leeds' ]);
    % modelling the electrod to find the recording leeds
    if orderXYZ(3)==1 && ...
            sign(node_existance_rotated_zy(abs(node_existance_rotated_zy(:))...
            ==max(abs(node_existance_rotated_zy(:)))))==-1
        [electrod_voxes,data_answer]=...
            modelling_electrod(node_existance_rotated_zy,leeds_number,electrod_type,'lh');
    else
        [electrod_voxes,data_answer]=...
            modelling_electrod(node_existance_rotated_zy,leeds_number,electrod_type,hemi);
    end
    %     hold on
    if strcmp(data_answer,'no')
        border_a=border_creaor(node_existance_rotated_zy,electrod_voxes);
        plot3(border_a(1,:),border_a(2,:),border_a(3,:),'b.');
        %     plot(electrod_voxes,point);
        
        axis image
        pause(1)
        hgsave(h2,[root_subj subj_name '/electrods_image/' elect_names(2*e) '_electrods_extracted.fig']);
        
        hold off
        %%%%  getting the center of all leads
        %    [node_existance_rotated_zy, first_rot,second_rot,reverse_rotation,....
        %    reverse_shift_matrix,resize_reverse,extracted_electrod]= ...
        %electrod_masking_x_max(coord_i,tip_head_vox_space,...
        %elect_line_coordinates,norm_vector_vox,transformation_matrix);
        %    plot3(extracted_electrod(1,:),extracted_electrod(2,:),extracted_electrod(3,:),'g.');
        extracted_electrod=round((transformation_matrix^-1)*extracted_electrod_tmp);
        % creating a nifti file for each electrod in the electrods_image
        % folder by using transformation matrix from r_oami images.
        
        if exist('./electrods_image/RF_ref_2_orig.dat') ==0
            copyfile('RF_ref_2_orig.dat', './electrods_image/RF_ref_2_orig.dat');
            copyfile('RF_ref_header.txt','./electrods_image/RF_ref_header.txt');
            copyfile(shifted_version,['./electrods_image/' shifted_version]);
        end
        
        surc_folder=pwd;
        disp('creating shifted electrod');
        cd('electrods_image');
        delete geo*
        seeg_filename=write_electrod_file(elect_names(2*e),...
            'RF_ref_header.txt',shifted_version,extracted_electrod);
        % finishing writing electrod
        % creating a paint file out of a electrod
        
        % the important_ ref_2_orig must be created. creating with 0.1
        % fraction
        Q_out1=[ seeg_filename(1:end-4) '_01.w']; % creating paint name
        unix(['mri_vol2surf --src '  seeg_filename '  --srcreg RF_ref_2_orig.dat  --hemi ' hemi ...
            ' --out ./' Q_out1 ' --out_type paint --projfrac 0.1']);
        unix(['mris_convert ' Q_out1 ' ' Q_out1(1:end-2) '.asc']);
        % reating with 0.3 fraction
        Q_out2=[ seeg_filename(1:end-4) '_03.w']; % creating paint name
        unix(['mri_vol2surf --src '  seeg_filename '  --srcreg RF_ref_2_orig.dat  --hemi ' hemi ...
            ' --out ./' Q_out2 ' --out_type paint --projfrac 0.3']);
        unix(['mris_convert ' Q_out2 ' ' Q_out2(1:end-2) '.asc']);
        % creatng caret paint file out of electrod paint asci file
        elect_paint=create_caret_paint_from_fs_paint(subj_name,surc_folder,...
            [Q_out1(1:end-2) '.asc'],[Q_out2(1:end-2) '.asc'],elect_names(2*e),hemi);
        deformed_electrod=[elect_paint(1:end-5) 'FS_LR.paint'];
        % applying deformation map file to electrods to go to the template
        % spcae
        defor_map_tmp=ls([caret_data 'ini*' upper(hemi(1)) '.deform_map']);
        deform_file_to_apply=defor_map_tmp(1:end-1);
        % deforming the original paint file to template mesh paint file
        % unix(['caret_command -deformation-map-apply ' deform_file_to_apply ...
        %' PAINT ' elect_paint ' ' deformed_electrod]);
        % going back to the main folder
        cd('../');
        
        
        
        %        %[node_existance_rotated_zy_ribbon, first_rot_tmp,second_rot_tmp,...
        %     reverse_rotation_tmp,reverse_shift_matrix_tmp,resize_reverse_tmp]= ...
        %       electrod_masking_x_max(coord_i2,tip_head_vox_space,elect_line_coordinates, ...
        %            norm_vector_vox,transformation_matrix);
        %        %%% to check the model with real data from Dexi recorders
        %        hold off
        %         pause(0.5)
        %        % check for recording site if they are in the same surface or they
        % have shared surfaces
        % finding each electrod sites
        disp('Checking maked image and the model to find the contact points.....');
        if orderXYZ(3)==1 && ....
                sign(node_existance_rotated_zy(abs(node_existance_rotated_zy(:))...
                ==max(abs(node_existance_rotated_zy(:)))))==-1
            
            [elect{e} elect_mean{e} percentage_recording{e} record_bean_percent_init{e}]=...
                create_recording_sites(node_existance_rotated_zy_ribbon ...
                ,node_existance_rotated_zy,electrod_voxes,reverse_rotation,reverse_shift_matrix,'lh');
        else
            [elect{e} elect_mean{e} percentage_recording{e} record_bean_percent_init{e}]=...
                create_recording_sites(node_existance_rotated_zy_ribbon ...
                ,node_existance_rotated_zy,electrod_voxes,reverse_rotation,reverse_shift_matrix,hemi);
        end
        % error break
        if sum(percentage_recording{e}>1)==1
            disp('Something is wrong');
            break;
        end
        % plot3(elect{e}{1}(1,:),elect{e}{1}(2,:),elect{e}{1}(3,:));
        disp('Create a report of  contact points.....');
        subject_path=[root_subj subj_name];
        
        
        for ee=1:size(elect_mean{e},2)
            if  isnan(elect_mean{e}{ee})~=1
                elect_mean_coord(:,ee,e)=[elect_mean{e}{ee};1];
                temp_coord_elect=elect_mean_coord(:,ee,e)';
                % nearest coord to mean_elect
                [nearest_node{e}(ee) elect_mean_nearest_coord{e}(ee,:) ]=...
                    nearest_node_finder(temp_coord_elect(1:3),subject_path,hemi,xfm_free);
                % create a leads recording paint file according to nearest
                % node for all recording leads.
                tmp_elect_coord= [elect{e}{ee};ones(1,size(elect{e}{ee},2))];
                for tm_i=1:size(tmp_elect_coord,2)
                    node_recording_site{ee}(tm_i)=...
                        nearest_node_finder(tmp_elect_coord(1:3,tm_i)',subject_path,hemi,xfm_free);
                end
                node_recording_site{ee}=setdiff(node_recording_site{ee},[]);
                disp(['For electrod ' elect_names(2*e) ' lead number ' ...
                    num2str(ee) ' found ' num2str(size(node_recording_site{ee},2)) ' nodes']);
                fprintf(fid_log,[' \n For electrod ' elect_names(2*e) ' lead number ' ...
                    num2str(ee) ' found ' num2str(size(node_recording_site{ee},2)) ' nodes; ' ...
                    ' Recording percentage= ' num2str(percentage_recording{e}(ee)) '%  \n ']);
            else
                disp(['For electrod ' elect_names(2*e) ' lead number ' ...
                    num2str(ee) ' found ' num2str(0) ' nodes']);
                fprintf(fid_log, [' \n For electrod ' elect_names(2*e) ' lead number ' ...
                    num2str(ee) ' found ' num2str(0) ' nodes'] );
                nearest_node{e}(ee)=0;
                elect_mean_nearest_coord{e}(ee,:)=[0 0 0];
                node_recording_site{ee}=[];
            end
        end
        
        cd('electrods_image');
        disp('Create a caret paint files.....');
        node_recording_site_e{e}=node_recording_site;
        clear node_recording_site
        file_paint_electrodes_cluster =paint_creator_from_coords_cluster(subj_name, ...
            subject_path,elect_names(2*e),node_recording_site_e{e},hemi,'');
        
        
        % creating the caret FOCI file of the mean coordinates;
        %FOCIFile=caret_foci_creation(subj_name,elect_names(2*e),nearest_node{e},hemi);
        
        
        % checking the center of cluster and cluster to find if the electrod
        % needs to be checked. To do so we look at the center of gravity in
        % native space nod and we get the coordinate from sphere native.
        % then we calculate the distance between nodes and center of
        % recording. if the recording site is one cluster and recording site
        % is near or inside we report as good lead but if the center is out
        % side of cluster or cluster is diveded to two we report as
        % probelemstic cluster. if it is two or tree clusters we look at
        % biggest one and find the center of gravity from that. then we make
        % the center of gravity and other niebouring node as total node
        % cluster and apply the transformation map to them to go to the
        % tempelate format. here nearest_node, and node_recording_site are
        % cluster and center of each electrod. we get the cooriante in 3d
        % from sphere. the function detect_ambigiuous_cluster do the job.
        files_coord_tmp_sphere_tmp=ls([caret_data 'InitialMesh/*' upper(hemi(1)) '.sphere.ini*.coord*']);
        files_coord_tmp_sphere=files_coord_tmp_sphere_tmp(1:end-1);
        % gives the leadss which are ambigious
        disp('Detecting ambiguous contact points.....');
        [electrod_ambigious{e} distances_nodes{e}]=detect_ambigiuous_cluster(files_coord_tmp_sphere,...
            nearest_node{e},node_recording_site_e{e});
        
        % find the nodes which the distnces of center is less than 5 mm then
        % make an average over nodes to find the center cooriinates and then
        % find the related nodes to that coorinates. it will be used for
        % foci type paint file by using the "cleaned_nearest_node"
        distance_threshold=5;
        
        for i=1:size(node_recording_site_e{e},2)
            if size(node_recording_site_e{e}{i},1)>0
                if size(distances_nodes{e}{i},1)<=2*size(node_recording_site_e{e}{i}...
                        (distances_nodes{e}{i}<distance_threshold),2) && size(node_recording_site_e{e}{i},2)>1
                    node_number=node_recording_site_e{e}{i}(distances_nodes{e}{i}<5);
                elseif size(distances_nodes{e}{i},1)<=2*size(node_recording_site_e{e}{i}(distances_nodes{e}{i}<distance_threshold),2) ...
                        && size(node_recording_site_e{e}{i},2)==1
                    node_number=node_recording_site_e{e}{i};
                else
                    node_number=node_recording_site_e{e}{i};
                end
                [ tmp1,tmp2,tmp3 ]=finding_node_center_of_node_group(node_number,subject_path,hemi,xfm_free);
                nearest_node_cleaned{e}(i)=tmp1;
                nearest_coord_cleaned{e}(i,:)=tmp2;
                nearest_coord_cleaned_std{e}(i,:)=tmp3;
            else
                nearest_node_cleaned{e}(i)=0;
                nearest_coord_cleaned{e}(i,:)=[0 0 0] ;
                nearest_coord_cleaned_std{e}(i,:)=[0 0 0];
            end
        end
        
        % checking for same node
        overlap_node=[];n_over=0;overlap_groups=[];
        for i=1:size(nearest_node_cleaned{e},2)
            equal_nod=sum((nearest_node_cleaned{e}==nearest_node_cleaned{e}(i)),2);
            if equal_nod>1 && nearest_node_cleaned{e}(i)~=0
                disp('There is overlap between two leeds');
                
                n_over=n_over+1;
                overlap_groups{n_over}= find(nearest_node_cleaned{e}==nearest_node_cleaned{e}(i)>0);
                fprintf(fid_log, [' \n For electrod ' elect_names(2*e) ' lead number ' ...
                    num2str(i) ' found overlap ' num2str(overlap_groups{n_over}) ' nodes'] );
            end
        end
        
        % if there are overlaps then we replace the node number with
        % the original node mean of that leads and check if there is no
        % overlap anymore. Could have mistakes or bug!
        if size(overlap_groups,2)>0
            orig_leed_nodes=nearest_node_cleaned{e};
            nearest_node_cleaned{e}=...
                cleaning_leed_cluster( nearest_node_cleaned{e},overlap_groups,nearest_node{e},node_recording_site_e{e});
            lead_has_changed= find(nearest_node_cleaned{e}~=orig_leed_nodes);
            fprintf(fid_log, [' \n For electrod ' elect_names(2*e) ' lead number ' ...
                num2str(lead_has_changed) ' has changed '] );
            disp( [' \n For electrod ' elect_names(2*e) ' lead number ' ...
                num2str(lead_has_changed) ' has changed '] );
            disp(nearest_node_cleaned{e})
        end
        clear cluster_population_node overlap_groups
        %file_foci=foci_creator(elect_names(2*e), elect_mean_nearest_coord{e},hemi,'mri_space');
        [file_paint_electrodes coord_pial]=paint_creator_from_foci_coord(subj_name,...
            subject_path,elect_names(2*e),nearest_node_cleaned{e},hemi);
        
        cd('../');
        
        
        % detecting coordinates according to the midtickness from caret data
        % and from registered midthiickness to MNI space
        files_coord_mid_thickness_tmp=ls([caret_data 'InitialMesh/*'...
            upper(hemi(1)) '.mid*orig.ini*.coord*']);
        files_coord_mid_thickness= files_coord_mid_thickness_tmp(1:end-1);
        files_coord_mid_thickness_mni_tmp=ls([caret_data 'InitialMesh/*'...
            upper(hemi(1)) '.mid*mni.ini*.coord*']);
        files_coord_mid_thickness_mni= files_coord_mid_thickness_mni_tmp(1:end-1);
        caret_file_to_ascii(files_coord_mid_thickness);
        caret_file_to_ascii(files_coord_mid_thickness_mni);
        [orig_cood{e} mni_cood{e}]=coordinate_orig_mni_creator(files_coord_mid_thickness,...
            files_coord_mid_thickness_mni,nearest_node{e});
        % creating the cluster around the center of recording and coordnates
        % from recording site in orig and MNI, the nearest around the center
        % node is coming from topology file
        files_topo_initial_tmp=ls([caret_data 'InitialMesh/*' upper(hemi(1)) '.initial_mesh*.topo*']);
        files_topo_initial=files_topo_initial_tmp(1:end-1);
        caret_file_to_ascii(files_topo_initial);
        cd('electrods_image');
        % create a matrix of niuboring nodes distance
        % the first step is creating all metic files to check the distances
        if exist([root_subj subj_name '/electrods_image/max_distance_'  elect_names(2*e) '.mat'],'file')~=2
            tic
            for i=1:size(node_recording_site_e{e},2)
                clear dist_nodes
                disp(['******  Checking the lead number  = ' num2str(i) ' of ' ...
                    num2str(size(node_recording_site_e{e},2)) ' *****']);
                disp(['******  Node numbers for checking = ' num2str(size(node_recording_site_e{e}{i},2)) ' *****']);
                node_to_check=setdiff(node_recording_site_e{e}{i},[]);
                if size(node_to_check,2)>=2
                    for j=1:size(node_to_check,2)
                        
                        if i<10
                            numi=['0' num2str(i)];
                        else
                            numi=num2str(i);
                        end
                        if j<10
                            numj=['0' num2str(j)];
                        else
                            numj=num2str(j);
                        end
                        unix(['caret_command -surface-geodesic ' files_coord_mid_thickness ...
                            ' '  files_topo_initial ' ' 'geo_dist_' numi '_' numj '.metric true -node '...
                            num2str(node_to_check(j))]);
                        caret_file_to_ascii(['geo_dist_' numi '_' numj '.metric'])
                        tmp_metric=importdata(['geo_dist_' numi '_' numj '.metric'],' ' ,16);
                        dist_nodes(j,:)=tmp_metric.data(node_to_check,2);
                    end
                    % here we check the nodes inside each lead to find the amx
                    % distance between nodes inside the lead
                    dist_nodes(dist_nodes>35)=NaN;
                    max_dist{e}(i)=max(dist_nodes(:));
                end
                delete geo*.metric
                clear dist_nodes
            end
            to_save_dist=max_dist{e};
            save([root_subj subj_name '/electrods_image/max_distance_'  elect_names(2*e)],'to_save_dist');
        else
            disp('******** Jump to the save data *******');
            tmp_save=load([root_subj subj_name '/electrods_image/max_distance_'  elect_names(2*e) '.mat']);
            max_dist{e}=tmp_save.to_save_dist;
        end
        %        disp(['time to check = ' num2str(toc) ' seconds']);
        % checking if there is mediall wall node exist
        node_to_check=setdiff(node_recording_site_e{e}{i},medialwall);
        
        %//////////////////////////////////
        % Paint delination by caret command
        disp('Create delinating contact point in native space.....');
        unix(['caret_command -paint-dilation ' files_coord_tmp_sphere ' ' files_topo_initial ' ' ...
            file_paint_electrodes ' '  [file_paint_electrodes(1:end-6) ...
            '_delinated.paint'] ' '  num2str(1)]);
        caret_file_to_ascii([file_paint_electrodes(1:end-6) '_delinated.paint'])
        
        
        % creating the Data on FS_LR
        disp('Create FSLR contact point....');
        FSlr_paint_file=[file_paint_electrodes(1:4) '_fsLR_TMP.paint'];
        unix(['caret_command -deformation-map-apply ' deform_file_to_apply ' PAINT ' ...
            [file_paint_electrodes(1:end-6) '_delinated.paint'] ' ' FSlr_paint_file]);
        caret_file_to_ascii(FSlr_paint_file);
        % creating two columns paint file with 7 nodes  using FSLR midthikness of
        % the subjects
        
        template_fslr=fs_lr_mid_thichness_tmpelate(1:end-1);
        template_coord_fslr=importdata(template_fslr,' ', 13);
        
        subject_fslr_midthick=fs_lr_mid_thichness(1:end-1);
        subject_coord_fslr=importdata(subject_fslr_midthick,' ', 12);
        % genertaing final FS_LR data
        % FSlr_paint_file_delinated=[file_paint_electrodes(1:4) '_fsLRDelinated.paint'];
        FSlr_paint_file_delinated=[file_paint_electrodes(1:4) '_fsLR_MULTI.paint'];
        FSLR_foci_OUTF=cleaning_fslr_paint(subj_name,elect_names(2*e),hemi,...
            FSlr_paint_file,subject_coord_fslr.data);
        
        disp('Create delinating contact point in FSLR space.....');
        unix(['caret_command -paint-dilation ' template_sphere ' ' template_topology ' ' ...
            FSLR_foci_OUTF ' '  FSlr_paint_file_delinated ' '  num2str(1)]);
        caret_file_to_ascii(FSlr_paint_file_delinated);
        
        % cleaning up the delinated file
        file_out =compressing_caret_paint({FSlr_paint_file_delinated});
        % making the electrod center of FS_LR
        % The FS_LR coorinaes comes from the FS_lR folder for each subjects
        % therefore the coorinates is related to subjects not final
        % template. To add that we have to look a final template coordinate
        % map too.
        
        flatmap_fslr=flat_map_template(1:end-1);
        faltmap_template_coord_fslr=importdata(flatmap_fslr,' ', 13);
        nan_leed=0;nan_leed_num=[];
        for i=1:size(nearest_node_cleaned{e},2);
            if nearest_node_cleaned{e}(i)==0
                nan_leed=nan_leed+1;
                nan_leed_num(nan_leed)=i;
            end
        end
        
        data_fs_lr_1=read_caret_paint( file_out);
        
        for i=1:size(node_recording_site_e{e},2)
            if ismember(i,nan_leed_num)
            else
                node_fslr=find(sum(data_fs_lr_1==i,2));
                recording_site_coord_template_fslr{e}(i,:)=...
                    mean(template_coord_fslr.data(node_fslr,2:4));
                recording_site_coord_subject_fslr{e}(i,:)=...
                    mean(subject_coord_fslr.data(node_fslr,2:4));
                recording_site_coord_flat_fslr{e}(i,:)=...
                    mean(faltmap_template_coord_fslr.data(node_fslr,2:4));
                % comparing it with broadman data to detect those areas
                group_brod=setdiff(broad_data(node_fslr,2),[]);
                if size(group_brod,2)>1
                    for j=1:size(group_brod,2)
                        broad_sum(j)=sum(broad_data(node_fslr,2)==group_brod(j));
                    end
                    num_brod_2_choos=find(max(broad_sum)==broad_sum);
                    num_brod_chosen=num_brod_2_choos(1);
                else
                    num_brod_chosen=1;
                end
                if size(group_brod,2)>1
                    if group_brod(num_brod_chosen)~=0 && group_brod(num_brod_chosen)~=1
                        recording_site_broadman_area{e}(i)=map_braod(map_braod(:,1)== group_brod(num_brod_chosen),2);
                    elseif group_brod(num_brod_chosen)==0
                        recording_site_broadman_area{e}(i)=0;
                    elseif group_brod(num_brod_chosen)==1
                        recording_site_broadman_area{e}(i)=-1;
                    end
                end
                clear node_fslr
            end
        end
        cd('../');
        % craete paint file from cluster around the center
    end
    Report.subject_name=subj_name;
    Report.electode_name=elect_names(2*e);
    Report.geodesic_distance_inside_leed=max_dist{e};
    Report.spherical_distance_inside_leed=electrod_ambigious{e};
    Report.percentage_of_recording_leed=round(percentage_recording{e}*100);
    Report.percentage_of_recording_leed_initial_data=record_bean_percent_init{e};
    Report.central_coordinate_recording_leed_native=nearest_coord_cleaned{e};
    Report.central_coordinate_recording_leed_native_std=nearest_coord_cleaned_std{e};
    Report.central_coordinate_recording_leed_subject_fslr=recording_site_coord_subject_fslr{e};
    Report.central_coordinate_recording_leed_template_fslr=recording_site_coord_template_fslr{e};
    Report.central_coordinate_recording_leed_template_falt_fslr=recording_site_coord_flat_fslr{e};
    save([root_subj subj_name '/electrod_report/' subj_name '_' elect_names(2*e) '_report'],'Report');
    % >>>>>>> save the elect_mean and its component to excel file
    
    % >>>>>>>>  **** try to create a scanity scene template file
    % >>>>>>  using sanity scene file to create image file out of them
    
    % >>>>>>>> using convert imagemagik  comand to create the psd files out of all images
    % >>>>>>>> that has bee created from sanity scene file
    
    %
    
    
    %plot(electrod_voxes,zero_elect)
    %dist_tip_head=round((max(tip_head3(1,:))+1.5)/3.5);  % it added by 1.5 because 1
    %distance less and divided by 3.5 for each lead.
    clear Report
    fclose(fid_log);
    fprintf(fid_log_gen,[ 'Electrode ' elect_names(2*e)  ' was finished successfully \n']);
end

% going to main subject folder
fclose(fid_log_gen);
cd(folder);
close all;