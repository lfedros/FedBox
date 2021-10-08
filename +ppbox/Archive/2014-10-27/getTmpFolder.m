function str = getTmpFolder()
%GETTMPFOLDER Summary of this function goes here
%   Detailed explanation goes here

str = 'C:\Temp2p\';

[~, hostname] = system('hostname');
hostname = hostname(1:end-1);

switch hostname
    case 'ZERO'
        str = 'G:\Processing\';
    case 'zpike'
        str = 'C:\Users\Federico\Documents\Data\2P';
end


