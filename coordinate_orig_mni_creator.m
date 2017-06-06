function [center_coord_orig center_coord_mni]=coordinate_orig_mni_creator(orig_coord_file, mni_coord_file,center_node)
coord_orig=caret_coord_reader(orig_coord_file);
coord_mni=caret_coord_reader(mni_coord_file);
center_coord_orig=nan(size(center_node,2),3);
center_coord_mni=nan(size(center_node,2),3);
for i=1:size(center_node,2)
    if center_node(i)>0
          center_coord_orig(i,:)=coord_orig(center_node(i));
          center_coord_mni(i,:)=coord_mni(center_node(i));
    end
end