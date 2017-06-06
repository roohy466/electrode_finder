function  [node_existance_rotated_zy, first_rot,second_rot,reverse_rotation]=electrod_masking_z_max(coord_i,tip_head_vox_space,elect_line_coordinates,norm_vector_vox,transformation_matrix)
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
                    plane(n,1)=a+l;  % x value
                    plane(n,2)=b+k; % y value
                    plane(n,3)=(-(nx_vox*(plane(n,1)-a)+ny_vox*(plane(n,2)-b))/nz_vox)+c;
                    n=n+1;
                end

            end
            % vertices out of 4 points
            [X,Y] = meshgrid(plane(1,1):plane(2,1),(plane(1,2)):(plane(4,2)));
            Z=round((-(nx_vox*(X-a)+ny_vox*(Y-b))/nz_vox)+c);
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
     
    
    reshaped_nod_exist=resize_matrix*nod_exist_final_masked;
    %plot3(tip_head(1,:),tip_head(2,:),tip_head(3,:),'black*');hold
    reshaped_nod_exist_shifted=reshaped_nod_exist-repmat(min(reshaped_nod_exist')',1,size(reshaped_nod_exist,2));
    %plot3(reshaped_nod_exist_shifted(1,:),reshaped_nod_exist_shifted(2,:),reshaped_nod_exist_shifted(3,:),'.');
      
    rot_matrix0=angle2dcm(0, -pi/2+alpha1, 0,'ZYX' );
    first_rot=rot_matrix0;
    node_existance_rotated_z=(rot_matrix0*reshaped_nod_exist_shifted);
    tip_head2=rot_matrix0*tip_head;
    %plot3(node_existance_rotated_z(1,:),node_existance_rotated_z(2,:),node_existance_rotated_z(3,:),'r.');
    
    rot_matrix1=angle2dcm( alpha2, 0, 0,'ZYX' );
    second_rot=rot_matrix1;
    tip_head3=rot_matrix1*tip_head2;
    node_existance_rotated_zy=(rot_matrix1*node_existance_rotated_z);
     plot3(tip_head3(1,:),tip_head3(2,:),tip_head3(3,:),'black*');
    plot3(node_existance_rotated_zy(1,:),node_existance_rotated_zy(2,:),node_existance_rotated_zy(3,:),'g.');
    rotattion_matrix_totti=rot_matrix1*rot_matrix0;
    reverse_rotation=rotattion_matrix_totti^-1;
     axis([0 150 0 150 0 150])
     axis image
     
     