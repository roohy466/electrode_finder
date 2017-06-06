% create paint file out of electrods to find x y z of recording sites.
function make_ribbon_v2(subject, hemisphere_need)  % hemispheler is 'right' or 'left'
    unix('echo $SUBJECTS_DIR');
    hemisphere=['lh';'rh'];
    subj=subject;%'Pintaldi_scene';
    if strcmp(hemisphere_need,'left');
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
    scr_name='r_oarm_seeg_cleaned.nii.gz';
    target_name='ref_plus_seeg.nii.gz';
    a_scr=dir(scr_name);
    b_scr=dir(target_name);
    if size(a_scr,1)==1
        disp('Unziping the data....');
        unix(['gzip -d ' scr_name]);
        scr_name='r_oarm_seeg_cleaned.nii';
    else
        scr_name='r_oarm_seeg_cleaned.nii';
    end
    if size(b_scr,1)==1
         disp('Unziping the data....');
        unix(['gzip -d ' target_name]);
        target_name='ref_plus_seeg.nii';
    else
        target_name='ref_plus_seeg.nii';
    end
    % gunzip('*.gz'); % for unzipping the gz files
    % masking the ref_plus_seeg
  
%     unix('echo $SUBJECTS_DIR');
%     unix(['cd $SUBJECTS_DIR/' subj]);

    % reading the scr file
    disp('Shifting the data....');
    disp('reading the reference image');
    shifted_version=['RF_shifted_' scr_name];
    if exist('RF_ref_header.txt')>0
        delete RF_ref_header.txt
    end
    unix(['fslhd -x ' target_name '  >> RF_ref_header.txt']);
    unix(['sed  "s/' target_name '/' shifted_version '/g"  RF_ref_header.txt']);
    a1=spm_vol(scr_name);
    i1=spm_read_vols(a1);
    % reading the ref file
    disp('reading the electrod image');
    a2=spm_vol(target_name);
    i2=spm_read_vols(a2);
    unix(['fslcreatehd RF_ref_header.txt ' shifted_version]);
    a3=spm_vol(shifted_version);
    % cehck if the ref and seeg are really in the same vox space
    f=(i2(:)>3000).*(i1(:)>0);
    size_overlap=size(find(f>0),1);
    targ_size=size(find(i1(:)>0),1);
    
        if (size_overlap) >=(targ_size/8)
            % we keep the mat0 in prive to show how much chnaged we applied 
            disp('applying the hdear of reference to electrods');
            spm_write_vol(a3,i1);
            if size(dir('RF_ref_2_orig.dat'),1)<1
               % registering the r_oarm_seeg to ref_plus_seeg
            % automatix registration  >>>>>   bbregister --s colin27 --mov Anatomy_V20alpha.nii --init-fsl --t1 --reg file_to_orig.dat
            disp('creating the reg file from reference to orig.mgz');
                unix(['bbregister --s ' subj ' --mov   ref_plus_seeg.nii --t1 --reg RF_ref_2_orig.dat --regheader --surf orig'])
            end
        else
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
     disp('changing the resolution of the shifted electrods');
     %unix('mri_convert -cm shifted_r_oarm_seeg_cleaned.nii shifted_seeg_hires.nii');
     %unix('mri_convert -cm  ref_plus_seeg.nii ref_plus_seeg_hires.nii');

     disp('making a filled brain');
     unix([' mris_fill -r 0.4 ' hemi '.white RF_' hemi '.white.filled.nii']);
     unix([' mris_fill -r 0.4 ' hemi '.pial RF_' hemi '.pial.filled.nii']);
     unix(['tkregister2 --s ' subj ' --mov RF_' hemi '.white.filled.nii' ...
         ' --targ ref_plus_seeg.nii  --reg RF_filled_2_ref.dat --regheader --surf white --noedit'])
     disp('changing the resolution of the filled brain');
     unix(['mri_vol2vol --reg RF_filled_2_ref.dat  --mov RF_' hemi '.white.filled.nii --targ ref_plus_seeg.nii --o RF_'  hemi '.white.filled.hires.nii']);
     unix(['mri_vol2vol --reg RF_filled_2_ref.dat  --mov RF_' hemi '.pial.filled.nii --targ ref_plus_seeg.nii --o RF_'  hemi '.pial.filled.hires.nii']);
    disp('creating RF_ribbon.nii');
    unix(['mri_mask RF_' hemi '.pial.filled.hires.nii RF_'  hemi '.white.filled.hires.nii RF_ribbon.nii']);

    % masking pial with white for finding the ribbon
    disp('creating electrods inside the RF_ribbon.nii');
    unix(['mri_mask RF_shifted_r_oarm_seeg_cleaned.nii  RF_ribbon.nii RF_masked_shifted_seeg.nii']);
    % create a paint file out of ribbon file.
    Q_out = 'RF_seeg_in_ribbon_surface.w';
    % creating ref to orig % important to be created
  %  unix(['tkregister2 --s ' subj ' --mov   ref_plus_seeg.nii.gz --targ ./mri/orig.mgz  --reg ref_2_orig.dat --regheader --surf orig'])
  % automatic registration
     disp('creating surface paint from electrods');
     unix(['mri_vol2surf --src ' scr_name ' --src_type t1 --srcreg RF_ref_2_orig.dat  --hemi ' hemi ...
     ' --projfrac 0.5 --out ./' Q_out ' --out_type paint --surf pial']);
     unix(['mris_convert ' Q_out ' ' Q_out(1:end-2) '.asc']);
%     
 