function [ERP, com] = pop_simplesubtractERP(ERP, varargin)

    com = '';
    if ~isempty(varargin)
        r=struct(varargin{:});
    end

    [filename, filepath] = uigetfile({'*.erp' 'ERPLAB .ERP File'}, 'Select an ERPLAB .ERP file to subtract from the current ERP -- pop_simplesubtractERP()'); 
    
    if ~(isequal(filename,0) || isequal(filepath,0))
                
        % place current ERP within the ALLERP Structure 
        com1 = sprintf('ALLERP = ERP; %%place currently loaded ERP dataset in ALLERP structure');
        
        % load the new file
        com2 = sprintf('[ERP, ALLERP] = pop_loaderp(''filename'',''%s'', ''filepath'', ''%s'');', filename, filepath);
        eval(sprintf('%s\n%s', com1, com2));
        
        % call function
        com3 = sprintf('ERP = simplesubtractERP(ALLERP, ''Method'', ''Change'');');
        eval(com3);
        
        com = sprintf('\npop_simplesubtractERP() Equivalent Code:\n\t%s\n\t%s\n\t%s', com1,com2,com3);
        disp(com)
    end    
end

