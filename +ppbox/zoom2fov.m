function [ fovx, fovy ] = zoom2fov(qzoom, micID, expDate)

%   INPUTS:

%   zoom:  the query zoom
%   objID:  the objective used, either 'x16' (default) or 'x20'.
%   micID:  the microscope used, either 'bscope' (default) or 'mom' or ' b2'.

%   zoom2fov(zoom) returns the width in micrometers of the FOV of the
%   microscope at a query zoom.
%   zoom2foc(zoom, micID) allows you to specify which microscope you used
%   zoom2foc(zoom, micID, objID) allows you to specify which scope and
%   which objective you used for imaging.

%   OUTPUTS:
%   fovx:  the size of the FOV along scanning lines
%   fovy:  the size of the FOV across scanning lines

%   2016-01-24 function and 2p measurements by L. Federico Rossi
%   2016-02-05 adapted from infoPixUm in Suite2P folder (SS)
%   2019-06-24 removed unused input objID,updated measurements for b-scope, added input expDate (LFR)
%   2022 -09-15 added the latest calibration for bscope (Anyi)

if nargin < 2 || isempty(micID)
    micID = 'bscope';
elseif ~any(strcmp(micID, {'b', 'bscope', 'b2', 'mom', 'bscope_intrinsic', 'lilrig_intrinsic'}))
    display('WARNING: unknown type of microscope.')
end

if nargin < 3 || isempty(expDate)
    expDate = datetime('today');
else
    expDate = datetime(str2double(expDate(1:4)), str2double(expDate(6:7)), str2double(expDate(9:10)));
end

% % we assume a 16x objective in all cases so far
% if nargin < 3
%     objID = 'x16';
% end

switch micID
    case {'bscope', 'b'} %assumes 16X obj was used

        if expDate < datetime(2019, 04,25)

            zooms = [1.1, 1.2, 1.3, 1.4, 1.5, 1.6, 1.7, 2, 2.2, 2.3, 2.5, 3, ...
                3.5, 4, 5, 6.1, 7.1, 9.1];
            measuredHoriz = [1014, 918.5, 855, 740, 680, 635, 615.5, 524, 491, 460, 431.5, 371, ...
                318, 287, 237.5, 199, 172.5, 140];
            measuredVert = [913, 828, 790, 715, 664.5, 615, 593, 503.5, 452.5, 430, 401, 337.5, ...
                284.5, 249, 179.5, 161, 141, 111.5];

        elseif expDate >= datetime(2019, 04,25) && expDate < datetime(2019, 05,08)

            zooms = [1, 1.1, 1.2, 1.3, 1.4, 1.5, 1.6, 1.7, 1.8, 1.9, 2,2.1, 2.2, 2.3,2.4, 2.5];
            measuredHoriz = [952, 859, 783, 723, 670, 625, 584, 557, 529, 504, 478, 457,...
                443, 427, 409, 395];
            measuredVert = [1180, 1067, 977, 898, 837, 783, 731, 692, 651, 614,...
                584, 556, 535.6, 512, 489, 472 ];

        elseif expDate >= datetime(2019, 05,08) && expDate < datetime(2022, 08,01)

            zooms = [1 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2 2.1 ...
                3.1 4.1 5.1 6.1 7.1 8.1 9.1 10.1 11.1 12.1 13.1 14.1 15.1];

            measuredHoriz = [914 853 776 711 674 624 588 555 522 492 474 ...
                449 306 231 188 155 135 117 105 95 87 79 73 68 64];

            measuredVert = measuredHoriz ;
%         elseif expDate >= datetime(2022, 08,01)
        elseif expDate >= datetime(2022, 03,01)

            zooms = (1:1:20);

            measuredHoriz = [920 477.5 334 261.5 221 185 163.5 143.5 133.5 121 109.5 104 96.5 89 83 80 75 72.5 67.5 67];

            measuredVert = [916.5 472 319.5 242.5 189.5 156.5 136 116.5 106 98.5 89.5 84 70.5 65.5 64.5 60.5 55.5 52 47.5 48.5];


        end

    case 'b2'
