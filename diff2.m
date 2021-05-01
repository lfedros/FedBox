function d2x = diff2(x)

sx = size(x); 

bkw = x(3:end,:);
fwd = x(1:end-2,:);

d2x = cat(1, zeros(1, sx(2)), bkw-fwd, zeros(1, sx(2)));

end