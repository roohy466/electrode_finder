function VerSurfSize=vertex_surfacesize(SubName)
path=pwd;
% generating the VD
initialpath=fullfile(path,SubName, 'fs_LR_output/InitialMesh/');
[OrigSurfsize,MniSurfsize]=generate_surface_file(initialpath);
VD=double(OrigSurfsize)./double(MniSurfsize);
%VDr=resample(double(VD),163842,length(VD));
VDr = interp1(1:length(VD),VD,1:length(VD)/163842:length(VD));
VDr(163842)=VDr(163841);
VDr=VDr';
% generating the SA
fslrpath=fullfile(path,SubName, 'fs_LR_output/');
[OrigSurfsize,MniSurfsize]=generate_surface_file(fslrpath);
SA=MniSurfsize;
%final calculation
VerSurfSize=SA.*VDr;

function [OrigSurfsize,MniSurfsize]=generate_surface_file(path)
topofile=ls([path '*topo.gii']);
topofiletmp=textscan(topofile,'%s');
topofile=topofiletmp{1}{1};
% mni coord
mnicoordfile=ls([path '*midthickness*mni*.coord.gii']);
mnicoordfile=mnicoordfile(1:end-1);
outFile=SurfaceMaker(mnicoordfile,topofile);
outsurfsizeMNI=export(gifti(outFile));
MniSurfsize=outsurfsizeMNI.cdata; % final surface size per vertex 
%orig coord
origcoordfile=ls([path '*midthickness*orig*.coord.gii']);
origcoordfile=origcoordfile(1:end-1);
outFile=SurfaceMaker(origcoordfile,topofile);
outsurfsizeORIG=export(gifti(outFile));
OrigSurfsize=outsurfsizeORIG.cdata; % final surface size per vertex 

function metric_surface=SurfaceMaker(coordfile,topofile)
surf_file_name=[coordfile(1:end-9) 'surf.gii'];
metric_surface=[coordfile(1:end-9) 'vertexsize.func.gii'];
unix(['caret_command -file-convert -sc -is CARET ' ...
    coordfile ' ' topofile ' -os GS ' surf_file_name ]);
disp(surf_file_name);
surf_file_name=ls(surf_file_name);
unix(['wb_command -surface-vertex-areas ' surf_file_name(1:end-1) ' ' metric_surface]);


