function [OUTEEG] = simplesyncartifacts(INEEG, varargin)
% function to syncronize EEGLAB and ERPLAB artifact rejection databases
% without corrupting the EEG.history.
%
%   1   Input EEG File From EEGLAB
%   2   'Direction' - Direction to sync ['bidirectional' (default) | 'erplab2eeglab' (erplab to eeglab synchro) | 'eeglab2erplab' (eeglab to erplab synchro) ]
%
%   Example Code Implementation:
%
%       EEG = simplesyncartifacts(EEG, 'Direction', 'bidirectional')

    if ~isempty(varargin)
    	r=struct(varargin{:});
    end
    try, r.Direction; catch,  r(1).Direction = 'bidirectional'; end

    eegdatatype = 'EEG';
    try
        isempty(INEEG.bindata);
        eegdatatype = 'ERP';
    catch
       boolerr = 1; 
    end
    
    com = '';
    if strcmpi(eegdatatype, 'EEG')
        if (size(INEEG.data,3) > 1)
            com = sprintf('pop_syncroartifacts(INEEG, ''Direction'', ''%s'');', r(1).Direction);
            [T, OUTEEG] = evalc(com); %synchronize artifact databases
            OUTEEG.history = INEEG.history;

            com = sprintf('EEG = simplesyncartifacts(EEG, ''Direction'', ''%s'');', r(1).Direction);
            OUTEEG.history = sprintf('%s\n%s', OUTEEG.history, com);
        end
    end
end