function EEG = simpleEEGfilter(EEG, varargin)
% Simple call for filtering using the signal processing toolbox.
%
%   Input Parameters:
%        1    Input continuous EEG dataset From EEGLAB .
%        2   The available parameters are as follows:
%           a    'Filter' ['Lowpass' (default) | 'Highpass' | 'Bandpass' | 'Notch'].
%           b    'Design' [ 'Windowed Symmetric FIR' (default) | 'IIR Butterworth']
%           c    'Cutoff' The frequency cutoffs (Hz). Default is 30, for a 30 Hz low-pass filter.
%           d    'Order' default is (3*fix(EEG.srate/0.5))
%
%   Example Code:
%
%       >>    EEG = simpleEEGfilter(EEG,'Filter','Bandpass','Design','Windowed Symmetric FIR','Cutoff',[0.5, 30],'Order',fix(EEG.srate/0.5));
%
%   Author: Matthew B. Pontifex, Michigan State University, July 29, 2019

    if ~isempty(varargin)
             r=struct(varargin{:});
    end
    try, r.Filter; catch, r.Filter = 'Lowpass'; end
    try, r.Design; catch, r.Design = 'Windowed Symmetric FIR'; end
    try, r.Cutoff; catch, r.Cutoff = 0.05; end
    try, r.Order; catch, r.Order = (3*fix(EEG.srate/0.5)); end
    try, r.Channels; catch, r.Channels = 1:size(EEG.chanlocs,2); end
    
    %     EEG         - input dataset
%     chanArray   - channel(s) to filter
%     locutoff    - lower edge of the frequency pass band (Hz)  {0 -> lowpass}
%     hicutoff    - higher edge of the frequency pass band (Hz) {0 -> highpass}
%     filterorder - length of the filter in points {default 3*fix(srate/locutoff)}
%     typef       - type of filter: 0=means IIR Butterworth;  1 = means FIR
%     remove_dc   - remove dc offset before filtering. 1 yes; 0 no
%     boundary    - event code for boundary events. e.g. 'boundary'

