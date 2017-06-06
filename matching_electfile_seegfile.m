function [message, electod_leeds]=matching_electfile_seegfile(elect_names,electrod_coordiantes,electod_leeds)

% cheking the coordinates does not have any similar electrodes
Seeglistsize=size(electrod_coordiantes,1);
 for i=1:Seeglistsize
   equality=sum((electrod_coordiantes==repmat(electrod_coordiantes(i,:),Seeglistsize,1)),2)==3;  
   size_equal=sum(sum(equality));
   if size_equal==1
   elseif size_equal>=2
      linesEquality=elect_names(floor(find(equality(:,1))'))';
       message='ERROR, the SEEGlist.fcsv or acsv files has a reapeated electrodes';
       %disp(message);
       disp(['Extra electrode is ==> ' linesEquality(2) ]);
       disp(['Remove it from the data']);
       return;
   end
 end
 % chekcing if two files have the same order  the manin is elect_names and
 % electod_leeds will adapt accordingly
if size(elect_names,1)/2==size(electod_leeds.data,1)
 for i=1:size(elect_names,1)/2
     if iscolumn(electod_leeds.textdata)==1
        data_tmp=cell2mat(electod_leeds.textdata');
        data_tmp=data_tmp(isletter(data_tmp));
     else
         data_tmp=cell2mat(electod_leeds.textdata);
          data_tmp=data_tmp(isletter(data_tmp));
     end
     data_tmp=data_tmp';
     order(i)=strfind(data_tmp(:,1)',elect_names(2*i));
     elect_orig(i,:)=elect_names(2*i);
 end
 diff_calc=max(order)-size(electod_leeds.data,1);
 order= order-diff_calc;
 electod_leeds.textdata=electod_leeds.textdata(order);
 electod_leeds.data=electod_leeds.data(order,:);
 message='OK';
else
    if size(elect_names,1)/2>size(electod_leeds.data,1)
        message='ERROR, the XLS or seeg_leeds.txt files has more electrodes than SEEGlist or acsv files';
    else
        message='ERROR, the XLS or seeg_leeds.txt files has less electrodes than SEEGlist or acsv files';
    end
   %disp(message);
end
 
 