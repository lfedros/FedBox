function PlotDisplacedLFRDev(tt, signals, space, color)
% signals are nT X nSignals
[nT, nS] = size(signals);

if nargin <4
    color = lines(nS);
end
if isempty(tt)
    tt = 1: nT;
end

top = max(signals(:));
bot = min(signals(:));
%% plot
disp = (0:nS-1);
disp = sort(disp,'descend') *space;

for is = 1: nS
plot(tt, signals(:, is)+ disp(is), 'Color', color(is, :)); hold on
end
xlim([min(tt), max(tt)])
ylim([0 + bot - space, max(disp) + top])

end