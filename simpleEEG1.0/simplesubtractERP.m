function [ OUTERP ] = simplesubtractERP( ALLERP, varargin)
%   Computes the difference wave of the ERP sets (ERP1-ERP2). Note bins
%   must be in the same order.
%
%   1   Input ALLERP structure containing both ERP sets
%   2   The available parameters are as follows:
%       a    'Smooth' - Optional smoothing parameter in number of points.
%       b    'Method' - [ 'Change' (default) | 'PercentChange' ].
%      
%   Example Code:
%
%   ERP = simplesubtractERP(ALLERP, 'Smooth', 20, 'Method', 'Change');
%
%   Author: Matthew B. Pontifex, Health Behaviors and Cognition Laboratory, Michigan State University, February 3, 2015
%   Revised November 7, 2017: Revision fixed issues related to computing difference waves for files with different numbers of channels
%   Revised August 1, 2019: Revision changed function name and added call to ERP.history

    if ~isempty(varargin)
        r=struct(varargin{:});
    end
    try, r.Smooth; catch, r.Smooth = 0; end
    try, r.Method; catch, r.Method = 'Change'; end
    
    OUTERP = buildERPstruct();
    
    nfiles = size(ALLERP,2); % Number of files in ALLERP structure
    if (nfiles < 2)
       error('Error in simplesubtractERP(): Only a single file is included in the ALLERP structure.')
    end
    if (nfiles > 2)
       error('Error in simplesubtractERP(): Too many files are included in the ALLERP structure.')
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
        error('Error at simplesubtractERP(). Sample Rates do not match.')
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
        error('Error at simplesubtractERP(). Bin information does not match.')
    end
    OUTERP.nbin = goodbinnum;
    OUTERP.bindescr = '';
    OUTERP.EVENTLIST.trialsperbin = 1;
    
    % Create matrix of all channels in all files
    goodchannels = {};
    goodchannels = intersect({ALLERP(1).chanlocs.labels}, {ALLERP(2).chanlocs.labels}); % Identify channels present in all data files
    
    
    % Populate location information
    OUTERP.chanlocs = ALLERP(1).chanlocs;
    for cL = 1:numel(goodchannels)
        tempcheck = find(strcmp({OUTERP.chanlocs.labels},goodchannels(cL)),1);
        if isempty(tempcheck) % Does the channel not already exist within the OUTERP structure
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
            OUTERP.chanlocs(tempcheck).urchan = []; % clear original channel index as it is irrelevant now
        end
    end
    OUTERP.nchan = size(OUTERP.chanlocs,2);
    OUTERP.ref = ALLERP(1).ref;
    
    % Create new time series based on min and max and sample rate (all rates should be the same)
    OUTERP.xmin = max([ALLERP(:).xmin]);
    OUTERP.xmax = min([ALLERP(:).xmax]);
    if (OUTERP.xmax < OUTERP.xmin)
        error('Error at simplesubtractERP(). Non-overlapping time periods provided.')
    end
    OUTERP.times = (OUTERP.xmin*1000):(1000/OUTERP.srate):(OUTERP.xmax*1000); % Convert to ms 
    OUTERP.pnts = size(OUTERP.times,2);
    
    OUTERP.erpname = [ALLERP(1).erpname, ' - ', ALLERP(2).erpname];
    OUTERP.filename = '';
    OUTERP.bindescr = {[ALLERP(1).erpname, ' - ', ALLERP(2).erpname]};

     % Load matrix
    datamatrix1 = zeros(OUTERP.nchan,OUTERP.pnts,OUTERP.nbin);
    datamatrix2 = zeros(OUTERP.nchan,OUTERP.pnts,OUTERP.nbin);
    errormatrix1 = zeros(OUTERP.nchan,OUTERP.pnts,OUTERP.nbin);
    errormatrix2 = zeros(OUTERP.nchan,OUTERP.pnts,OUTERP.nbin);
    
    for cChannels = 1:OUTERP.nchan
        tempchanindex = find(strcmp({ALLERP(1).chanlocs.labels},OUTERP.chanlocs(cChannels).labels),1);
        if ~isempty(tempchanindex) % should not be possible for it to not exist
            [m,intimemin] = min(abs(ALLERP(1).times-OUTERP.times(1)));
            [m,intimemax] = min(abs(ALLERP(1).times-OUTERP.times(end)));
            datamatrix1(cChannels,:,:) = ALLERP(1).bindata(tempchanindex,intimemin:intimemax,:);
            errormatrix1(cChannels,:,:) = ALLERP(1).binerror(tempchanindex,intimemin:intimemax,:);
        end
        tempchanindex = find(strcmp({ALLERP(2).chanlocs.labels},OUTERP.chanlocs(cChannels).labels),1);
        if ~isempty(tempchanindex) % should not be possible for it to not exist
            [m,intimemin] = min(abs(ALLERP(2).times-OUTERP.times(1)));
            [m,intimemax] = min(abs(ALLERP(2).times-OUTERP.times(end)));
            datamatrix2(cChannels,:,:) = ALLERP(2).bindata(tempchanindex,intimemin:intimemax,:);
            errormatrix2(cChannels,:,:) = ALLERP(2).binerror(tempchanindex,intimemin:intimemax,:);
        end
    end
    
     % Compute Difference Waves
    changedatamatrix = zeros(OUTERP.nchan,OUTERP.pnts,OUTERP.nbin);
    changeerrormatrix = zeros(OUTERP.nchan,OUTERP.pnts,OUTERP.nbin);
    pchangedatamatrix = zeros(OUTERP.nchan,OUTERP.pnts,OUTERP.nbin);
    
    for cChannels = 1:OUTERP.nchan
        for cBins = 1:OUTERP.nbin
            tempmat1 = datamatrix1(cChannels,:,cBins);
            tempmat2 = datamatrix2(cChannels,:,cBins);
            tempmat1err = errormatrix1(cChannels,:,cBins);
            tempmat2err = errormatrix2(cChannels,:,cBins);
            if (r.Smooth ~= 0)
                try
                    tempmat1 = fastsmooth(tempmat1,r.Smooth,2,1);
                catch
                    boolerr = 1;
                end
                try
                    tempmat2 = fastsmooth(tempmat2,r.Smooth,2,1);
                catch
                    boolerr = 1;
                end
            end
            changedatamatrix(cChannels,:,cBins) = tempmat1 - tempmat2;
            changeerrormatrix(cChannels,:,cBins) = sqrt((tempmat1.^2) + (tempmat2.^2));%http://onlinestatbook.com/2/sampling_distributions/samplingdist_diff_means.html
            
            if (strcmpi(r.Method,'PercentChange'))
                for cPoints = 1:OUTERP.pnts
                    pchangedatamatrix(cChannels,cPoints,cBins) = (changedatamatrix(cChannels,cPoints,cBins)/tempmat1(cPoints))*100;
                end
            end
        end
    end
       
    % Load data into structure
    if (strcmpi(r.Method,'PercentChange'))
        OUTERP.bindata = pchangedatamatrix;
    else
        OUTERP.bindata = changedatamatrix;
    end
    OUTERP.binerror = changeerrormatrix;
    
    % place call in history
    history1 = sprintf('\n\t File 1 History Start\n%s\n\t File 1 History Stop\n', ALLERP(1).history);
    history2 = sprintf('\n\t File 2 History Start\n%s\n\t File 2 History Stop\n', ALLERP(2).history);
    com = sprintf('%s\n%s\nERP = simplesubtractERP(ALLERP, ''Smooth'', ''%s'', ''Method'', ''%s'');', history1, history2, r.Smooth, r.Method);
    OUTERP.history = sprintf('%s\n%s', OUTERP.history, com);
end
    