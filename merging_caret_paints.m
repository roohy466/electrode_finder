% This function merges caret paint files and crete the new piant files
function merging_caret_paints(files, root)
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
p=1;
for i=1:size(files,2)
    [nodes names]=read_caret_paint(files{i});
    for j=1:size(names,2)
        node_tmp(:,p)=(nodes==j)*p;
        %node_tmp(:,i)=(nodes==j)*p;
        pp{n+p}=[num2str(p) names{j}(strfind(names{j},' ' ):end)];
        disp(pp{n+p})
        p=p+1;
    end
    clear nodes names
end
pp{9}=[pp{9}(1:20) num2str(size(node_tmp,1))];
pp{11}=[pp{11} pp{n-1+p}(strfind(pp{n-1+p},' '):strfind(pp{14+p},'center')-7) '_all_electrods'];
pp{12}=[pp{12} num2str(p)];

if size(find(sum(node_tmp(:,:)'>0)>1),2)==0
    final_node=[0:size(node_tmp,1)-1; sum(node_tmp(:,:)')]';
    file_to_write=[root '/all_electrods_FS_LR.paint'];
    fid=fopen(file_to_write,'w');
    for i=1:size(pp,2)
         fprintf(fid,[ pp{i} '\n']);
    end
    dlmwrite(file_to_write, final_node, '-append','roffset', 0, 'delimiter', ' ','precision', 6); % adding noddes data to file
    fclose(fid);
    disp('Final FS_LR file is created: all_electrods_FS_LR.paint');
else
    disp(' Removing overlaps===> Overlaps between nodes of :');
    disp(find(sum(node_tmp(:,:)'>0)>1))
    overlaps_lines=find(sum(node_tmp(:,:)'>0)>1);
    % choosing the overlaps nodes according to the population of that node.
    % if the it has lowest population we choose the node for that one or if
    % they are similar in poulation chose one of them randomly.
    for i=1:size(overlaps_lines,2)
         overlapchek_tmp{i}=check_overlapping(node_tmp,overlaps_lines(i));
         t_over=find((min(overlapchek_tmp{i}(:,2))==overlapchek_tmp{i}(:,2))==1);
         node_tmp(overlaps_lines(i),:)=node_tmp(overlaps_lines(i),:).*...
             (node_tmp(overlaps_lines(i),:)==overlapchek_tmp{i}(t_over(1),1)); 
    end
    if size(find(sum(node_tmp(:,:)'>0)>1),2)==0
        disp('No overlaps');
    end
    final_node=[0:size(node_tmp,1)-1; sum(node_tmp(:,:)')]';
    file_to_write=[root '/all_electrods_FS_LR.paint'];
    fid=fopen(file_to_write,'w');
    for i=1:size(pp,2)
         fprintf(fid,[ pp{i} '\n']);
    end
    dlmwrite(file_to_write, final_node, '-append','roffset', 0, 'delimiter', ' ','precision', 6); % adding noddes data to file
    fclose(fid);
    disp('Final FS_LR file is created: all_electrods_FS_LR.paint');
end

% cheking populations
function pop_ckeck=check_overlapping(node_tmp,overlaps_line)
    group_node_paint_tmp=node_tmp(overlaps_line,node_tmp(overlaps_line ,:)>0);
    group_node_paint=setdiff(group_node_paint_tmp,[]);
    %checking population for overlaping nodes
    for i=1:size(group_node_paint,2)
        pop_ckeck(i,:)=[group_node_paint(i) size(find(node_tmp(: ,group_node_paint(i))>0),1)];
    end
