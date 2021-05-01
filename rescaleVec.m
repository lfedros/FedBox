function scaled = rescaleVec(xx, top, bot)
%% stretches/compresses the vector xx between the new specified max and min values (top/bot)

dims = size(xx);

xx = xx(:);

if nargin <2
    bot = 0;
    top = max(xx) - min(xx);
end

if top == bot
    scaled = xx;
else
    
    
    scaled = ((xx -min(xx))*(top-bot)/(max(xx)-min(xx))) + bot;
end

scaled = reshape(scaled, dims);
end