function [problemistic_lead distances]=detect_ambigiuous_cluster(coord_file,nearest_node_center,node_recording_site)
sphere_coord_data=caret_coord_reader(coord_file);
nod_size=size(sphere_coord_data,1);
for i=1:size(node_recording_site,2)
    if size(node_recording_site{i},2)>0
        wrong_node=find(node_recording_site{i}>nod_size);
        coord_to_check=sphere_coord_data(node_recording_site{i},:);
        coord_center=sphere_coord_data(nearest_node_center(i),:);
        distances{i}=sqrt(sum(((coord_to_check-repmat(coord_center,size(coord_to_check,1),1)).^2)'))';
    else
        distances{i}=0;
    end
end
for i=1:size(node_recording_site,2)
    problemistic_lead(i)=max(distances{i});
end