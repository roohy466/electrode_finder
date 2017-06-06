function topo=caret_topo_reader(file)
fid=fopen(file);
tline = fgetl(fid);
k=1;
while strcmp(tline,'EndHeader')==0
    %disp(tline)
    tline = fgetl(fid);
    k=k+1;
end
k_final=k+2;
fclose(fid);
data_coord=importdata(file,' ',k_final);
topo=data_coord.data;