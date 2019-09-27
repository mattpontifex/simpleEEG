function [com] = pop_simplesaveavg(INERP)
%   Save .ERP file as a single file

%   Author: Matthew B. Pontifex, Health Behaviors and Cognition Laboratory, Michigan State University, July 26, 2019


    if isobject(INERP) % eegobj
        disp('Error in pop_simplesaveavg(): This function is not designed to work with the ERP object.')
        beep
    else
        if isempty(INERP)
            disp('Error in pop_simplesaveavg(): This function cannot run on an empty dataset.')
            beep
        else

            [filename, filepath] = uiputfile({'*.erp' 'ERPLAB .ERP File'}, 'Save a ERPLAB .ERP file -- pop_simplesaveavg()'); 
            if ~(isequal(filename,0) || isequal(filepath,0))
                
                saveERP(INERP, strcat(filepath, filename));
                com = sprintf('\npop_simplesaveavg() Equivalent Code:\n\t saveERP(%s, ''%s'');\n', inputname(1), strcat(filepath, filename));
                disp(com)
                
            else
                com = '';
            end
        
        end
    end
        
end

