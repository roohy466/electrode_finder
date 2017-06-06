function [electrod_voxes_out]=...
    model_the_nodes_v2(node_existance_rotated_zy,number_of_leeds,type_of_electrod)

%plot3(node_existance_rotated_zy(:,1),node_existance_rotated_zy(:,2),node_existance_rotated_zy(:,3))
min_tip=min(node_existance_rotated_zy(1,:));
node_shifted=node_existance_rotated_zy-...
    repmat([min_tip; 0 ;0],1,size(node_existance_rotated_zy,2));

if isnan(type_of_electrod(2))==1
    estimated_lenght=number_of_leeds*2+(number_of_leeds-1)*1.5+1;
    for i=2:number_of_leeds+1
        estimated_zeros(i)=(i-1)*2+(i-1)*1.5-0.75;
    end
    electrod_voxes_out=zeros(1,number_of_leeds+1);
else
    % here the number of electrodes plus the distance between them 11 is
    % distance between the groups of electrodes
    number_of_leedsTot=number_of_leeds*type_of_electrod(1)*type_of_electrod(2);
    estimated_lenght= number_of_leedsTot*2+( number_of_leedsTot-3)*1.5+(max(type_of_electrod)-1)*11+1;
    distbetween=0;
    for i=2: number_of_leedsTot+1
        intTest=((i-1)/max(number_of_leeds))==floor(i/max(number_of_leeds)) ;
        if  intTest==1 && floor(i/max(number_of_leeds))< max(type_of_electrod)
            distbetween=distbetween+11-1.75;
        end
        estimated_zeros(i)=(i-1)*2+(i-1)*1.5-0.75+distbetween;
    end
    electrod_voxes_out=zeros(1,number_of_leedsTot+1);
end

electrod_voxes_out(1:end)=estimated_zeros(1:end)+min_tip; %% here is the data out
% cheking the convolution of the electrod
%%% under development
conv=min(node_shifted(1,:)):(estimated_lenght/100):max(node_shifted(1,:));
for i=1:size(conv,2)-1
    numbVox(i)=size(find((node_shifted(1,:)>conv(i)) .* (node_shifted(1,:)<conv(i+1))),2);
end
zero_estmated(1:19)=1;
%plot(electrod_voxes_out,zero_estmated,'*');hold
zero_elect=zeros(size(node_existance_rotated_zy(1,:)));
node_related=zero_elect+1;

