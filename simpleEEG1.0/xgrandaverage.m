function [ OUTERP ] = xgrandaverage( ALLERP, varargin)
%   Computes the grand average ERP based upon the ERPLAB bin structure,
%   retaining only those channels present in all inputted files.
%
%   1   Input ALLERP structure containing multiple ERP sets
%   2   The available parameters are as follows:
%       a    'Method' - Central tendency measure [ 'Mean'  (default) | 'Median' ]
%       b    'Variance' - Output [ 'SD' | 'SE' (default) ].
%       c    'Recompute' - [ 'True'  (default) | 'False' ]. Optional
%               parameter to compute the error/min/max of all the files that contributed to the mean (default)
%               or to compute the mean of the error/min/max data  already present within each of the files.
%       d    'Smooth' - Optional smoothing parameter in number of points.
%      
%   Example Code:
%
%       ERP = xgrandaverage(ALLERP, 'Method', 'Mean', 'Variance', 'SE', 'Recompute', 'True', 'Smooth', 20);
%
%   Author: Matthew B. Pontifex, Health Behaviors and Cognition Laboratory, Michigan State University, January 28, 2015
%  3-20-15: revised to take inputs with different numbers of channels and epoch lengths - mp
%  3-24-15: revised to allow for computation of median/min/max - mp
%  4-17-15: revised to pull peak information
%  

    if ~isempty(varargin)
             r=struct(varargin{:});
    end
    try, r.Method; catch, r.Method = 'Mean'; end
    try, r.Variance; catch, r.Variance = 'SE'; end
    try, r.Recompute; catch, r.Recompute = 'True'; end
    try, r.Smooth; catch, r.Smooth = 0; end
    try, r.Peaks; catch, r.Peaks = 'True'; end
    
    OUTERP = buildERPstruct();
    
    nfiles = size(ALLERP,2); % Number of files in ALLERP structure
    if (nfiles < 2)
       error('Error in xgrandaverage(): Only a single file is included in the ALLERP structure.')
    end
    OUTERP.nfiles = nfiles;
    
    % Check Sample Rates
    goodrates = ALLERP(1).srate;
    boolcont = 1;
    for cF = 2:nfiles
        if (ALLERP(cF).srate ~= goodrates)
            boolcont = 0;
        end
    end
    if (boolcont == 0)
        error('Error at xgrandaverage(). Sample Rates do not match.')
    end
    OUTERP.srate = goodrates;
    
    % Check Bin information
    goodbinnum = ALLERP(1).nbin;
    boolcont = 1;
    for cF = 2:nfiles
        if (goodbinnum ~= ALLERP(cF).nbin)
            boolcont = 0;
        end
    end
    if (boolcont == 0)
        error('Error at xgrandaverage(). Bin information does not match.')
    end
    OUTERP.nbin = goodbinnum;
    OUTERP.bindescr = '';
    OUTERP.EVENTLIST.trialsperbin = 1;
    
    % Create matrix of all channels in all files
    goodchannels = {};
    for cF = 1:nfiles
        temp = {ALLERP(cF).chanlocs.labels};
        goodchannels = [goodchannels, temp];
    end
    goodchannels = unique(goodchannels); % remove any duplicate channels
    
    % Populate location information
    OUTERP.chanlocs = ALLERP(1).chanlocs;
    for cL = 1:numel(goodchannels)
        if isempty(find(strcmp({OUTERP.chanlocs.labels},goodchannels(cL)))); % Does the channel not already exist within the OUTERP structure
            tempfill = []; cF = 1;
            while isempty(tempfill)
                temp = find(strcmp({ALLERP(cF).chanlocs.labels},goodchannels(cL)));
                 if ~isempty(temp) % If the ALLERP file has the channel
                     tempfill = ALLERP(cF).chanlocs(temp);
                 end
                cF = cF + 1; 
                if (cF > nfiles), break; end % this should not be possible
            end
            nindex = size(OUTERP.chanlocs,2)+1;
            OUTERP.chanlocs(nindex).labels = tempfill.labels;
            try
                OUTERP.chanlocs(nindex).type = tempfill.type;
                OUTERP.chanlocs(nindex).theta = tempfill.theta;
                OUTERP.chanlocs(nindex).radius = tempfill.radius;
                OUTERP.chanlocs(nindex).X = tempfill.X;
                OUTERP.chanlocs(nindex).Y = tempfill.Y;
                OUTERP.chanlocs(nindex).Z = tempfill.Z;
                OUTERP.chanlocs(nindex).sph_theta = tempfill.sph_theta;
                OUTERP.chanlocs(nindex).sph_phi = tempfill.sph_phi;
                OUTERP.chanlocs(nindex).sph_radius = tempfill.sph_radius;
            catch
                boolerr = 1;
            end
        else
            try
                OUTERP.chanlocs(find(strcmp({OUTERP.chanlocs.labels},goodchannels(cL)))).urchan = []; % clear original channel index as it is irrelevant now
            catch
                booler = 1;
            end
        end
    end
    OUTERP.nchan = size(OUTERP.chanlocs,2);
    OUTERP.ref = ALLERP(1).ref;
    
    % Create new time series based on min and max and sample rate (all rates should be the same)
    OUTERP.xmin = max([ALLERP(:).xmin]);
    OUTERP.xmax = min([ALLERP(:).xmax]);
    OUTERP.times = (OUTERP.xmin*1000):(1000/OUTERP.srate):(OUTERP.xmax*1000); % Convert to ms 
    OUTERP.pnts = size(OUTERP.times,2);
    
    % Check that files have error/min/max computed already
    if ~(strcmpi(r.Recompute, 'True')) % if attempting to compute the mean variance rather than the variance surrounding the mean.
        boolcont = 1;
        for cF = 1:nfiles
            if (isempty(ALLERP(cF).binerror))
                boolcont = 0;
            end
            if ~(isfield(ALLERP(cF),'binmax'))
                boolcont = 0;
            end
            if ~(isfield(ALLERP(cF),'binmin'))
                boolcont = 0;
            end
        end
        if (boolcont == 0)
            error('Error at xgrandaverage(). Requested computation of the mean error/min/max, but not every file reports this information.')
        end
    end
    
    % Compute Channel Means
    for cBins = 1:OUTERP.nbin
        masterdatamatrix = NaN(nfiles,OUTERP.pnts,OUTERP.nchan);
        mastererrormatrix = NaN(nfiles,OUTERP.pnts,OUTERP.nchan);
        meandatamatrix = NaN(OUTERP.nchan,OUTERP.pnts);
        minimumdatamatrix = NaN(OUTERP.nchan,OUTERP.pnts);
        maximumdatamatrix = NaN(OUTERP.nchan,OUTERP.pnts);
        variancedatamatrix = NaN(OUTERP.nchan,OUTERP.pnts);
        stddatavector = NaN(1,OUTERP.pnts);
        sedatavector = NaN(1,OUTERP.pnts);
        for cChannels = 1:OUTERP.nchan
            % Calculate mean
            for cFiles = 1:nfiles
                tempchanindex = find(strcmp({ALLERP(cFiles).chanlocs.labels},OUTERP.chanlocs(cChannels).labels),1);
                if ~isempty(tempchanindex) % if the channel exists populate the master matrix, if it does not then skip it because the matrix contains NaN
                    try
                        masterdatamatrix(cFiles,find(OUTERP.times==(ALLERP(cFiles).xmin*1000)):find(OUTERP.times==(ALLERP(cFiles).xmax*1000)),cChannels) = ALLERP(cFiles).bindata(tempchanindex,:,cBins);
                    catch
                        [~,tstrtime] = min(abs(OUTERP.times-(ALLERP(cFiles).xmin*1000)));
                        [~,tstptime] = min(abs(OUTERP.times-(ALLERP(cFiles).xmax*1000)));
                        masterdatamatrix(cFiles,tstrtime:tstptime,cChannels) = ALLERP(cFiles).bindata(tempchanindex,tstrtime:tstptime,cBins);
                    end
                end
            end
            if (strcmpi(r.Method,'Mean'))
                meandatamatrix(cChannels,:) = nanmean(masterdatamatrix(:,:,cChannels)); % Compute mean ignoring NAN
            end
            if (strcmpi(r.Method,'Median'))
                meandatamatrix(cChannels,:) = nanmedian(masterdatamatrix(:,:,cChannels)); % Compute median ignoring NAN
            end
            
            if (strcmpi(r.Recompute, 'True')) % Calculate variance/min/max surrounding the mean
                minimumdatamatrix(cChannels,:) = min(masterdatamatrix(:,:,cChannels));
                maximumdatamatrix(cChannels,:) = max(masterdatamatrix(:,:,cChannels));
                stddatavector(1,:) = nanstd(masterdatamatrix(:,:,cChannels));
                if (strcmpi(r.Variance,'SE'))
                   tempnancount = isnan(std(masterdatamatrix(:,:,cChannels)));
                    for cPoints = 1:OUTERP.pnts
                        sedatavector(1,cPoints) = stddatavector(1,cPoints)/(sqrt(nfiles)-tempnancount(cPoints)); % Divide each SD value by the square root of the number of files minus missing files for that point
                    end
                    variancedatamatrix(cChannels,:) = sedatavector(1,:);
                else
                    variancedatamatrix(cChannels,:) = stddatavector(1,:);
                end
            else % Calculate mean variance/min/max
                for cFiles = 1:nfiles      
                    tempchanindex = find(strcmp({ALLERP(cFiles).chanlocs.labels},OUTERP.chanlocs(cChannels).labels));
                    if ~isempty(tempchanindex) % if the channel exists populate the master matrix, if it does not skip it because the matrix contains NaN
                        try
                            mastererrormatrix(cFiles,find(OUTERP.times==(ALLERP(cFiles).xmin*1000)):find(OUTERP.times==(ALLERP(cFiles).xmax*1000)),cChannels) = ALLERP(cFiles).binerror(tempchanindex,:,cBins);
                        catch
                            mastererrormatrix(cFiles,:,cChannels) = ALLERP(cFiles).binerror(tempchanindex,:,cBins);
                        end
                    end
                end
                variancedatamatrix(cChannels,:) = nanmean(mastererrormatrix(:,:,cChannels));
               
                mastererrormatrix = NaN(nfiles,OUTERP.pnts,OUTERP.nchan);  % Reset for computation of minimum
                for cFiles = 1:nfiles      
                    tempchanindex = find(strcmp({ALLERP(cFiles).chanlocs.labels},OUTERP.chanlocs(cChannels).labels));
                    if ~isempty(tempchanindex) % if the channel exists populate the master matrix, if it does not skip it because the matrix contains NaN
                        try
                            mastererrormatrix(cFiles,find(OUTERP.times==(ALLERP(cFiles).xmin*1000)):find(OUTERP.times==(ALLERP(cFiles).xmax*1000)),cChannels) = ALLERP(cFiles).binmin(tempchanindex,:,cBins);
                        catch
                            mastererrormatrix(cFiles,:,cChannels) = ALLERP(cFiles).binmin(tempchanindex,:,cBins);
                        end
                    end
                end
                minimumdatamatrix(cChannels,:) = nanmean(mastererrormatrix(:,:,cChannels));
                
                mastererrormatrix = NaN(nfiles,OUTERP.pnts,OUTERP.nchan);  % Reset for computation of maximum
                for cFiles = 1:nfiles      
                    tempchanindex = find(strcmp({ALLERP(cFiles).chanlocs.labels},OUTERP.chanlocs(cChannels).labels));
                    if ~isempty(tempchanindex) % if the channel exists populate the master matrix, if it does not skip it because the matrix contains NaN
                        try
                            mastererrormatrix(cFiles,find(OUTERP.times==(ALLERP(cFiles).xmin*1000)):find(OUTERP.times==(ALLERP(cFiles).xmax*1000)),cChannels) = ALLERP(cFiles).binmax(tempchanindex,:,cBins);
                        catch
                            mastererrormatrix(cFiles,:,cChannels) = ALLERP(cFiles).binmax(tempchanindex,:,cBins);
                        end
                    end
                end
                maximumdatamatrix(cChannels,:) = nanmean(mastererrormatrix(:,:,cChannels));
            end

            % Smooth data if necessary
            if (r.Smooth > 0)
                meandatamatrix(cChannels,:) = fastsmooth(meandatamatrix(cChannels,:), r.Smooth, 2, 1);
                variancedatamatrix(cChannels,:) = fastsmooth(variancedatamatrix(cChannels,:), r.Smooth, 2, 1);
                minimumdatamatrix(cChannels,:) = fastsmooth(minimumdatamatrix(cChannels,:), r.Smooth, 2, 1);
                maximumdatamatrix(cChannels,:) = fastsmooth(maximumdatamatrix(cChannels,:), r.Smooth, 2, 1);
            end
        end

        % Load data into structure
        OUTERP.bindata(:,:,cBins) = meandatamatrix;
        OUTERP.binerror(:,:,cBins) = variancedatamatrix;
        OUTERP.binmin(:,:,cBins) = minimumdatamatrix;
        OUTERP.binmax(:,:,cBins) = maximumdatamatrix;
    end
    
    if (strcmpi(r.Peaks, 'True'))
        % Check to see if peak information is saved within the ALLERP structure
        partwarninglist = [];
        for cF = 1:nfiles
            if (isfield(ALLERP(cF),'peaks'))
                if isempty(ALLERP(cF).erpname)
                    OUTERP.peaks.(sprintf('file_%d',cF)) = ALLERP(cF).peaks;
                else
                    try
                        peakname = cell2mat(ALLERP(cF).erpname);
                    catch
                        peakname = ALLERP(cF).erpname;
                    end
                    checkvalstring = strfind(peakname,'-'); peakname(checkvalstring)='';
                    checkvalstring = strfind(peakname,'_'); peakname(checkvalstring)='';
                    OUTERP.peaks.(sprintf('%s',peakname)) = ALLERP(cF).peaks;
                end
            else
                if isempty(ALLERP(cF).erpname)
                    OUTERP.peaks.(sprintf('file_%d',cF)) = [];
                else
                    try
                        OUTERP.peaks.(sprintf('%s',cell2mat(ALLERP(cF).erpname))) = [];
                    catch
                        try
                            OUTERP.peaks.(sprintf('%s',ALLERP(cF).erpname)) = [];
                        catch
                            boolerr = 1;
                        end
                    end
                end
                partwarninglist(end+1) = cF; % add participant to list
            end
        end
        if ~isempty(partwarninglist)
            if (size(partwarninglist,2) < nfiles)
                fprintf('Peak information not available for ALLERP indices: %s', mat2str(partwarninglist));
            end 
        else
            try
                names = {};
                for cF = 1:nfiles
                    if (isfield(ALLERP(cF),'peaks'))
                        names = unique(vertcat(names,fieldnames(ALLERP(cF).peaks))); % combine and remove duplicate names
                    end
                end
                for cN = 1:numel(names) % For each peak label
                    outstruct = struct('channel', [], 'amplitude', [], 'error', [], 'latency', [], 'label', {}, 'minimum', [], 'maximum', []);
                    for cC = 1:size(OUTERP.chanlocs,2) % For each channel in ERP set
                        mastermat = NaN(nfiles,5);
                        for cF = 1:nfiles % For each file
                            if (isfield(ALLERP(cF),'peaks')) % Does it contain peak information
                                if (isfield(ALLERP(cF).peaks,names(cN))) % Does it contain peak information for that peak label
                                    tempind = find(strcmpi(eval(sprintf('{ALLERP(cF).peaks.%s.channel}', names{cN})),OUTERP.chanlocs(cC).labels));
                                    if ~isempty(tempind) % If the channel has peak information
                                        tempvect = eval(sprintf('[ALLERP(cF).peaks.%s.amplitude]', names{cN}));
                                        mastermat(cF,1) = tempvect(tempind);
                                        tempvect = eval(sprintf('[ALLERP(cF).peaks.%s.error]', names{cN}));
                                        mastermat(cF,2) = tempvect(tempind);
                                        tempvect = eval(sprintf('[ALLERP(cF).peaks.%s.latency]', names{cN}));
                                        mastermat(cF,3) = tempvect(tempind);
                                        tempvect = eval(sprintf('[ALLERP(cF).peaks.%s.minimum]', names{cN}));
                                        mastermat(cF,4) = tempvect(tempind);
                                        tempvect = eval(sprintf('[ALLERP(cF).peaks.%s.maximum]', names{cN}));
                                        mastermat(cF,5) = tempvect(tempind);
                                    end
                                end
                            end
                        end
                        outstruct(cC).channel = OUTERP.chanlocs(cC).labels;
                        outstruct(cC).label = names(cN);
                        tempmean = nanmean(mastermat);
                        outstruct(cC).amplitude = tempmean(1);
                        outstruct(cC).error = tempmean(2);
                        outstruct(cC).latency = tempmean(3);
                        outstruct(cC).minimum = tempmean(4);
                        outstruct(cC).maximum = tempmean(5);
                        outstruct(cC).fullarray = mastermat;
                    end
                    OUTERP.peaks.GA.(sprintf('%s',names{cN})) = outstruct;
                end
            catch
                fprintf('Peak GA information not available for ALLERP indices\n');
                boolerr = 1;
            end

        end
    end
    
end
    