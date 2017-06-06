function [answer,WorkDir]=check_requirements(SubjName)
WorkDir='';
% checking FREESURER SUBJECTS_DIR
[txt_tmp ,root_subj]=unix('echo $SUBJECTS_DIR');
disp(['The SUBJECT_DIR= ' root_subj]);
root_subj=root_subj(1:end-1);
if size(root_subj,2)==0
    disp('Please define SUBJECTS_DIR') ;
    answer='NO';
    return;
else
    answer='yes';
end
if exist([root_subj '/' SubjName ],'dir')==0
    disp('The SUBJNAME is missing') ;
    answer='NO';
    return;
end
%%% checking premission
unix(['echo "Test Writing Permission" > '  [root_subj '/' SubjName '/' 'TestPersmission.txt']]);
if exist([root_subj '/' SubjName '/' 'TestPersmission.txt'],'file')==0
    
    
    disp('NO Permission to write. try "sudo  chmod  776 -R  PatientName " in linux command') ;
    disp('NO Permission to write. try "sudo  chown -R  YourUserName  PatientName " in linux command') ;
    answer='NO';
    return;
else
    delete([root_subj '/' SubjName '/' 'TestPersmission.txt'])
end
mkdir([root_subj '/' SubjName '/TEST']);
messageTMP=rmdir([root_subj '/' SubjName '/TEST']);
if messageTMP==0
    disp('NO Permission to write. try "sudo  chmod  776 -R  PatientName " in linux command') ;
    disp('NO Permission to write. try "sudo  chown -R  YourUserName  PatientName " in linux command') ;
    answer='NO';
    return;
end
WorkDir=[root_subj '/' SubjName '/'];