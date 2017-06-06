% create paint file out of electrods to find x y z of recording sites.
function make_ribbon(subject, hemisphere_need)  % hemispheler is 'right' or 'left'
    unix('echo $SUBJECTS_DIR');
    hemisphere=['lh';'rh'];
    subj=subject;%'Pintaldi_scene';
    if strcmp(hemisphere_need,'left');
        h=1;
    else
        h=2;
    end
    hemi=hemisphere(h,:);
    scr_name='r_oarm_seeg_cleaned.nii';
    target_name='ref_plus_seeg.nii.gz';  
    scr_orig_seeg='v_oarm_seeg.nii.gz';
    out_name=[hemi '.' scr_name(1:end-7)  '.w'];
    % example
    %     mri_vol2surf --src ' hOC1.nii --src_type t1 --srcreg register.dat  --hemi lh ...
    %     --projfrac 0.5 --out ./hOC1-lh.w --out_type paint
    %     mris_convert hOC1-lh.w hOC1-lh.asc
    % cecking if the program runs in the correct folder
    unix('echo $SUBJECTS_DIR');
    unix(['cd $SUBJECTS_DIR/' subj]);
    % registering the r_oarm_seeg to ref_plus_seeg
    % automatix registration  >>>>>   bbregister --s colin27 --mov Anatomy_V20alpha.nii --init-fsl --t1 --reg file_to_orig.dat
    %%% mri_robust_registration
    unix(['bbregister --s ' subj ' --mov ' scr_orig_seeg  ' --init-fsl --t1 --reg register_to_orig.dat '])
    unix(['tkregister2 --s ' subj ' --mov ' scr_name ' --targ ' target_name ' --reg register.dat --regheader'])
    % Change the resolution from ref_plus_seeg low to high resolution 
    unix(['mri_vol2vol --reg register.dat  --mov ' target_name ' --targ ' scr_name ' --o ref_plus_seeg_hires.nii']);
    
    % making mask for high resoloutions
    unix([' mris_fill -r 0.4571 ' hemi '.white ' hemi '.white.filled.nii']); 
    unix([' mris_fill -r 0.4571 ' hemi '.pial ' hemi '.pial.filled.nii']); 
    
    % create the registration file for new high resolution filled 
    unix(['tkregister2 --s ' subj ' --mov ' hemi '.white.filled.nii' ' --targ ref_plus_seeg_hires.nii  --reg register2.dat --regheader --surf white'])
    unix(['mri_vol2vol --reg register2.dat  --mov ' hemi '.white.filled.nii --targ ref_plus_seeg_hires.nii --o '  hemi '.white.filled.hires.nii']);
    unix(['mri_vol2vol --reg register2.dat  --mov ' hemi '.pial.filled.nii --targ ref_plus_seeg_hires.nii --o '  hemi '.pial.filled.hires.nii']);
    %unix(['mri_convert -i ' hemi '.white.filled.hires.nii -odt int -o ' hemi '.white.filled.hires.int16.nii'])
    % masking pial with white for finding the ribbon
    p=dir('*filled.hires*.nii');
    P = char(p(1).name,p(2).name);
    f='i1.*(i2==0)';
    Q = 'ribbon.nii';
    flags = {[],[],[],4};
    Q = spm_imcalc_ui(P,Q,f,flags);
    %%%%%%
    % Masking r_oarm_seeg_cleaned.nii with ribbon
    unix(['gzip -d ' scr_name]); 
    p=dir('*filled.hires*.nii');
    P = char(scr_name(1:end-3),p(1).name,p(2).name);
    f='i1.*(i2>0).*(i3==0)';
    Q = 'seeg_in_ribbon.nii';
    flags = {[],[],[],4};
    Q = spm_imcalc_ui(P,Q,f,flags);  
    % create a paint file out of ribbon file.
    Q_out = 'seeg_in_ribbon_surface.w';
    % creating ref to orig % important to be created
  %  unix(['tkregister2 --s ' subj ' --mov   ref_plus_seeg.nii.gz --targ ./mri/orig.mgz  --reg ref_2_orig.dat --regheader --surf orig'])
  % automatic registration
    unix(['bbregister --s ' subj ' --mov   ref_plus_seeg.nii.gz --targ ./mri/orig.mgz  --reg ref_2_orig.dat --regheader --surf orig'])
%      unix(['mri_vol2vol --reg ref_2_orig.dat  --mov ' Q ' --targ ref_plus_seeg.nii.gz --o '  hemi '.seeg.nii']);
% 
%     unix(['mri_vol2vol --reg hires_ref_2_orig.dat  --mov ' Q ' --targ ref_plus_seeg.nii.gz --o '  hemi '.seeg.nii']);

     unix(['mri_vol2surf --src ' scr_name ' --src_type t1 --srcreg ref_2_orig.dat  --hemi ' hemi ...
     ' --projfrac 0.5 --out ./' Q_out ' --out_type paint --surf pial']);
     unix(['mris_convert ' Q_out ' ' Q_out(1:end-2) '.asc']);
%     
    % compressing back
    % unix(['gzip ' scr_name(1:end-3)]);  % if you want to have compressed
    % scource file