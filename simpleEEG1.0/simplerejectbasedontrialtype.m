function [EEG] = simplerejectbasedontrialtype(EEG, varargin)
%   Reject epochs based on the trial type
%
%   1   Input EEG File From EEGLAB
%   2   'Types' - Event types to reject.
%
%   Example Code Implementation:
%
%       EEG = simplerejectbasedontrialtype(EEG, 'Types', [1, 4])
%
%   Author: Matthew B. Pontifex, Health Behaviors and Cognition Laboratory, Michigan State University, July 30, 2019

    if ~isempty(varargin)
             r=struct(varargin{:});
    end
    try, r.Types; catch, error('Error at simplerejectbasedontrialtype(). No trial types were specified.'); end

    if ~(size(EEG.data,3) > 1)
        error('Error at simplerejectbasedontrialtype(). This function is designed for epoched EEG, but a continous EEG dataset has been inputted.');
    end
    
    % obtain available epochs
    INEEG2 = EEG;
    [T, INEEG2] = evalc('pop_syncroartifacts(INEEG2, ''Direction'', ''bidirectional'');'); %synchronize artifact databases
    if (isempty(INEEG2.reject.rejmanual))
        EEG.reject.rejmanual = zeros(1,EEG.trials);
    else
        EEG.reject.rejmanual = INEEG2.reject.rejmanual;
    end
    epochindex = find([EEG.reject.rejmanual] == 0); % find accepted trials
    totaltrials = EEG.trials;
    
    % cycle through available epochs
    tempmat = [];
    for cE = 1:numel(epochindex)
        if ~(isnumeric(EEG.event(epochindex(cE)).type))
            try
                EEG.event(epochindex(cE)).type = str2double(EEG.event(epochindex(cE)).type);
            catch
                boolerr = 1;
            end
        end
        if ~isempty(intersect(EEG.event(epochindex(cE)).type, r.Types))
            tempmat(end+1) = cE;
        end
    end
    if ~isempty(tempmat)
    	EEG.reject.rejmanual(epochindex(tempmat)) = 1; % use the actual trials
    end
    com = sprintf('simplerejectbasedontrialtype() - Identified %d trials for rejection.', numel(tempmat));
    disp(com)
    com = sprintf('simplerejectbasedontrialtype() - %d total trials are identified for rejection and %d trials remain accepted.', sum([EEG.reject.rejmanual]), sum(~[EEG.reject.rejmanual]));
    disp(com)
    
    com = sprintf('%s = simplerejectbasedontrialtype(%s, ''Types'', %s);', inputname(1), inputname(1), makematrixarraystr(r.Types));
    EEG.history = sprintf('%s\n%s', EEG.history, com);
    EEG = simplesyncartifacts(EEG, 'Direction', 'bidirectional');
        
end
