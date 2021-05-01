function pars = fitTuning(alpha, r, type, fixPars)


switch type
    
    case 'vm2'
        
        if nargin < 4
            fixPars = nan(1,4);
        end
        
        %----hardcoded pars
        mink = 1;
        maxk = 10000;
        minPrefDir = 0;
        maxPrefDir = 360;
        
        %-----average r
        
        r = r(:);
        alpha = alpha(:);
        unique_ang = unique(alpha)*pi/180;
        nStim = numel(unique_ang);
        rhat = mean(reshape(r, nStim, []),2);
        
        %-----estimate pref R and pref Dir
        
        [Rp, Dp] = max(rhat);
        Dp = unique_ang(Dp);
        [Ro] = min(rhat);
% vector sum does not work for double peaked dists       
%         Rp = abs(sum(rhat.*exp(1i*unique_ang))); 
%         Dp = angle(sum(rhat.*exp(1i*unique_ang)));

        if Dp <0
            Dp = Dp+2*pi;
        end
        Dp = Dp*180/pi;
        k = Rp*(2-Rp^2)/(1-Rp^2); % estimate of k
        k = k*180/pi;
        
        % r = r -Ro;
        
        %----- refine estimate of k
        
        
        
        %---do the fit
        pars0 = [Dp, Rp, (Rp+Ro)/2, Ro, k];
        parslb = [0, 0, 0, -5, 10];
        parsub = [360, Rp*5, Rp*5, Rp, 1000];
        
        parslb(~isnan(fixPars)) = fixPars(~isnan(fixPars));
        parsub(~isnan(fixPars)) = fixPars(~isnan(fixPars));
        pars0(~isnan(fixPars)) = pars0(~isnan(fixPars));

        pars = lsqcurvefit(@vonMises2, ...
            pars0, alpha, r, ...
            parslb,...
            parsub);
        
        % pars(4) = pars(4)+Ro;
        
    case 'vm1'
        
        if nargin < 4
            fixPars = nan(1,3);
        end
        
        %----hardcoded pars
        mink = 1;
        maxk = 10000;
        minPrefDir = 0;
        maxPrefDir = 360;
        
        %-----average r
        
        r = r(:);
        alpha = alpha(:)*2;
        unique_ang = unique(alpha)*pi/180;
        nStim = numel(unique_ang);
        rhat = mean(reshape(r, nStim, []),2);
        
        %-----estimate pref R and pref Dir
        
        [Rp, Dp] = max(rhat);
        [Ro] = min(rhat);
        
        Rp = abs(sum(rhat.*exp(1i*unique_ang)));
        Dp = angle(sum(rhat.*exp(1i*unique_ang)));
        if Dp <0
            Dp = Dp+2*pi;
        end
        Dp = Dp*180/pi;
        k = Rp*(2-Rp^2)/(1-Rp^2); % estimate of k
        k = k*180/pi;
        % r = r -Ro;
        
        %----- refine estimate of k
        
        
        
        %---do the fit
        pars0 = [Dp, Rp, Ro, k];
        parslb = [0, 0, -5, 10];
        parsub = [360, Rp*5, Rp, 1000];
        
        parslb(~isnan(fixPars)) = fixPars(~isnan(fixPars));
        parsub(~isnan(fixPars)) = fixPars(~isnan(fixPars));
        pars0(~isnan(fixPars)) = pars0(~isnan(fixPars));

        pars = lsqcurvefit(@vonMises, ...
            pars0, alpha, r, ...
            parslb,...
            parsub);
        
        % pars(4) = pars(4)+Ro;
        
end

end