function [EEG, com] = simplespectral(EEG, varargin)
% Simple call for computing the spectral activity of EEG data. This
% function will change the data in within the EEG structure. Also
% compatible with ERPLAB ERP data (.data will be put in .bindata).
%
% For Spectral computation, 
%   EEG.times will reflect the frequency range 
%   EEG.data will reflect the spectral activity (channels x frequency x epoch).
%
% For TimeFrequency computation, 
%   EEG.times will reflect the time range 
%   EEG.freqs will reflect the frequency range 
%   EEG.data will reflect the spectral activity (channels x time x epoch x frequency).
%
%   Input Parameters:
%        1    Input continuous EEG dataset From EEGLAB .
%        2   The available parameters are as follows:
%           a    'Design' [ 'Spectral' (default) | 'TimeFrequency']
%           b    'Unitpower' Parameter to select the output unit:
%                           default: 
%                                    'Absolute Power FFT (microV^{2}/Hz)' - Scale is Absolute, uses FFT() rather than newtimef()
%                                    'Log Power FFT (10*log10(microV^{2}/Hz))' - Scale is Log, uses FFT() rather than newtimef()
%                                    'Absolute Power Spectrum Density (microV^{2}/Hz)' - Scale is Absolute, Baseline is NaN, Basenorm is off
%                                    'Log Power Spectrum Density (10*log10(microV^{2}/Hz))' - Scale is Log, Baseline is NaN, Basenorm is off
%                                    'Power Spectrum Density (dB)' - Scale is Log, Baseline is provided, Basenorm is off
%                                    'Power Spectrum Density (std.)' - Scale is Absolute, Basenorm is on
%                                    'Normalized Power (% of Baseline)' - Scale is Absolute, Baseline is provided, Basenorm is off
%           c    'Baseline' Baseline correct output based on activity in range [min max] (in ms). Default is no baseline (NaN). 
%           d    'Winsize' The *longest* window length to use. This determines the lowest output frequency. Note: this parameter is overwritten when the minimum frequency requires a longer time window. default is [3] for FFT or [fix(length([EEG.times])/7)] for other calls. 
%           e    'Frequencies' Frequency range (default is [0, 50]). 
%           f    'Times' Number of output times (default is 200). Enter a negative value [-S] to subsample original times by S. Enter an array to obtain spectral decomposition at specific times.
%           g    'Padratio' Controls the outputted frequency resolution (default is 8; larger numbers increase the resolution, must be a power of 2).
%           h    'Output' [ 'Spectral' (default) | 'IntertrialCoherence']
%
%   Example Code:
%
%       >>    EEG = simplespectral(EEG,'Design','Spectral', 'Scale', 'Log Power Spectrum Density', 'Baseline', NaN);
%
%   Author: Matthew B. Pontifex, Michigan State University, August 5, 2019

    if ~isempty(varargin)
             r=struct(varargin{:});
    end
    try, r.Design; catch, r(1).Design = 'Spectral'; end
    try, r.Unitpower; catch, r(1).Unitpower = 'log'; end
    try, r.Baseline; catch, r(1).Baseline = NaN; end
    try, r.Winsize; catch, r(1).Winsize = 0; end
    try, r.Frequencies; catch, r(1).Frequencies = [0.1, 50]; end
    try, r.Times; catch, r(1).Times = 200; end
    try, r.Cycles; catch, r(1).Cycles = [0.5, 0.1]; end
    try, r.Padratio; catch, r(1).Padratio = 8; end
    try, r.Output; catch, r(1).Output = 'Spectral'; end
    
    fileindata = [];
    eegdatatype = 'EEG';
    try
        isempty(EEG.bindata);
        eegdatatype = 'ERP';
    catch
       boolerr = 1; 
    end
    if strcmpi(eegdatatype, 'EEG')
        fileindata = EEG.data;
    elseif strcmpi(eegdatatype, 'ERP')
        fileindata = EEG.bindata;
    else
        error('Error at simplespectral(). Check the inputted structure.')
    end
    
    if (size(fileindata,2) < 10)
         error('Error at simplespectral(). There is an insufficient number of points for these computations.')
    end
    
    if (strcmpi(r(1).Design, 'TimeFrequency') | (strcmpi(r(1).Design, 'TimexFrequency')))
        r(1).Design = 'TimeFrequency';
    else
        r(1).Design = 'Spectral';
        r(1).Times = 1;
    end
    if strcmpi(r(1).Output, 'IntertrialCoherence')
        r(1).Output = 'IntertrialCoherence';
    else
        r(1).Output = 'Spectral';
    end
    
    % check max frequency against functional Nyquist
    if (r(1).Frequencies(2) > fix(EEG.srate/3))
        r(1).Frequencies(2) = fix(EEG.srate/3);
    end
    if (r(1).Frequencies(1) < 0)
        r(1).Frequencies(1) = 0;
    elseif (r(1).Frequencies(1) > 0)
        r(1).Cycles(1) = (r(1).Frequencies(1)/2);
    end
    r(1).Padratio = pow2(floor(log2(r(1).Padratio))); % make sure pad ratio is a power of 2.
    
    % hack for missing datapoints - interpolate NaN
    if ~isempty(find(isnan(fileindata),1))
        fprintf(1, 'simplespectral(): Missing data detected, interpolating data - |')
        WinStart = 1;
        WinStop = size(fileindata,1);
        nSteps = 25;
        step = 1;
        strLength = fprintf(1, [repmat(' ', 1, nSteps-step) '|   0%%']);
        tic    
        
        for chanind = 1:size(fileindata,1)
            tempi = find(isnan(fileindata(chanind,:))); % find discontinuities in the data
            if ~(isempty(tempi))
                temps = inpaint_nans(double(fileindata(chanind,:)),4); % Interpolate Missing Data
                fileindata(chanind,tempi) = temps(1,tempi); % Replace with Interpolated data points
            end
            [step, strLength] = commandwaitbar(chanind, WinStop, step, nSteps, strLength); % progress bar update
        end
        % Closeout progress bar
        [step, strLength] = commandwaitbar(WinStop, WinStop, step, nSteps, strLength);
        fprintf(1, '\n')
    end
    
    % -----------------
    % ERSP scaling unit
    % -----------------   % modified from newtimef.m
    boolfft = 0;
    if ((strcmpi(r(1).Unitpower, 'abs fft') | strcmpi(r(1).Unitpower, 'Absolute Power FFT (microV^{2}/Hz)') | strcmpi(r(1).Unitpower, 'Absolute Power FFT') | strcmpi(r(1).Unitpower, 'FFT')))
        r(1).Unitpower = 'Absolute Power FFT (microV^{2}/Hz)';
        r(1).Scale = 'abs';
        r(1).Baseline = NaN;
        r(1).Basenorm = 'off';
        r(1).Design = 'Spectral';
        r(1).Output = 'Spectral';
        boolfft = 1;
    elseif ((strcmpi(r(1).Unitpower, 'log fft') | strcmpi(r(1).Unitpower, 'Log Power FFT (10*log10(microV^{2}/Hz))') | strcmpi(r(1).Unitpower, 'Log Power FFT')))
        r(1).Unitpower = 'Log Power FFT (10*log10(microV^{2}/Hz))';
        r(1).Scale = 'log';
        r(1).Baseline = NaN;
        r(1).Basenorm = 'off';
        r(1).Design = 'Spectral';
        r(1).Output = 'Spectral';
        boolfft = 1;
    elseif (strcmpi(r(1).Unitpower, 'log') | strcmpi(r(1).Unitpower, 'Log Power') | strcmpi(r(1).Unitpower, 'Log PSD') | strcmpi(r(1).Unitpower, 'Log Power Spectrum Density') | strcmpi(r(1).Unitpower, 'Log Power Spectrum Density (10*log10(microV^{2}/Hz))'))
        r(1).Unitpower = 'Log Power Spectrum Density (10*log10(microV^{2}/Hz))';
        r(1).Scale = 'log';
        r(1).Baseline = NaN;
        r(1).Basenorm = 'off';
    elseif ((strcmpi(r(1).Unitpower, 'dB') | strcmpi(r(1).Unitpower, 'Power Spectrum Density (dB)')) & ~isnan(r(1).Baseline))
        r(1).Unitpower = 'Power Spectrum Density (dB)';
        r(1).Scale = 'log';
        %r(1).Baseline = []; % user input a baseline window
        r(1).Basenorm = 'off';
    elseif (strcmpi(r(1).Unitpower, 'std.') | strcmpi(r(1).Unitpower, 'STD') | strcmpi(r(1).Unitpower, 'Power Spectrum Density (std.)'))
        r(1).Unitpower = 'Power Spectrum Density (std.)';
        r(1).Scale = 'abs';
        %r(1).Baseline = NaN | []; % either is fine
        r(1).Basenorm = 'on';
    elseif (strcmpi(r(1).Unitpower, 'abs') | strcmpi(r(1).Unitpower, 'Absolute Power') | strcmpi(r(1).Unitpower, 'Absolute PSD') | strcmpi(r(1).Unitpower, 'Abs PSD') | strcmpi(r(1).Unitpower, 'Absolute Power Spectrum Density') | strcmpi(r(1).Unitpower, 'Abs Power Spectrum Density') | strcmpi(r(1).Unitpower, 'Absolute Power Spectrum Density (microV^{2}/Hz)'))
        r(1).Unitpower = 'Absolute Power Spectrum Density (microV^{2}/Hz)';
        r(1).Scale = 'abs';
        r(1).Baseline = NaN;
        r(1).Basenorm = 'off';
    elseif (strcmpi(r(1).Unitpower, 'Normalized') | strcmpi(r(1).Unitpower, 'Percent') | strcmpi(r(1).Unitpower, 'Normalized Power (% of Baseline)'))
        r(1).Unitpower = 'Normalized Power (% of Baseline)';
        r(1).Scale = 'abs';
        %r(1).Baseline = []; % user input a baseline window
        r(1).Basenorm = 'off';
    else
        r(1).Unitpower = 'Log Power Spectrum Density (10*log10(microV^{2}/Hz))';
        r(1).Scale = 'log';
        r(1).Baseline = NaN;
        r(1).Basenorm = 'off';
    end
    
    % generate call
    if (boolfft == 1)
        % check window size
        if (r(1).Winsize == 0)
           r(1).Winsize = 3; 
        end
        com = sprintf('%s = simplespectral(%s, ''Design'', ''%s'', ''Unitpower'', ''%s'', ''Output'', ''%s'', ''Frequencies'', %s, ''Padratio'', %s, ''Winsize'', %d);', inputname(1), inputname(1), r(1).Design, r(1).Unitpower, r(1).Output, makematrixarraystr(r(1).Frequencies), num2str(fix(r(1).Padratio/8)), r(1).Winsize);
    else
        % check window size
        if (r(1).Winsize == 0)
           r(1).Winsize = fix(length([EEG.times])/7); 
        end
        if (r(1).Winsize < fix(length([EEG.times])/7))
           r(1).Winsize = fix(length([EEG.times])/7); 
        end
        com = sprintf('%s = simplespectral(%s, ''Design'', ''%s'', ''Unitpower'', ''%s'', ''Output'', ''%s'', ''Frequencies'', %s, ''Times'', %d, ''Padratio'', %d, ''Winsize'', %d, ''Baseline'', %s);', inputname(1), inputname(1), r(1).Design, r(1).Unitpower, r(1).Output, makematrixarraystr(r(1).Frequencies), r(1).Times, r(1).Padratio, r(1).Winsize, makematrixarraystr(r(1).Baseline));
    end
    
    % obtain available epochs
    if (size(fileindata,3) > 1)
        INEEG2 = EEG;
        [T, INEEG2] = evalc('pop_syncroartifacts(INEEG2, ''Direction'', ''bidirectional'');'); %synchronize artifact databases
        if (isempty(INEEG2.reject.rejmanual))
            EEG.reject.rejmanual = zeros(1,EEG.trials);
        else
            EEG.reject.rejmanual = INEEG2.reject.rejmanual;
        end
        acceptindex = find([EEG.reject.rejmanual] == 0); % find accepted trials
    else
        acceptindex = 1:size(fileindata,3);
    end
    
    % execute code
    if (boolfft == 1)
    
            fprintf(1, 'simplespectral(): Computing Spectral Power FFT - |')
            WinStart = 1;
            WinStop = size(fileindata,1);
            nSteps = 25;
            step = 1;
            strLength = fprintf(1, [repmat(' ', 1, nSteps-step) '|   0%%']);
            tic    

            % hack to always generate the output matrix of the correct size
            [T, pspectr, frequencyout] = evalc(sprintf('simpleEEGFFT(fileindata(1,:,1),''SamplingRate'', EEG.srate, ''Unitpower'', ''%s'', ''Frequencies'', %s, ''Bins'', %s, ''Maxwin'', %s);', r(1).Unitpower, makematrixarraystr([r(1).Frequencies]), num2str(fix(r(1).Padratio/8)), num2str(r(1).Winsize)));
            outmatrix = NaN(size(fileindata,1), numel(frequencyout), size(fileindata,3)); % channel x frequency x epoch

            for cChan = 1:size(fileindata,1)
                for cEpoch = 1:size(fileindata,3)
                    tmpsig = fileindata(cChan,:,cEpoch);
                    [T, pspectr, frequencyout] = evalc(sprintf('simpleEEGFFT(tmpsig,''SamplingRate'', EEG.srate, ''Unitpower'', ''%s'', ''Frequencies'', %s, ''Bins'', %s, ''Maxwin'', %s);', r(1).Unitpower, makematrixarraystr([r(1).Frequencies]), num2str(fix(r(1).Padratio/8)), num2str(r(1).Winsize)));
                    outmatrix(cChan,:,cEpoch) = pspectr;
                end
                [step, strLength] = commandwaitbar(cChan, WinStop, step, nSteps, strLength); % progress bar update
            end

            % Closeout progress bar
            [step, strLength] = commandwaitbar(WinStop, WinStop, step, nSteps, strLength);
            fprintf(1, '\n')

            EEG.times = frequencyout;
            for cEpoch = 1:size(fileindata,3) 
                EEG.event(cEpoch).latency = ((numel(frequencyout) * cEpoch) - (numel(frequencyout)-0)); % Adjust EEG.Event Latency
            end
            
            EEG.xmin = EEG.times(1);
            EEG.xmax = EEG.times(end);
            EEG.srate = round((EEG.times(2)-EEG.times(1)) * 1000/59.8,2);
    else

        tmpsig = fileindata(1,:,1);
        tmpsig = reshape(tmpsig, 1, size(tmpsig,2)*size(tmpsig,3));
        [ersp,itc,powbase,times,frequencyout] = newtimef( tmpsig, length([EEG.times]), [EEG.times(1), EEG.times(end)], EEG.srate, [r(1).Cycles],'winsize', r(1).Winsize, 'freqs', [r(1).Frequencies], 'padratio', r(1).Padratio, 'timesout', r(1).Times, 'baseline', r(1).Baseline, 'basenorm', r(1).Basenorm,'plotphase','off','plotitc','off','plotersp','off');

        if (strcmpi(r(1).Design, 'Spectral'))

            fprintf(1, 'simplespectral(): Computing Spectral Power - |')
            WinStart = 1;
            WinStop = size(fileindata,1);
            nSteps = 25;
            step = 1;
            strLength = fprintf(1, [repmat(' ', 1, nSteps-step) '|   0%%']);
            tic    

            outmatrix = NaN(size(fileindata,1), numel(frequencyout), size(fileindata,3)); % channel x frequency x epoch

            for cChan = 1:size(fileindata,1)
                for cEpoch = 1:size(fileindata,3)

                    if ~isempty(intersect(cEpoch,acceptindex)) % if the trial is accepted
                        tmpsig = fileindata(cChan,:,cEpoch);
                        tmpsig = reshape(tmpsig, 1, size(tmpsig,2)*size(tmpsig,3));
                        [T,ersp,itc,powbase,times,frequencyout] = evalc(sprintf('newtimef( tmpsig, length([EEG.times]), [EEG.times(1), EEG.times(end)], EEG.srate, [r(1).Cycles],''winsize'', r(1).Winsize, ''freqs'', [r(1).Frequencies], ''padratio'', r(1).Padratio, ''timesout'', r(1).Times, ''baseline'', r(1).Baseline, ''basenorm'', r(1).Basenorm,''plotphase'',''off'',''plotitc'',''off'',''plotersp'',''off'');'));

                        if strcmpi(r(1).Output, 'IntertrialCoherence')
                            outmatrix(cChan,:,cEpoch) = squeeze(nanmean(itc, 2));
                        else
                            outmatrix(cChan,:,cEpoch) = squeeze(nanmean(ersp,2));
                        end
                    end

                end
                [step, strLength] = commandwaitbar(cChan, WinStop, step, nSteps, strLength); % progress bar update
            end

            % Closeout progress bar
            [step, strLength] = commandwaitbar(WinStop, WinStop, step, nSteps, strLength);
            fprintf(1, '\n')

            EEG.times = frequencyout;
            for cEpoch = 1:size(fileindata,3) 
                EEG.event(cEpoch).latency = ((numel(frequencyout) * cEpoch) - (numel(frequencyout)-0)); % Adjust EEG.Event Latency
            end

            EEG.xmin = EEG.times(1);
            EEG.xmax = EEG.times(end);
            EEG.srate = round((EEG.times(2)-EEG.times(1)) * 1000/59.8,2);

        elseif (strcmpi(r(1).Design, 'TimeFrequency'))

            fprintf(1, 'simplespectral(): Computing Time x Frequency Spectral Power - |')
            WinStart = 1;
            WinStop = size(fileindata,1);
            nSteps = 25;
            step = 1;
            strLength = fprintf(1, [repmat(' ', 1, nSteps-step) '|   0%%']);
            tic    

            outmatrix = NaN(size(fileindata,1), numel(times), size(fileindata,3), numel(frequencyout)); % channel x time x epoch x frequency

            for cChan = 1:size(fileindata,1)
                for cEpoch = 1:size(fileindata,3)
                    if ~isempty(intersect(cEpoch,acceptindex)) % if the trial is accepted

                        tmpsig = fileindata(cChan,:,cEpoch);
                        tmpsig = reshape(tmpsig, 1, size(tmpsig,2)*size(tmpsig,3));
                        [T,ersp,itc,powbase,times,frequencyout] = evalc(sprintf('newtimef( tmpsig, length([EEG.times]), [EEG.times(1), EEG.times(end)], EEG.srate, [r(1).Cycles],''winsize'', r(1).Winsize, ''freqs'', [r(1).Frequencies], ''padratio'', r(1).Padratio, ''timesout'', r(1).Times, ''baseline'', r(1).Baseline, ''basenorm'', r(1).Basenorm,''plotphase'',''off'',''plotitc'',''off'',''plotersp'',''off'');'));

                        if strcmpi(r(1).Output, 'IntertrialCoherence')
                            outmatrix(cChan,:,cEpoch,:) = itc';
                        else
                            outmatrix(cChan,:,cEpoch,:) = ersp';
                        end
                    end

                end
                [step, strLength] = commandwaitbar(cChan, WinStop, step, nSteps, strLength); % progress bar update
            end

            % Closeout progress bar
            [step, strLength] = commandwaitbar(WinStop, WinStop, step, nSteps, strLength);
            fprintf(1, '\n')

            EEG.freqs = frequencyout;

        end
    end
    
    % Store data
    if strcmpi(eegdatatype, 'EEG')
        EEG.data = outmatrix;
    else
        EEG.bindata = outmatrix;
    end
    EEG.pnts = size(outmatrix,2);
    
    EEG.history = sprintf('%s\n%s', EEG.history, com);
end

