function nodes_around=cluster_creator_around_a_node(node_cent,topologyfile)
topo_data=caret_topo_reader(topologyfile);
% it look at the nearest node to the source node and its trangulation
for i=1:size(node_cent,2);
    if node_cent(i)>0
        line_topo=find(sum(topo_data==repmat(node_cent(i)-1,size(topo_data)),2)>0);  % it should be minus one because the topo are based on 0:..n-1
        nodes_around_tmp=topo_data(line_topo,:);
        nodes_around{i}=setdiff(nodes_around_tmp(:),[]);
    end
end