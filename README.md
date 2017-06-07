# electrode_finder
This a project was done to extract the implanted electrodes in the patients skull. The script needs the T1 of the brain and CT scan of the implanted electrodes. 

The result of using the script has been published in 

    Avanzini et al, "Four-dimensional maps of the human somatosensory system",
    Proceedings of the National Academy of Sciences (PNAS),2016


# Using
Before running the program you need to install following software:

    gnumeric
    FSL 
    Freesurfer
    CARET 
    
the SUBJECTS_DIR should be defined before running MATLAB

**************************************************************************

these files must be there:

       SEEGlist.fcsv , seeg_leeds.XLS ,

SEEGlist: is the list of electrode names with the contact number
seeg_leeds: is the coordinates of end or begining of each electrode

_____________________________________________________________________________
if your matlab has problem in running libc and libesdc64++ run following
commands
64 bits linux >>  

    sudo ln -s /lib/x86_64-linux-gnu/libc.so.6 /lib64/libc.so.6
32 bits linux >>  

    sudo ln -s /lib/i386-linux-gnu/libc.so.6 /lib/libc.so.6
cd /MATLAB/bin
Backup original soft link by issuing: ???

    sudo mv libstdc++.so.6 ORIGINAL_libstdc++.so.6???
Create a link by issuing: 
        
    sudo ln -s /usr/lib/libstdc++.so.6 libstdc++.so.6???


######################################################################
list of electrods that used in the patients first you shoud go the subjects folder.

     electrode_finder(SUBJName,varagin)

function variables is SUBJName can be 'Subj01',

     electrode_finder('Subj01')

varagin is the electrode that you want to exclude from processing for example: you want to exclude the electrodes 2 and 4 from further processing:

     electrode_finder('Subj01',[2 4])

 if you want to delete all previous analysis then add the "delete' like
 this:
 
      electrode_finder('Subj01','delete')

or skip some electrodes also
         
       electrode_finder('Subj01','delete',[2:4])

It will be behave as if the subject is newly added and create everything from scracth. Also it will check if the segmentaion data from freesurfer are available or not. if you want to do the segmentation directly you can add the freesurfer str in the electrode_finder as follow

        electrode_finder('Subj01','freesurfer')
