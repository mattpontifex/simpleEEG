function [channelsCurrent, EEG] = eegchannelarrayindex(EEG, desiredarray)
%   Looks up the channel index for each channel label in the array. Outputs
%   an array of the channel index values.
%
%   1   Input EEG File From EEGLAB
%   2   Array of channel labels
%
%   selectarraylabel = { 'FZ', 'FCZ', 'CZ', 'CPZ', 'PZ', 'POZ', 'OZ' };
%   selectarrayindex = eegchannelarrayindex( EEG, selectarraylabel);
%
%   Author: Matthew B. Pontifex, Health Behaviors and Cognition Laboratory, Michigan State University, March 20, 2014

    
    nchannelsCurrent = size(EEG.chanlocs, 2);
    nchannelsIdeal = size(desiredarray, 2);
    
    channelsCurrent = [];
    for index=1:nchannelsCurrent
        tempval1 = cellstr(EEG.chanlocs(index).('labels'));
        tempbol = 0;
        for index2=1:nchannelsIdeal
            tempval2 = cellstr(desiredarray(index2));
            if (strcmpi(tempval1, tempval2) == 1)
                tempbol = 1;
            end
        end
        if (tempbol == 1)
            channelsCurrent(end+1) = index;
        end
    end   
end