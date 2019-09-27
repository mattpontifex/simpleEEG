function [ERP, com] = pop_simpleaverage(EEG)

    if isobject(EEG) % eegobj
        disp('Error in pop_simpleaverage(): This function is not designed to work with the EEG object.')
        beep
    else
        if isempty(EEG)
            disp('Error in pop_simpleaverage(): This function cannot run on an empty dataset.')
            beep
        else
            if isempty(EEG.data)
                disp('Error in pop_simpleaverage(): This function cannot run on an empty dataset.')
                beep
            else
                
                g1 = [0.5 0.5 ];
                s1 = [1];
                geometry = { g1 s1 g1 s1 };
                uilist = { ...
                      { 'Style', 'text', 'string', 'Choose central tendency approach:'} ...
                      { 'Style', 'popupmenu', 'string', 'Mean | Median' 'tag' 'Method' } ...  
                      ...
                      { } ...
                      ...
                      { 'Style', 'text', 'string', 'Choose variance approach:'} ...
                      { 'Style', 'popupmenu', 'string', 'Standard Error | Standard Deviation' 'tag' 'Variance' } ...
                      ...
                      { } ...
                      ...
                  };

                  [ tmp1 tmp2 strhalt structout ] = inputgui( geometry, uilist, 'pophelp(''simpleaverage'');', 'Average -- pop_simpleaverage');
                  if ~isempty(structout)
                      
                      switch structout.Method
                          case 1
                              structout.Method = 'Mean';
                          case 2
                              structout.Method = 'Median';
                      end
                      
                      switch structout.Variance
                          case 1
                              structout.Variance = 'SE';
                          case 2
                              structout.Variance = 'SD';
                      end
                      com = sprintf('ERP = simpleaverage(%s, ''Method'', ''%s'', ''Variance'', ''%s'');', inputname(1), structout.Method, structout.Variance);
                      eval(com)
                      
                      com = sprintf('\npop_simpleaverage() Equivalent Code:\n\t%s\n', com);
                      disp(com)
                  else
                      ERP = [];
                      com = '';
                  end
            end
        end
    end
end