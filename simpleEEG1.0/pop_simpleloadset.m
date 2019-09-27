function [EEG, com] = pop_simpleloadset(EEG)
%   Load set file

    [filename, filepath] = uigetfile({'*.set' 'EEGLAB .SET File'}, 'Load a EEGLAB .SET file -- pop_simpleloadset()'); 
    if ~(isequal(filename,0) || isequal(filepath,0))
        EEG = [];
        com = sprintf('%s = pop_loadset(''%s'');', inputname(1), strcat(filepath, filename));
        eval(com)
        com = sprintf('\npop_simpleloadset() Equivalent Code:\n\t%s\n', com);
        disp(com)
    else
        EEG = EEG;
        com = '';
    end
        
end

