function [badchannels] = catchbadchannels(EEG, varargin)
%   Returns a list of channels which deviate from other channels in the EEG
%   array based on either the Z score of the variance of the channel
%   relative to a smoothed ideal or the mean point-by-point Z score of the channel.
%
%   1   Input EEG File From EEGLAB
%   2   The available parameters are as follows:
%       a   'Smoothed' - Z scores each channel based on the variance of the channel data relative to the channel data smoothed using a sliding gaussian function.
%       b   'PointByPoint' - Z scores each point across all channels to identify if a channel's mean Z score consistently deviates from the mean Z score of other channels in the array.
%       c   'Trim' - Number of values to trim from the extremes before Z scoring
%       d   'Skip' - Channels to skip
%
%   Example Code Implementation:
%
%   badchanneldata = catchbadchannels( EEG, 'Smoothed', 20, 'Trim', 2, 'Skip', {'VEO', 'HEO', 'M1', 'M2'});
%   badchannelpoints = catchbadchannels( EEG, 'PointByPoint', 20, 'Trim', 2, 'Skip', {'VEO', 'HEO', 'M1', 'M2'});
%   badchannels = unique(horzcat(badchanneldata, badchannelpoints));
%   if (size(badchannels, 2) > 0)
%       fprintf('\nChannel(s) %s where identified as bad.\n\n', [badchannels{:}]);
%       EEG = pop_select( EEG, 'nochannel', badchannels);
%    else
%       fprintf('\nNo channels met the specified criteria for removal.\n\n');
%    end
%   
%   or
%
%   badchannels = catchbadchannels( EEG, 'Smoothed', 20, 'PointByPoint', 20, 'LineNoise', 20, 'Trim', 2, 'Skip', {'VEO', 'HEO', 'M1', 'M2'});
%
%   Author: Matthew B. Pontifex, Health Behaviors and Cognition Laboratory, Michigan State University, July 21, 2014
%
%  revision August 9, 2019 to compute FFT for each channel and assess 60 Hz line noise

    if ~isempty(varargin)
             r=struct(varargin{:});
    end
    
    try r.Smoothed; zcritSmooth =  r.Smoothed; zcritSmooth = abs(zcritSmooth);  catch zcritSmooth=0; end
    try r.PointByPoint; zcritPoint =  r.PointByPoint; zcritPoint =  abs(zcritPoint); catch zcritPoint=0; end
    try r.LineNoise; zcritLineNoise =  r.LineNoise; zcritLineNoise = abs(zcritLineNoise); catch zcritLineNoise=20; end
    try r.Trim; trimval =  r.Trim; catch trimval=0; end
    try r.Skip; skipchan = {r.Skip}; catch skipchan=[]; end
    
    if ((zcritSmooth == 0) && (zcritPoint == 0) && (zcritLineNoise == 0))
         error('Error at catchbadchannels(). Missing information for how bad channels should be identified.')
    end
  
    INEEG = EEG;
    fprintf(1, 'catchbadchannels(): Preparing data (this may take a moment)...\n')
    %Skip channels specified
    if ~isempty(skipchan) & (~strcmpi(skipchan{1}, "")) & (~isempty(skipchan{1}))
        [T, INEEG] = evalc('pop_select( INEEG, ''nochannel'', skipchan);'); % Remove skipped channels
    end
    
    r = size(INEEG.chanlocs, 2);
    c = size(INEEG.data, 2);
    
    %Create coding array
    r = size(INEEG.chanlocs, 2);
    badchanlist = zeros(1,r);
    
    if (zcritLineNoise ~= 0)
        fprintf(1, 'catchbadchannels(): Assessing 60hz line noise - |')
    
        % Setup Controls for Progress Bar
        WinStart = 1;
        WinStop = size(INEEG.data,1);
        nSteps = 25;
        step = 1;
        strLength = fprintf(1, [repmat(' ', 1, nSteps-step) '|   0%%']);
        tic
        
        tempmat = INEEG.data;
        specmat=[];
        for rN=1:size(INEEG.data, 1)
            [pspectr, freq] = simpleEEGFFT(tempmat(rN,:,:),'SamplingRate', INEEG.srate, 'Unitpower', 'Absolute Power Spectrum Density (microV^{2}/Hz)', 'Frequencies', [0, 80]);
            if isempty(specmat)
                specmat = pspectr;
            else
                specmat(end+1,:) = pspectr;
            end
            [step, strLength] = commandwaitbar(rN, WinStop, step, nSteps, strLength); % progress bar update
        end
        
        [~, winstart1] = min(abs(freq-40));
        [~, winstop1] = min(abs(freq-55));
        [~, winstart2] = min(abs(freq-65));
        [~, winstop2] = min(abs(freq-75));
        
        matrixout = NaN(size(INEEG.data, 1),1);
        for rN=1:size(INEEG.data, 1)
            if (badchanlist(rN) == 0)
                matrixout(rN,1) = nanmean(specmat(rN,winstop1:winstart2)) - nanmean(specmat(rN,[winstart1:winstop1,winstart2:winstop2]));
            end
        end
        [step, strLength] = commandwaitbar(WinStop, WinStop, step, nSteps, strLength);
        
        tempZ = abs(trimzscore(matrixout, 'trimMin', trimval, 'trimMax', trimval)); % absolute Z score noise level    
        
        %Identify bad channel based on Z score
        goodchannelsstart = numel(find(badchanlist == 0));
        for m=1:r
           if (tempZ(m) > zcritLineNoise)
               badchanlist(m) = 1;
           end
        end 
        goodchannelsstop = numel(find(badchanlist == 0));
        outcall = sprintf(' - \tidentified %d channels\n', (goodchannelsstart-goodchannelsstop));
        fprintf(1, outcall)
    end
    
    
    if (zcritSmooth ~= 0) | (zcritPoint ~= 0)
        %Removes the DC Offset
        for m=1:r
            INEEG.data(m, :,:) = (INEEG.data(m, :, :) - INEEG.data(m,1,1));
        end
    end
    
    
    if (zcritSmooth ~= 0)
        fprintf(1, 'catchbadchannels(): Computing moving weighted variance - |')
    
        % Setup Controls for Progress Bar
        WinStart = 1;
        WinStop = size(INEEG.data,1);
        nSteps = 25;
        step = 1;
        strLength = fprintf(1, [repmat(' ', 1, nSteps-step) '|   0%%']);
        tic
        
        tempmat = INEEG.data;
        for rN=1:size(INEEG.data, 1)
            if (badchanlist(rN) == 0)
                try,
                    tempmat(rN,:,:) = gaussmooth(tempmat(rN,:,:), 'Window', floor(100 /((1/EEG.srate)*1000)), 'Sigma', 2.0);
                catch,
                    boolpass = 1;
                end
            end
            [step, strLength] = commandwaitbar(rN, WinStop, step, nSteps, strLength); % progress bar update
        end
        tempdif = INEEG.data - tempmat;
        tempdif = power(tempdif,2);
        matrixout = NaN(size(INEEG.data, 1),1);
        for rN=1:size(INEEG.data, 1)
            if (badchanlist(rN) == 0)
                matrixout(rN,1) = mean(tempdif(rN,:));
            end
        end
        [step, strLength] = commandwaitbar(WinStop, WinStop, step, nSteps, strLength);
        
        tempZ = abs(trimzscore(matrixout, 'trimMin', trimval, 'trimMax', trimval)); % absolute Z score channel variance    
        
        %Identify bad channel based on Z score
        goodchannelsstart = numel(find(badchanlist == 0));
        for m=1:r
           if (tempZ(m) > zcritSmooth)
               badchanlist(m) = 1;
           end
        end 
        goodchannelsstop = numel(find(badchanlist == 0));
        outcall = sprintf(' - \tidentified %d channels\n', (goodchannelsstart-goodchannelsstop));
        fprintf(1, outcall)
    end
    
    if (zcritPoint ~= 0)
        fprintf(1, 'catchbadchannels(): Computing point by point variance - |')
    
        % Setup Controls for Progress Bar
        WinStart = 1;
        WinStop = c;
        nSteps = 25;
        step = 1;
        strLength = fprintf(1, [repmat(' ', 1, nSteps-step) '|   0%%']);
        tic
        
        goodchannels = find(badchanlist == 0);
        %Zscore columns
        for n=2:c
            tempZ = abs(trimzscore(INEEG.data(goodchannels,n,:), 'trimMin', trimval, 'trimMax', trimval)); % absolute Zscore point variance
            INEEG.data(goodchannels,n,:) = tempZ(:);
            [step, strLength] = commandwaitbar(n, WinStop, step, nSteps, strLength); % progress bar update
        end
        [step, strLength] = commandwaitbar(WinStop, WinStop, step, nSteps, strLength);

        %Compute mean absolute Z score for each channel
        meanchan = NaN(r,1);
        for m=1:r
            if (badchanlist(m) == 0)
                meanchan(m) = mean(INEEG.data(m,:));
            end
        end

        %Identify bad channel based on Z score above criteria
        goodchannelsstart = numel(find(badchanlist == 0));
        for m=1:r
           if (meanchan(m) > zcritPoint)
               badchanlist(m) = 1;
           end
        end  
        goodchannelsstop = numel(find(badchanlist == 0));
        outcall = sprintf(' - \tidentified %d channels\n', (goodchannelsstart-goodchannelsstop));
        fprintf(1, outcall)
    end
    
    % Build array of bad channel labels
     nbadcharray = {};
     for index=1:r
          if (badchanlist(index) == 1)
              tempval = INEEG.chanlocs(index).('labels');
              nbadcharray(end+1) =  cellstr(tempval); 
          end
     end
     badchannels = nbadcharray;
     
     if (numel(nbadcharray) == 0)
         outcall = sprintf('catchbadchannels(): No channels identified.\n');
         fprintf(1, outcall)
     else
         outcall = sprintf('catchbadchannels(): The following channels were identified as bad: %s\n', makecellarraystr(badchannels));
         fprintf(1, outcall)
     end
     
end