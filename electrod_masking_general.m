function  [node_existance_rotated_zy,reverse_rotation,reverse_shift_matrix,extracted_electrod,extracted_number_mat]=...
    electrod_masking_general(coord_spm_orig,elect_line_coordinates_spm)
nearest_cooords_collect=[500 ; 500 ; 500  ;   1]; %test coordinate
g=1;
node_existance_rotated_zy=[];
reverse_rotation=[];
reverse_shift_matrix=[];
extracted_electrod=[];


%figure;hold
extracted_number_mat=[];
for j=1:size(elect_line_coordinates_spm,1)
    % plane is passing theorugh a point with normal vector nx_vox ny_vox nz
    [nearest_cooords_tmp,number_mat]=...
        nearest_vox_coorinates_finder(elect_line_coordinates_spm(j,:),coord_spm_orig);
    if size(nearest_cooords_tmp,2)>0
        for k=1:size(nearest_cooords_tmp,2)
            test_coord=nearest_cooords_collect==...
                repmat(nearest_cooords_tmp(:,k),1,size(nearest_cooords_collect,2));
            t_sum=sum((sum(test_coord)==3)==0);
            if t_sum==size(nearest_cooords_collect,2)
                g=g+1;
                nearest_cooords_collect(:,g)=nearest_cooords_tmp(:,k);
                %  plot3(nearest_cooords_tmp(1,k),nearest_cooords_tmp(2,k),nearest_cooords_tmp(3,k),'r.')
                % pause(0.001)
            end
        end
        extracted_number_mat=[number_mat;  extracted_number_mat];
    end
end
nearest_cooords_collect_f=nearest_cooords_collect(:,2:end);
%plot3(nearest_cooords_collect_f(1,:),nearest_cooords_collect_f(2,:),nearest_cooords_collect_f(3,:),'b.');
% comparing with electrod images to filter it out
clear nod_exist_final_masked

% detecting the rotaion center by finding nearest point to the center
% of brain
A=sqrt(sum(elect_line_coordinates_spm(1,:).^2));
B=sqrt(sum(elect_line_coordinates_spm(end,:).^2));
if A<B
    tip_coord=elect_line_coordinates_spm(1,:);
    tail_coord=elect_line_coordinates_spm(end,:);
else
    tip_coord=elect_line_coordinates_spm(end,:);
    tail_coord=elect_line_coordinates_spm(1,:);
end
tip_tail_distance=sqrt(sum((tip_coord-tail_coord).^2));
%     figure
%     hold
%     axis([0 150 0 150 0 150])
%     axis image
% plot3(nod_exist_final_masked(1,:),nod_exist_final_masked(2,:),nod_exist_final_masked(3,:),'.g');
% this is the matrix which shift the data to the center
shift_matrix=repmat(tip_coord',1,size(nearest_cooords_collect_f,2));
tail_shifted=tail_coord-tip_coord;
extracted_electrod_shifted=nearest_cooords_collect_f(1:3,:)-shift_matrix;

% REturn Nothing if no voxel found!
if size(extracted_electrod_shifted,2)<2
    return
end

%%% cheking if the what has been extracted having some acceptable lenght
[A,B,MaxDist]=extracting_most_far_coordinates(extracted_electrod_shifted);
if MaxDist<(tip_tail_distance*0.7 )
    node_existance_rotated_zy=[];
    reverse_rotation=[];
    reverse_shift_matrix=[];
    extracted_electrod=[];
    return
end
% extract eaxct vector from electrod body
norm_line_pre =electrod_vector_finder(extracted_electrod_shifted);
% correcting the norm_line
% checking distances for the voxels neear norm_line coordinaes tip and
% tail
% find the first value which is less than 1
[norm_line,mess]=norm_line_correction(extracted_electrod_shifted,norm_line_pre);
if strfind(lower(mess),'error')
    node_existance_rotated_zy=[];
    reverse_rotation=[];
    reverse_shift_matrix=[];
    extracted_electrod=[];
    return
end
%       plot3(extracted_electrod_shifted(1,:),extracted_electrod_shifted(2,:),extracted_electrod_shifted(3,:),'.');hold
%       plot3(norm_line_pre(1,:),norm_line_pre(2,:),norm_line_pre(3,:),'r');
%      axis image

% normal vector in real space
norm_dist=sqrt(sum((norm_line(:,end)-norm_line(:,1)).^2));
if norm_dist==0
    norm_line(:,end)=norm_line(:,end)+0.01*norm_line(:,end);
    norm_dist=sqrt(sum((norm_line(:,end)-norm_line(:,1)).^2));
end
n_vector=(norm_line(:,end)-norm_line(:,1))/norm_dist;
% plot3([0 60*n_vector(1)],[0 60*n_vector(2)],[0 60*n_vector(3)],'LineWidth',3,'Color',[0 0 0]);
alpha_xyz_to_xz=atan(n_vector(2)/n_vector(1));

rot_matrix0=angle2dcm(alpha_xyz_to_xz,0,0,'ZYX' );
first_rot=rot_matrix0;
node_existance_rotated_z=(first_rot*extracted_electrod_shifted);
%     plot3(node_existance_rotated_z(1,:),node_existance_rotated_z(2,:),node_existance_rotated_z(3,:),'r.');

% then we have to find the new normal line for rotated electrod.
norm_line2 =electrod_vector_finder(node_existance_rotated_z);
norm_dist2=sqrt(sum((norm_line2(:,end)-norm_line2(:,1)).^2));
%  plot3(norm_line2(1,:),norm_line2(2,:),norm_line2(3,:),'black');
n_vector=(norm_line2(:,end)-norm_line2(:,1))/norm_dist2;
alpha_xz_to_x=atan(n_vector(3)/n_vector(1));
rot_matrix1=angle2dcm( 0,-alpha_xz_to_x, 0 ,'ZYX' );
second_rot=rot_matrix1;
node_existance_rotated_zy=(second_rot*node_existance_rotated_z);
%     plot3(node_existance_rotated_zy(1,:),node_existance_rotated_zy(2,:),node_existance_rotated_zy(3,:),'g.');

% if needed to rotate the third times!
p1=node_existance_rotated_zy(1,:)';
p2=node_existance_rotated_zy(3,:)';
f1= fit(p1, p2,  'poly1');
if abs(atand(f1.p1))>5
    alpha_xz_to_x2=atan(f1.p1);
    rot_matrix2=angle2dcm( 0,-alpha_xz_to_x2, 0 ,'ZYX' );
    third_rot=rot_matrix2;
    node_existance_rotated_zy=(third_rot*node_existance_rotated_zy);
    rotattion_matrix_totti=third_rot*second_rot*first_rot;
    reverse_rotation=rotattion_matrix_totti^-1;
else
    rotattion_matrix_totti=second_rot*first_rot;
    reverse_rotation=rotattion_matrix_totti^-1;
end
reverse_shift_matrix=shift_matrix(:,1);
extracted_electrod=nearest_cooords_collect_f;

% to get the data back to original coorinate we have to apply the
% recerse rotation then apply the reverse shift matrix



