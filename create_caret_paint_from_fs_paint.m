function electrod_paint=create_caret_paint_from_fs_paint(subj,surc_folder,w_file1,w_file2,electtord_name,hemi)
  if strcmp(hemi,'rh')==1
    [ver fac]=readsurface([surc_folder '/surf/rh.white']); % extacting faces and verteces  depending on Hemisphier **** has to be correct1=;hmpr
  else
    [ver fac]=readsurface([surc_folder '/surf/lh.white']); % extacting faces and verteces  depending on Hemisphier **** has to be correct1=;hmpr
  end 
  fac=fac-1; 
  A.textdata={'BeginHeader';
    'Caret-Version 5.64';
    'Date 2012-03-10T15:08:35';
    'comment';
    'encoding ASCII';
    'pubmed_id ';
    'EndHeader';
    'tag-version 1';
    'tag-number-of-nodes ' ;
    'tag-number-of-columns 1';
    'tag-title'; 
    'tag-number-of-paint-names 2';
    'tag-column-name 0 few_forced-MPA-lh';
    'tag-column-comment 0'; 
    'tag-column-study-meta-data 0 ';
    'tag-BEGIN-DATA';
    '0 ???';
    '1 FST'};
  A.textdata{3}=['Date  ' date] ;
  nodes(:,1)=0:max(max(fac)); % all nodes for left hemisphere
  nodes(:,2)=0;
  % readding the first fs paint file
  tmp_lab_tmp=importdata(w_file1,' ',2);
  tmp_lab=tmp_lab_tmp.data;
  nodes(tmp_lab(:,1)+1,2)=1;
  % reading the second fs paint file
  tmp_lab_tmp=importdata(w_file2,' ',2);
  tmp_lab=tmp_lab_tmp.data;
  nodes(tmp_lab(:,1)+1,2)=1;
  A.textdata{13}=['tag-column-name 0 ' subj '_' electtord_name '-' hemi '_overlay'];
  A.textdata{9}=['tag-number-of-nodes ' num2str(size(nodes,1))];
  A.textdata{18}=['1 ' subj '_' electtord_name '-' hemi '_overlay']; 
  A.textdata{17}='0 ???'; 
  file_to_write=[hemi '.' electtord_name '.paint'];
  fid=fopen(file_to_write,'w');
  for a_2=1:18
      fprintf(fid,[ A.textdata{a_2} '\n']);  % to create header file for paint file
  end
  dlmwrite(file_to_write, nodes, '-append','roffset', 0, 'delimiter', ' ','precision', 6); % adding noddes data to file
  fclose(fid);
  disp(['Electrod ' file_to_write ' is created']);
  electrod_paint=file_to_write;
        
