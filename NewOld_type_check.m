function [data_type, message,node_existance]=NewOld_type_check(x1,y1,z1,coord_spm_orig,checkpoint)
data_type='old';
message='All electordes look fine';
if floor(size(x1,1)/2) > 3
    check_size=3;
else
    check_size=floor(size(x1,1)/2);
end

for i=1:floor(size(x1,1)/2)
    elect_line_coordinates_spm=...
        model_line_between_tip_tail(x1(2*i-1:2*i),y1(2*i-1:2*i),z1(2*i-1:2*i),0);
    node_existance(i)=...
        size(electrod_masking_general(coord_spm_orig,elect_line_coordinates_spm),2);
    if sum(node_existance==0 )>=check_size
        data_type='new';
        if checkpoint==2
            message='ERROR, something wrong with data';
        else
            message='All electordes look fine';
            return;
        end
    end
end




