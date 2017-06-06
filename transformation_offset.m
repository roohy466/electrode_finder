function mat_trans=transformation_offset(file)
% matrix : the first line is the orig  x1, y1, z1
% the second line is the centered


mat_file=importdata(file,',');
if isfield(mat_file,'data')==1
    x1=mat_file.data(1,1:3);
    x2=mat_file.data(2,1:3);
    mat_trans=x1-x2;
else
   x1=mat_file(1,1:3);
    x2=mat_file(2,1:3);
    mat_trans=x1-x2; 
end