%         zooms = [1.6 1.9 2 2.2];
%         measuredHoriz = [772 653 619.5 565.5];
%         measuredVert = [755 640 605.5 547];

        zooms = [1.3, 1.2, 1.1, 1, 1.4, 1.5, 1.6, 1.7, 1.8, 1.9, 2, 1, 2.5, 3, 3.5, 4, 4.5, 5, 7, 2, 1.5, 1, 1.2, 1.3, 1.1, 10];
        zooms = [zooms, 10:25, 29];

        measuredHoriz = [873.5, 952, 1093.5, 1307.5, 829, 756, 710, 673, 630.5, 598.5, 568.5, 1271, 467, 382.5, 329.5, 289, 258, 232.5, 168, 571.5, 767, 1275, 962.5, 876.5, 1081.5, 118];
        measuredHoriz = [measuredHoriz, 116.5, 106.5, 98.5, 90.5, 84.75, 78.25, 75, 71, 64, 63, 61.75, 57.5, 55.25, 51, 50.5, 48.5, 41.75];
        
        measuredVert = measuredHoriz;

    case 'mom'
        zooms = [3 4];
        measuredHoriz = [155 117];
        measuredVert = [155 117];

    case 'bscope_intrinsic' % assumes 4X obj was used
        zooms = [1];
        measuredHoriz = [3550];
        measuredVert = [3550];

    case 'lilrig_intrinsic' % assumes 1.2X obj was used
        zooms = [1];
        measuredHoriz = [3300]; % this is a temporary hack, the fov size is not fixed, depends on the camera ROI
        measuredVert = [3300]; % this is a temporary hack, the fov size is not fixed, depends on the camera ROI
end

if numel(zooms)>1

%     curveX = fit(zooms', 1./measuredHoriz', 'poly1');
%     fovx = 1./curveX(zooms);
% % 
% %     figure;
% %     subplot(3,1,1);
% %     plot(zooms, 1./measuredHoriz, 'ob');
% %     hold on;
% %     plot(zooms, 1./fovx, '-r');
% %     ylabel('inverse fov size (1/um)');
% % 
% %     subplot(3,1,2);
% %     plot(zooms, measuredHoriz, 'ob');
% %     hold on;
% %     plot(zooms, fovx, '-r');
% %     ylabel('fov size (um)');
% % 
% %     subplot(3,1,3);
% %     plot(zooms, abs(measuredHoriz'-fovx), '-ok');
% %     
% %     xlabel('zooms')
% %     ylabel('absolute error (um)');
% 
%     curveY = fit(zooms', 1./measuredVert', 'poly1');
%     fovy = 1./curveY(zoom);
   
if qzoom < 2

fovx = interp1(zooms, measuredHoriz, qzoom, 'pchip', NaN);
fovy = interp1(zooms, measuredVert, qzoom, 'pchip', NaN);


else
    curveX = fit(zooms', 1./measuredHoriz', 'poly1');
    fovx = 1./curveX(qzoom);
    curveY = fit(zooms', 1./measuredVert', 'poly1');
    fovy = 1./curveY(qzoom);
end

else

    fovx = measuredHoriz;
    fovy = measuredVert;


end

%% Visualize fit, measured data, and queried zoom
% figure
% hold on
% x = min(1,zoom):0.05:max(10,zoom);
% plot(x, curveX(x))
% plot(zooms, measuredHoriz, 'ko')
% plot(zoom, fovx, 'ko', 'MarkerFaceColor', 'k')
% title('Field of view in X')
% figure
% hold on
% x = min(1,zoom):0.05:max(10,zoom);
% plot(x, curveY(x))
% plot(zooms, measuredVert, 'ko')
% plot(zoom, fovy, 'ko', 'MarkerFaceColor', 'k')
% title('Field of view in Y')

end

