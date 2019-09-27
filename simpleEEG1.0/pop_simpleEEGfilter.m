function [OUTEEG, OUTALLEEG, com] = pop_simpleEEGfilter(EEG, ALLEEG)

    if isobject(EEG) % eegobj
        disp('Error in pop_simpleEEGfilter(): This function is not designed to work with the EEG object.')
        beep
    else
        if isempty(EEG)
            disp('Error in pop_simpleEEGfilter(): This function cannot run on an empty dataset.')
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
                disp('Error in pop_simpleEEGfilter(): This function cannot run on an empty dataset.')
                beep
            else
                
                try
                    OUTALLEEG = ALLEEG;
                catch
                    boolerr = 1;
                end
                
                g1 = [0.5 0.5 ];
                s1 = [1];
                geometry = { g1 s1 g1 s1 g1 s1 };
                uilist = { ...
                      { 'Style', 'text', 'string', 'Choose filter:'} ...
                      { 'Style', 'popupmenu', 'string', 'Bandpass | Lowpass | Highpass | Notch' 'tag' 'Method' } ...  
                      ...
                      { } ...
                      ...
                      { 'Style', 'text', 'string', 'Choose filter design:'} ...
                      { 'Style', 'popupmenu', 'string', 'Windowed Symmetric FIR | IIR Butterworth' 'tag' 'Design' } ...
                      ...
                      { } ...
                      ...
                      { 'Style', 'text', 'string', 'Choose filter cutoffs (in Hz):'} ...
                      { 'Style', 'edit', 'string', '[ 0.5, 30 ]' 'tag' 'Cutoffs' } ...
                      ...
                      { } ...
                      ...
                  };

                  [ tmp1 tmp2 strhalt structout ] = inputgui( geometry, uilist, 'pophelp(''simpleEEGfilter'');', 'Epoch -- pop_simpleEEGfilter');
                  if ~isempty(structout)
                      
                      switch structout.Method
                          case 1
                              structout.Method = 'Bandpass';
                          case 2
                              structout.Method = 'Lowpass';
                          case 3
                              structout.Method = 'Highpass';
                          case 4
                              structout.Method = 'Notch';
                      end
                      
                      switch structout.Design
                          case 1
                              structout.Design = 'Windowed Symmetric FIR';
                              structout.OrderNum = (3*fix(EEG.srate/0.5));
                              structout.Order = '(3*fix(EEG.srate/0.5))';
                          case 2
                              structout.Design = 'IIR Butterworth';
                              structout.OrderNum = 2;
                              structout.Order = '2';
                      end
                      if (ischar(structout.Cutoffs))
                         structout.Cutoffs = str2num(structout.Cutoffs); 
                      end
                      
                      if (booleeg == 1)
                          OUTEEG = simpleEEGfilter( EEG, 'Filter', structout.Method, 'Design', structout.Design, 'Cutoff', structout.Cutoffs, 'Order', structout.OrderNum);
                            try
                                if (size(OUTALLEEG,2) > 1)
                                    for cF = 1:size(OUTALLEEG,2)
                                        EEG = OUTALLEEG(cF); % because the input call gets entered into the history
                                        OUTALLEEG(cF) = simpleEEGfilter( EEG, 'Filter', structout.Method, 'Design', structout.Design, 'Cutoff', structout.Cutoffs, 'Order', structout.OrderNum);
                                    end
                                end
                            catch
                                boolerr = 1;
                            end
                        
                      end                  
                      if (boolerp == 1)
                          ERP = EEG; % because the input call gets entered into the history
                          OUTEEG = simpleEEGfilter( ERP, 'Filter', structout.Method, 'Design', structout.Design, 'Cutoff', structout.Cutoffs, 'Order', structout.OrderNum);
                            try
                                if (size(OUTALLEEG,2) > 1)
                                    for cF = 1:size(OUTALLEEG,2)
                                        ERP = OUTALLEEG(cF); % because the input call gets entered into the history
                                        OUTALLEEG(cF) = simpleEEGfilter( ERP, 'Filter', structout.Method, 'Design', structout.Design, 'Cutoff', structout.Cutoffs, 'Order', structout.OrderNum);
                                    end
                                end
                            catch
                                boolerr = 1;
                            end
                      end
                      
                      com = sprintf('\npop_simpleEEGfilter() Equivalent Code:\n\t%s = simpleEEGfilter(%s, ''Filter'', ''%s'', ''Design'', ''%s'', ''Cutoff'', %s, ''Order'', %d);\n', inputname(1), inputname(1), structout.Method, structout.Design, makematrixarraystr(structout.Cutoffs), structout.OrderNum);
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