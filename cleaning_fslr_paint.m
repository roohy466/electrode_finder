function outfile=cleaning_fslr_paint(subj,elect,hemi,file,subj_fslrMID)
 subj_fslrMID=subj_fslrMID(:,2:4);
[LeedData,LName]=read_caret_paint(file);

% finding the 
for i=1:size(LeedData,2)
    if sum(LeedData(:,i))>0
        cent_data=subj_fslrMID(LeedData(:,i)>0,:);
        if size(cent_data,1)>1
            cent_data=mean(cent_data);
        end
        node(i)=finding_the_node_center(cent_data,subj_fslrMID);
    else
        node(i)=NaN;
    end
end
outfile=paint_creator_from_nodes_FSLR(subj,elect,node,hemi);

% removing the columns with full zeros;

function node=finding_the_node_center(cent_data,subj_fslrMID)
dist=sqrt(sum((repmat(cent_data,size(subj_fslrMID,1),1)-subj_fslrMID).^2,2));
A=find(min(dist)==dist);
node=A(1);