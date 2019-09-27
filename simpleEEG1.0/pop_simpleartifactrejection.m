function [EEG, com] = pop_simpleartifactrejection(EEG)

    if isobject(EEG) % eegobj
        disp('Error in pop_simpleartifactrejection(): This function is not designed to work with the EEG object.')
        beep
    else
        if isempty(EEG)
            disp('Error in pop_simpleartifactrejection(): This function cannot run on an empty dataset.')
            beep
        else
            if isempty(EEG.data)
                disp('Error in pop_simpleartifactrejection(): This function cannot run on an empty dataset.')
                beep
            else
                
               cb_chansel1 = 'tmpchanlocs = EEG(1).chanlocs; [tmp tmpval] = pop_chansel({tmpchanlocs.labels}, ''withindex'', ''on''); set(findobj(gcbf, ''tag'', ''Skip''   ), ''string'',tmpval); clear tmpchanlocs tmp tmpval';
                
               % Obtain threshold minimum and maximum
               VThresmax = floor(prctile((nanmax(nanmax(EEG.data))),95));
               VThresmin = floor(prctile((nanmin(nanmin(EEG.data))),95));
               VThres = sprintf('[ %s, %s ]', num2str(VThresmin), num2str(VThresmax));
               P2Pmax = num2str(floor(prctile((nanmax(nanmax(diff(EEG.data)))),95)));
                availabletimes = sprintf('[ %s, %s ]', num2str(EEG.times(1)), num2str(EEG.times(end)));
               
                g1 = [0.3 0.3 ];
                g2 = [0.3 0.3 0.2];
                s1 = [1];
                geometry = { g1 s1 g1 s1 g1 s1 g2 s1 };
                uilist = { ...
                      { 'Style', 'text', 'string', 'Enter voltage threshold parameters:'} ...
                      { 'Style', 'edit', 'string', VThres 'tag' 'VoltageThreshold' } ...  
                      ...
                      { } ...
                      ...
                      { 'Style', 'text', 'string', 'Enter sample to sample threshold parameter:'} ...
                      { 'Style', 'edit', 'string', P2Pmax 'tag' 'PointByPoint' } ...
                      ...
                      { } ...
                      ...
                      { 'Style', 'text', 'string', 'Enter the window period to screen for artifacts (default is entire window)'} ...
                      { 'Style', 'edit', 'string', availabletimes, 'tag' 'Window'} ...   
                      ...
                      { } ...
                      ...
                      { 'Style', 'text', 'string', 'Select channels to use for artifact rejection (default is all channels):'} ...
                      { 'Style', 'edit', 'string', '' 'tag' 'Skip' } ...
                      { 'Style' 'pushbutton' 'string' '...' 'callback' cb_chansel1 'tag' 'refbr' } ...
                      ...
                      { } ...
                      ...
                  };

                  [ tmp1 tmp2 strhalt structout ] = inputgui( geometry, uilist, 'pophelp(''simpleartifactrejection'');', 'Artifact Reject -- pop_simpleartifactrejection');
                  if ~isempty(structout)
                      if strcmpi(structout.VoltageThreshold, "")
                          structout.VoltageThreshold = NaN;
                      end
                      if strcmpi(structout.PointByPoint, "")
                          structout.PointByPoint = NaN;
                      end
                      if strcmpi(structout.Window, "")
                          structout.Window = NaN;
                      end
                      if strcmpi(structout.Skip, "")
                          structout.Skip = NaN;
                          skipchanlist = [];
                      else
                          skipchanlist = textscan(structout.Skip,'%s','Delimiter',' ');
                          skipchanlist = skipchanlist{1}';
                          skipchanlistcom = sprintf('{');
                          for cE = 1:size(skipchanlist,2)
                              skipchanlistcom = sprintf('%s ''%s''', skipchanlistcom, skipchanlist{cE});
                              if (cE ~= size(skipchanlist,2))
                                  skipchanlistcom = sprintf('%s,', skipchanlistcom);
                              end
                          end
                          skipchanlistcom = sprintf('%s }', skipchanlistcom);
                          structout.Skip = skipchanlistcom;
                      end
                      
                      com = sprintf('%s = simpleartifactrejection(%s, ''VoltageThreshold'', %s, ''PointThreshold'', %s, ''Window'', %s', inputname(1), inputname(1), structout.VoltageThreshold, structout.PointByPoint, structout.Window);
                      if (size(skipchanlist,2) == EEG.nbchan) | isnan(structout.Skip) % if the entire array was selected or was not entered
                          com = sprintf('%s);\n', com);
                      else
                          % only a subset of channels was selected
                          com = sprintf('%s, ''Channels'', %s', com, structout.Skip);
                          com = sprintf('%s);\n', com);
                      end
                      eval(com);
                      com = sprintf('\npop_simpleartifactrejection() Equivalent Code:\n\t%s', com);
                      disp(com)
                  else
                      com = '';
                  end
            end
        end
    end
end