% 
% locutoff = 0.5;
% hicutoff = 30;
% filterorder = 2;
% [b, a, labelf, v] = filter_tf(0, filterorder, hicutoff, locutoff, EEG.srate);
% EEG.data = filtfilt(b,a, double(EEG.data)')';
%                 
% load noisysignals x;                    % noisy waveform
% [b,a] = butter(12,0.2,'low');           % IIR filter design
% y = filtfilt(b,a,x);                    % zero-phase filtering
% y2 = filter(b,a,x);                     % conventional filtering
% plot(x,'k-.'); grid on ; hold on
% plot([y y2],'LineWidth',1.5);
% legend('Noisy ECG','Zero-phase Filtering','Conventional Filtering');

    if (ischar(r.Cutoff))
        r.Cutoff = str2num(r.Cutoff);
    end

    boolEEG = 0;
    boolERP = 0;
    try
        if ~isempty(EEG.data)
            boolEEG = 1;
        end
    catch
        boolerr = 1;
    end
    try
        if ~isempty(EEG.bindata)
            boolERP = 1;
        end
    catch
        boolerr = 1;
    end
    if (boolERP == 0) & (boolEEG == 0)
        error('Error at simpleEEGfilter(). Data does not appear to be from either a EEGLAB or ERPLAB dataset.');
    end
    
    com = sprintf('%s = simpleEEGfilter(%s, ''Design''', inputname(1), inputname(1));
    
    % design check
    if (strcmpi(r.Design, 'FIR')) | (strcmpi(r.Design, 'Windowed Symmetric FIR'))
        if strcmpi(r(1).Filter, 'Notch')
            r(1).Design = 'IIR Butterworth';
        end
    end

    if ((strcmpi(r.Design, 'Butter')) | (strcmpi(r.Design, 'Butterworth')) | (strcmpi(r.Design, 'IIR')) | (strcmpi(r.Design, 'IIR Butterworth')))
        com = sprintf('%s, ''IIR Butterworth''', com);
    elseif (strcmpi(r.Design, 'FIR')) | (strcmpi(r.Design, 'Windowed Symmetric FIR'))
        com = sprintf('%s, ''Windowed Symmetric FIR''', com);
    elseif ~((r.Design == 0) | (r.Design == 1) | (r.Design == 2))
        error('simpleEEGfilter(): Filter design can be IIR Butterworth or Windowed Symmetric FIR.');
    end
    
    com = sprintf('%s, ''Filter'', ''%s'', ''Cutoff''', com, r(1).Filter);
    lowcut = 0;
    highcut = 0;
    if strcmpi(r(1).Filter, 'Lowpass')
       r(1).Filter = 'Lowpass';
       highcut = r(1).Cutoff(end);
       com = sprintf('%s, %s', com, num2str(highcut));
    elseif strcmpi(r(1).Filter, 'Highpass')
       r(1).Filter = 'Highpass';
       lowcut = r(1).Cutoff(1);
       com = sprintf('%s, %s', com, num2str(lowcut));
    elseif strcmpi(r(1).Filter, 'Bandpass')
       r(1).Filter = 'Bandpass';
       lowcut = r(1).Cutoff(1);
       highcut = r(1).Cutoff(end);
       com = sprintf('%s, [%s, %s]', com, num2str(lowcut), num2str(highcut));
    elseif strcmpi(r(1).Filter, 'Notch')
       r(1).Filter = 'Notch';
       lowcut = r(1).Cutoff(1);
       highcut = r(1).Cutoff(end);
       com = sprintf('%s, [%s, %s]', com, num2str(lowcut), num2str(highcut));
       r.Design = 2;
    end
    
    % order check
    if (floor(EEG.pnts/3) <= r(1).Order)
        r(1).Order = (floor(EEG.pnts/3) - 1);
    end
    if (strcmpi(r.Design, 'FIR')) | (strcmpi(r.Design, 'Windowed Symmetric FIR'))
        if (r(1).Order < fix(fix(EEG.srate/0.5)/4))
            r(1).Order = (fix(EEG.srate/0.5));
        end
    end
    if (mod(r(1).Order,2)) % if it is an odd number
        r(1).Order = r(1).Order - 1;
    end
    
    
    com = sprintf('%s, ''Order'', %s', com, num2str(r.Order));
    com = sprintf('%s);', com);
    
    % hack for different data storage locations
    ORIGEEG = EEG;
    if (boolERP == 1)
        EEG.data = EEG.bindata;
        origdata = EEG.bindata;
        EEG.trials = 1;
        EEG.event = struct('type', [], 'latency', [], 'urevent', []);
    else
        origdata = EEG.data;
    end
    
    % hack for missing datapoints - interpolate NaN
    if ~isempty(find(isnan(EEG.data),1))
        fprintf(1, 'simpleEEGfilter(): Missing data detected, interpolating data - |')
        WinStart = 1;
        WinStop = size(EEG.data,1);
        nSteps = 25;
        step = 1;
        strLength = fprintf(1, [repmat(' ', 1, nSteps-step) '|   0%%']);
        tic    
        
        for chanind = 1:size(EEG.data,1)
            tempi = find(isnan(EEG.data(chanind,:))); % find discontinuities in the data
            if ~(isempty(tempi))
                temps = inpaint_nans(double(EEG.data(chanind,:)),4); % Interpolate Missing Data
                EEG.data(chanind,tempi) = temps(1,tempi); % Replace with Interpolated data points
            end
            [step, strLength] = commandwaitbar(chanind, WinStop, step, nSteps, strLength); % progress bar update
        end
        % Closeout progress bar
        [step, strLength] = commandwaitbar(WinStop, WinStop, step, nSteps, strLength);
        fprintf(1, '\n')
    end
    
    if ((strcmpi(r.Design, 'FIR')) | (strcmpi(r.Design, 'Windowed Symmetric FIR'))) & ~(strcmpi(r(1).Filter, 'Notch'))
        EEG = pop_firws(EEG, 'ftype', lower(r(1).Filter), 'fcutoff', nonzeros([ lowcut, highcut ])', 'wtype', 'hamming', 'forder', r(1).Order);
        %EEG = pop_firws(EEG, 'ftype', 'bandpass', 'fcutoff', [0.5, 30], 'wtype', 'hamming', 'forder', 3*fix(EEG.srate/0.5));
    else
        EEG = basicfilter(EEG, r.Channels, lowcut, highcut, r.Order, 0, 0, 87);
    end
   
    % hack for missing datapoints - restore NaN
    if ~isempty(find(isnan(origdata),1))
        fprintf(1, 'simpleEEGfilter(): Missing data points have been restored in the filtered data.\n')
        for chanind = 1:size(EEG.data,1)
            tempi = find(isnan(origdata(chanind,:))); % find discontinuities in the data
            if ~(isempty(tempi))
                EEG.data(chanind,tempi) = NaN;
            end
        end
    end
    
    % hack for different data storage locations
    if (boolERP == 1)
        ORIGEEG.bindata = EEG.data;
    else
        ORIGEEG.data = EEG.data;
    end
    
    EEG = ORIGEEG;
    EEG.history = sprintf('%s\n%s', ORIGEEG.history, com);
end

