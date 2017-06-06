function coord=caret_coord_reader(file)
fid=fopen(file);
tline = fgetl(fid);
k=1;
while strcmp(tline,'EndHeader')==0
    %disp(tline)
    tline = fgetl(fid);
    k=k+1;
end
k_final=k+1;
fclose(fid);
data_coord=importdata(file,' ',k_final);
coord=data_coord.data(:,2:4);