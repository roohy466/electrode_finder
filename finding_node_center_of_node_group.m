function [center_node, mean_coord, mean_std]=finding_node_center_of_node_group(node_number,subject_path,hemi,xfm_fr)

[node1 ver]=readsurface([subject_path '/surf/' hemi '.white']);
node1=node1+repmat(xfm_fr(1:3,4)',size(node1,1),1);
[node2 ver]=readsurface([subject_path '/surf/' hemi '.pial']);
node2=node2+repmat(xfm_fr(1:3,4)',size(node2,1),1);
if size(node_number,2)>=2
    coord1=mean(node1(node_number,:));
    coord1_std=std(node1(node_number,:));
    coord2=mean(node2(node_number,:));
    coord2_std=std(node2(node_number,:));
    mean_coord=mean([coord1;coord2]);
    mean_std=mean([coord1_std;coord2_std]);
    center_node=nearest_node_finder(mean_coord,subject_path,hemi,xfm_fr);
elseif size(node_number,2)==1
    coord1=node1(node_number,:);
    coord2=node2(node_number,:);
    mean_coord=mean([coord1;coord2]);
    mean_std=[0 0 0];
    center_node=nearest_node_finder(mean_coord,subject_path,hemi,xfm_fr);  
else
    coord1=[NaN NaN NaN];
    coord1_std=[NaN NaN NaN];
    coord2=[NaN NaN NaN];
    coord2_std=[NaN NaN NaN];
    mean_coord=[NaN NaN NaN];
    mean_std=[NaN NaN NaN];
    center_node=[NaN];
end
%finding the best node between pial and white surface
% if d1>d2
%     node_number=node_number_2;
%     coord_node=node2(node_number_2,:);
% else
%     node_number=node_number_1;
%     coord_node=node1(node_number_1,:);
% end
