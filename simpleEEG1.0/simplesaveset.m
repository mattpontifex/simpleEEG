function simplesaveset(EEG, fileout)
% Save EEG set as one file.
%
%   Input Parameters:
%        1    Input EEG dataset From EEGLAB.
%        2    File name.
%
%   Example Code:
%
%       >>    simplesaveset(EEG, '/Studies/file1.set');
%
%   Author: Matthew B. Pontifex, Michigan State University, July 26, 2019

    if (isempty(fileout))
        error('error in simplesaveset(): Missing filepath.')
    end

    [pathstr,name,ext] = fileparts(fileout);
    pop_saveset( EEG, 'filename', strcat(name, ext), 'filepath', pathstr, 'savemode', 'onefile');
    
end

