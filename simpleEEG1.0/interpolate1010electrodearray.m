function [EEG, com] = interpolate1010electrodearray(EEG, varargin)
%   This function replaces by interpolation any missing
%   electrodes from the primary array by calculating
%   the mean for the available surrounding channels.
%
%   1   Input EEG File From EEGLAB
%   Input parameters are as follows:
%       2    'Array' - Complete electrode array desired (ex: {'FZ', 'FCZ'}). Default is full 10-10 array.
%       3    'ChannelMinimum' - Minimum number of channels needed for interpolation. Default is 2 channels.
%       4    'MaximumIterations' - Maximum number of iterations allowed to obtain full array. Default is 4 iterations.
%
%   Example Code:
%
%       EEG = interpolate1010electrodearray(EEG);
%
%   Author: Matthew B. Pontifex, Health Behaviors and Cognition Laboratory, Michigan State University, March 12, 2014
%   revised 5-14-2015 to add varargin structure for default settings

    try
        if ~isempty(varargin)
              r=struct(varargin{:});
        end
    catch
        help interpolate1010electrodearray
        error('This function has been updated! Please update your code to reflect the new settings. Refer to help documentation provided above.')
    end
    try, r.Array; desiredarray = {r.Array}; catch, desiredarray = {'AF7', 'AF3', 'AF4', 'AF8', 'F7', 'F5', 'F3', 'F1', 'FZ', 'F2', 'F4', 'F6', 'F8', 'FT7', 'FC5', 'FC3', 'FC1', 'FCZ', 'FC2', 'FC4', 'FC6', 'FT8', 'T7', 'C5', 'C3', 'C1', 'CZ', 'C2', 'C4', 'C6', 'T8', 'TP7', 'CP5', 'CP3', 'CP1', 'CPZ', 'CP2', 'CP4', 'CP6', 'TP8', 'P7', 'P5', 'P3', 'P1', 'PZ', 'P2', 'P4', 'P6', 'P8', 'PO7', 'PO5', 'PO3', 'POZ', 'PO4', 'PO6', 'PO8', 'O1', 'OZ', 'O2'}; end
    try, r.ChannelMinimum; minchan = r.ChannelMinimum; catch, minchan = 2; end
    try, r.MaximumIterations; maxit = r.MaximumIterations; catch, maxit = 4; end
    try, Pop = r(1).Pop; catch, Pop = 'False'; end

%   Note: This procedure requires 'pop_eegchanoperator.m', 'primary8surroundingchannels.m', and 'pullchannellocations.m'

    nchannelsIdeal = size(desiredarray, 2);
    
    for mastindex=1:maxit
        %Creates a list of all the channels currently in the array
        nchannelsCurrent = size(EEG.chanlocs, 2);
        channelsCurrent = {};
        for index=1:nchannelsCurrent
            tempval = EEG.chanlocs(index).('labels');
            channelsCurrent(end+1) = cellstr(tempval);
        end
        
        % Creates a list of all the channels currently missing from the array
        missingChannels = {};
        %For each channel in the desired array
        for index1=1:nchannelsIdeal
            tempval = desiredarray(index1);
            %For each channel in the actual array
            tempbol = 0;
            for index2=1:nchannelsCurrent
                %Compare channel labels
                if (strcmpi(channelsCurrent(index2), tempval) == 1)
                    tempbol = 1;
                end
            end
            %If channel was missing add to list
            if (tempbol == 0)
                missingChannels(end+1) = cellstr(tempval);    
            end
        end
        
        nchannelsMissing = size(missingChannels, 2);
        if (nchannelsMissing > 0)
            
            fprintf(1, sprintf('interpolate1010electrodearray(): Interpolating electrodes (iteration %d) - |', mastindex))

            % Setup Controls for Progress Bar
            WinStart = 1;
            WinStop = nchannelsMissing;
            nSteps = 25;
            step = 1;
            strLength = fprintf(1, [repmat(' ', 1, nSteps-step) '|   0%%']);
            tic
            
            tempmissingChannelsRef = {};
            for index1=1:nchannelsMissing
                RefChanIndex = [];
                RefChanLab = primary8surroundingchannels( EEG, char(missingChannels(index1)));
                nRefChanLab = size(RefChanLab,2);
                if (nRefChanLab > 0)
                    for index2=1:nRefChanLab
                        tempval2 = char(RefChanLab(index2));
                        tempval3 = find(strcmpi({EEG.chanlocs.labels},tempval2));
                        RefChanIndex(end+1) = tempval3;
                    end
                end
                nRefChanIndex = size (RefChanIndex,2);
                if (nRefChanIndex >= minchan)
                    temparraylab = {};
                    for index2=1:nRefChanIndex
                        index2temp = RefChanIndex(index2);
                        switch index2
                            case 1
                                tempstr = sprintf('(ch%d+', index2temp);
                                temparraylab = [temparraylab tempstr];                               
                            case nRefChanIndex
                                tempstr = sprintf('ch%d)', index2temp);
                                temparraylab = [temparraylab tempstr];
                            otherwise
                                tempstr = sprintf('ch%d+', index2temp);
                                temparraylab = [temparraylab tempstr];
                        end
                    end
                    tempstr = sprintf('/%d', nRefChanIndex);
                    temparraylab = [temparraylab tempstr];
                    temparraylab2 = [temparraylab{:}];
                    nchannelsNew = nchannelsCurrent + 1;
                    tempoutput = sprintf('ch%d=%s label %s', nchannelsNew, temparraylab2, char(missingChannels(index1)));
                    [T, EEG] = evalc('pop_eegchanoperator( EEG, {tempoutput});');
                    nchannelsCurrent = nchannelsNew;
                end
                [step, strLength] = commandwaitbar(index1, WinStop, step, nSteps, strLength); % progress bar update
            end
            [step, strLength] = commandwaitbar(WinStop, WinStop, step, nSteps, strLength);
            fprintf(1, '\n')
        else
            break
        end
    end
    com = sprintf('%s = interpolate1010electrodearray(%s);', inputname(1), inputname(1));
    EEG.history = sprintf('%s\n%s', EEG.history, com);
    EEG = pullchannellocations(EEG); % Reorder channel array
    
    if strcmpi(Pop, 'True')
      com = sprintf('\nEquivalent Code:\n\t%s', com);
      disp(com)
    end
end