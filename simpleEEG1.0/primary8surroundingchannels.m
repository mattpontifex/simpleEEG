function [channelssurround, EEG] = primary8surroundingchannels(EEG, chanlab)
%   Looks up the primary channels surrounding the selected channel and
%   returns an array of those channels which exist in the inputted EEG
%   file.
%
%   1   Input EEG File From EEGLAB
%   2   Selected Channel
%
%   selectarrayindex = primary8surroundingchannels( EEG, 'CPZ');
%
%   Author: Matthew B. Pontifex, Health Behaviors and Cognition Laboratory, Michigan State University, April 1, 2014
   
    RefChanArray = {};
    RefChanLab = {};
    nchannelsCurrent = size(EEG.chanlocs, 2);
    if (nchannelsCurrent < 78)
        switch chanlab
            case 'FP1'
                RefChanLab = { 'AF7', 'AF3', 'FPZ', 'AFZ' };
            case 'FPZ'
                RefChanLab = { 'AFZ', 'FP1', 'FP2', 'AF3', 'AF4' };
            case 'FP2'
                RefChanLab = { 'AF8', 'AF4', 'FPZ',  'AFZ' };
            case 'AF7'
                RefChanLab = { 'FP1', 'F5', 'F7', 'AF3' };
            case 'AF3'
                RefChanLab = { 'F1', 'F3', 'AF7', 'FPZ', 'FP1' };
            case 'AF4'
                RefChanLab = { 'F4', 'F2', 'AF8', 'FPZ', 'FP2' };
            case 'AF8'
                RefChanLab = { 'FP2', 'F6', 'F8', 'AF4' };
            case 'F7'
                RefChanLab = { 'F5', 'FT7', 'FC5', 'AF7' };
            case 'F5'
                RefChanLab = { 'AF7', 'AF3', 'F7', 'F3', 'FT7', 'FC5', 'FC3' };
            case 'F3'
                RefChanLab = { 'AF7', 'AF3', 'AFZ', 'F5', 'F1', 'FC5', 'FC3', 'FC1' };
            case 'F1'
                RefChanLab = { 'AF3', 'AFZ', 'F3', 'FZ', 'FC3', 'FC1', 'FCZ' };
            case 'FZ'
                RefChanLab = { 'AF3', 'AF4', 'F1', 'F2', 'FC1', 'FCZ', 'FC2' };
            case 'F2'
                RefChanLab = { 'AF4', 'AFZ', 'F4', 'FZ', 'FC4', 'FC2', 'FCZ' };
            case 'F4'
                RefChanLab = { 'AF8', 'AF4', 'AFZ', 'F6', 'F2', 'FC6', 'FC4', 'FC2' };
            case 'F6'
                RefChanLab = { 'AF8', 'AF4', 'F8', 'F4', 'FT8', 'FC6', 'FC4' };
            case 'F8'
                RefChanLab = { 'F6', 'FT8', 'FC6', 'AF8' };
            case 'FT7'
                RefChanLab = { 'F7', 'F5', 'FC5', 'C5', 'T7' };
            case 'FC5'
                RefChanLab = { 'F7', 'F5', 'F3', 'FT7', 'FC3', 'T7', 'C5', 'C3' };
            case 'FC3'
                RefChanLab = { 'F5', 'F3', 'F1', 'FC5', 'FC1', 'C5', 'C3', 'C1' };
            case 'FC1'
                RefChanLab = { 'F3', 'F1', 'FZ', 'FC3', 'FCZ', 'C3', 'C1', 'CZ' };
            case 'FCZ'
                RefChanLab = { 'F1', 'FZ', 'F2', 'FC1', 'FC2', 'C1', 'CZ', 'C2' };
            case 'FC2'
                RefChanLab = { 'F4', 'F2', 'FZ', 'FC4', 'FCZ', 'C4', 'C2', 'CZ' };
            case 'FC4'
                RefChanLab = { 'F6', 'F4', 'F2', 'FC6', 'FC2', 'C6', 'C4', 'C2' };
            case 'FC6'
                RefChanLab = { 'F8', 'F6', 'F4', 'FT8', 'FC4', 'T8', 'C6', 'C4' };
            case 'FT8'
                RefChanLab = { 'F8', 'F6', 'FC6', 'C6', 'T8' };
            case 'T7'
                RefChanLab = { 'FT7', 'FC5', 'C5', 'CP5', 'TP7' };
            case 'C5'
                RefChanLab = { 'FT7', 'FC5', 'FC3', 'T7', 'C3', 'TP7', 'CP5', 'CP3' };
            case 'C3'
                RefChanLab = { 'FC5', 'FC3', 'FC1', 'C5', 'C1', 'CP5', 'CP3', 'CP1' };
            case 'C1'
                RefChanLab = { 'FC3', 'FC1', 'FCZ', 'C3', 'C1', 'CP3', 'CP1', 'CPZ' };
            case 'CZ'
                RefChanLab = { 'FC1', 'FCZ', 'FC2', 'C1', 'C2', 'CP1', 'CPZ', 'CP2' };
            case 'C2'
                RefChanLab = { 'FC4', 'FC2', 'FCZ', 'C4', 'C2', 'CP4', 'CP2', 'CPZ' };
            case 'C4'
                RefChanLab = { 'FC6', 'FC4', 'FC2', 'C6', 'C2', 'CP6', 'CP4', 'CP2' };
            case 'C6'
                RefChanLab = { 'FT8', 'FC6', 'FC4', 'T8', 'C4', 'TP8', 'CP6', 'CP4' };
            case 'T8'
                RefChanLab = { 'FT8', 'FC6', 'C6', 'CP6', 'TP8' };
            case 'TP7'
                RefChanLab = { 'T7', 'C5', 'CP5', 'P5', 'P7' };
            case 'CP5'
                RefChanLab = { 'T7', 'C5', 'C3', 'TP7', 'CP3', 'P7', 'P5', 'P3' };
            case 'CP3'
                RefChanLab = { 'C5', 'C3', 'C1', 'CP5', 'CP1', 'P5', 'P3', 'P1' };
            case 'CP1'
                RefChanLab = { 'C3', 'C1', 'CZ', 'CP3', 'CPZ', 'P3', 'P1', 'PZ' };
            case 'CPZ'
                RefChanLab = { 'C1', 'CZ', 'C2', 'CP1', 'CP2', 'P1', 'PZ', 'P2' };
            case 'CP2'
                RefChanLab = { 'C4', 'C2', 'CZ', 'CP4', 'CPZ', 'P4', 'P2', 'PZ' };
            case 'CP4'
                RefChanLab = { 'C6', 'C4', 'C2', 'CP6', 'CP2', 'P6', 'P4', 'P2' };
            case 'CP6'
                RefChanLab = { 'T8', 'C6', 'C4', 'TP8', 'CP4', 'P8', 'P6', 'P4' };
            case 'TP8'
                RefChanLab = { 'T8', 'C6', 'CP6', 'P6', 'P8' };
            case 'P7'
                RefChanLab = { 'TP7', 'CP5', 'P5', 'PO5', 'PO7' };
            case 'P5'
                RefChanLab = { 'TP7', 'CP5', 'CP3', 'P7', 'P3', 'PO7', 'PO5', 'PO3' };
            case 'P3'
                RefChanLab = { 'CP5', 'CP3', 'CP1', 'P5', 'P1', 'PO7', 'PO5', 'PO3' };
            case 'P1'
                RefChanLab = { 'CP3', 'CP1', 'CPZ', 'P3', 'PZ', 'PO5', 'PO3', 'POZ' };
            case 'PZ'
                RefChanLab = { 'CP1', 'CPZ', 'CP2', 'P1', 'P2', 'PO3', 'POZ', 'PO4' };
            case 'P2'
                RefChanLab = { 'CP4', 'CP2', 'CPZ', 'P4', 'PZ', 'PO6', 'PO4', 'POZ' };
            case 'P4'
                RefChanLab = { 'CP6', 'CP4', 'CP2', 'P6', 'P2', 'PO8', 'PO6', 'PO4' };
            case 'P6'
                RefChanLab = { 'TP8', 'CP6', 'CP4', 'P8', 'P4', 'PO8', 'PO6', 'PO4' };
            case 'P8'
                RefChanLab = { 'TP8', 'CP6', 'P6', 'PO6', 'PO8' };
            case 'PO7'
                RefChanLab = { 'P7', 'P5', 'PO5' };
            case 'PO5'
                RefChanLab = { 'P5', 'PO7', 'PO3', 'O1' };
            case 'PO3'
                RefChanLab = { 'POZ', 'O1', 'PO5', 'P3' };
            case 'POZ'
                RefChanLab = { 'P1', 'PZ', 'P2', 'PO3', 'PO4', 'O1', 'OZ', 'O2' };
            case 'PO4'
                RefChanLab = { 'POZ', 'O2', 'PO6', 'P4' };
            case 'PO6'
                RefChanLab = { 'PO8', 'O2', 'PO4', 'P6' };
            case 'PO8'
                RefChanLab = { 'P6', 'P8', 'PO6' };
            case 'O1'
                RefChanLab = { 'OZ', 'PO7', 'PO5', 'PO3' };
            case 'OZ'
                RefChanLab = { 'PO3', 'POZ', 'PO4', 'O1', 'OZ', 'O2' };
            case 'O2'
                RefChanLab = { 'PO4', 'PO6', 'PO8', 'OZ' };
        end 
    end
    nRefChanLab = size(RefChanLab,2);
    if (nRefChanLab > 0)
        for index2=1:nRefChanLab
            tempval2 = char(RefChanLab(index2));
            n = size(EEG.chanlocs, 2);
            chann = 0;
            for m=1:n
                tempval = EEG.chanlocs(m).('labels');
                if (strcmp(tempval,tempval2) > 0)
                    chann = m;
                    break;
                end
            end
            if (chann ~= 0)    
                RefChanArray(end+1) = RefChanLab(index2);
            end
        end
    end
        
    channelssurround = RefChanArray;
end

