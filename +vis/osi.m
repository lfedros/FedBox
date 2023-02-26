function si = osi(angles, amps, deg_flag)
% relies on circ_stat toolbox
% angles: stimuli shown, in radians (or degrees), periodic [0 pi]
% amps: responses. Should be positive

if nargin <3
    deg_flag = false;
end

if deg_flag
    angles = angles*pi/180;
end

angles = angles*2; % stretch to full circle
si = circ_r(angles, amps);

end