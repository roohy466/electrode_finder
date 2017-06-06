function [electrod_voxes_out]=...
    model_the_nodes(node_existance_rotated_zy,number_of_leeds,electord_lenght)
        % counting population for X direction
        % getting electrod data inside mask
       % shifting the electrod tip to 0 value in coordnate to be sure it is
       % really tip and model it afterward.\
       
       min_tip=min(node_existance_rotated_zy(1,:));
       node_shifted=node_existance_rotated_zy-repmat([min_tip; 0 ;0],1,size(node_existance_rotated_zy,2));
       dist_comp=min(node_shifted(1,:)):0.4: electord_lenght;
       real_dist=dist_comp(2:end);
       pop_y_plane=[node_shifted(1,:);node_shifted(3,:)];
       pop_z_plane=[node_shifted(1,:);node_shifted(2,:)];
       for j=1:size(dist_comp,2)-1
           pop_j_z(j)= size(find((pop_z_plane(1,:)>=dist_comp(j)) .* (pop_z_plane(1,:)<dist_comp(j+1))==1),2);
           max_1=max(pop_z_plane(2,find((pop_z_plane(1,:)>=dist_comp(j)) .* (pop_z_plane(1,:)<dist_comp(j+1))==1)));
           min_1=min(pop_z_plane(2,find((pop_z_plane(1,:)>=dist_comp(j)) .* (pop_z_plane(1,:)<dist_comp(j+1))==1)));
           if size(max_1)>0
                max_pop_max(j)=max_1;
           else
                max_pop_max(j)=0;
           end
           if size(max_1)>0
               min_pop_max(j)=min_1;
           else
               min_pop_max(j)=0;
           end
           dis_max_min(j)=max_pop_max(j)- min_pop_max(j);
           pop_j_y(j)= size(find((pop_y_plane(1,:)>=dist_comp(j)) .* (pop_y_plane(1,:)<dist_comp(j+1))==1),2);
       end
       % modeling the population of electrods
%        plot( dist_comp(1:end-1),max_pop_max,'r'); hold
%        plot( dist_comp(1:end-1),min_pop_max,'g');
     %  plot( dist_comp(1:end-1),dis_max_min,'b'); hold
%        plot(pop_y_plane(1,:),pop_y_plane(2,:),'.');
   %     axis image
       % here we add the biased stmation from electrod leed number
       % if the model doesnot give the good result it will use the leed
       % number to estimate the position of each leads in the electrod
       % lenght.
       % point  should be similar as number of leads
       estimated_lenght=number_of_leeds*2+(number_of_leeds-1)*1.5+1; 
       %   with 1 mm error
       l=estimated_lenght;
       n=number_of_leeds;
       st=(2*pi)/size(dis_max_min,2);
       x=(0:st:2*pi)*l/(2*pi);
       model_leeds=sin((n-0.5)*x(1:end-1)*(2*pi/l));
        
       final_d=dis_max_min+model_leeds+1;
       mean_mid=(mean(smooth(final_d))-min(smooth(final_d)))/2;
%        plot(x(1:end-1),smooth(final_d));hold 
%        plot(x(1:end-1),repmat(mean(smooth(final_d)),size(final_d)));
%        plot(x(1:end-1),repmat(min(smooth(final_d))+mean_mid,size(final_d)));
%        plot(x(1:end-1),model_leeds+min(smooth(final_d)),'r-')
%       % electrod_voxes=real_dist(1):(max(real_dist)-min(real_dist))/(10*size(real_dist,2)):real_dist(end);
%        plot(x(1:end-2),model_leeds(1:end-1)-model_leeds(2:end))
%       d1 = differentiate(fun_model,electrod_voxes);
       d1=model_leeds(1:end-1)-model_leeds(2:end);
       c=d1(1);
       k=1;
       for i=2:size( d1,2)
           if sign(d1(i))==sign(c)
               c=d1(i);
           else
               c=d1(i);
               point(k)=i;            
               k=k+1;  
           end
       end
      val_point=zeros(size(x(1:end-1)));
      val_point(point(1:2:end))=1;
      x2=x(1:end-1);
      x_zeros=x2(val_point==1);
      x_zeros(1)=0;
      % plot(x(1:end-1),val_point)
       if size(val_point,2)>=n-2
            zero_elect= val_point;
           electrod_voxes_out=x_zeros+ min_tip;
       end
       for i=1:size(node_existance_rotated_zy(1,:))
       end
