function histContour(xcol, val, color, pad0)
%first 2 inputs are the same you would pass to the function 'bar'

if nargin <4
pad0 = 0;
end
colwidth = mean(diff(xcol));
x = numel(xcol)*2; 
y = numel(xcol)*2; 
for icol = 1:numel(xcol)
    x(2*icol - 1) = xcol(icol)-colwidth/2;
    x(2*icol) = xcol(icol)+colwidth/2;
    y(2*icol - 1) = val(icol);
    y(2*icol) = val(icol);
end

if pad0
x = [x(1), x, x(end)];
y = [0, y, 0];
end

plot(x, y, 'Color', color, 'Linewidth', 1)

end
