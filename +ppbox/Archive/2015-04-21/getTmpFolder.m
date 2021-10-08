function str = getTmpFolder()

% This location will be used to keep all the processed data of the ppbox
% package
% Make sure you have enough space for all the processed files there
% Do not use network drives, this will slow down the process. If you have
% SSD - use it, it will make things faster. The ppbox code tries to be
% memory-efficient (this is required for large datasets), which means it is
% writing to disk more than minimally needed.

str = 'C:\Temp2p\';

[~, hostname] = system('hostname');
hostname = hostname(1:end-1);

switch hostname
    case 'ZERO'
        str = 'G:\Processing\';
    case 'zpike'
        str = 'C:\Users\Federico\Documents\Data\2P';
    case 'zigzag'
        str = 'F:\elad\Tmp';
    case 'zunder'
        str = 'J:\Processing\';
end


