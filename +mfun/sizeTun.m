function st_r = sizeTun(pars, stim_size)

% f(s) = R*[erf(s/sigma1 - k*erf(s/sigma2)];

R = pars(1); % amplitude of response
sigma1 = pars(2); % standard deviation 1 in degrees
sigma2 = pars(3); % standard deviation 1 in degrees
k = pars(4); % not sure what this is for
b = pars(5); % baseline
s = stim_size; % stimulus size in degrees

st_r = R*(erf(s/sigma1) - k* erf(s/sigma2)) +b;


end