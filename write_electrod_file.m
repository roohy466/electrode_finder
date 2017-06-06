function name_file=write_electrod_file(elect_name,header_file,shifted_version,extracted_electrod)
 name_file=['electrod_' elect_name '.nii'];
 %unix([ 'sed  "s/' shifted_version '/' name_file '/g"  ' header_fie ' '  header_fie]);
 disp('creating FSL electrod');
 unix(['fslcreatehd ' header_file ' ' name_file ]);
 
 if exist([name_file '.gz'])
     disp('unziping...');
     unix(['gzip -d ' name_file]);
 end
 i_seeg=spm_vol(name_file);
 i1=spm_read_vols(i_seeg);
 if exist([shifted_version '.gz'])
     disp('unziping...');
     unix(['gzip -d ' [shifted_version '.gz']]);
 end
 p1=spm_vol(shifted_version);
 i2=spm_read_vols(p1); 
 disp('creating nifti of this electrod ')
 for i=1:size(extracted_electrod,2)
     x=extracted_electrod(1,i);
     y=extracted_electrod(2,i);
     z=extracted_electrod(3,i);
     i1(x,y,z)= i2(x,y,z);
 end
 spm_write_vol(i_seeg,i1);