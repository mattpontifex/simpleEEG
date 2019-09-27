function [OUTEEG, com] = simpleevent2channel(INEEG, varargin)
%   Function to take all event types in the EEG.event structure and store
%   them as a channel within the data.
%
%   1   Input EEG File From EEGLAB
%   2   'ChannelName' - Parameter to change what the channel is named (default is 'EventMarkers').
%   3   'Boundary' - Parameter to change what the boundary markers are named (default is 'Boundary').
%
%   Example Code Implementation:
%
%       EEG = simpleevent2channel(EEG, 'ChannelName', 'EventMarkers');
%
%   Author: Matthew B. Pontifex, Health Behaviors and Cognition Laboratory, Michigan State University, July 26, 2019

    if ~isempty(varargin)
             r=struct(varargin{:});
    end
    try, r.ChannelName; catch, r.ChannelName = "EventMarkers"; end
    try, r.Boundary; catch, r.Boundary = -88; end
    try, r.Suppress; catch, r.Suppress = 'False'; end
        
    if (size(INEEG.data,3) > 1)
        error('Error at simpleevent2channel(). This function is designed for continous EEG, but an epoched EEG dataset has been inputted.');
    end
    
    OUTEEG = INEEG;
    
    % Create trigger channel as data check
    OUTEEG.data(end+1,:) = zeros(1,size(OUTEEG.data(end,:),2)); % populate empty channel
    OUTEEG.chanlocs(end+1).labels = r.ChannelName;
    OUTEEG.nbchan = OUTEEG.nbchan+1;
    for cE = 1:size(OUTEEG.event,2)
        boolbound = 0;
        if ~(isnumeric(OUTEEG.event(cE).type))
            if (~strcmpi(OUTEEG.event(cE).type, 'Boundary')) & (~strcmpi(OUTEEG.event(cE).type, r.Boundary))
                OUTEEG.event(cE).type = str2double(OUTEEG.event(cE).type);
            else
                boolbound = 1;
            end
        end
        if (boolbound == 0)
            try
                OUTEEG.data(end,fix(OUTEEG.event(cE).latency)) = OUTEEG.event(cE).type;
            catch
                booler = 1;
            end
            OUTEEG.event(cE).urevent = cE;
        end
    end
            
    % Place command in History
    com = sprintf('%s = simpleevent2channel(%s, ''ChannelName'', ''%s'');', inputname(1), inputname(1), r.ChannelName);
    OUTEEG.history = sprintf('%s\n%s', OUTEEG.history, com);
    
    if strcmpi(r.Suppress, 'False')
        com = sprintf('\nEquivalent Code:\n\t%s\n', com);
        disp(com)
    end
    
end
