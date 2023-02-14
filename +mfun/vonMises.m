function st_r = sizeTun(pars, stim_size)

% f(s) = R*[erf(s/sigma1 - k*erf(s/sigma2)];

R = pars(1); 
sigma1 = pars(2); % standard deviation 1 in degrees
sigma2 = pars(3); % standard deviation 1 in degrees
k = pars(4);
s = stim_size; % stimulus size in degrees

st_r = R*(erf(s/sigma1) - k* erf(s/sigma2));


end