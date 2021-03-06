function mat_transformation=new_transformation_matrix(file)
% transformation matrix will be [a1 b1 c1 d1; a2 b2 c2 d2; a3 b3 c3 d3 ; 0 0 0 1];
% to slove we need to solve 4 different from 3 different X Y Z;
mat_file=importdata(file);
%a1*x1+b1*y1+c1*z1+d1=X1;
%a1*x2+b1*y2+c1*z2+d1=X2;
%a1*x3+b1*y3+c1*z3+d1=X3;
%a1*x4+b1*y4+c1*z4+d1=X4;
% x1(1:3)=[x1 y1 z1];
% x2(1:3)=[x2 y2 z2];
% x3(1:3)=[x3 y3 z3];
% x4(1:3)=[x4 y4 z4];
% X(1)=[X1 X2 X3 X4]; 
% X(2)=[Y1 Y2 Y3 Y4]; 
% X(3)=[Z1 Z2 Z3 Z4]; 
x1=mat_file(1,1:3);
x2=mat_file(2,1:3);
x3=mat_file(3,1:3);
x4=mat_file(4,1:3);
X(1,:)=mat_file(:,4)';
X(2,:)=mat_file(:,5)';
X(3,:)=mat_file(:,6)';
for i=1:3
    answer_mat(i,:)=solve(x1,x2,x3,x4,X(i,:));
end
mat_transformation=[answer_mat; 0 0 0 1];
end

function answer=solve(x1,x2,x3,x4,X)
% by subtracting first from the others we have:
%a1*(x2-x1)+b1*(y2-y1)+c1*(z2-z1)=X2-X1;
%a1*(x3-x1)+b1*(y3-y1)+c1*(z3-z1)=X3-X1;
%a1*(x4-x1)+b1*(y4-y1)+c1*(z4-z1)=X4-X1;
%then we can use this simple equation to sovle the a1 b1 c1 
A=[ x2-x1; x3-x1  ; x4-x1 ];
b=[X(2)-X(1); X(3)-X(1);X(4)-X(1)];
x=A\b;
d=X(1)-x1*x;
answer=[x' d];
end