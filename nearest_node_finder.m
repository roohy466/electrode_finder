% finding the nearest coordinate to the node on pial or white
function [ node_number coord_node]=nearest_node_finder(elect_xyz,subject_path,hemi,xfm_fr)
[node1 ver]=readsurface([subject_path '/surf/' hemi '.white']);
node1=node1+repmat(xfm_fr(1:3,4)',size(node1,1),1);
diff=node1-repmat(elect_xyz,size(node1,1),1);
diff_dist=sqrt(diff(:,1).^2+diff(:,2).^2+diff(:,3).^2);
node_number_10=find(diff_dist==min(diff_dist));
% if two or more point has the this character
node_number_1=node_number_10(1);
d1=sum(((repmat(elect_xyz,size(node_number_1))-node1(node_number_1,:)).^2)');
[node2 ver]=readsurface([subject_path '/surf/' hemi '.pial']);
node2=node2+repmat(xfm_fr(1:3,4)',size(node2,1),1);
diff=node2-repmat(elect_xyz,size(node2,1),1);
diff_dist=sqrt(diff(:,1).^2+diff(:,2).^2+diff(:,3).^2);
node_number_20=find(diff_dist==min(diff_dist));
node_number_2=node_number_20(1);
d2=sum(((repmat(elect_xyz,size(node_number_1))-node2(node_number_2,:)).^2)');
%finding the best node between pial and white surface
if d1>d2
    node_number=node_number_2;
    coord_node=node2(node_number_2,:);
else
    node_number=node_number_1;
    coord_node=node1(node_number_1,:);
end
