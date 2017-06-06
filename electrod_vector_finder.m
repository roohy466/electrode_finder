function norm_line=electrod_vector_finder(extracted_electrod_shifted)

a_tmp=extracted_electrod_shifted';
p1=a_tmp(:,1);
p2=a_tmp(:,2);
f1= fit(p1, p2,  'poly1');
p3=a_tmp(:,2);
p4=a_tmp(:,3);
f2 = fit(p3, p4,  'poly1');
p1=a_tmp(:,1);
p2=a_tmp(:,3);
f3= fit(p1, p2,  'poly1');
p1=a_tmp(:,3);
p2=a_tmp(:,2);
f4= fit(p1, p2,  'poly1');
% choose the two which are bigger 
 dis_min_max=max(a_tmp(:,1))-min(a_tmp(:,1));
 x_tmp=(min(a_tmp(:,1)):dis_min_max/20:max(a_tmp(:,1)));
if abs(f1.p1)>0.05
     y_tmp=f1(x_tmp)';
     z_tmp=f2(y_tmp)';
     norm_line=[x_tmp ;y_tmp ;z_tmp];
else
    z_tmp=f3(x_tmp)';
    y_tmp=f4(z_tmp)';
    norm_line=[x_tmp ;y_tmp ;z_tmp];
end
 
      
                
     