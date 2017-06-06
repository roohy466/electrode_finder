function [file_to_write]=paint_creator_from_coords_cluster(subj,subject_path,elect_name,nearest_node,hemi,suffix)
% nearest node should be a cluster of nodes in a cell format.
if strcmp(hemi,'lh')
    hemisp='left';
else
    hemisp='right';
end
[node ver]=readsurface([subject_path '/surf/' hemi '.white']);
[node_pial ver]=readsurface([subject_path '/surf/' hemi '.pial']);
AA={'BeginHeader' ...
'Caret-Version 5.64' ...
'Date  '  ...
'comment' ...
'encoding ASCII' ...
'pubmed_id '...
'EndHeader'...
'tag-version 1'...
'tag-number-of-nodes ' ...
'tag-number-of-columns 1'...
'tag-title'...
'tag-number-of-paint-names '  ...
'tag-column-name 0 '  ...
'tag-column-comment 0' ...
'tag-column-study-meta-data 0 ' ...
'tag-BEGIN-DATA' ...
'0 ???'};

AA{3}=['Date  ' num2str(date) ]; 
AA{9}=['tag-number-of-nodes ' num2str(size(node,1))];
AA{12}=['tag-number-of-paint-names ' num2str(size(nearest_node,2)+1)]; 
AA{13}=['tag-column-name 0 '  subj '_' elect_name '_' hemi '_cluster_of_nodes'] ;
start_line=size(AA,2);
nodes=[(0:size(node,1)-1)' zeros(size(node,1),1)];
for i=1:size(nearest_node,2)
    if i<10
        number_nod=['0' num2str(i)];
    else
        number_nod= num2str(i);
    end
    if size(nearest_node{i},2)>0
        nodes(nearest_node{i},2)=i;
        %coordinates(i,:)=node_pial(nearest_node{i},:);

        AA{start_line+i}=[num2str(i) ' '   elect_name '_' number_nod '_' subj '_cluster'];
    else
        AA{start_line+i}=[num2str(i) ' '   elect_name '_' number_nod '_' subj '_cluster_NO'];
    end
end
file_to_write=[hemi '.' elect_name '_cluster' suffix '.paint'];
fid=fopen(file_to_write,'w');
  for a_2=1:size(AA,2)
      fprintf(fid,[ AA{a_2} '\n']);  % to create header file for paint file
  end    
dlmwrite(file_to_write, nodes, '-append','roffset', 0, 'delimiter', ' ','precision', 6); % adding noddes data to file
fclose(fid);
