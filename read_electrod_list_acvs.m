function [electrod_names, electrod_coordiantes]= read_electrod_list_acvs(electrodes_file_list)
fid = fopen(electrodes_file_list);
tline = fgets(fid);
j=0;i=1;
    while tline~=-1
         tline = fgets(fid);
         j=j+1;
         %disp(tline)
         if strcmp(tline(1),'#')==0
             if size(tline,2)>10
              elect_coord_tmp{i}=tline;
              i=i+1;
             end
        end
    end
fclose(fid); 
a=strfind(elect_coord_tmp{1},'|');
for j=1:size(a,2)-1
    elect_coord_tmp2(1,j)=str2double(elect_coord_tmp{1}(a(j)+1:a(j+1)-1));
end
electrod_names=electrodes_file_list(1);
electrod_coordiantes=elect_coord_tmp2(:,1:3);