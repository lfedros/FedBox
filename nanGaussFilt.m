function dataFiltered = nanGaussFilt(data, varargin)

switch numel(varargin)
    case 0
        filtWidth = 3;
        filtSigma = 1;
        
    case 1
        filtWidth = varargin{1};
        filtSigma = 1;
    case 2
        filtWidth = varargin{1};
        filtSigma = varargin{2};
end

imageFilter=fspecial('gaussian',filtWidth,filtSigma);
dataFiltered = nanconv(data,imageFilter, 'nanout');

end