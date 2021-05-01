function newmap = gBlues(n, gamma)

if nargin < 1
    n = 101;
end

if nargin < 1
    gamma = 1;
end

bottom = [0 0 0.5];
botmiddle = [0 0.5 1];
middle = [1 1 1];

new = [bottom; botmiddle; middle];

oldsteps = linspace(0, 1, 3);
newsteps = linspace(0, 1, n);

for i=1:3
    % Interpolate over RGB spaces of colormap
    newmap(:,i) = min(max(interp1(oldsteps, new(:,i), newsteps)', 0), 1);
end

newmap = newmap.^gamma;
end