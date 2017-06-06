% create paint file out of electrods to find x y z of recording sites.
function make_ribbon_v2(subject, hemisphere_need)  % hemispheler is 'right' or 'left'
unix('echo $SUBJECTS_DIR');
hemisphere=['lh';'rh'];
subj=subject;%'Pintaldi_scene';
if strcmp(hemisphere_need,'lh');
    h=1;
else
    h=2;
end
hemi=hemisphere(h,:);
% the first thing is we create image of r_oarm_seeg_cleaned.nii with
% the header of ref_plus_seeg.nii. Then we register ref_plus_seeg.nii
% to orig.mgz from mri directory.
% before we can use gnuzip to uzip all gz file. but we can zip them
% afterward of uzing the unzip one.
scr_name_tmp='r_oarm_seeg_cleaned.nii.gz';
target_name_tmp='ref_plus_seeg.nii.gz';
ref_centered='RF_ref_cent.nii';

copyfile(scr_name_tmp, ['RF_' scr_name_tmp]);
copyfile( target_name_tmp, ['RF_' target_name_tmp]);

disp('Unziping the data....');

unix(['gzip -d RF_' scr_name_tmp]);
unix(['gzip -d RF_' target_name_tmp]);

target_name=['RF_' target_name_tmp(1:end-3)];
scr_name=['RF_' scr_name_tmp(1:end-3)];
% gunzip('*.gz'); % for unzipping the gz files
if exist([target_name '.gz'])>0
    delete([target_name '.gz']);
end
%delete([target_name '.gz']);
% masking the ref_plus_seeg

%     unix('echo $SUBJECTS_DIR');
%     unix(['cd $SUBJECTS_DIR/' subj]);

% reading the scr file
disp('Shifting the data....');
disp('reading the reference image');
shifted_version=['RF_shifted_' scr_name];
if exist('RF_ref_header.txt','file')>0
    delete RF_ref_header.txt
    delete([target_name '.gz']);
end
unix(['fslhd -x ' target_name '  >> RF_ref_header.txt']);
%unix(['cat RF_ref_header.txt | sed -e "s/' target_name '/' shifted_version '/g" >> RF_ref_header.txt']);
i1=spm_read_vols(spm_vol(scr_name));
% reading the ref file
disp('reading the electrod image');
i2=spm_read_vols(spm_vol(target_name));

unix(['fslcreatehd RF_ref_header.txt ' shifted_version]);
unix(['gzip -d ' shifted_version]);
a3=spm_vol(shifted_version);
% cehck if the ref and seeg are really in the same vox space
% [N,X]=hist(i2(:),0:50:7000);
% targ_size=size(find(i1(:)>0),1);
% threshold_data=targ_size/9;
% dataThresh=min(X(N<threshold_data));
% f=(i2(:)>dataThresh).*(i1(:)>0);
% size_overlap=size(find(f>0),1);




% we keep the mat0 in prive to show how much chnaged we applied
disp('applying the hdear of reference to electrods');
spm_write_vol(a3,i1);
if exist('RF_ref_2_orig.dat','file')==0
    % registering the r_oarm_seeg to ref_plus_seeg
    % automatix registration  >>>>>   bbregister --s colin27 --mov Anatomy_V20alpha.nii --init-fsl --t1 --reg file_to_orig.dat
    disp('creating the reg file from reference to orig.mgz');
    unix(['bbregister --s ' subj ' --mov  ' target_name ' --t1 --reg RF_ref_2_orig.dat --regheader --surf orig'])
end
if exist('RF_ref_2_orig.dat','file')==0
    disp('register the images manually')
    unix(['tkregister2 --s ' subj ' --mov ' scr_name ' --targ ' target_name ' --reg RF_ref_2_orig.dat --regheader'])
end


% example
%     mri_vol2surf --src ' hOC1.nii --src_type t1 --srcreg register.dat  --hemi lh ...
%     --projfrac 0.5 --out ./hOC1-lh.w --out_type paint
%     mris_convert hOC1-lh.w hOC1-lh.asc
% cecking if the program runs in the correct folder

