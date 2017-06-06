% This function merges caret paint files and crete the new piant files
function file_to_write=merging_caret_paints_v2(files, root)
pp={'BeginHeader' ...
'Caret-Version 5.65' ...
'Date ' num2str(date) ...
'comment 	' ...
'encoding ASCII'...
'EndHeader'...
'tag-version 1'...
'tag-number-of-nodes 163842'...
'tag-number-of-columns 1'...
'tag-title ' ...
'tag-number-of-paint-names ' ...
'tag-column-name 0 ALL_electrods_FS_LR' ...
'tag-column-comment'...
'tag-BEGIN-DATA'...
'0 ???'};
n=size(pp,2);
p=1;paint_int=0;
for i=1:size(files,2)
    [nodes names]=read_caret_paint(files{i});
    node_tmp_final(:,i)=(nodes+paint_int).*(nodes>0);
    
    for j=1:size(names,2)
        node_tmp(:,p)=(nodes==j)*p;
        %node_tmp(:,i)=(nodes==j)*p;
        pp{n+p}=[num2str(p) ' ' names{j}];
        disp(pp{n+p})
        p=p+1;
    end
    paint_int=size(names,2)+paint_int;
    clear nodes names
end
pp{9}=[pp{9}(1:20) num2str(size(node_tmp,1))];
pp{11}=[pp{11} pp{n-1+p}(strfind(pp{n-1+p},' '):strfind(pp{14+p},'center')-7) '_all_electrods'];
pp{12}=[pp{12} num2str(p)];
file_to_write=[root '/all_electrods_FS_LR.paint'];
pp{10}=['tag-number-of-columns ' num2str(size(files,2))];

% check if the file exists
if exist(file_to_write)>0
     reply = input('Do you want to overwrite the paint file taht already existed: y/n', 's')
     if strcmp(reply,'n')==1
          return
     end
end
disp('Final FS_LR file is created: all_electrods_FS_LR.paint');
final_node=[[0:size(node_tmp,1)-1]', node_tmp_final];
fid=fopen(file_to_write,'w');
for i=1:size(pp,2)
     fprintf(fid,[ pp{i} '\n']);
end
dlmwrite(file_to_write, final_node, '-append','roffset', 0, 'delimiter', ' ','precision', 6); % adding noddes data to file
fclose(fid);

    


