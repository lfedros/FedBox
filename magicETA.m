function [ETAmat, ETA, ETAse, window] = magicETA(t, signal, etaT, periT)
% t are the timestamps of each sample in signal. etaT are the event
% timestasmps you want to trigger the average to, periT is a 2 element
% vector that specifies the window around etaT to be considered

%% one line magic peri-stimulus triggered average, courtesy of CB wisdom
if numel(periT) ==2
    window = linspace(periT(1), periT(2), range(periT)*10);
else
    window = periT;
end

bsl = periT(periT <0);
% ETAmat = interp1(t,signal,bsxfun(@plus,window,etaT'));
% [nStim, nRep] = size(etaT);
newT = permute(etaT, [2, 3, 1]);

ETAmat = interp1(t,signal,bsxfun(@plus,window,newT));
ETAbsl = prctile(interp1(t,signal,bsxfun(@plus,bsl,newT)), 50,2);
ETAmat = bsxfun(@minus,ETAmat, ETAbsl);

%% compute median resp and se
ETA = squeeze(mean(ETAmat,1));
ETAse = squeeze(std(ETAmat,1,1)/sqrt(size(etaT,2)));

% %% plotting
% figure
% shadePlot(window, ETA(:,5), ETAse(:,5),'b');
end