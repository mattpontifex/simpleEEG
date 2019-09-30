function [OUTEEG, com] = pop_simpletrim(EEG)

    if isobject(EEG) % eegobj
        disp('Error in pop_simpletrim(): This function is not designed to work with the EEG object.')
        beep
    else
        if isempty(EEG)
            disp('Error in pop_simpletrim(): This function cannot run on an empty dataset.')
            beep
        else
            
            if isempty(EEG.data)
                disp('Error in pop_simpletrim(): This function cannot run on an empty dataset.')
                beep
            else

                winstart = EEG.times(ceil(EEG.event(1).latency))/1000;
                winstop = (EEG.times(end) - EEG.times(floor(EEG.event(end).latency)))/1000;
                
                g1 = [0.75 0.5 ];
                s1 = [1];
                geometry = { g1 s1 g1 s1};
                uilist = { ...
                      { 'Style', 'text', 'string', 'Enter the number of seconds to use for the delay prior to the first stimulus:'} ...
                      { 'Style', 'edit', 'string', num2str(winstart), 'tag' 'StartWin' } ...    
                      ...
                      { } ...
                      ...
                      { 'Style', 'text', 'string', 'Enter the number of seconds to use for the delay following the last stimulus:'} ...
                      { 'Style', 'edit', 'string',  num2str(winstop), 'tag' 'StopWin'} ...   
                      ...
                      { } ...
                      ...
                  };

                  [ tmp1 tmp2 strhalt structout ] = inputgui( geometry, uilist, 'pophelp(''simpletrim'');', 'Baseline Correct -- pop_simpletrim');
                  if ~isempty(structout)
                      
                      OUTEEG = simpletrim( EEG, 'Pre', str2num(structout.StartWin), 'Post', str2num(structout.StopWin));
                      com = sprintf('\npop_simpletrim() Equivalent Code:\n\t%s = simpletrim(%s, ''Pre'', %s, ''Post'', %s);\n', inputname(1), inputname(1), structout.StartWin, structout.StopWin);
                      disp(com)
                  else
                      OUTEEG = EEG;
                      com = '';
                  end
            end
        end
    end
end