function signal = interpNaN(signal, method)
if nargin <2
    method = 'linear';
end

nanp = isnan(signal);
gdp = find(~nanp);
signal = signal(gdp);
signal = interp1(gdp, signal, 1:numel(nanp),method);

end