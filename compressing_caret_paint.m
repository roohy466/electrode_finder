function [file_out, MaxColumn]=compressing_caret_paint(file,varargin)
% reading the file
p=1;paint_int=0;node_tmp_final=[];ElectrodeNames=[]; orignodesize=0;
for i=1:size(file,2)
    [PaintData,ElectrodData]=read_caret_paint(file{i});
    % checking the survived nodes
    orignodesize=size(find(PaintData(:)>0),1)+orignodesize;
    if size(file,2)>1
        node_tmp_final=[node_tmp_final (PaintData+paint_int).*(PaintData>0)];
        for j=1:size(ElectrodData,2)
            electnameTMP=ElectrodData{j}(strfind(ElectrodData{j},' '):end);
            ElectrodeNames{p}=[num2str(p) electnameTMP];
            disp(ElectrodeNames{p})
            p=p+1;
        end
        %size(PaintData,2)
        paint_int=size(ElectrodData,2)+paint_int;
    else
         node_tmp_final=PaintData;
         ElectrodeNames=ElectrodData;
    end
end

PaintDataChanging=sort(node_tmp_final,2,'descend');
disp(['Size of node in file: ' num2str(size(find(PaintDataChanging(:)>0),1))]);

% calculating a moving data for each row
MaxColumn=max(sum(node_tmp_final>0,2));
Paint_to_write=PaintDataChanging(:,1:MaxColumn);

if size(varargin,1)==0
    % if no varagin means one file is in input
    file_out=create_caret_multicolumns_paints(file{1},Paint_to_write,ElectrodeNames);
else
    file_to_write=[varargin{1} '/' varargin{2} '_MultiColumns_ AllElectrodes_fsLR.paint'];
    file_out=create_caret_multicolumns_paints(file_to_write,Paint_to_write,ElectrodeNames);
end




