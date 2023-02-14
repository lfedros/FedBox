function st_r = sizeTun(pars, stim_size)
% modified from Dipoppa et al., Neuron, 2018 


% f(s) = R*[erf(s/sigma1 - k*erf(s/sigma2)];

R = pars(1); % amplitude of response
sigma1 = pars(2); % standard deviation 1 in degrees
sigma2 = pars(3); % standard deviation 1 in degrees
b = pars(4); % baseline
k = pars(5); % allows to switch the sign of the subtraction. Besides the sign, I think it trades off with the sigmas
s = stim_size; % stimulus ssize in degrees

st_r = R*(erf(s/sigma1.^2) - k*erf(s/sigma2.^2)) +b;


end