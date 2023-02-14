function r = vonMises(pars, alpha)

Dp = pars(1)*pi/180; % preferred direction in degrees
Rp = pars(2); % 
Ro = pars(3);
kappa = pars(4)*pi/180; % concentration, in degrees
alpha = alpha(:)*pi/180;
kappa = 1/kappa; % 1/kappa is ~ sigma^2 of the gaussian

% s_vm_p = exp( kappa*(cos(alpha-Dp)-1))/ (2*pi*besseli(0,kappa,1));
% s_vm_n = exp(kappa*(cos(alpha-(Dp+pi))-1))/ (2*pi*besseli(0,kappa,1));

s_vm_p = exp( kappa*(cos(alpha-Dp)))/ (2*pi*besseli(0,kappa,1));

s_vm_p = s_vm_p /max(s_vm_p);

% s_vm_p = (s_vm_p - min(s_vm_p))/max(s_vm_p - min(s_vm_p));
% s_vm_n = (s_vm_n - min(s_vm_n))/max(s_vm_n - min(s_vm_n));

r = Rp*s_vm_p + Ro;

end