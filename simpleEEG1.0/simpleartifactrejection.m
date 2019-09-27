function [EEG] = simpleartifactrejection(EEG, varargin)
%   Reject epochs containing voltage deflections (overall and point by point) beyond the specified
%   parameters.
%
%   1   Input EEG File From EEGLAB
%   2   'VoltageThreshold' - Voltage range of amplitudes e.g. [-100 100].
%   3   'PointThreshold' - Sample to sample absolute value threshold e.g. [100].
%   4   'Window' - Window in ms to search within (default is entire window).
%   5   'Channels' - Channels to search within (default is all channels).
%
%   Example Code Implementation:
%
%       EEG = simpleartifactrejection(EEG, 'VoltageThreshold', [ -100, 100 ], 'PointThreshold', 100, 'Window', [ -100, 900 ], 'Channels', { 'FZ', 'FCZ', 'CZ', 'CPZ', 'PZ', 'POZ', 'OZ' })
%
%   Author: Matthew B. Pontifex, Health Behaviors and Cognition Laboratory, Michigan State University, July 29, 2019

    if ~isempty(varargin)
             r=struct(varargin{:});
    end
    try, r.VoltageThreshold; catch, r(1).VoltageThreshold = NaN; end
    try, r.PointThreshold; catch, r(1).PointThreshold = NaN; end
    try, r.Window; catch, r(1).Window = NaN; end
    try, r.Channels; catch, r(1).Channels = NaN; end

    if ~(size(EEG.data,3) > 1)
        error('Error at simpleartifactrejection(). This function is designed for epoched EEG, but a continous EEG dataset has been inputted.');
    end
    
    if (~isnan(r(1).VoltageThreshold(1)) | (~isnan(r(1).PointThreshold(1)))) % at least one method is selected
        
        if isnan(r(1).Channels(1))
            selectchanindex = 1:EEG.nbchan;
        else
            selectchanindex = eegchannelarrayindex(EEG, {r.Channels});
        end
        if isnan(r(1).Window(1))
            selecttimeindex = 1:EEG.pnts;
            r(1).Window = [EEG.times(1), EEG.times(end)];
        else
            [~, winstart] = nanmin(abs(EEG.times - r(1).Window(1)));
            [~, winstop] = nanmin(abs(EEG.times - r(1).Window(end)));
            selecttimeindex = winstart:winstop;
        end
        
        INEEG2 = EEG;
        [T, INEEG2] = evalc('pop_syncroartifacts(INEEG2, ''Direction'', ''bidirectional'');'); %synchronize artifact databases
        if (isempty(INEEG2.reject.rejmanual))
            EEG.reject.rejmanual = zeros(1,EEG.trials);
        else
            EEG.reject.rejmanual = INEEG2.reject.rejmanual;
        end
        epochindex = find([EEG.reject.rejmanual] == 0); % find accepted trials
        
        totaltrials = EEG.trials;
        prerejectedtrials = sum([EEG.reject.rejmanual]);
        
        % Voltage Threshold
        if ~isnan(r(1).VoltageThreshold(1))
            tempmat = nanmax(squeeze(nanmax(EEG.data(selectchanindex,selecttimeindex,epochindex),[],1)),[],1); % epoch matrix of largest values in each channel and then each time
            tempmathigh = find(tempmat > r(1).VoltageThreshold(end));
            tempmat = nanmin(squeeze(nanmin(EEG.data(selectchanindex,selecttimeindex,epochindex),[],1)),[],1); % epoch matrix of smallest values in each channel and then each time
            tempmatlow = find(tempmat < r(1).VoltageThreshold(1));
            tempmat = unique([tempmathigh, tempmatlow]);
            if ~(isempty(tempmat))
                for cE = 1:numel(tempmat)
                    EEG.reject.rejmanual(epochindex(tempmat(cE))) = 1; % use the actual trials
                end
            end
            com = sprintf('simpleartifactrejection() - Voltage threshold identified %d trials for rejection.', numel(tempmat));
            disp(com)
        end
        
        % Point By Point
        if ~isnan(r(1).PointThreshold(1))
            tempmat = nanmax(squeeze(nanmax(abs(diff(EEG.data(selectchanindex,selecttimeindex,epochindex))),[],1)),[],1); % epoch matrix of largest change in each channel and then each time
            tempmathigh = find(tempmat > r(1).PointThreshold(1));
            if ~(isempty(tempmathigh))
                for cE = 1:numel(tempmathigh)
                    EEG.reject.rejmanual(epochindex(tempmathigh(cE))) = 1; % use the actual trials
                end
            end
            com = sprintf('simpleartifactrejection() - Point-by-point threshold identified %d trials for rejection.', numel(tempmathigh));
            disp(com)
        end
        com = sprintf('simpleartifactrejection() - %d total trials are identified for rejection and %d trials remain accepted.', sum([EEG.reject.rejmanual]), sum(~[EEG.reject.rejmanual]));
        disp(com)
        
        EEG = EEG;
        
        % format
        com = sprintf('%s = simpleartifactrejection(%s', inputname(1), inputname(1));
        if ~isnan(r(1).VoltageThreshold(1))
            VTstring = sprintf('[ %s, %s ]', num2str(r(1).VoltageThreshold(1)), num2str(r(1).VoltageThreshold(end)));
            com = sprintf('%s, ''VoltageThreshold'', %s', com, VTstring);
        end
        if ~isnan(r(1).PointThreshold(1))
            com = sprintf('%s, ''PointThreshold'', %s', com, num2str(r(1).PointThreshold));
        end
        Winstring = sprintf('[ %s, %s ]', num2str(r(1).Window(1)), num2str(r(1).Window(end)));
        com = sprintf('%s, ''Window'', %s', com, Winstring);
        
        if ~(numel(selectchanindex) == EEG.nbchan) % if a subset of channels was selected then indicate which channels otherwise ignore
            com = sprintf('%s, ''Channels'', {', com);
            for cChan = 1:numel(selectchanindex)
                com = sprintf('%s ''%s''', com, EEG.chanlocs(selectchanindex(cChan)).labels);
                if (cChan ~= numel(selectchanindex))
                    com = sprintf('%s,', com);
                end
            end
            com = sprintf('%s }', com);
        end
        com = sprintf('%s);', com);
        EEG.history = sprintf('%s\n%s', EEG.history, com);
        
        EEG = simplesyncartifacts(EEG, 'Direction', 'bidirectional'); %synchronize artifact databases
    else
        com = "";
    end
end
