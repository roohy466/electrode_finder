function C2=matching_ribbon_electrod(A,B)
% A extracted electrod is a electrod from seeg
% B the masked from ribbon file
p1=[];
n=size(A,2);k=1;
for i=1:n
    dis=find(sum(repmat(A(:,i),1,size(B,2)) ==B)==4);
    if size(dis,2)>0
       % disp(dis)
       
        p1(:,k)=B(:,dis(1));
        k=k+1;
    end
end
p2=[];k=1;
for i=1:n
    dis=find((sqrt(sum((repmat(A(:,i),1,size(B,2)) -B).^2)))<0.001);
    if size(dis,2)>0
       %disp(dis)
       p2=[p2 A(:,i)];
       k=k+1;
    end
end
if size(p1,2)>size(p2,2)
    C=p1;
else
    C=p2;
end
C2=clean_coordinates(C);