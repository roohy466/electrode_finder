function [electrod_voxes,no_data]=...
    modelling_electrod(node_existance_rotated_zy,number_of_leeds,type_of_electrod,hemi)
nodes=node_existance_rotated_zy;
if strcmp(hemi,'rh')==1
    [electrod_voxes]= model_the_nodes_v2(nodes,number_of_leeds,type_of_electrod);
elseif strcmp(hemi,'lh')==1
    nodes(1,:)=-nodes(1,:);
    [electrod_voxes]= model_the_nodes_v2(nodes,number_of_leeds,type_of_electrod);
    electrod_voxes=-electrod_voxes;
end
if size(electrod_voxes)==0
    no_data='yes';
else
    no_data='no';
end

