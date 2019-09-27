function [OUTEEG] = simplebaselinecorrect(INEEG, varargin)
%   Baseline correct a .SET or .AVG file. 
%
%   1   Input EEG or AVG File From EEGLAB
%   2   'Approach' - ['Mean' (default) | 'Median'] Parameter to specify central tendency approach.
%   3   'Window' - Window in ms to use for the creation of the epoch.
%
%   Example Code Implementation:
%
%       EEG = simplebaselinecorrect(EEG, 'Approach', 'Mean', 'Window', [-100, 0])
%
%   Author: Matthew B. Pontifex, Health Behaviors and Cognition Laboratory, Michigan State University, July 25, 2019

    if ~isempty(varargin)
             r=struct(varargin{:});
    end
    try, r.Approach; catch, r.Approach = 'Mean'; end
    try, r.Window; catch, r.Window = [0 0]; end
    
    if (ischar(r.Window))
        r.Window = str2num(r.Window);
    end

    OUTEEG = INEEG;
    
    booleeg = 0;
    boolerp = 0;
    try
        if ~isempty(INEEG.data)
            booleeg = 1;
            cEpochSize = size(INEEG.data,3);
            cChannelSize = size(INEEG.data,1);
        end
    catch
        boolerr = 1;
    end
    try
        if ~isempty(INEEG.bindata)
            boolerp = 1;
            cEpochSize = size(INEEG.bindata,3);
            cChannelSize = size(INEEG.bindata,1);
        end
    catch
        boolerr = 1;
    end
    
    [~,baselinestartpoint] = min(abs(INEEG.times - (r(1).Window(1))));
    [~,baselinestoppoint] = min(abs(INEEG.times - (r(1).Window(end))));
    
    for cEpoch = 1:cEpochSize
        for cChannel = 1:cChannelSize
            newbaseline = 0;
            if (strcmpi(r.Approach, 'Median'))
                if (booleeg == 1)
                    newbaseline = nanmedian(INEEG.data(cChannel,baselinestartpoint:baselinestoppoint,cEpoch));
                end
                if (boolerp == 1)
                    newbaseline = nanmedian(INEEG.bindata(cChannel,baselinestartpoint:baselinestoppoint,cEpoch));
                end
            else
                if (booleeg == 1)
                    newbaseline = nanmean(INEEG.data(cChannel,baselinestartpoint:baselinestoppoint,cEpoch));
                end
                if (boolerp == 1)
                    newbaseline = nanmean(INEEG.bindata(cChannel,baselinestartpoint:baselinestoppoint,cEpoch));
                end
            end
            if (isnan(newbaseline))
                newbaseline = 0;
            end
            if (booleeg == 1)
                OUTEEG.data(cChannel,:,cEpoch) = INEEG.data(cChannel,:,cEpoch) - newbaseline;
            end
            if (boolerp == 1)
                OUTEEG.bindata(cChannel,:,cEpoch) = INEEG.bindata(cChannel,:,cEpoch) - newbaseline;
            end
        end
    end
        
    % Place command in History
    com = sprintf('%s = simplebaselinecorrect(%s, ''Approach'', ''%s'', ''Window'', %s);', inputname(1), inputname(1), r.Approach, mat2str(r.Window));
    OUTEEG.history = sprintf('%s\n%s', OUTEEG.history, com);
    
end
