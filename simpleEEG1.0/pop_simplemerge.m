function [OUTEEG, OUTALLEEG, com] = pop_simplemerge(INEEG, INALLEEG, varargin)
%   Merge a .set file onto the end of an open .set file.

%   Author: Matthew B. Pontifex, Health Behaviors and Cognition Laboratory, Michigan State University, July 26, 2019

    if ~isempty(varargin)
        r=struct(varargin{:});
    end

    [filename1, filepath1] = uigetfile({'*.set' 'EEGLAB .SET File'}, 'Select the EEGLAB .SET file to merge -- pop_simplemerge()'); 
    
    if ~(isequal(filename1,0) || isequal(filepath1,0))
                
        % Merge files
        OUTALLEEG = []; % Clear ALLEEG structure
        com = sprintf('\n\t File 1 History');

        % File 1 already loaded
        OUTEEG = INEEG;
        OUTEEG.data = double(OUTEEG.data);
        OUTEEG.times = double(OUTEEG.times);
        OUTEEG.icaact = [];
        OUTALLEEG = eeg_store(OUTALLEEG, OUTEEG);
        com = sprintf('\n\t File 1 History Start\n%s\n\t File 1 History Stop\n', OUTEEG.history);
        OUTEEG = []; % Clear EEG structure

        % Load file 2
        OUTEEG = pop_loadset('filename', filename1, 'filepath', filepath1);
        OUTEEG.data = double(OUTEEG.data);
        OUTEEG.times = double(OUTEEG.times);
        OUTEEG.icaact = [];
        OUTALLEEG = eeg_store(OUTALLEEG, OUTEEG);
        com = sprintf('%s\n\t File 2 History Start\n%s\n\t File 2 History Stop\n', com, OUTEEG.history);
        OUTEEG = []; % Clear EEG structure

        % Merge EEG sets - screening for the same channels in the same order
        OUTEEG = xmerge(OUTALLEEG);
        OUTEEG = eeg_checkset(OUTEEG); 

        % Reorder channel array
        OUTEEG = pullchannellocations(OUTEEG);

        OUTEEG.history = sprintf('%s\n%s', OUTEEG.history, com);

        com = sprintf('\n\t ALLEEG = [];');
        com = sprintf('%s\n\t EEG.data = double(EEG.data); EEG.times = double(EEG.times);', com);
        com = sprintf('%s\n\t ALLEEG = eeg_store(ALLEEG, EEG); EEG = [];', com);

        com = sprintf('%s\n\t EEG = pop_loadset(''filename'', ''%s'', ''filepath'', ''%s'');', com, filename1, filepath1);
        com = sprintf('%s\n\t EEG.data = double(EEG.data); EEG.times = double(EEG.times);', com);
        com = sprintf('%s\n\t ALLEEG = eeg_store(ALLEEG, EEG); EEG = [];', com);

        com = sprintf('%s\n\t EEG = xmerge(ALLEEG);', com);
        com = sprintf('%s\n\t EEG = eeg_checkset(EEG);', com);
        com = sprintf('%s\n\t EEG = pullchannellocations(EEG);', com);

        % Place command in History
        OUTEEG.history = sprintf('%s\n%s', OUTEEG.history, com);
        com = sprintf('\npop_simplemerge() Equivalent Code:%s', com);
        disp(com)
     
    else
        % user cancelled
        OUTALLEEG = INALLEEG;
        OUTEEG = INEEG;
        com = '';
    end
            
end

