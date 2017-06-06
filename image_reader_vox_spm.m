function [coord coord_spm_orig transformation_matrix images_size]=image_reader_vox_spm(P1)
    
    % original seeg file
%P1='r_oarm_seeg_cleaned.nii'; 
A=spm_vol_nifti(P1);
i1=spm_read_vols(A);
n=1;
coord(:,n)=[0 0 0 1];
[l1, j1, k1]= ind2sub(size(i1),find(i1(:)>0));
coord=[l1 j1 k1 ones(size(l1))]';

if size(coord,2)==1
    error('Something wrong in your registration part, check the make_riibon function');
    
else
coord_spm_orig=A.mat*coord;%;
transformation_matrix=A.mat;
images_size=size(i1);
end
% figure
% plot3(coord_spm_orig(1,:),coord_spm_orig(2,:),coord_spm_orig(3,:),'.');

