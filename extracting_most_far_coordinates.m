function [A,B,MaxDist]=extracting_most_far_coordinates(extracted_electrod_shifted)
LenghtMat=size(extracted_electrod_shifted,2);
MatDevision=300;NumberofNode=0;
while floor(LenghtMat/MatDevision)==0  && NumberofNode<20
   MatDevision=MatDevision/3;
   NumberofNode=length(1:floor(LenghtMat/MatDevision):LenghtMat);
end
% cheking only for 300 points
LenghtMatCheck=1:floor(LenghtMat/MatDevision):LenghtMat;
Subextracted_electrod_shifted=extracted_electrod_shifted(:,LenghtMatCheck);
q=0;
for i=LenghtMatCheck
    q=q+1;
    distCalc(q,:)=sum((repmat(extracted_electrod_shifted(:,i),1,length(LenghtMatCheck))'...
        -Subextracted_electrod_shifted').^2,2)';
end

TotDist=distCalc.*triu(ones(size(distCalc,1)));
[A,B]=ind2sub(size(distCalc),find(max(TotDist(:))==TotDist));
MaxDist=max(TotDist(:));