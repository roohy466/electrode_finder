function [file_to_write coordinates]=paint_creator_from_foci_coord(subj,subject_path,elect_name,nearest_node,hemi)
if strcmp(hemi,'lh')
    hemisp='left';
else
    hemisp='right';
end
coordinates=zeros(size(nearest_node,2),3);
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
['tag-number-of-columns ' num2str(size(nearest_node,2))]...
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
AA{13}=['tag-column-name 0 ' subj '_' elect_name '_' hemi '_one_node'] ;
start_line=size(AA,2);
nodes=[(0:size(node,1)-1)' zeros(size(node,1),size(nearest_node,2))];
for i=1:size(nearest_node,2)
    if i<10
        number_nod=['0' num2str(i)];
    else
        number_nod= num2str(i);
    end
    if nearest_node(i)>0
        nodes(nearest_node(i),i+1)=i;
        coordinates(i,:)=node_pial(nearest_node(i),:);
        AA{start_line+i}=[num2str(i) ' '  subj '_' elect_name '_' number_nod ];
    else
        AA{start_line+i}=[num2str(i) ' '  subj '_' elect_name '_' number_nod   '_0_node'];
    end
end
file_to_write=[hemi '.' elect_name '_focitype.paint'];
fid=fopen(file_to_write,'w');
  for a_2=1:size(AA,2)
      fprintf(fid,[ AA{a_2} '\n']);  % to create header file for paint file
  end    
dlmwrite(file_to_write, nodes, '-append','roffset', 0, 'delimiter', ' ','precision', 6); % adding noddes data to file
fclose(fid);
