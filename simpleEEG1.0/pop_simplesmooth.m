function [OUTEEG, OUTALLEEG, com] = pop_simplesmooth(EEG, ALLEEG)

    if isobject(EEG) % eegobj
        disp('Error in pop_simplesmooth(): This function is not designed to work with the EEG object.')
        beep
    else
        if isempty(EEG)
            disp('Error in pop_simplesmooth(): This function cannot run on an empty dataset.')
            beep
        else
            
            booleeg = 0;
            boolerp = 0;
            try
                if ~isempty(EEG.data)
                    booleeg = 1;
                end
            catch
                boolerr = 1;
            end
            try
                if ~isempty(EEG.bindata)
                    boolerp = 1;
                end
            catch
                boolerr = 1;
            end
            if (booleeg == 0) && (boolerp == 0)
                disp('Error in pop_simplesmooth(): This function cannot run on an empty dataset.')
                beep
            else
                
                try
                    OUTALLEEG = ALLEEG;
                catch
                    boolerr = 1;
                end
                
                g1 = [0.75 0.5 ];
                s1 = [1];
                geometry = { g1 s1 g1 s1};
                uilist = { ...
                      { 'Style', 'text', 'string', 'Enter the number of points to use'} ...
                      { 'Style', 'edit', 'string', '100' 'tag' 'Window' } ...    
                      ...
                      { } ...
                      ...
                      { 'Style', 'text', 'string', 'Enter the PDF sigma for calculation of gaussian weights (larger values will give muted peak)'} ...
                      { 'Style', 'edit', 'string', '1.5', 'tag' 'Sigma'} ...   
                      ...
                      { } ...
                      ...
                  };

                  [ tmp1 tmp2 strhalt structout ] = inputgui( geometry, uilist, 'pophelp(''simplesmooth'');', 'Smooth Data -- pop_simplesmooth');
                  if ~isempty(structout)
                      if (booleeg == 1)
                        OUTEEG = simplesmooth( EEG, 'Window', str2num(structout.Window), 'Sigma', str2num(structout.Sigma));
                        try
                            if (size(OUTALLEEG,2) > 1)
                                for cF = 1:size(OUTALLEEG,2)
                                    EEG = OUTALLEEG(cF); % because the input call gets entered into the history
                                    OUTALLEEG(cF) = simplesmooth( EEG, 'Window', str2num(structout.Window), 'Sigma', str2num(structout.Sigma));
                                end
                            end
                        catch
                            boolerr = 1;
                        end
                      end
                      if (boolerp == 1)
                        ERP = EEG; % because the input call gets entered into the history
                        OUTEEG = simplesmooth( ERP, 'Window', str2num(structout.Window), 'Sigma', str2num(structout.Sigma));
                        try
                            if (size(OUTALLEEG,2) > 1)
                                for cF = 1:size(OUTALLEEG,2)
                                    ERP = OUTALLEEG(cF); % because the input call gets entered into the history
                                    OUTALLEEG(cF) = simplesmooth( ERP, 'Window', str2num(structout.Window), 'Sigma', str2num(structout.Sigma));
                                end
                            end
                        catch
                            boolerr = 1;
                        end
                      end
                      com = sprintf('\npop_simplesmooth() Equivalent Code:\n\t%s = simplesmooth(%s, ''Window'', %s, ''Sigma'', %s);\n', inputname(1), inputname(1), structout.Window, structout.Sigma);
                      disp(com)
                  else
                      OUTALLEEG = ALLEEG;
                      OUTEEG = EEG;
                      com = '';
                  end
            end
        end
    end
end