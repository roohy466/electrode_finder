% finding the nearest coordinate to the node on pial or white
function [coord_near,vox_near_level]=nearest_vox_coorinates_finder(coord_xyz,coord_spm)
% extracting the  vox coordinates that arenot empty. 
coord_spm_xyz=coord_spm(1:3,:)';
diff=coord_spm_xyz-repmat(coord_xyz,size(coord_spm_xyz,1),1);
diff_dist=sqrt(diff(:,1).^2+diff(:,2).^2+diff(:,3).^2);
% finding minimum distance to be neare or inside an electrod coordinates is 2 mm 
thresh_distance=2.5;
vox_near_level=find(diff_dist<=thresh_distance);
coord_near=coord_spm(:,vox_near_level);


