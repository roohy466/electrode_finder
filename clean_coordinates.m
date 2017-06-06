function coords=clean_coordinates(coord0)
k=0;t=1;
number_all=1:size(coord0,2);
while t~=0 && k<size(coord0,2)
    k=k+1;
    coord_to_check=repmat(coord0(:,k),1,size(coord0,2));
    group_checked=find(sum(coord0==coord_to_check)==size(coord0,1));
    number_all=setdiff(number_all,group_checked(2:end));
    coord0=coord0(:,number_all);
    number_all=1:size(coord0,2);
    %disp(size(coord0,2))
    if size(coord0,2)==k
        t=0;
    end
end
coords=coord0;