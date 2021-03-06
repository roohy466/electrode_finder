function file_to_write=foci_creator(electrod_name,coordinates,hemi,suffix_name)
AA={'CSVF-FILE,0,,,,,,,,,,,,,,,,,,,,,,,,,' ...
'csvf-section-start,header,2,,,,,,,,,,,,,,,,,,,,,,,,' ...
'tag,value,,,,,,,,,,,,,,,,,,,,,,,,,' ...
'Caret-Version,5.65,,,,,,,,,,,,,,,,,,,,,,,,,' ...
'Date,2013-01-25T17:05:34,,,,,,,,,,,,,,,,,,,,,,,,,' ...
'comment,,,,,,,,,,,,,,,,,,,,,,,,,,' ...
'encoding,COMMA_SEPARATED_VALUE_FILE,,,,,,,,,,,,,,,,,,,,,,,,,' ...
'csvf-section-end,header,,,,,,,,,,,,,,,,,,,,,,,,,' ...
'csvf-section-start,Cells,27,,,,,,,,,,,,,,,,,,,,,,,,' ...
'Cell Number,X,Y,Z,Section,Name,Study Number,Geography,Area,Size,Statistic,Comment,Structure,Class Name,SuMS ID Number,SuMS Repeat Number,SuMS Parent Cell Base ID,SuMS Version Number,SuMS MSLID,Attribute ID,Study PubMed ID,Study Table Number,Study Table Subheader,Study Figure Number,Study Figure Panel,Study Page Reference Number,Study Page Reference Subheader' ...
'0,-57.400002,-38.099998,42.500000,-1,test,-1,,,0.000000,,,left,,-1,-1,-1,-1,-1,-1,0,,,,,,' ...
'csvf-section-end,Cells,,,,,,,,,,,,,,,,,,,,,,,,,'};
aa_end=AA{12};
% the order should be like
%  1, x, y ,z ,-1, name_foci , -1 ,,,0.000000,,,left or
%  right,,-1,-1,-1,-1,-1,-1,0,,,,,,';
if strcmp(hemi,'lh')
    hemisp='left';
else
    hemisp='right';
end
for i=1:size(coordinates,1)
    if sum(coordinates(i,:)==0)==3
        
    AA{10+i}=[num2str(i-1) ',' num2str(coordinates(i,1)) ',' num2str(coordinates(i,2))  ',' num2str(coordinates(i,3))  ...
        ',-1,' electrod_name '_' num2str(i) '_notgray',  ...
        ',-1,,,0.000000,,,' hemisp ',,-1,-1,-1,-1,-1,-1,0,,,,,,'];
    else
        AA{10+i}=[num2str(i-1) ',' num2str(coordinates(i,1)) ',' num2str(coordinates(i,2))  ',' num2str(coordinates(i,3))  ...
        ',-1,' electrod_name '_' num2str(i) ,  ...
        ',-1,,,0.000000,,,' hemisp ',,-1,-1,-1,-1,-1,-1,0,,,,,,'];
    end
end
AA{ size(AA,2)+1}=aa_end;

file_to_write=[hemi '.' electrod_name '_' suffix_name '.foci'];
fid=fopen(file_to_write,'w');
  for a_2=1:size(AA,2)
      fprintf(fid,[ AA{a_2} '\n']);  % to create header file for paint file
  end    
fclose('all');
%%% create the paint file to check the foci on the template
% here by using nearest node we create a paint file wich correspond to the
% nearest node. But it should be chec


