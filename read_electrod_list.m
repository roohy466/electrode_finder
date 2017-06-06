function [electrod_names, electrod_coordiantes, leads, file_version]= read_electrod_list(electrodes_file_list)
% check for the version of data
fid = fopen(electrodes_file_list);
tline = fgets(fid);
while tline~=-1
   if strfind(tline,'version =')>0
        file_version= str2num(tline(strfind(tline,'version =')+9:end));
   end
   tline = fgets(fid);
end
fclose(fid); 
    % for the version 2
if file_version==2
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
        for i=1:size(elect_coord_tmp,2)
            a=strfind(elect_coord_tmp{i},',');
            elect_coord_tmp2(i,:)=str2num(elect_coord_tmp{i}(a(1):end));
            electrod_names(i,:)=elect_coord_tmp{i}(1);
        end

    electrod_coordiantes=elect_coord_tmp2(:,1:3);
    x1=electrod_coordiantes(:,1);
    y1=electrod_coordiantes(:,2);
    z1=electrod_coordiantes(:,3);
    for i=1:size(elect_coord_tmp2,1)/2;
        electrods_lenght(i)=sqrt((x1(2*i-1)-x1(2*i))^2+(y1(2*i-1)-y1(2*i))^2+(z1(2*i-1)-z1(2*i))^2);

    end
    leads=round((electrods_lenght+1.5)/3.5);
    
    % for the version 4.3
elseif file_version >4
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
     
     for i=1:size(elect_coord_tmp,2)
            a=strfind(elect_coord_tmp{i},',');
            elect_coord_tmp2(i,:)=str2num(elect_coord_tmp{i}(a(1):a(4)));
            electrod_names_tmp{i}=elect_coord_tmp{i}(a(end-2)+1:a(end-1)-1);
            electod_name_size(i,:)=size(electrod_names_tmp{i},2);
     end
    set_names=setdiff(electod_name_size,[]);
    if find(set_names==1) * find(set_names==3)==3
        disp('****************************************************************')
        disp('Your electrod list has a mixture of left and right electrodes!')
        disp('To evoid any mistakes please clean your data!!')
        disp('****************************************************************')
    else
        for i=1:size(elect_coord_tmp,2)
            electrod_names(i,:)=electrod_names_tmp{i}(1);
        end
    end
    electrod_coordiantes=elect_coord_tmp2(:,1:3);
    x1=electrod_coordiantes(:,1);
    y1=electrod_coordiantes(:,2);
    z1=electrod_coordiantes(:,3);
    for i=1:size(elect_coord_tmp2,1)/2;
        electrods_lenght(i)=sqrt((x1(2*i-1)-x1(2*i))^2+(y1(2*i-1)-y1(2*i))^2+(z1(2*i-1)-z1(2*i))^2);
    end
    leads=round((electrods_lenght+1.5)/3.5);
end