function coord_final=apply_shift_rotation_matrices(coords,shift_matrix,rotation_matrix)
if size(coords,1)==4
    coords=coords(1:3,:);
end
coord_shifted=coords-repmat(shift_matrix,1,size(coords,2));
coord_final=rotation_matrix*coord_shifted;