function nearest_node_cleaned=...
    cleaning_leed_cluster( nearest_node_cleaned,overlap_groups,original_mean_center_node,recording_site)

for i=1:size(overlap_groups,2)
    if size(setdiff(nearest_node_cleaned,[0]),2)~=sum(nearest_node_cleaned>0)
        for j=1:size(overlap_groups{i},2) 
           size_cluster(j)=length( recording_site{overlap_groups{i}(j)});
        end
        node_to_change=overlap_groups{i}(max(size_cluster)>size_cluster);
        nearest_node_cleaned(node_to_change)=original_mean_center_node(node_to_change);
    end
end