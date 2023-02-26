function si = dsi(angles, amps, circ_flag, deg_flag)
% relies on circ_stat toolbox
% angles: stimuli shown, in degrees
% amps: responses. Should be positive

if nargin <4
    deg_flag = false;
end

if nargin <3
    circ_flag = true;
end


if deg_flag
    angles = angles*pi/180;
end

if circ_flag
% vector sum, circular approach
si = 1 - circ_var(angles, amps);

else
% linear approach, assumes equally spaced, unique angles
[Rp, Dp] = max(amps);
shifted_amps = circshift(amps, numel(amps)/2);
Ra = shifted_amps(Dp);
si = (Rp-Ra)/(Rp+Ra);

end

end