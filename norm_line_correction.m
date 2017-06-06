function [norm_line_corrected, message]=norm_line_correction( extracted_electrod_shifted,  norm_line)
message='OK';
number_norm=size(norm_line,2);
test_check=0;
for i=1:round(number_norm/2)-1
    tmp_ck(i)=min(sum((extracted_electrod_shifted - ...
        repmat(norm_line(:,i),1,size(extracted_electrod_shifted,2))).^2));
    if tmp_ck(i)<1 && test_check==0;
        first_check=i+1;
        test_check=1;
    end
end
try 
    first_check;
catch 
    message='Error in tip or tail,this electrode will be ignored';
    norm_line_corrected=NaN;
    disp(message)
    return;
end 

clear tmp_ck
test_check=0;
for i=number_norm-1:-1:round(number_norm/2)
    tmp_ck(i)=min(sum((extracted_electrod_shifted - ...
        repmat(norm_line(:,i),1,size(extracted_electrod_shifted,2))).^2));
    if tmp_ck(i)<1 && test_check==0;
        last_check=i;
        test_check=1;
    end
end

testcheck_tmp=find(tmp_ck==min(tmp_ck(tmp_ck>0)));
try 
    last_check;
catch 
    last_check=testcheck_tmp;
end 
tt_tmp_ckeck_norm_1=(sum((extracted_electrod_shifted - ...
    repmat(norm_line(:,first_check),1,size(extracted_electrod_shifted,2))).^2));
tt_tmp_ckeck_norm_2=(sum((extracted_electrod_shifted - ...
    repmat(norm_line(:,last_check),1,size(extracted_electrod_shifted,2))).^2));
tail_population=extracted_electrod_shifted(:,tt_tmp_ckeck_norm_1<8);
tip_population=extracted_electrod_shifted(:,tt_tmp_ckeck_norm_2<8);
if  size(tail_population,2)>=2
    tail_coord=mean(tail_population,2);
else
    tail_coord=tail_population;
end
if  size(tip_population,2)>=2
    tip_coord=mean(tip_population,2);
else
    tip_coord=tip_population;
end
norm_line_corrected=[tip_coord tail_coord];