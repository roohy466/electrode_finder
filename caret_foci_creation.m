function file_to_write=caret_foci_creation(subjName,elect_names,elect_mean,hemi)

% header for foci file
AA={'CSVF-FILE,0,,,,,,,,,,,,,,,,,,,,,,,,,'
    'csvf-section-start,header,2,,,,,,,,,,,,,,,,,,,,,,,,'
    'tag,value,,,,,,,,,,,,,,,,,,,,,,,,,'
    'Caret-Version,5.65,,,,,,,,,,,,,,,,,,,,,,,,,'
    'Date,2015-04-18T17:34:03,,,,,,,,,,,,,,,,,,,,,,,,,'
    ['comment,' subjName ',,,,,,,,,,,,,,,,,,,,,,,,,']
    'encoding,COMMA_SEPARATED_VALUE_FILE,,,,,,,,,,,,,,,,,,,,,,,,,'
    'csvf-section-end,header,,,,,,,,,,,,,,,,,,,,,,,,,'
    'csvf-section-start,Cells,27,,,,,,,,,,,,,,,,,,,,,,,,'
    'Cell Number,X,Y,Z,Section,Name,Study Number,Geography,Area,Size,Statistic,Comment,Structure,Class Name,SuMS ID Number,SuMS Repeat Number,SuMS Parent Cell Base ID,SuMS Version Number,SuMS MSLID,Attribute ID,Study PubMed ID,Study Table Number,Study Table Subheader,Study Figure Number,Study Figure Panel,Study Page Reference Number,Study Page Reference Subheader'};
addingline=[];
if strcmp(hemi,'rh')==1
    hem='right';
else
    hem= 'left';
end
for i=1:size(elect_mean,2)
    if size(elect_mean{i},1)>2
        X=elect_mean{i}(1);
        Y=elect_mean{i}(2);
        Z=elect_mean{i}(3);
    else
        X=0;Y=0;Z=0;
    end
    if i<10
        elect_name= strcat(elect_names ,'0',num2str(i));
    else
        elect_name= strcat(elect_names ,num2str(i));
    end
    addingline{i}= [num2str(i-1) ',' num2str(X) ',' num2str(Y) ',' num2str(Z) ',-1,' ...
        elect_name  ',-1,,,0.0,,,' hem ',,-1,-1,-1,-1,-1,-1,0,,,,,,'];
end


file_to_write=[hemi '_' elect_names '_MNRec.foci'];
fid=fopen(file_to_write,'w');
for a=1:size(AA,1)
    fprintf(fid,[ AA{a} '\n']);  % to create header file for foci file
end
for a=1:size(addingline,2)
    fprintf(fid,[ addingline{a} '\n']); % adding the data to foci file
end
fprintf(fid,'csvf-section-end,Cells,,,,,,,,,,,,,,,,,,,,,,,,,');
fclose(fid);