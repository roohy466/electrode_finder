%     >>>>>>>>>>>>>>>>> This part was cut from main program
%     figure;
%     hold on
%      plot3(coord_spm_orig(1,:),coord_spm_orig(2,:),coord_spm_orig(3,:),'r.'); hold
%      plot3(tip_tmp_spm(:,1),tip_tmp_spm(:,2),tip_tmp_spm(:,3),'LineWidth',3,'Color',[0 0 0]);
%     
    % transfrom tip and head to voxel space
    tip_head_vox_space=round(transformation_matrix^-1*transformation_matrix_0^-1*[x1(2*e-1:2*e)' ;y1(2*e-1:2*e)' ;z1(2*e-1:2*e)'; [1 1]]);
    x1_vox=tip_head_vox_space(1,:);
    y1_vox=tip_head_vox_space(2,:);
    z1_vox=tip_head_vox_space(3,:);
   %  plot3(x1_vox,y1_vox,z1_vox,'LineWidth',3,'Color',[0 0 0]);
    p1=x1_vox';
    p2=y1_vox';
    f1= fit(p1, p2,  'poly1');

    p1=y1_vox';
    p2=z1_vox';
    f2 = fit(p1, p2,  'poly1');
    
    x_dist_vox=abs(x1_vox(1)-x1_vox(2));
    y_dist_vox=abs(y1_vox(1)-y1_vox(2));
    z_dist_vox=abs(z1_vox(1)-z1_vox(2));

    x1y1z1_lenght=sqrt(x_dist_vox^2+y_dist_vox^2+z_dist_vox^2);
    % finding the prependecular plane to the line at the current point
    %finding nearest nodes or coordiante to the x_ineter_tmp 
    x_tmp=(min(x_line):0.3:max(x_line))';
    y_tmp=f1(x_tmp);
    z_tmp=f2(y_tmp);
    elect_line_coordinates=[x_tmp y_tmp z_tmp];
    tip_tmp(1,:)=elect_line_coordinates(1,:);
    tip_tmp(2,:)=elect_line_coordinates(end,:);
%     figure;
%     hold on
   
 %   plot3(tip_tmp(:,1),tip_tmp(:,2),tip_tmp(:,3),'LineWidth',3,'Color',[0 0 0]);
%     
%     hold off
%     y_line=round(f1(x_line_set));
%     z_line=round(f2(y_line));
    
   % plot3(x_line_set,f1(x_line_set),f2(f1(x_line_set)),'black');hold
    
    % normal vector which preendicular for each vox (voxel space)
    nx_vox=(x1_vox(1)-x1_vox(2))/x1y1z1_lenght;
    ny_vox=(y1_vox(1)-y1_vox(2))/x1y1z1_lenght;
    nz_vox=(z1_vox(1)-z1_vox(2))/x1y1z1_lenght;
    norm_vector_vox=[nx_vox ny_vox nz_vox];
   
    axis_max=find([x_dist_vox y_dist_vox z_dist_vox]==max([x_dist_vox y_dist_vox z_dist_vox]));