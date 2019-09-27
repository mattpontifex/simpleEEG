function [epochevents, epocheventlist, epochmatrix] = simplecheckavailabletrials(EEG)

    % Identify eligible events - slow but reliable
    epochevents = [];
    epochmatrix = NaN(size(EEG.event,2),2);
    for cE = 1:size(EEG.event,2)
        boolbound = 0;
        if ~(isnumeric(EEG.event(cE).type))
            if (~strcmpi(EEG.event(cE).type, 'Boundary'))
                EEG.event(cE).type = str2double(EEG.event(cE).type);
            else
                boolbound = 1;
            end
        elseif (EEG.event(cE).type == -88)
            boolbound = 1;
        end
        if (boolbound == 0)
            epochevents = unique([epochevents, EEG.event(cE).type]);
            epochmatrix(cE,1) = cE; % add event
            epochmatrix(cE,2) = EEG.event(cE).type;
        end
    end
    epochmatrix(isnan(epochmatrix(:,2)),:) = [];
    epochevents = sort(epochevents);

    % identify consecutive runs of numbers
    epocheventlist = sprintf('['); 
    k = [true;diff(epochevents(:))~=1 ];
    s = cumsum(k);
    x =  histc(s,1:s(end));
    numrunsstart = find(k);
    numrunsstop = numrunsstart - 1;
    numrunsstop = vertcat(numrunsstop, numel(epochevents));
    for cE = 1:numel(numrunsstart)
        if (numrunsstart(cE) == numrunsstop(cE+1)) % start and stop are the same numbers which means they are not runs
            if (strcmpi(epocheventlist, '[')) %first event added
                epocheventlist = sprintf('%s %s', epocheventlist, num2str(epochevents(numrunsstart(cE))));
            else
                epocheventlist = sprintf('%s, %s', epocheventlist, num2str(epochevents(numrunsstart(cE))));
            end
        else
            if (strcmpi(epocheventlist, '[')) %first event added
                epocheventlist = sprintf('%s %s:%s', epocheventlist, num2str(epochevents(numrunsstart(cE))), num2str(epochevents(numrunsstop(cE+1))));
            else
                epocheventlist = sprintf('%s, %s:%s', epocheventlist, num2str(epochevents(numrunsstart(cE))), num2str(epochevents(numrunsstop(cE+1))));
            end
        end
    end
    epocheventlist = sprintf('%s ]', epocheventlist);
    
end

