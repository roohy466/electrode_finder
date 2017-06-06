% rubust rotation and robust translation and reslice the image according
% the data wich you get
root='/media/sf_freesurfer/Pintaldi_scene/';
P3=[root 'ref_plus_seeg.nii'];

% [m,s]=spm_affreg(P1,P2,{'reg','rigid'});
a1=spm_vol(P1);
i1=spm_read_vols(A);

a2=spm_vol(P3);
i2=spm_read_vols(a2);

for i=1:220
    %mask_elect=i2(:,:,i).*(i2(:,:,i)>5);
imagesc((i2(:,:,i)>2400));
colormap(gray)
axis image
pause
end

% gunzip('*.gz'); % for unzipping the gz files
% masking the ref_plus_seeg
p_tmp= 'ref_plus_seeg.nii';
Q1=[p_tmp1(1:end-4) '_removed_brain.nii'];
f='i1>2800';
flags={[],[],[],4};
spm_imcalc_ui(p_tmp1,Q1,f,flags);

p_tmp2=[ 'r_oarm_seeg_cleaned.nii'];
Q2=[p_tmp2(1:end-4) '_low_density.nii'];
f='i1>1400';
flags={[],[],[],4};
spm_imcalc_ui(p_tmp2,Q2,f,flags);

% find affine registration by using density detection
[coord_i coord_spm_orig ]=image_reader_vox_spm(Q1);
 round(mean(coord_i'))
  mean(coord_spm_orig')
[coord_i2 coord_spm_orig2 ]=image_reader_vox_spm(p_tmp2);
 round(mean(coord_i2'));

 mean(coord_spm_orig2')
plot3(coord_i(1,:),coord_i(2,:),coord_i(3,:),'r.'); hold
plot3(coord_i2(1,:),coord_i2(2,:),coord_i2(3,:),'b.'); 













