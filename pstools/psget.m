%psget
%
%	Get an image from Photoshop
%
% -Usage-
%	[im,alpha] = psget(type,atype)
%
% -Inputs-
%	type	convert type to logical, uint8, uint16, single, or double
%	atype	get alpha channel, selection or quick mask
%
% -Outputs-
%	im
%	alpha
%
% Last Modified: 05/16/2009
function [im,mask] = psget(varargin)

	settings = unpackargs(varargin); 

	try
		pspixels = psgetpixels();
	catch
		error('cannot get pixels.');
	end

	im = convertim(pspixels, settings);

	if nargout > 1
		try
			psmask = psgetpixels(settings.alphacode);
		catch
			psmask = true(size(im,1),size(im,2));
		end

		mask = convertim(psmask, settings);
	end

end

%
%
%
function [settings] = unpackargs(args)

	nargs = numel(args);

	% Only autoscale floating-point images by default
	settings.type      = 'unspecified';
	settings.alphacode = 16;

	for k = 1 : nargs
		arg = args{k};

		if ~ischar(arg)
			error('element in varargin is not a string');
		end

		switch lower(arg) 
			case {'logical','uint8','uint16','double','single','float'}
				settings.type = arg;

			case {'alpha','transparency','trans'}
				settings.alphacode = 16;

			case {'selection','select','selectionmask'}
				settings.alphacode = 19;

			case {'quick','quick mask'}
				settings.alphacode = 'Quick Mask';

			otherwise
				warning('Invalid psget option: ''%s''.',arg)
		end

	end

end


%
%
%
function im = convertim(pspixels, settings)

	type = settings.type;

	% For 16-bit images, multiply by 2
	% because Photoshop only uses 15-bits, 
	% while MATLAB uses all 16
	if strcmp(class(pspixels),'uint16')
		pspixels = im2double(2*pspixels);
		if strcmp(type,'unspecified')
			type = 'uint16';
		end
	end

	% Convert type
	switch type
		case {'logical','binary'}
			im = im2bw(pspixels);
		case 'uint8'
			im = im2uint8(pspixels);
		case 'uint16'
			im = im2uint16(pspixels);
		case {'float','double'}
			im = im2double(pspixels);
		case 'single'
			im = im2single(pspixels);
		case 'unspecified'
			im = pspixels;
	end
end