% making mask for high resoloutions
%unix('mri_vol2vol --reg ref_2_orig.dat --mov ref_plus_seeg.nii --fstarg --o orig_in_targ.nii --inv');
% tkregister2 --mov orig_in_targ.nii --targ ref_plus_seeg.nii --reg orig_in_targ.nii.reg
disp('Masking the shifted electrods');
%unix('mri_convert -cm shifted_r_oarm_seeg_cleaned.nii shifted_seeg_hires.nii');
%unix('mri_convert -cm  ref_plus_seeg.nii ref_plus_seeg_hires.nii');

disp('making a filled brain to make a ribbon');
unix([' mris_fill -r 0.4 ./surf/' hemi '.white RF_' hemi '.white.filled.nii']);
unix([' mris_fill -r 0.4 ./surf/' hemi '.pial RF_' hemi '.pial.filled.nii']);
unix(['tkregister2 --s ' subj ' --mov RF_' hemi '.white.filled.nii' ...
    ' --targ ' target_name ' --reg RF_filled_2_ref.dat --regheader --surf white --noedit'])
disp('changing the resolution of the filled brain');
unix(['mri_vol2vol --reg RF_filled_2_ref.dat  --mov RF_' hemi '.white.filled.nii --targ ' target_name ' --o RF_'  hemi '.white.filled.hires.nii']);
unix(['mri_vol2vol --reg RF_filled_2_ref.dat  --mov RF_' hemi '.pial.filled.nii --targ ' target_name  ' --o RF_'  hemi '.pial.filled.hires.nii']);
disp('creating RF_ribbon.nii');
unix(['fslmaths RF_' hemi '.pial.filled.hires.nii -add RF_'  hemi '.white.filled.hires.nii RF_ribbon_filled.nii']);
unix('fslmaths RF_ribbon_filled.nii.gz -thr 0.4 -uthr 1 RF_ribbon.nii');
if exist('RF_ribbon_filled.nii')==1
    delete RF_ribbon_filled.nii
end
unix('gzip -d RF_ribbon.nii.gz');
% unix(['mri_mask RF_' hemi '.pial.filled.hires.nii RF_'  hemi '.white.filled.hires.nii RF_ribbon.nii']);

% masking pial with white for finding the ribbon
disp('creating electrods inside the RF_ribbon.nii');
%     unix('fslmaths RF_shifted_RF_r_oarm_seeg_cleaned.nii -thr 100 RF_masked_shifted_seeg_binary.nii');
%     unix('fslmaths RF_masked_shifted_seeg_binary.nii.gz -add RF_ribbon.nii RF_masked_shifted_seeg_tmp.nii');
%     unix('fslmaths RF_masked_shifted_seeg_tmp.nii.gz -thr 1.2  RF_masked_shifted_seeg.nii');
%     delete RF_masked_shifted_seeg_tmp.nii.gz
%     unix('gzip -d RF_masked_shifted_seeg.nii.gz');
unix(['mri_mask RF_shifted_RF_r_oarm_seeg_cleaned.nii  RF_ribbon.nii RF_masked_shifted_seeg.nii']);
% create a paint file out of ribbon file.
Q_out = 'RF_seeg_in_ribbon_surface.w';
% creating ref to orig % important to be created
%  unix(['tkregister2 --s ' subj ' --mov   ref_plus_seeg.nii.gz --targ ./mri/orig.mgz  --reg ref_2_orig.dat --regheader --surf orig'])
% automatic registration
disp('creating surface paint from electrods');
unix(['mri_vol2surf --src ' shifted_version ' --src_type t1 --srcreg RF_ref_2_orig.dat  --hemi ' hemi ...
    ' --projfrac 0.5 --out ./' Q_out ' --out_type paint --surf pial']);
unix(['mris_convert ' Q_out ' ' Q_out(1:end-2) '.asc']);
%
