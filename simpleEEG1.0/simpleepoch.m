function [OUTEEG] = simpleepoch(INEEG, varargin)
%   Convert a continuous EEG dataset to epoched data by extracting data
%   epochs time locked to specified event types. 
%
%   1   Input EEG File From EEGLAB
%   2   'Window' - Window in ms to use for the creation of the epoch.
%   3   'Types' - Event types to epoch.
%   4   'Label' - Optional parameter to label event types.
%   5   'Boundary' - Optional parameter for Boundary event types [default is ['Boundary']].
%   6   'Strict' - Optional parameter to remove any epoch that contains incomplete data (default is 'True').
%
%   Example Code Implementation:
%
%       EEG = simpleepoch(EEG, 'Window', [-600, 1000], 'Types', [1, 4])
%
%   Author: Matthew B. Pontifex, Health Behaviors and Cognition Laboratory, Michigan State University, July 24, 2019

    if ~isempty(varargin)
             r=struct(varargin{:});
    end
    try, r.Window; catch, 
        error('Error at simpleepoch(). This function requires an epoch window in ms to be specified.');
    end
    try, r.Types; catch, 
        error('Error at simpleepoch(). This function requires event type(s) to be specified.');
    end
    try, r.Label; catch, r.Label = ""; end
    try, r.Boundary; catch, r.Boundary = '-88'; end
    try, r.Strict; catch, r.Strict = 'False'; end

    if (size(INEEG.data,3) > 1)
        error('Error at simpleepoch(). This function is designed for continous EEG, but an epoched EEG dataset has been inputted.');
    end
    
    epochwindowms = r.Window;
    epochtrials = r.Types;
    if ~((epochwindowms(1) <= 0) & (epochwindowms(2) >= 0) & ((epochwindowms(2)-epochwindowms(1)) > 0))
        error('Error at simpleepoch(). This function requires an epoch window in ms to be specified that encompasses 0 (i.e., [-100, 1000]).');
    end
        
    % Identify eligible events - slow but reliable
    includeevents = zeros(1,size(INEEG.event,2));    
    boundaries = [];
    epochevents = [];
    for cE = 1:size(INEEG.event,2)
        boolbound = 0;
        if ~(isnumeric(INEEG.event(cE).type))
            if (~strcmpi(INEEG.event(cE).type, 'Boundary')) & (~strcmpi(INEEG.event(cE).type, r.Boundary))
                INEEG.event(cE).type = str2double(INEEG.event(cE).type);
            else
                boolbound = 1;
                boundaries = unique([boundaries, cE]);
            end
        end
        if (boolbound == 0)
            if ~(isempty(find(epochtrials == INEEG.event(cE).type)))
                epochevents = unique([epochevents, cE]);    
            end
        end
    end
    includeevents(epochevents) = 1;
    if (isempty(epochevents))
        error('Error at simpleepoch(). None of the requested event types occur in EEG.event.type.');
    end
        
    boundaryvect = zeros(1,INEEG.pnts);
    % Createa boundary screen
    if ~isempty(boundaries)
        for cE = 1:numel(boundaries)
            boundaryvect(boundaries(cE)) = 1;
        end
    end
    
    % repopulate urevent
    for cE = 1:size(INEEG.event,2)
        INEEG.event(cE).urevent = cE;
    end
    
    % Setup framework
    epochpoints = fix((((epochwindowms(2) - epochwindowms(1))/1000) * INEEG.srate + 1));
    epochtimes = linspace(epochwindowms(1), epochwindowms(2), epochpoints);
    [~, epochtimeszeropt] = min(abs(epochtimes));
    epochtimespointsafterzero = (epochpoints-epochtimeszeropt); % determine how many points after zero are needed
    epochdataframe = NaN(INEEG.nbchan,epochpoints,numel(epochevents)); % channel x time x epoch
    OUTEEG = INEEG;
    OUTEEG.xmin = epochtimes(1)/1000;
    OUTEEG.xmax = epochtimes(end)/1000;
    OUTEEG.pnts = epochpoints;
    OUTEEG.times = epochtimes;
    
        % Setup Controls for Progress Bar
    fprintf(1, 'simpleepoch(): Epoching data - |')
    WinStart = 1;
    WinStop = numel(epochevents);
    nSteps = 25;
    step = 1;
    strLength = fprintf(1, [repmat(' ', 1, nSteps-step) '|   0%%']);
    tic    
    
    
    % Extract Data
    dataintersectevents = zeros(1,numel(epochevents));
    boundaryintersectevents = zeros(1,numel(epochevents));
    for cEpoch = 1:numel(epochevents)
        
        % Obtain window indeces
        eventlatencyindx = fix(INEEG.event(epochevents(cEpoch)).latency); % event index
        winstartpoint = eventlatencyindx - epochtimeszeropt; % current index minus points preceeding marker
        winstoppoint = eventlatencyindx + epochtimespointsafterzero - 1;
                
        % check to see if full epoch length can be extracted
        outdatastart = 1;
        outdatastop = epochpoints;
        if (winstartpoint < 1)
            outdatastart = abs(winstartpoint)+2;
            winstartpoint = 1;
            dataintersectevents(cEpoch) = 1;
        end
        if (winstoppoint > INEEG.pnts)
            outdatastop = outdatastop-(winstoppoint-INEEG.pnts);
            winstoppoint = INEEG.pnts;
            dataintersectevents(cEpoch) = 1;
        end
        
        if ~((winstoppoint-winstartpoint) == (outdatastop-outdatastart))
           error('math issue'); 
        end
        
        % check to see if parts of epoch intersect with boundary event
        tempvect = boundaryvect(winstartpoint:winstoppoint);
        if (sum(tempvect) > 1)
            boundindx = find(tempvect == 1, 1);
            if (boundindx <= epochtimeszeropt) % boundary is before the stimulus
                % bring window in to just after boundary event
                winstartpoint = winstartpoint+boundindx+1;
                outdatastart = outdatastart+boundindx+1;
            else % boundary is before the stimulus
                % bring window in to just befre boundary event
                winstoppoint = winstoppoint-boundindx-1;
                outdatastop = outdatastop-boundindx-1;
            end
            boundaryintersectevents(cEpoch) = 1;
        end
        
        if ~((winstoppoint-winstartpoint) == (outdatastop-outdatastart))
           error('math issue'); 
        end
        epochdataframe(:,outdatastart:outdatastop,cEpoch) = INEEG.data(:,winstartpoint:winstoppoint);
       
        [step, strLength] = commandwaitbar(cEpoch, WinStop, step, nSteps, strLength); % progress bar update
    end
    
    % Closeout progress bar
    [step, strLength] = commandwaitbar(WinStop, WinStop, step, nSteps, strLength);
    fprintf(1, '\n')
    fprintf('simpleepoch(): mimicking ERPLAB structures')
    
    % Place in structure
    OUTEEG.data = epochdataframe;
    OUTEEG.trials = size(epochdataframe,3);
    OUTEEG.icaact = [];
    OUTEEG.event(~includeevents) = [];  
    
    % Remove events containing NaN
    if strcmpi(r.Strict, 'True')
        tempbound = logical(sum([dataintersectevents; boundaryintersectevents]));
        if (sum(tempbound) > 0)
            fprintf('Warning at simpleepoch(): %d Events were excluded from epoching as they intersected with a boundary event.\n', sum(tempbound));
            OUTEEG.data(:,:,tempbound) = [];
            OUTEEG.event(tempbound) = [];
            OUTEEG.trials = size(OUTEEG.event,2);
        end
    end
    
    % Adjust EEG.Event Latency
    for cEpoch = 1:OUTEEG.trials 
        OUTEEG.event(cEpoch).latency = ((epochpoints * cEpoch) - (epochpoints-epochtimeszeropt));
        OUTEEG.event(cEpoch).epoch = cEpoch;
    end
    
    % Compatibility with EEGLAB/ERPLAB
    OUTEEG.epoch = struct('event',[],'eventbepoch',[],'eventbini',[],'eventbinlabel',[],'eventcodelabel',[],'eventduration',[],'eventenable',[],'eventflag',[],'eventitem',[],'eventtype',[],'eventlatency',[],'eventurevent',[]);
    for cEpoch = 1:OUTEEG.trials
        OUTEEG.event(cEpoch).bepoch = cEpoch;
        OUTEEG.event(cEpoch).bini = 1;
        OUTEEG.event(cEpoch).binlabel = 'B1';
        OUTEEG.event(cEpoch).codelabel = '""';
        OUTEEG.event(cEpoch).duration = 0;
        OUTEEG.event(cEpoch).enable = 1;
        OUTEEG.event(cEpoch).flag = 0;
        OUTEEG.event(cEpoch).item = OUTEEG.event(cEpoch).urevent;
        
        OUTEEG.epoch(cEpoch).event = OUTEEG.event(cEpoch).epoch;
        OUTEEG.epoch(cEpoch).eventbepoch = OUTEEG.event(cEpoch).epoch;
        OUTEEG.epoch(cEpoch).eventbini = OUTEEG.event(cEpoch).bini;
        OUTEEG.epoch(cEpoch).eventbinlabel = OUTEEG.event(cEpoch).binlabel;
        OUTEEG.epoch(cEpoch).eventcodelabel = OUTEEG.event(cEpoch).codelabel;
        OUTEEG.epoch(cEpoch).eventduration = OUTEEG.event(cEpoch).duration;
        OUTEEG.epoch(cEpoch).eventenable = OUTEEG.event(cEpoch).enable;
        OUTEEG.epoch(cEpoch).eventflag = OUTEEG.event(cEpoch).flag;
        OUTEEG.epoch(cEpoch).eventitem = OUTEEG.event(cEpoch).urevent;
        OUTEEG.epoch(cEpoch).eventtype = OUTEEG.event(cEpoch).type;
        OUTEEG.epoch(cEpoch).eventlatency = 0;
        OUTEEG.epoch(cEpoch).eventurevent = OUTEEG.event(cEpoch).urevent;
    end
    fprintf('.')
    
    % Compatibility with ERPLAB
    OUTEEG.EVENTLIST = struct('setname',[],'report',[],'bdfname',[],'nbin',[],'version',[],'account',[],'username',[],'trialsperbin',[],'elname',[],'bdf',[],'eldate',[],'eventinfo',[]);
    OUTEEG.EVENTLIST.setname = 'EEG file';
    OUTEEG.EVENTLIST.report = '';
    OUTEEG.EVENTLIST.bdfname = 'binbypass.txt';
    OUTEEG.EVENTLIST.nbin = 1;
    OUTEEG.EVENTLIST.version = '6.1.4';
    OUTEEG.EVENTLIST.account = 'Documents';
    OUTEEG.EVENTLIST.username = '';
    OUTEEG.EVENTLIST.trialsperbin = OUTEEG.trials;
    OUTEEG.EVENTLIST.elname = '';
    OUTEEG.EVENTLIST.eldate = datetime('now');
    
    OUTEEG.EVENTLIST.eventinfo = struct('item',[],'code',[],'binlabel',[],'codelabel',[],'time',[],'spoint',[],'dura',[],'flag',[],'enable',[],'bini',[],'bepoch',[]);
    for cEvent = 1:size(INEEG.event,2)
        if isempty(find(boundaries == cEvent, 1)) % if not a boundary event
            OUTEEG.EVENTLIST.eventinfo(cEvent).item = cEvent;
            OUTEEG.EVENTLIST.eventinfo(cEvent).code = INEEG.event(cEvent).type;

            tempcheck = find([OUTEEG.event.urevent] == cEvent,1);
            if isempty(tempcheck)
                OUTEEG.EVENTLIST.eventinfo(cEvent).binlabel = '""';
                OUTEEG.EVENTLIST.eventinfo(cEvent).bini = -1;
                OUTEEG.EVENTLIST.eventinfo(cEvent).bepoch = 0;
            else
                OUTEEG.EVENTLIST.eventinfo(cEvent).binlabel = OUTEEG.event(tempcheck).binlabel;
                OUTEEG.EVENTLIST.eventinfo(cEvent).bini = 1;
                OUTEEG.EVENTLIST.eventinfo(cEvent).bepoch = OUTEEG.event(tempcheck).bepoch;
            end
            
            [~, eventlatencyindx] = min(abs(INEEG.times - INEEG.event(cEvent).latency));
            OUTEEG.EVENTLIST.eventinfo(cEvent).time = INEEG.times(eventlatencyindx)/1000;         
            OUTEEG.EVENTLIST.eventinfo(cEvent).spoint = INEEG.event(cEvent).latency;
            OUTEEG.EVENTLIST.eventinfo(cEvent).dura = 0;
            OUTEEG.EVENTLIST.eventinfo(cEvent).flag = 0;
            OUTEEG.EVENTLIST.eventinfo(cEvent).enable = 1;
            OUTEEG.EVENTLIST.eventinfo(cEvent).codelabel = '""';
        end
    end
    
    OUTEEG.EVENTLIST.bdf = struct('expression',[],'description',[],'prehome',[],'athome',[],'posthome',[],'namebin',[],'rtname',[],'rtindex',[],'rt',[]);
    OUTEEG.EVENTLIST.bdf.description = 'Bin1';
    OUTEEG.EVENTLIST.bdf.namebin = 'Bin1';
    OUTEEG.EVENTLIST.bdf.expression = sprintf('.{%s}', mat2str(epochtrials));
    OUTEEG.EVENTLIST.bdf.athome = struct('eventcode',[],'eventsign',[],'timecode',[],'flagcode',[],'flagmask',[],'writecode',[],'writemask',[]);
    OUTEEG.EVENTLIST.bdf.athome.eventcode = epochtrials;
    OUTEEG.EVENTLIST.bdf.athome.eventsign = 1;
    OUTEEG.EVENTLIST.bdf.athome.timecode = [-1,-1];
    OUTEEG.EVENTLIST.bdf.athome.flagcode = 0;
    OUTEEG.EVENTLIST.bdf.athome.flagmask = 0;
    OUTEEG.EVENTLIST.bdf.athome.writecode = 0;
    OUTEEG.EVENTLIST.bdf.athome.writemask = 0;
    fprintf('.') 
    
    % Incorporate artifact rejection tracking
    OUTEEG.reject.rejmanual = zeros(1,OUTEEG.trials);
    OUTEEG.reject.rejmanualE = zeros(OUTEEG.nbchan,OUTEEG.trials);   
    
    % Place command in History
    
     % identify consecutive runs of numbers
    epochevents =  sort(r.Types);
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
    
    com = sprintf('%s = simpleepoch(%s, ''Window'', %s, ''Types'', %s);', inputname(1), inputname(1), mat2str(r.Window), epocheventlist);
    OUTEEG.history = sprintf('%s\n%s', OUTEEG.history, com);
    OUTEEG = simplesyncartifacts(OUTEEG, 'Direction', 'bidirectional');
    fprintf('.\n')
end
