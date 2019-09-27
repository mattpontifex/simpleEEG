function [OUTEEG, com] = pop_simplespectral(EEG)

    if isobject(EEG) % eegobj
        disp('Error in pop_simplespectral(): This function is not designed to work with the EEG object.')
        beep
    else
        if isempty(EEG)
            disp('Error in pop_simplespectral(): This function cannot run on an empty dataset.')
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
                disp('Error in pop_simplespectral(): This function cannot run on an empty dataset.')
                beep
            else
                
                %cb_setbaseon = 'set(findobj(''parent'', gcbf, ''tag'', ''Baseline'' ), ''enable'',''on'');';
                %cb_setbaseoff = 'set(findobj(''parent'', gcbf, ''tag'', ''Baseline'' ), ''enable'',''off'');';
                
                %enabbaseline = 'off';     
                %cb_chansel1 = 'fprintf(''%s\n'',get(gcbo, ''string''))';
                %cb_chansel1 = 'fprintf(''%s\n'',get(findobj(''parent'', gcbf, ''tag'', ''Unitpower'' ), ''string''))';
                
                %cb_chansel1 = 'tempstr = get(gcbo, ''string''); if (strcmpi(tempstr, ''Power Spectrum Density (dB)'') | strcmpi(tempstr, ''Power Spectrum Density (std.)'') | strcmpi(tempstr, ''Normalized Power (% of Baseline)'')); set(findobj(''parent'', gcbf, ''tag'', ''Baseline'' ), ''enable'',''on''); else; set(findobj(''parent'', gcbf, ''tag'', ''Baseline'' ), ''enable'',''off''); end;';
                
                g1 = [0.5 0.5 ];
                s1 = [1];
                geometry = { g1 s1 g1 s1 g1 s1 g1 s1 g1 s1 g1 s1 };
                uilist = { ...
                      { 'Style', 'text', 'string', 'Choose design'} ...
                      { 'Style', 'popupmenu', 'string', 'Spectral | TimeFrequency' 'tag' 'Design' } ...    
                      ...
                      { } ...
                      ...
                      { 'Style', 'text', 'string', 'Choose output unit:'} ...
                      { 'Style', 'popupmenu', 'string', 'Absolute Power FFT (microV^{2}/Hz) | Log Power FFT (10*log10(microV^{2}/Hz)) | Absolute Power Spectrum Density (microV^{2}/Hz) | Log Power Spectrum Density (10*log10(microV^{2}/Hz)) | Power Spectrum Density (dB) | Power Spectrum Density (std.) | Normalized Power (% of Baseline)' 'tag' 'Unitpower' } ...    
                      ...
                      { } ...
                      ...
                      { 'Style', 'text', 'string', 'Choose baseline window (only necessary for PSD dB/std or Normalized Power):'} ...
                      { 'Style', 'edit', 'string', '[ NaN ]', 'tag' 'Baseline'} ...   
                      ...
                      { } ...
                      ...
                      { 'Style', 'text', 'string', 'Choose frequency range:'} ...
                      { 'Style', 'edit', 'string', '[ 0, 50 ]', 'tag' 'Frequencies'} ...   
                      ...
                      { } ...
                      ...
                      { 'Style', 'text', 'string', 'Choose frequency resolution (larger numbers increase resolution):'} ...
                      { 'Style', 'edit', 'string', '8', 'tag' 'Padratio'} ...   
                      ...
                      { } ...
                      ...
                      { 'Style', 'text', 'string', 'Choose output data:'} ...
                      { 'Style', 'popupmenu', 'string', 'Spectral | IntertrialCoherence' 'tag' 'Output' } ...  
                      ...
                      { } ...
                      ...
                  };

                  [ tmp1 tmp2 strhalt structout ] = inputgui( geometry, uilist, 'pophelp(''simplespectral'');', 'Compute Spectral Power -- pop_simplespectral');
                  if ~isempty(structout)
                      switch structout.Design
                          case 1
                              structout.Design = 'Spectral';
                          case 2
                              structout.Design = 'TimeFrequency';
                      end
                      
                      switch structout.Unitpower
                          case 1
                              structout.Unitpower = 'Absolute Power FFT (microV^{2}/Hz)';
                          case 2
                              structout.Unitpower = 'Log Power FFT (10*log10(microV^{2}/Hz))';
                          case 3
                              structout.Unitpower = 'Absolute Power Spectrum Density (microV^{2}/Hz)';
                          case 4
                              structout.Unitpower = 'Log Power Spectrum Density (10*log10(microV^{2}/Hz))';
                          case 5
                              structout.Unitpower = 'Power Spectrum Density (dB)';
                          case 6
                              structout.Unitpower = 'Power Spectrum Density (std.)';
                          case 7
                              structout.Unitpower = 'Normalized Power (% of Baseline)';
                      end
                      
                      switch structout.Output
                          case 1
                              structout.Output = 'Spectral';
                          case 2
                              structout.Output = 'IntertrialCoherence';
                      end
                      
                      if (booleeg == 1)
                        [OUTEEG, com] = simplespectral(EEG,'Design',structout.Design, 'Unitpower', structout.Unitpower, 'Output', structout.Output, 'Baseline', structout.Baseline, 'Padratio', str2num(structout.Padratio), 'Frequencies', str2num(structout.Frequencies));
                      elseif (boolerp == 1)
                        ERP = EEG; % because the input call gets entered into the history
                        [OUTEEG, com] = simplespectral(ERP,'Design',structout.Design, 'Unitpower', structout.Unitpower, 'Output', structout.Output, 'Baseline', structout.Baseline, 'Padratio', str2num(structout.Padratio), 'Frequencies', str2num(structout.Frequencies));
                      end
                      com = sprintf('\npop_simplespectral() Equivalent Code:\n\t%s', com);
                      disp(com)
                  else
                      OUTEEG = EEG;
                      com = '';
                  end
            end
        end
    end
end