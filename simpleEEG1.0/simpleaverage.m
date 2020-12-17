
function [ ERP ] = simpleaverage( EEG, varargin)
%   Computes the average ERP from an epoched EEG dataset.
%
%   1   Input epoched EEG structure
%   2   The available parameters are as follows:
%       a    'Method' - Central tendency measure [ 'Mean'  (default) | 'Median' ]
%       b    'Variance' - Output [ 'SD' | 'SE' (default) ].
%      
%   Example Code:
%
%       ERP = simpleaverage(EEG, 'Method', 'Mean', 'Variance', 'SE');
 
    if ~isempty(varargin)
             r=struct(varargin{:});
    end
    try, r.Method; catch, r(1).Method = 'Mean'; end
    try, r.Variance; catch, r(1).Variance = 'SE'; end
    try, r.Sync; catch, r(1).Sync = 'True'; end
    
    % make sure everything is up to date
    if strcmpi(r(1).Sync, 'True')
        try
            EEG = simplesyncartifacts(EEG, 'Direction', 'bidirectional');
        catch
            booler = 1;
        end
    end
    EEG = eeg_checkset(EEG);
    ERP = buildERPstruct(EEG); %nchan, nbin, pnts, srate, xmin,xmax,times,chanlocs are all automatically extracted
    ERP.erpname = EEG.setname;
    ERP.filename = EEG.filename;
    ERP.filepath = EEG.filepath;
    ERP.ntrials.accepted = sum(~EEG.reject.rejmanual);
    ERP.ntrials.rejected = sum(EEG.reject.rejmanual);
    ERP.pexcluded  = round((sum(ERP.ntrials.rejected)/(sum(ERP.ntrials.accepted)+sum(ERP.ntrials.rejected)))*100,1);
    ERP.times = EEG.times;
    
    % in case channel labels are empty - shouldnt be possible but pulled from averager
    if isempty(ERP.chanlocs)
        for cc = 1:ERP.nchan
            ERP.chanlocs(cc).labels = ['Ch:' num2str(cc)];
        end
    end
    
    acceptedepochs = find([EEG.reject.rejmanual] == 0); % find accepted trials
    epochdataframe = EEG.data(:,:,acceptedepochs); % channel x time x accepted epochs
    
    if (strcmpi(r(1).Method, 'Median'))
        ERP.bindata = double(nanmedian(epochdataframe,3)); % channel x time
    else
        ERP.bindata = double(nanmean(epochdataframe,3)); % channel x time
    end
    
    ERP.binerror = nanstd(epochdataframe,[],3); % channel x time
    if (strcmpi(r(1).Variance,'SE')) % slow but reliable
        for cChannels = 1:ERP.nchan
            for cPoints = 1:ERP.pnts
                 % number included
                ERP.binerror(cChannels,cPoints) = ERP.binerror(cChannels,cPoints)/sqrt(sum(~isnan(squeeze(epochdataframe(cChannels,cPoints,:))))); % Divide each SD value by the square root of the number of included trials
 
            end
        end
    end
    ERP.binerror = double(ERP.binerror);
    ERP.binmax = nanmax(epochdataframe,[],3);
    ERP.binmin = nanmin(epochdataframe,[],3);
    ERP.peaks = [];
    ERP.peakdata = struct('Channel', [], 'Time', [], 'Latency', [], 'Label', []);
    
    ERP.nbin = size(ERP.bindata,3);
    ERP.bindescr = {'bin'};
    ERP.nchan = size(ERP.bindata,1); 
    
    com = sprintf('ERP = simpleaverage(%s, ''Method'', ''%s'', ''Variance'', ''%s'');', inputname(1), r(1).Method, r(1).Variance);
    ERP.history = sprintf('%s\n%s', ERP.history, com);
 
end
