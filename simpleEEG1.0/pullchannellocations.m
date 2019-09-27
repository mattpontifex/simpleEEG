function [EEG] = pullchannellocations(EEG)
%   Uses EEGLAB channel locations
%
%   Input Parameters:
%        1    EEG set from EEGLAB
%
%   Example Code:
%
%       >> EEG = pullchannellocations(EEG);
%
%   Author Matthew B. Pontifex, Health Behaviors and Cognition Laboratory, Michigan State University, August 26, 2015

    % Use default channel locations for time being
    tempEEG = EEG; % for dipfitdefs
    dipfitdefs;
    tmpp = which('eeglab.m');
    tmpp = fullfile(fileparts(tmpp), 'functions', 'resources', 'Standard-10-5-Cap385_witheog.elp');
    userdatatmp = { template_models(1).chanfile template_models(2).chanfile  tmpp };
    try
        [T, tempEEG] = evalc('pop_chanedit(tempEEG, ''lookup'', userdatatmp{1})');
    catch
        try
            [T, tempEEG] = evalc('pop_chanedit(tempEEG, ''lookup'', userdatatmp{3})');
        catch
            booler = 1;
        end
    end
    EEG.chanlocs = tempEEG.chanlocs;
end