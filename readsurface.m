function [verts,faces] = readsurface(filename)
% READSURFACE  Read FreeSurfer surface file
%
%  usage:
%         [vertices,faces] = readsurface(filename);
%
%   Example:
%      [verts,faces] = readsurface('lh.pial');
%      patch('vertices',verts,'faces',faces,'facecolor','w')
%

% written by Colin Humphries
%   Medical College of Wisconsin
%    6/2006


% Note: freesurfer uses big endian formating as far as I can tell.

fid = fopen(filename,'r','b');
if fid < 0
  error('Cannot open file');
end

fseek(fid,3,'bof');

ncount = 0;
while(1)
  tmp = fread(fid,1,'char');
  if tmp == 10
    if ncount == 0
      ncount = 1;
    else
      break;
    end
  else
    if ncount == 1
      ncount = 0;
    end
  end
end

numverts = fread(fid,1,'int32');
numfaces = fread(fid,1,'int32');

verts = fread(fid,[3,numverts],'float32')';

% Note: the face data is made to be 1-indexed to conform with matlab
% standards
faces = fread(fid,[3,numfaces],'int32')'+1;

fclose(fid);