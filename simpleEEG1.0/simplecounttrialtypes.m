function [outacceptnum, outtotalnum] = simplecounttrialtypes(INEEG, varargin)
%   Function to check the number of accepted trials of a given type
%
%   1   Input EEG File From EEGLAB
%   2   'Types' - Event types to count.
%
%   Example Code Implementation:
%
%      [outacceptnum, outtotalnum] = simplecounttrialtypes(EEG, 'Types', [1, 4]);
%
%   Author: Matthew B. Pontifex, Health Behaviors and Cognition Laboratory, Michigan State University, August 20, 2019
    
    if ~isempty(varargin)
             r=struct(varargin{:});
    end
    try, r.Types; catch, error('Error at simplecounttrialtypes(). No trial types were specified.'); end
    try, r.Suppress; catch, r.Suppress = 'True'; end
    
    outacceptnum = 0;
    outtotalnum = 0;
    [epochevents, epocheventlist, epochmatrix] = simplecheckavailabletrials(INEEG);
    
    % obtain available epochs
    if (size(INEEG.data,3) > 1)
        INEEG2 = INEEG;
        [T, INEEG2] = evalc('pop_syncroartifacts(INEEG2, ''Direction'', ''bidirectional'');'); %synchronize artifact databases
        if (isempty(INEEG2.reject.rejmanual))
            INEEG.reject.rejmanual = zeros(1,INEEG.trials);
        else
            INEEG.reject.rejmanual = INEEG2.reject.rejmanual;
        end
    end
    
    tempvect = intersect([r.Types],[epochmatrix(:,2)]);
    tempindx = [];
    if ~isempty(tempvect)
        for cE = 1:size(epochmatrix,1)
            tempindx = intersect([r.Types], epochmatrix(cE,2));
            if ~isempty(tempindx)
                outtotalnum = outtotalnum + 1;
                if (size(INEEG.data,3) > 1)
                    if (INEEG.reject.rejmanual(cE) == 0)
                        outacceptnum = outacceptnum + 1;
                    end
                else
                    outacceptnum = outacceptnum + 1;
                end
            end
        end
    end
            
    com = sprintf('[outacceptnum, outtotalnum] = simplecounttrialtypes(%s, ''Types'', ''%s'');', inputname(1), collapsematrixarray(r.Types));
    if strcmpi(r.Suppress, 'False')
        com = sprintf('\nEquivalent Code:\n\t%s\n', com);
        disp(com)
    end
    
end
