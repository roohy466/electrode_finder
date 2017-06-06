function [nodes name_electrods]=read_caret_paint(file)
fid=fopen(file);
k=1;
st=0;
while st==0
    %disp(tline)
    tline = fgetl(fid);
    if strcmp(tline,'tag-BEGIN-DATA')==1
        st=1;
    end
    k=k+1;
    if size(strfind(tline,'tag-number-of-paint-names'),2)==1
       num_line=str2double(tline(strfind(tline,'tag-number-of-paint-names')+25:end));
    end
end
k_final=k+num_line;

data_coord=importdata(file,' ',k_final);
if size(data_coord.data,2)>2
    nodes_tmp=[str2double(data_coord.colheaders) ;data_coord.data];
else
    nodes_tmp=[ 0 str2double(data_coord.colheaders{2}) ;data_coord.data];
end
nodes=nodes_tmp(:,2:end);
for i=1:num_line-1
    name_electrods{i}=data_coord.textdata{k_final-num_line+i};
end
fclose(fid);