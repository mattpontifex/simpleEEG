function [ERP, ALLERP, com] = pop_simpleloaderp(ERP, ALLERP)
%   Load erp file

    [filename, filepath] = uigetfile({'*.erp' 'ERPLAB .ERP File'}, 'Load a ERPLAB .ERP file -- pop_simpleloaderp()'); 
    if ~(isequal(filename,0) || isequal(filepath,0))
        ERP = [];
        if ~isstruct(ALLERP)
            com = sprintf('%s = pop_loaderp(''filename'',''%s'', ''filepath'', ''%s'');', inputname(1), filename, filepath);
            t = evalc(com);
            ALLERP = ERP;
        else
            com = sprintf('[%s, %s] = pop_loaderp(''filename'',''%s'', ''filepath'', ''%s'');', inputname(1), inputname(2), filename, filepath);
            t = evalc(com);
        end
        com = sprintf('\npop_simpleloaderp() Equivalent Code:\n\t%s\n', com);
        disp(com)
    else
        com = '';
    end
        
end

