function  [node_existance_rotated_zy, first_rot,second_rot,reverse_rotation,reverse_shift_matrix,resize_reverse,extracted_electrod]=electrod_masking_x_max(coord_i,tip_head_vox_space,elect_line_coordinates,norm_vector_vox,transformation_matrix)
    nx_vox=norm_vector_vox(1);
    ny_vox=norm_vector_vox(2);
    nz_vox=norm_vector_vox(3);
    x_tmp=elect_line_coordinates(:,1);
    y_tmp=elect_line_coordinates(:,2);
    z_tmp=elect_line_coordinates(:,3);
    x1_vox=tip_head_vox_space(1,:);
    y1_vox=tip_head_vox_space(2,:);
    z1_vox=tip_head_vox_space(3,:);
    for j=1:size(x_tmp,1)
            % plane is passing theorugh a point with normal vector nx_vox ny_vox nz
            a=x_tmp(j);
            b=y_tmp(j);
            c=z_tmp(j);
            n=1;
            for k=[-4 4 ]
                for l=[ -4 4]
                    plane(n,2)=b+k; % y value
                    plane(n,3)=c+l;
                    plane(n,1)=(-(nz_vox*(plane(n,1)-c)+ny_vox*(plane(n,2)-b))/nx_vox)+a;  % x value
                   
                    n=n+1;
                end

            end
            % vertices out of 4 points
            [Z,Y] = meshgrid(plane(1,3):plane(2,3),(plane(1,2)):(plane(4,2)));
            X=round((-(nz_vox*(Z-c)+ny_vox*(Y-b))/nx_vox)+a);
            %mesh(X,Y,Z)
            % find the voxels which are 1 in the mesh
            node_existance(:,:,j)=round([X(:)';Y(:)';Z(:)']);

           % plot3(node_existance(1,:,j),node_existance(2,:,j),node_existance(3,:,j),'.');

            %elec_mask(node_existance(1,:,j),node_existance(2,:,j),node_existance(3,:,j))=1;
    end
        % rotation matrix to remove the oriantation in space
        alpha1=atan(nx_vox);
        alpha2=atan(ny_vox);
        alpha3=atan(nz_vox);
        [n1 n2 n3]=size(node_existance);
        reshaped_nod_exist= reshape( node_existance, n1,n2*n3);
        % clean repetition inside reshape node
        n=1;
        for j=1:size(reshaped_nod_exist,2)
            pos_j=find(sum(repmat(reshaped_nod_exist(:,j),1,size(reshaped_nod_exist,2))==reshaped_nod_exist)==3);
             if size(pos_j,2)==1
                 nod_exist_final(:,n)=reshaped_nod_exist(:,j);
                 n=n+1;
             elseif size(pos_j,2)>1
                 nod_exist_final(:,n)=reshaped_nod_exist(:,j);
                 reshaped_nod_exist(:,setdiff(pos_j,j))=0;
                 n=n+1;
             end
        end
       n=1;
       for j=1:size(reshaped_nod_exist,2)
             if sum(nod_exist_final(:,j)~=0)==3
                 nod_exist_final2(:,n)=nod_exist_final(:,j);
                 n=n+1;
             end
       end
       % comparing with electrod images to filter it out
        clear nod_exist_final_masked
        n=1;
            for j=1:size(nod_exist_final2,2)
                 pos_j=find(sum(repmat(nod_exist_final2(:,j),1,size(coord_i,2))==coord_i(1:3,:))==3);
                 if size(pos_j,2)==1
                     nod_exist_final_masked(:,n)=nod_exist_final2(:,j);
                     n=n+1;
                 end
            end
            
          resize_matrix=[transformation_matrix(1,1) 0 0;0 transformation_matrix(2,2) 0; 0 0 transformation_matrix(3,3)];           
    %    z_mm(1)=max(nod_exist_final_masked(3,:)) ;
    %    z_mm(2)= min(nod_exist_final_masked(3,:));
    %    xyz_tmp=mean(nod_exist_final_masked(:, nod_exist_final_masked(3,:)==z_mm(1))');
    %    x_mm(1)= xyz_tmp(1);
    %    y_mm(1)= xyz_tmp(2);
    % 
    %     xyz_tmp=mean(nod_exist_final_masked(:, nod_exist_final_masked(3,:)==z_mm(2))');
    %    x_mm(2)= xyz_tmp(1);
    %    y_mm(2)= xyz_tmp(2);
    %    tip_head_vox=[x_mm ;y_mm; z_mm];
        tip_head_vox=[x1_vox;y1_vox;z1_vox];
        tip_head=resize_matrix*tip_head_vox;
        tip_head=tip_head-repmat(min(tip_head')',1,2);
        x_dist=abs(tip_head(1,1)-tip_head(1,2));
        y_dist=abs(tip_head(2,1)-tip_head(2,2));
        z_dist=abs(tip_head(3,1)-tip_head(3,2));
        x1y1z1_dist=sqrt(x_dist^2+y_dist^2+z_dist^2);       

        % normal vector in real space
        nx=(tip_head(1,1)-tip_head(1,2))/x1y1z1_dist;
        ny=(tip_head(2,1)-tip_head(2,2))/x1y1z1_dist;
        nz=(tip_head(3,1)-tip_head(3,2))/x1y1z1_dist;        

        alpha1=atan(nx);
        alpha2=atan(ny);
        alpha3=atan(nz);

       % plot3(nod_exist_final_masked(1,:),nod_exist_final_masked(2,:),nod_exist_final_masked(3,:),'.g');

        reshaped_nod_exist=resize_matrix*nod_exist_final_masked;
        resize_reverse=[1/transformation_matrix(1,1) 0 0;0 1/transformation_matrix(2,2) 0; 0 0 1/transformation_matrix(3,3)]; 
        %plot3(tip_head(1,:),tip_head(2,:),tip_head(3,:),'black*');hold
        % this is the matrix which shift the data to the center
        shift_matrix_tmp=repmat(min(reshaped_nod_exist')',1,size(reshaped_nod_exist,2));
        reshaped_nod_exist_shifted=reshaped_nod_exist-repmat(min(reshaped_nod_exist')',1,size(reshaped_nod_exist,2));
       % plot3(reshaped_nod_exist_shifted(1,:),reshaped_nod_exist_shifted(2,:),reshaped_nod_exist_shifted(3,:),'.');

        rot_matrix=angle2dcm(0, -alpha3, 0,'ZYX' );
        first_rot=rot_matrix;
        node_existance_rotated_z=(rot_matrix*reshaped_nod_exist_shifted);
        tip_head2=rot_matrix*tip_head;
        %plot3(node_existance_rotated_z(1,:),node_existance_rotated_z(2,:),node_existance_rotated_z(3,:),'r.');

        rot_matrix=angle2dcm( alpha2, 0, 0,'ZYX' );
        second_rot=rot_matrix;
        tip_head3=rot_matrix*tip_head2;
        node_existance_rotated_zy=(rot_matrix*node_existance_rotated_z);
        % plot3(tip_head3(1,:),tip_head3(2,:),tip_head3(3,:),'black*');
        %plot3(node_existance_rotated_zy(1,:),node_existance_rotated_zy(2,:),node_existance_rotated_zy(3,:),'g.'); 
         rotattion_matrix_totti=second_rot*first_rot;
        reverse_rotation=rotattion_matrix_totti^-1;
        reverse_shift_matrix=shift_matrix_tmp(:,1);
        
        extracted_electrod=nod_exist_final_masked;
        % to get the data back to original coorinate we have to apply the
        % recerse rotation then apply the reverse shift matrix
         axis([0 150 0 150 0 150])
         axis image
         

     