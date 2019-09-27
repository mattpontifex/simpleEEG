function [ PowerSpectrumDensitiy, frq ] = simpleEEGFFT( signal, varargin)
% Simple call for computing the spectral activity of a vector using FFT.
%
%   Input Parameters:
%        1   Input vector [1 by X]
%        2   The available parameters are as follows:
%           a    'SamplingRate' Sampling rate of the vector.
%           b    'Unitpower' Parameter to select the output unit:
%                           default: 'Log Power FFT (10*log10(microV^{2}/Hz))'
%                                    'Absolute Power FFT (microV^{2}/Hz)'
%           c    'Frequencies' Frequency range (default is [0, 50]). 
%           d    'Bins' Frequency bins (default is 1, larger numbers result in larger bin sizes and a smoother output). 
%           d    'Maxwin' Maximum window length in seconds to utilize before subsampling (default 3). 
%           d    'MaxwinOverlap' Overlapping percentage for subsampling (default 0.5). 
%
%   Example Code:
%
%       >>    [pspectr, freq] = simpleEEGFFT(EEG.data(1,:),'SamplingRate', EEG.srate, 'Unitpower', 'Absolute Power Spectrum Density (microV^{2}/Hz)', 'Frequencies', [0, 80]); plot(freq, pspectr)
%
%   Author: Matthew B. Pontifex, Michigan State University, August 9, 2019

    if ~isempty(varargin)
             r=struct(varargin{:});
    end
    try, r.SamplingRate; catch, r(1).SamplingRate = 1000; end
    try, r.Unitpower; catch, r(1).Unitpower = 'log'; end
    try, r.Frequencies; catch, r(1).Frequencies = [0, 80]; end
    try, r.Bins; catch, r(1).Bins = 1; end
    try, r.Maxwin; catch, r(1).Maxwin = 3; end
    try, r.MaxwinOverlap; catch, r(1).MaxwinOverlap = 0.5; end

    if (min(size(signal)) > 1)
    	error('Error at simpleEEGFFT(). This functiuon is designed for vector inputs.') 
    elseif (size(signal, 1) > size(signal, 2))
        signal = signal';
    end
    
    if (strcmpi(r(1).Unitpower, 'log') | strcmpi(r(1).Unitpower, 'Log Power') | strcmpi(r(1).Unitpower, 'Log PSD') | strcmpi(r(1).Unitpower, 'Log Power Spectrum Density') | strcmpi(r(1).Unitpower, 'Log Power Spectrum Density (10*log10(microV^{2}/Hz))') | strcmpi(r(1).Unitpower, 'Log Power FFT (10*log10(microV^{2}/Hz))') | strcmpi(r(1).Unitpower, 'Log Power FFT'))
        r(1).Unitpower = 'Log Power FFT (10*log10(microV^{2}/Hz))';
    elseif (strcmpi(r(1).Unitpower, 'abs') | strcmpi(r(1).Unitpower, 'Absolute Power') | strcmpi(r(1).Unitpower, 'Absolute PSD') | strcmpi(r(1).Unitpower, 'Abs PSD') | strcmpi(r(1).Unitpower, 'Absolute Power Spectrum Density') | strcmpi(r(1).Unitpower, 'Abs Power Spectrum Density') | strcmpi(r(1).Unitpower, 'Absolute Power Spectrum Density (microV^{2}/Hz)') | strcmpi(r(1).Unitpower, 'Absolute Power FFT (microV^{2}/Hz)') | strcmpi(r(1).Unitpower, 'Absolute Power FFT'))
        r(1).Unitpower = 'Absolute Power FFT (microV^{2}/Hz)';
    else
        r(1).Unitpower = 'Log Power FFT (10*log10(microV^{2}/Hz))';
    end
    
    % handle potentially missing datapoints
    tempi = find(isnan(signal)); % find discontinuities in the data
    if ~(isempty(tempi))
        temps = inpaint_nans(double(signal),4); % Interpolate Missing Data
        signal(tempi)= temps(1,tempi); % Replace with Interpolated data points
    end
    
    fnyq = fix(r(1).SamplingRate)/2;
    % check window length
    if ((length(signal)/r(1).SamplingRate) > r(1).Maxwin)
        L = r(1).SamplingRate*r(1).Maxwin;  %number of datapoints in 1 window-size stretch of signal
        Lm = round(L*r(1).MaxwinOverlap); % window move size
        windowpoints = 1:Lm:length(signal);
        NFFT = fix((2^nextpow2(L))/r(1).Bins);
        specmatrix = NaN(1,NFFT);
        frq = fnyq*linspace(0,1,NFFT/2);
        
        for cDirs = 1:2
            if (cDirs == 2)
               signal = fliplr(signal); 
            end
            for cWins = 1:(fix((numel(windowpoints)/2)) + 1) % cycle through just over half the points (flip then do again to capture the entire length)
                try,
                    tempsignal = signal(windowpoints(cWins):(windowpoints(cWins)+L-1));
                    tempsignal = detrend(tempsignal);
                    specdata = fft(tempsignal,NFFT)/L;
                    specdata = (abs( specdata ).^2);
                    if (strcmpi(r(1).Unitpower, 'Absolute Power Spectrum Density (microV^{2}/Hz)'))
                        specmatrix(end+1,:) = specdata;
                    else
                        specmatrix(end+1,:) = 10*log10(specdata);
                    end
                catch,
                    boolerr = 1;
                end
            end
        end
        PowerSpectrumDensitiy = nanmean(specmatrix,1);
    else
        L = length(signal);
        NFFT = fix((2^nextpow2(L))/r(1).Bins);
        frq = fnyq*linspace(0,1,NFFT/2);
        signal = detrend(signal);
        specdata = fft(signal,NFFT)/L;
        specdata = (abs( specdata ).^2);
        if (strcmpi(r(1).Unitpower, 'Absolute Power Spectrum Density (microV^{2}/Hz)'))
            PowerSpectrumDensitiy = specdata;
        else
            PowerSpectrumDensitiy = 10*log10(specdata);
        end
    end
    
    % subset only those frequencies requested
    [~, winstart] = min(abs(frq-(r(1).Frequencies(1))));
    [~, winstop] = min(abs(frq-(r(1).Frequencies(end))));
    PowerSpectrumDensitiy = PowerSpectrumDensitiy(winstart:winstop);
    frq = frq(winstart:winstop);
    
end