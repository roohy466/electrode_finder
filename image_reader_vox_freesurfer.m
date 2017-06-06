function [coord coord_ras_orig transformation_matrix images_size]=image_reader_vox_freesurfer(P1)
    
    % original seeg file
%P1='r_oarm_seeg_cleaned.nii'; 
A=load_nifti(P1);
i1=A.vol;
n=1;
coord(:,n)=[0 0 0 1];
for i=1:size(i1,1)
    for j=1:size(i1,2)
        for k=1:size(i1,3)
            if i1(i,j,k)>0
                coord(:,n)=[ i j k 1];
                n=n+1;
            end
        end
    end
end

% [i j k]=size(i1)
% vox_numb=find(i1(:)>0);
% z=fix(vox_numb/(i*j));
% y=fix((vox_numb-z*(i*j))/j);
% x=vox_numb-z*(i*j)-y*j;
% coord_i2=[x'; y'; z'];
if size(coord,2)==1
    error('Something wrong in your registration part, check the make_riibon function');
    
else
coord_ras_orig=A.vox2ras*coord;%;
transformation_matrix=A.vox2ras;
images_size=size(i1);
end
% figure
% plot3(coord_spm_orig(1,:),coord_spm_orig(2,:),coord_spm_orig(3,:),'.');

