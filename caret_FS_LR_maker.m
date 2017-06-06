function message=caret_FS_LR_maker( root_program,root_subj,subj_name,hemi)
caret_data=[root_subj subj_name '/fs_LR_output/'];
%unix(['rm -r ' caret_data]);
unix(['sh ' root_program '/freesurfer_to_fs_LR/freesurfer_to_fs_LR.sh ' ...
    root_subj subj_name ' ' root_program ' ' hemi] );
movefile([root_subj subj_name '/fs_LR_output/' subj_name '/*'],[root_subj subj_name '/fs_LR_output/']);
% movefile([root_subj subj_name '/fs_LR_output/InitialMesh/*'],[root_subj subj_name '/fs_LR_output/']);
rmdir([root_subj subj_name '/fs_LR_output/' subj_name ])
% modifying the path inside deformation map files
files_deforms=dir([caret_data '*.deform_map']);
for i=1:size(files_deforms,1);
    unix(['caret_command -file-convert -format-convert ASCII ' caret_data files_deforms(i).name]);
end
files_coord=dir([caret_data '/InitialMesh/*.sphere.initial*']);
for i=1:size(files_coord,1);
    unix(['caret_command -file-convert -format-convert ASCII ' ...
        caret_data '/InitialMesh/' files_coord(i).name]);
end
for i=1:size(files_deforms,1);
    deform_file_to_apply=[caret_data files_deforms(i).name];
    [txt1 txt2]=grep('source-directory',deform_file_to_apply);
    text2change=txt2.match{1}(strcmp('source-directory',txt2.match{1})+18:end);
    text2replace=caret_data(1:end-1);
    unix(['sed "s:' text2change ':' text2replace ':g" '...
        deform_file_to_apply  ' > ' caret_data 'modified_' files_deforms(i).name ]);
    delete( deform_file_to_apply)
end
files_deforms2=dir([caret_data '*.deform_map']);
for i=1:size(files_deforms,1);
    deform_file_to_apply=[caret_data files_deforms2(i).name];
    [txt1 txt2]=grep('target-directory',deform_file_to_apply);
    text2change=txt2.match{1}(strcmp('target-directory',txt2.match{1})+18:end);
    text2replace=caret_data(1:end-1);
    unix(['sed "s:' text2change ':' text2replace ':g" '...
        deform_file_to_apply  ' > ' caret_data files_deforms(i).name ]);
    delete( deform_file_to_apply)
end
% changing two coord files to ascii format

% end of deform_file modification
delete RF*
% creating the Paint file for broadman on original space
trans_back_to_native_tmp=ls([caret_data '164*']);
trans_back_to_native=trans_back_to_native_tmp(1:end-1);
brodman_paint=ls([root_program '/freesurfer_to_fs_LR/'...
    'standard_mesh_atlases/*' upper(hemi(1)) '*Brod*']);
out_put_broadman=[caret_data 'InitialMesh/' subj_name ...
    '.' upper(hemi(1)) '.Brodman.initial.label.paint'];
unix(['caret_command -deformation-map-apply ' trans_back_to_native ' PAINT ' ...
    brodman_paint(1:end-1) ' '  out_put_broadman]);

message='FSLR are fine';