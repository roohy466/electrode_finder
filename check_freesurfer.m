function message=check_freesurfer(folder,subject)
areas_to_ckeck={'.area'
    '.defect_chull'
    '.orig'
    '.smoothwm.FI.crv'
    '.sphere'
    '.area.mid'
    '.defect_labels'
    '.orig.nofix'
    '.smoothwm.H.crv'
    '.sphere.reg'
    '.area.pial'
    '.inflated'
    '.pial'
    '.smoothwm.K.crv'
    '.sulc'
    '.avg_curv'
    '.inflated.H'
    '.qsphere.nofix'
    '.smoothwm.K1.crv'
    '.thickness'
    '.curv'
    '.inflated.K'
    '.smoothwm'
    '.smoothwm.K2.crv'
    '.volume'
    '.curv.pial'
    '.inflated.nofix'
    '.smoothwm.BE.crv'
    '.smoothwm.S.crv'
    '.white'
    '.defect_borders'
    '.jacobian_white'
    '.smoothwm.C.crv'
    '.smoothwm.nofix'};
hemi=['lh';'rh'];
message=0;
for h=1:2
    hemi_to_check=hemi(h,:);
    for i=1:size(areas_to_ckeck,1)
        if exist([folder '/' subject '/surf/' hemi_to_check  areas_to_ckeck{i}],'file')
        else
            message=message+1;
            disp(['Freesurfer file ' hemi_to_check  areas_to_ckeck{i} ' is missing'] );
        end
    end
end
if message>0
    disp('Add the freesurfer to electrode finder function or ')
    disp('run the segementation process "recon-all" agian...')
    disp('###############################################')
    message='ERROR, No segmentation data';
    disp(message);
    return;
end

