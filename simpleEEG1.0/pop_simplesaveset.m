function [com] = pop_simplesaveset(INEEG)
%   Save .SET file as a single file

%   Author: Matthew B. Pontifex, Health Behaviors and Cognition Laboratory, Michigan State University, July 26, 2019


    if isobject(INEEG) % eegobj
        disp('Error in pop_simplesaveset(): This function is not designed to work with the EEG object.')
        beep
    else
        if isempty(INEEG)
            disp('Error in pop_simplesaveset(): This function cannot run on an empty dataset.')
            beep
        else

            [filename, filepath] = uiputfile({'*.set' 'EEGLAB .SET File'}, 'Save a EEGLAB .SET file -- pop_simplesaveset()'); 
            if ~(isequal(filename,0) || isequal(filepath,0))

                simplesaveset(INEEG, strcat(filepath, filename));
                com = sprintf('\npop_simplesaveset() Equivalent Code:\n\t simplesaveset(%s, ''%s'');\n', inputname(1), strcat(filepath, filename));
                disp(com)
                
            else
                com = '';
            end
        
        end
    end
        
end

