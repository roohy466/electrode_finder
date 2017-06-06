%psnew
%
%	Open a matrix as a new document in Photoshop.
%
% -Usage-
%	psnew(im, varargin)
%
% -Inputs-
%	im		a logical, integer, or floating-point image
%	varargin:
%	  mask		alpha mask
%	  type		target type: uint8, uint16, float	
%	  'name'	optional name for file
%	  'auto'	auto scale
%
% -Outputs-
%	none
%
% Last Modified: 05/15/2009
function psnew(im, varargin)
	
	if nargin < 1
		error('Insufficient number of input arguments.');
	end

	[settings,alpha] = unpackargs(im, varargin);

	[im,outa] = autoscale(im, alpha, settings);

	openimage(im, outa, settings);

	% Remove background if alpha is set
	if ~isempty(outa)
		removebackground();
	end
end

%
%
%
function [settings,alpha] = unpackargs(im, args)

	if ~isnumeric(im) && ~islogical(im)
		error('first argument must be an image');
	end

	[ydim,xdim,zdim] = size(im);

	nargs = numel(args);

	% Only autoscale floating-point images by default
	settings.auto = isfloat(im);

	% Default type is same as image for int types
	% uint16 for float types
	if isfloat(im)
		settings.type = 'uint16';
	else
		settings.type = class(im);
	end
	settings.name = 'undefined';

	typeisgiven  = false;
	scaleisgiven = false;

	alpha = [];
	k = 0;
	while k < nargs
		k = k + 1;
		arg = args{k};
		if isnumeric(arg) || islogical(arg)
			sz = size(arg);
			if numel(sz) > 2
				error('alpha mask must be grayscale');
			end

			if any(sz(1:2) ~= [ydim xdim])
				error('alpha mask must be the same size as the image');
			end
			alpha = arg;
			continue;
		end

		if ~ischar(arg)
			error('element in varargin is not a string');
		end

		switch lower(arg) 
		case {'auto','scale'}
			settings.auto = true;
			scaleisgiven  = true;
		case {'noauto','noscale'}
			settings.auto = false;
			scaleisgiven  = true;
		case {'uint8','uint16','double','single','float'}
			settings.type = arg;
			typeisgiven = true;
		case 'name'
			if k >= nargs || ~ischar(args{k+1})
				error('name not specified');
			end
			settings.name = args{k+1};
			k = k + 1;

		otherwise
			warning('Invalid psnew option: ''%s''.',arg)
		end

	end

	% Floating point images are automatically autoscaled
	% converted to 8-bit if no preferences are given.
	%
	% If a type is specified but scaling is not specified, 
	% the image is not autoscaled.
	if typeisgiven & ~scaleisgiven
		settings.auto = false;
	end

end

%
% Scale image
%
function [out,outa] = autoscale(im, alpha, settings)
	out = im2double(im);
	if settings.auto
		mn = double(min(im(:)));
		mx = double(max(im(:)));
		out = (out - mn)/(mx - mn);
	end

	outa = im2double(alpha);
	if strcmp(settings.type,'logical') || strcmp(settings.type,'uint8')
		out  = im2uint8(out);
		outa = im2uint8(alpha);
	%
	% Photoshop's 16-bit format is only 15-bits
	%
	elseif strcmp(settings.type,'uint16')
		out  = im2uint16(0.5*out);
		outa = im2uint16(0.5*alpha);
	else
		out  = im2single(out);
		outa = im2single(alpha);
	end

end

%
% Code copied from psnewdocmatrix.m
%
function openimage(img, alpha, settings)
	h = size(img);
	if length(h) > 2
		m = h(3);
		if m == 3
			m = 'rgb';
		elseif m == 4
			m = 'cmyk';
		else
			m = 'grayscale';
		end
	else
		m = 'grayscale';
	end

	w = h(2);
	h = h(1);

	ru = psconfig();

	if ~strcmp(ru, 'pixels')
		psconfig('pixels');
	end

	% create the doc
	psnewdoc(w, h, 'undefined', settings.name, m);

	% convert the mode, you need to go to 16 and then to 32
	if isa(img, 'uint16') || isfloat(img)
		psjavascriptu('activeDocument.bitsPerChannel = BitsPerChannelType.SIXTEEN');
	end

	if isfloat(img)
		psjavascriptu('activeDocument.bitsPerChannel = BitsPerChannelType.THIRTYTWO');
	end

	% set the pixels
	if ~isempty(alpha)
		psnewlayer();
		pssetpixels(alpha, 16);
	end
	pssetpixels(img);

	if ~strcmp(ru, 'pixels')
		psconfig(ru);
	end
end

%
%
%
function removebackground()

	pstext = 'try { var result = "";';
	pstext = [pstext 'app.activeDocument.backgroundLayer.remove();'];
	pstext = [pstext ' result = "OK";'];
	pstext = [pstext '}'];
	pstext = [pstext 'catch(e) { result = e.toString(); } '];
	pstext = [pstext 'result;'];

	psresult = psjavascriptu(pstext);

	if ~strcmp(psresult, 'OK')
		error(psresult);
	end

end

