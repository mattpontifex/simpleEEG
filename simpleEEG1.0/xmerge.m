function [ OUTEEG ] = xmerge( INALLEEG, varargin)
% Merge EEG structures using pop_mergeset but first remove any channels which are not consistent across EEG sets.
%
%   1   Input ALLEEG structure containing multiple EEG sets
%      
%   Example Code:
%
%           ALLEEG = [];
%           for block = ['A', 'B', 'C']
%                EEG = pop_loadset('filename', strcat('File1_', cell2mat(block), def.SET), 'filepath', '\Studies\');      
%                ALLEEG = eeg_store(ALLEEG, EEG); EEG = [];
%            end
%            EEG = xmerge(ALLEEG);
%
%   Author: Matthew B. Pontifex, Health Behaviors and Cognition Laboratory, Michigan State University, April 3, 2015

    nfiles = size(INALLEEG,2); % Number of files in ALLEEG structure
    
    if (nfiles < 2)
        error('Error at xmerge(). Less than 2 sets were entered into the ALLEEG structure.')
    end
    
    % Identify Channels which are consistent across sets
    GoodChannels = {INALLEEG(1).chanlocs.labels}; 
    for cF = 1:size(INALLEEG,2)
        GoodChannels = intersect(GoodChannels,{INALLEEG(cF).chanlocs.labels}); 
    end
    
    % Remove missing channels
    for cF = 1:size(INALLEEG,2)
        BadChannels = setdiff({INALLEEG(cF).chanlocs.labels},GoodChannels); 
        INALLEEG(cF) = pop_select( INALLEEG(cF), 'nochannel', BadChannels);
    end
    
    % Reorder each set to have channels in the same location
    for cF = 1:size(INALLEEG,2)
        INALLEEG(cF) = reorderchannelarray( INALLEEG(cF), GoodChannels);
    end
    
    com = sprintf('Starting the merge process...');
    disp(com)
    OUTEEG = pop_mergeset(INALLEEG, [1:size(INALLEEG,2)], 0);
    
end

