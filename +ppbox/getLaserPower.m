function laserPw = getLaserPower(info)
% 2019 LFR created. Works with ScanImage 2018

allTiffInfo = dir([info.folder2p, filesep, info.basename2p, '*.tif']);
tiffName = allTiffInfo(1).name;
filename=fullfile(info.folder2p, tiffName);
[~, header]= loadFramesBuff(filename, 1, 1, 1);
hh=header{1};

str = hh(strfind(hh, 'hBeams.powers = '):end);
ind = strfind(str, 'SI');
basePw  = str2double(str(17 : ind(1)-1));

str = hh(strfind(hh, 'hBeams.lengthConstants = '):end);
ind = strfind(str, 'SI');
lengthConstant  = str2double(str(26 : ind(1)-1));


str = hh(strfind(hh, 'numFramesPerVolume = '):end);
ind = strfind(str, 'SI');
nPlanes  = str2double(str(22 : ind(1)-1));

str = hh(strfind(hh, 'stackZStepSize = '):end);
ind = strfind(str, 'SI');
stackZStepSize  = str2double(str(18 : ind(1)-1));

planesDepth = (0:nPlanes)*stackZStepSize;

% P = P0 * exp^((z-z0)/Lz)
laserPw = basePw*exp(planesDepth/lengthConstant);

end