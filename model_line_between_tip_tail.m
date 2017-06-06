function [elect_line_coordinates_spm, tip_tmp_spm,order]=model_line_between_tip_tail(x1,y1,z1,error_dist)
% checking the best fit:
[max_diff order]=sort([abs(diff(x1))  abs(diff(y1)) abs(diff(z1))],'descend');
% the assumtion is the two coordinates never be equal.
x_cord=1;y_cord=1; z_cord=1;
% checking if there are some equal values values which makes the calculation uncertain 
if  x1(1)==x1(2)
     x1(1)=x1(1)+0.1;
end
if y1(1)==y1(2)
     y1(1)=y1(1)+0.1;
end
if z1(1)==z1(2)
     z1(1)=z1(1)+0.1;
end

% the first two show what coordinates to use for modelling

p_11=x1;
p_12=y1;
f_1= fit(p_11, p_12,  'poly1');

p_21=y1;
p_22=z1;
f_2 = fit(p_21, p_22,  'poly1');


% if theere no relation between y and z
p_31=x1;
p_32=z1;
f_3 = fit(p_31, p_32,  'poly1');

p_41=z1;
p_42=y1;
f_4 = fit(p_41, p_42,  'poly1');
% model  the line
% check if the electrod is ZY 
pzpy=mean( [abs(f_1.p1) abs(f_3.p1)]);
if order(3)==1 && error_dist>0
    error_dist=error_dist/(4*pzpy);
else
    error_dist=error_dist/2;
end
step_between=abs(min(x1)-error_dist-max(x1)+error_dist)/40;
x_tmp_1=(min(x1)-error_dist:step_between:max(x1)+error_dist)';

if abs(f_1.p1)>0.05
    y_tmp_1=f_1(x_tmp_1);
    z_tmp_1=f_2(y_tmp_1);
    norm_line=[x_tmp_1 y_tmp_1 z_tmp_1];
else
    z_tmp_1=f_3(x_tmp_1);
    y_tmp_1=f_4(z_tmp_1);
    norm_line=[x_tmp_1 y_tmp_1 z_tmp_1];
end
elect_line_coordinates_spm=norm_line;
tip_tmp_spm(1,:)=elect_line_coordinates_spm(1,:);
tip_tmp_spm(2,:)=elect_line_coordinates_spm(end,:);