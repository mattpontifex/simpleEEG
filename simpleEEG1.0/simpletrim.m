function [EEG] = simpletrim(EEG, varargin)
%   Remove data prior to the first event and following the last event. 
%
%   1   Input EEG File From EEGLAB
%   2   'Pre' - Window in seconds to use for the delay prior to the first stimulus.
%   3   'Post' - Window in seconds to use for the delay following the last stimulus.
%
%   Example Code Implementation:
%
%       EEG = simpletrim(EEG, 'Pre', 2, 'Post', 10);
%
%   Author: Matthew B. Pontifex, Health Behaviors and Cognition Laboratory, Michigan State University, July 29, 2019

    if ~isempty(varargin)
             r=struct(varargin{:});
    end
    try, r.Pre; catch, r.Pre = ""; end
    try, r.Post; catch, r.Post = ""; end
    try, r.Suppress; catch, r.Suppress = 'False'; end

    if isempty(EEG.data)
        error('Error at simpletrim(). This function cannot run on an empty dataset.');
    end
    
    winStart = 1;
    if ~(strcmpi(r.Pre, ""))
        winStart = double(EEG.event(1).latency-(EEG.srate*((1000/EEG.srate)*r.Pre)));
        if (winStart < 1); winStart = 1; end;
    end
    
    winStop = EEG.pnts;
    if ~(strcmpi(r.Post, ""))
        winStop = double(EEG.event(end).latency+(EEG.srate*((1000/EEG.srate)*r.Post)));
        if (winStop > EEG.pnts); winStop = EEG.pnts; end;
    end
    
    % check that triggers remain in the correct location
    EEG2 = simpleevent2channel(EEG, 'ChannelName', 'EventMarkers', 'Suppress', 'True');
    [T, EEG2] = evalc('pop_select(EEG2, ''point'', [winStart winStop]);');
    EEG2 = simpleevent2channel(EEG2, 'ChannelName', 'EventMarkers2', 'Suppress', 'True');
    
    if (isequal(EEG2.data(find(strcmpi({EEG2.chanlocs.labels}, 'EventMarkers'),1),:), EEG2.data(find(strcmpi({EEG2.chanlocs.labels}, 'EventMarkers2'),1),:))) % event markers stay in the correct space 
        [T, EEG] = evalc('pop_select(EEG, ''point'', [winStart winStop]);');
    else
        error('Error at simpletrim(). pop_select() bug detected where removal of beginning of dataset corrupts event markers. Please update EEGLAB.');
    end
    
    if strcmpi(r.Suppress, 'False')
        % Place command in History
        com = sprintf('%s = simpletrim(%s, ''Pre'', %s, ''Post'', %s);', inputname(1), inputname(1), num2str(r.Pre), num2str(r.Post));
        EEG.history = sprintf('%s\n%s', EEG.history, com);
    end
    
end