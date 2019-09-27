function [OUTEEG, OUTALLEEG, com] = pop_simplebaselinecorrect(EEG, ALLEEG)

    if isobject(EEG) % eegobj
        disp('Error in pop_simplebaselinecorrect(): This function is not designed to work with the EEG object.')
        beep
    else
        if isempty(EEG)
            disp('Error in pop_simplebaselinecorrect(): This function cannot run on an empty dataset.')
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
                disp('Error in pop_simplebaselinecorrect(): This function cannot run on an empty dataset.')
                beep
            else

                % Extract available times
                availabletimes = sprintf('[%s, %s]', num2str(EEG.times(1)), num2str(EEG.times(end)));
                
                % check if ALLEEG is different
                try
                    if (size(ALLEEG,2) > 1)
                        mintim = EEG.times(1); maxtim = EEG.times(end);
                        for cF = 1:size(ALLEEG,2)
                            if (ALLEEG(cF).times(1) < mintim)
                                mintim = ALLEEG(cF).times(1);
                            end
                            if (ALLEEG(cF).times(end) > maxtim)
                                maxtim = ALLEEG(cF).times(end);
                            end
                        end
                        availabletimes = sprintf('[%s, %s]', num2str(mintim), num2str(maxtim));
                    end
                    OUTALLEEG = ALLEEG;
                catch
                    boolerr = 1;
                end
                
                prompttext = sprintf('Choose window period from EEG.times:');
                
                g1 = [0.5 0.5 ];
                s1 = [1];
                geometry = { g1 s1 g1 s1};
                uilist = { ...
                      { 'Style', 'text', 'string', 'Choose method'} ...
                      { 'Style', 'popupmenu', 'string', 'Mean | Median' 'tag' 'Method' } ...    
                      ...
                      { } ...
                      ...
                      { 'Style', 'text', 'string', prompttext} ...
                      { 'Style', 'edit', 'string', availabletimes, 'tag' 'Window'} ...   
                      ...
                      { } ...
                      ...
                  };

                  [ tmp1 tmp2 strhalt structout ] = inputgui( geometry, uilist, 'pophelp(''simplebaselinecorrect'');', 'Baseline Correct -- pop_simplebaselinecorrect');
                  if ~isempty(structout)
                      switch structout.Method
                          case 1
                              structout.Method = 'Mean';
                          case 2
                              structout.Method = 'Median';
                      end
                      if (booleeg == 1)
                        OUTEEG = simplebaselinecorrect( EEG, 'Approach', structout.Method, 'Window', structout.Window);
                        try
                            if (size(OUTALLEEG,2) > 1)
                                for cF = 1:size(OUTALLEEG,2)
                                    EEG = OUTALLEEG(cF); % because the input call gets entered into the history
                                    OUTALLEEG(cF) = simplebaselinecorrect(EEG, 'Approach', structout.Method, 'Window', structout.Window);
                                end
                            end
                        catch
                            boolerr = 1;
                        end
                      end
                      if (boolerp == 1)
                        ERP = EEG; % because the input call gets entered into the history
                        OUTEEG = simplebaselinecorrect( ERP, 'Approach', structout.Method, 'Window', structout.Window);
                        try
                            if (size(OUTALLEEG,2) > 1)
                                for cF = 1:size(OUTALLEEG,2)
                                    ERP = OUTALLEEG(cF); % because the input call gets entered into the history
                                    OUTALLEEG(cF) = simplebaselinecorrect(ERP, 'Approach', structout.Method, 'Window', structout.Window);
                                end
                            end
                        catch
                            boolerr = 1;
                        end
                      end
                      com = sprintf('\npop_simplebaselinecorrect() Equivalent Code:\n\t%s = simplebaselinecorrect(%s, ''Approach'', ''%s'', ''Window'', %s);\n', inputname(1), inputname(1), structout.Method, structout.Window);
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