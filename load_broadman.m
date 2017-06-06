function [data,brodman_map]=load_broadman(hemi,root)
broadman_left=[root ...
    '/freesurfer_to_fs_LR/standard_mesh_atlases/fsaverage.L.Brodman.164k_fs_LR.label.paint'];
broadman_right=[root ...
    '/freesurfer_to_fs_LR/standard_mesh_atlases/fsaverage.R.Brodman.164k_fs_LR.label.paint'];
if strcmp(hemi,'lh')==1
    tmp=importdata(broadman_left,' ',112);
    tmp2=importdata(broadman_left,' ',111);
    p=1;
    for i=71:size(tmp.textdata,1)-1
        num_tmp(p,:)=[str2double(tmp.textdata{i,1}(1:2)) ...
            str2double(tmp.textdata{i,1}(3:strfind(tmp.textdata{i,1},'_')-1))];
        p=p+1;
    end
    data=tmp2.data;
    brodman_map=num_tmp;
elseif strcmp(hemi,'rh')==1
    tmp=importdata(broadman_right,' ',113);
    tmp2=importdata(broadman_right,' ',112);
    p=1;
    for i=71:size(tmp.textdata,1)-1
        num_tmp(p,:)=[str2double(tmp.textdata{i,1}(1:2)) ...
            str2double(tmp.textdata{i,1}(3:strfind(tmp.textdata{i,1},'_')-1))];
        p=p+1;
    end
    data=tmp2.data;
     brodman_map=num_tmp;
end