function coord_spm_orig_out=removing_extracted_from_maincoord(coord_spm_orig,extracted_electrod_tmp)
% cleaning the input extracted
extracted_real=1:size(coord_spm_orig,2);
remining_mat=setdiff(extracted_real,extracted_electrod_tmp);
if size(remining_mat,1)>0
    coord_spm_orig_out=coord_spm_orig(:,remining_mat);
else
    coord_spm_orig_out=[];
end