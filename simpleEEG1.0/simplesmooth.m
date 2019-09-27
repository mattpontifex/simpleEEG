function [EEG, com] = simplesmooth(EEG, varargin)
%   Function to smooth EEG or ERP data. 
%
%   1   Input EEG structure
%   2   The available parameters are as follows:
%       a    'Window' - Window of gaussian weights to use.
%       b    'Sigma' - PDF sigma for calculation of gaussian weights (default is 1, larger values will give muted peak).
%       
%   Example Code:
%
%   EEG = simplesmooth(EEG, 'Window', 100, 'Sigma', 1.5);
%
%   NOTE: You must have the Matlab Statistics Toolbox installed.
%
%   Author: Matthew B. Pontifex, Health Behaviors and Cognition Laboratory, Michigan State University, July 29, 2019

    if ~isempty(varargin)
             r=struct(varargin{:});
    end
    try, r.Window; winsize = r.Window; catch, r.Window=0;  error('Error at simplesmooth(). Missing information! Please input Window size.');   end
    try, r.Sigma; sig = r.Sigma; catch, sig = 1; end
    
    if (winsize < 3)
        winsize = 3;
    end
    if ~mod(winsize,2)
        winsize = winsize + 1;
    end 
    
    epochc = 1; % continuous EEG data & ERP data
    boolEEG = 0;
    boolERP = 0;
    try
        if ~isempty(EEG.data)
            epochc = size(EEG.data,3); % continuous and epoched EEG
            boolEEG = 1;
            WinStop = EEG.nbchan;
        end
    catch
        boolerr = 1;
    end
    try
        if ~isempty(EEG.bindata)
            boolERP = 1;
            WinStop = EEG.nchan;
        end
    catch
        boolerr = 1;
    end
    if (boolERP == 0) & (boolEEG == 0)
        error('Error at simplesmooth(). Data does not appear to be from either a EEGLAB or ERPLAB dataset use gaussmooth() for vector inputs.');
    end
    
    
    % Setup Controls for Progress Bar
    fprintf(1, 'simplesmooth(): Smoothing data - |')
    WinStart = 1;
    nSteps = 25;
    step = 1;
    strLength = fprintf(1, [repmat(' ', 1, nSteps-step) '|   0%%']);
    tic    
    
    for countChannel = 1:WinStop
        for countEpoch = 1:epochc
            if (boolEEG == 1)
                EEG.data(countChannel,:,countEpoch) = gaussmooth( EEG.data(countChannel,:,countEpoch), 'Window', winsize, 'Sigma', sig);
            elseif (boolERP == 1)
                EEG.bindata(countChannel,:,countEpoch) = gaussmooth( EEG.bindata(countChannel,:,countEpoch), 'Window', winsize, 'Sigma', sig);
            end
        end
        [step, strLength] = commandwaitbar(countChannel, WinStop, step, nSteps, strLength); % progress bar update
    end
  
    % Closeout progress bar
    [step, strLength] = commandwaitbar(WinStop, WinStop, step, nSteps, strLength);
    fprintf(1, '\n')
    
    com = sprintf('%s = simplesmooth(%s, ''Window'', %s, ''Sigma'', %s);', inputname(1), inputname(1), num2str(winsize), num2str(sig));
    EEG.history = sprintf('%s\n%s', EEG.history, com);
end
    
    
