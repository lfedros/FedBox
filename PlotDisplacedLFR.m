function PlotDisplacedLFR(tt, signals, space, color)
% signals are nT X nSignals
[nT, nS] = size(signals);

if nargin <4
    color = hsv(nS);
    color(:,1) = 0;
elseif size(color,1) ==1
    color = repmat(color, nS,1);
end


if isempty(tt)
    tt = repmat(makeVec(1:nT), 1, nS);
elseif numel(tt) == nT
    tt = repmat(makeVec(tt), 1, nS);
end

top = max(signals(:));
bot = min(signals(:));
%% plot
disp = (0:nS-1);
disp = sort(disp,'descend') *space;

for is = 1: nS
plot(tt(:, is), signals(:, is)+ disp(is), 'Color', color(is, :), 'LineWidth', 1); hold on
end
xlim([min(tt(:)), max(tt(:))])
ylim([0 + bot - space, max(disp) + top])
formatAxes
xlabel('Time')

end