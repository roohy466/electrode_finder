function border=border_creaor(A, B)
% A is electrod coorinates
% B is zeors electrods
% x_electrod this coming from Vox_electrod
X=B;
min_y=min(A(2,:));
max_y=max(A(2,:));
min_z=min(A(3,:));
max_z=max(A(3,:));
Z=min_z:0.4:max_z;
Y=min_y:0.4:max_y;
n=1;
for i=1:size(X,2)
    for j=1:size(Y,2)
        for k=1:size(Z,2)
            border(:,n)=[X(i);Y(j);Z(k)];
            n=n+1;
        end
    end
end