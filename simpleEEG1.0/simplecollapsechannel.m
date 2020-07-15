function [ERP, com] = simplecollapsechannel(ERP, varargin)
%   Averages the selected channels into a single channel.
%
%   1   Input ERP File From ERPLAB
%   2   The available parameters are as follows:
%       a    'Method' - Central tendency measure [ 'Mean'  (default) | 'Median' ]
%       b    'Channels' - List of channels to collapse across.
%       c    'NewChannelName' - String to use as the new channel name.
%
%   Example Code Implementation:
%
%   ERP = simplecollapsechannel( ERP, 'Method', 'Mean', 'Channels', {'CP1', 'CPZ', 'CP2', 'P1', 'PZ', 'P2'}, 'NewChannelName', 'CPZhot');
%
%   Author: Matthew B. Pontifex, Health Behaviors and Cognition Laboratory, Michigan State University, July 12, 2020

    if ~isempty(varargin)
             r=struct(varargin{:});
    end
    com = '';
    try, r.Method; catch, r(1).Method = 'Mean'; end
    try, r.Channels; channels = {r.Channels}; catch, channels=[]; end
    
    % manage channels
    chancom = '';
    if (size(channels, 2) == 0)
        % no channels were selected
        channels = {ERP.chanlocs.labels};
    end
    if ~(size(channels, 2) == ERP.nchan) % if a subset of channels was selected then indicate which channels otherwise ignore
        chancom = sprintf('''Channels'', {');
        for cC = 1:size(channels, 2)
            chancom = sprintf('%s ''%s''', chancom,  channels{cC});
            if (cC ~= size(channels, 2))
                chancom = sprintf('%s,', chancom);
            end
        end
        chancom = sprintf('%s }, ', chancom);
    end
    
    % collapse bindata
    INERP = ERP;
    tempmat = NaN(1, ERP.pnts);
    for cC = 1:size(channels, 2)
        tempindx = find(strcmpi({ERP.chanlocs.labels}, channels{cC}));
        if ~isempty(tempindx)
            tempmat(end+1,:) = ERP.bindata(tempindx,:);
        end
    end
    if (strcmpi(r(1).Method, 'Median'))
        tempmat = double(nanmedian(tempmat,1)); % channel x time
    else
        tempmat = double(nanmean(tempmat,1)); % channel x time
    end
    tempindx = find(strcmpi({ERP.chanlocs.labels}, r(1).NewChannelName));
    if isempty(tempindx)
        ERP.bindata(end + 1,:) = tempmat; % label does not exist so will need to be added
    else
        ERP.bindata(tempindx,:) = tempmat; % label exists so just drop in
    end
    
    % collapse binerror
    tempmat = NaN(1, ERP.pnts);
    for cC = 1:size(channels, 2)
        tempindx = find(strcmpi({ERP.chanlocs.labels}, channels{cC}));
        if ~isempty(tempindx)
            tempmat(end+1,:) = ERP.binerror(tempindx,:);
        end
    end
    if (strcmpi(r(1).Method, 'Median'))
        tempmat = double(nanmedian(tempmat,1)); % channel x time
    else
        tempmat = double(nanmean(tempmat,1)); % channel x time
    end
    tempindx = find(strcmpi({ERP.chanlocs.labels}, r(1).NewChannelName));
    if isempty(tempindx)
        ERP.binerror(end + 1,:) = tempmat; % label does not exist so will need to be added
    else
        ERP.binerror(tempindx,:) = tempmat; % label exists so just drop in
    end
    
    try
        % collapse binmax
        tempmat = NaN(1, ERP.pnts);
        for cC = 1:size(channels, 2)
            tempindx = find(strcmpi({ERP.chanlocs.labels}, channels{cC}));
            if ~isempty(tempindx)
                tempmat(end+1,:) = ERP.binmax(tempindx,:);
            end
        end
        tempmat = double(nanmax(tempmat)); % channel x time
        tempindx = find(strcmpi({ERP.chanlocs.labels}, r(1).NewChannelName));
        if isempty(tempindx)
            ERP.binmax(end + 1,:) = tempmat; % label does not exist so will need to be added
        else
            ERP.binmax(tempindx,:) = tempmat; % label exists so just drop in
        end

        % collapse binmin
        tempmat = NaN(1, ERP.pnts);
        for cC = 1:size(channels, 2)
            tempindx = find(strcmpi({ERP.chanlocs.labels}, channels{cC}));
            if ~isempty(tempindx)
                tempmat(end+1,:) = ERP.binmin(tempindx,:);
            end
        end
        tempmat = double(nanmin(tempmat)); % channel x time
        tempindx = find(strcmpi({ERP.chanlocs.labels}, r(1).NewChannelName));
        if isempty(tempindx)
            ERP.binmin(end + 1,:) = tempmat; % label does not exist so will need to be added
        else
            ERP.binmin(tempindx,:) = tempmat; % label exists so just drop in
        end
    catch
        booler = 1;
    end
    
    % Manage channel label
    tempindx = find(strcmpi({ERP.chanlocs.labels}, r(1).NewChannelName));
    if isempty(tempindx)
        ERP.chanlocs(end + 1).labels = r(1).NewChannelName;
        ERP.nchan = ERP.nchan + 1;
    end
    
    com = sprintf('ERP = simplecollapsechannel(%s, ''Method'', ''%s'', %s''NewChannelName'', ''%s'');', inputname(1), r(1).Method, chancom, r(1).NewChannelName);
    ERP.history = sprintf('%s\n%s', ERP.history, com);
     
end