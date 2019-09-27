function [OUTEEG, com] = pop_catchbadchannels(EEG)

    if isobject(EEG) % eegobj
        disp('Error in pop_catchbadchannels(): This function is not designed to work with the EEG object.')
        beep
    else
        if isempty(EEG)
            disp('Error in pop_catchbadchannels(): This function cannot run on an empty dataset.')
            beep
        else
            if isempty(EEG.data)
                disp('Error in pop_catchbadchannels(): This function cannot run on an empty dataset.')
                beep
            else
                
               cb_chansel1 = 'tmpchanlocs = EEG(1).chanlocs; [tmp tmpval] = pop_chansel({tmpchanlocs.labels}, ''withindex'', ''on''); set(findobj(gcbf, ''tag'', ''Skip''   ), ''string'',tmpval); clear tmpchanlocs tmp tmpval';
                
                g1 = [0.5 0.5 ];
                g2 = [0.5 0.5 0.2];
                s1 = [1];
                geometry = { g1 s1 g1 s1 g1 s1 g1 s1 g2 s1 };
                uilist = { ...
                      { 'Style', 'text', 'string', 'Enter Z score for 60hz line noise detection:'} ...
                      { 'Style', 'edit', 'string', '20' 'tag' 'LineNoise' } ...  
                      ...
                      { } ...
                      ...
                      { 'Style', 'text', 'string', 'Enter Z score for channel outlier detection:'} ...
                      { 'Style', 'edit', 'string', '20' 'tag' 'Smoothed' } ...  
                      ...
                      { } ...
                      ...
                      { 'Style', 'text', 'string', 'Enter Z score for point by point outlier detection:'} ...
                      { 'Style', 'edit', 'string', '20' 'tag' 'PointByPoint' } ...
                      ...
                      { } ...
                      ...
                      { 'Style', 'text', 'string', 'Enter number of values to trim from the extremes:'} ...
                      { 'Style', 'edit', 'string', '2' 'tag' 'Trim' } ...
                      ...
                      { } ...
                      ...
                      { 'Style', 'text', 'string', 'Select channels to exclude:'} ...
                      { 'Style', 'edit', 'string', '' 'tag' 'Skip' } ...
                      { 'Style' 'pushbutton' 'string' '...' 'callback' cb_chansel1 'tag' 'refbr' } ...
                      ...
                      { } ...
                      ...
                  };

                  [ tmp1 tmp2 strhalt structout ] = inputgui( geometry, uilist, 'pophelp(''catchbadchannels'');', 'Epoch -- pop_catchbadchannels');
                  if ~isempty(structout)
                      
                      if strcmpi(structout.LineNoise, "")
                        structout.LineNoise = '0';
                      end
                      
                      if strcmpi(structout.Smoothed, "")
                          structout.Smoothed = '0';
                      end
                      if strcmpi(structout.PointByPoint, "")
                          structout.PointByPoint = '0';
                      end
                      if strcmpi(structout.Trim, "")
                          structout.Trim = '0';
                      end
                      if strcmpi(structout.Skip, "")
                          skipchanlistcom = "";
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
                      end

                      badchannels = catchbadchannels( EEG, 'LineNoise', str2num(structout.LineNoise), 'Smoothed', str2num(structout.Smoothed), 'PointByPoint', str2num(structout.PointByPoint), 'Trim', str2num(structout.Trim), 'Skip', skipchanlistcom);
                      if ~isempty(badchannels)
                          OUTEEG = pop_select( EEG, 'nochannel', badchannels);
                          [T, OUTEEG] = evalc('letterkilla(OUTEEG);');
                      else
                          OUTEEG = EEG;
                      end
                      if (strcmpi(skipchanlistcom, ""))
                          skipchanlistcom = '[]';
                      end
                      com = sprintf('\npop_catchbadchannels() Equivalent Code:\n\t');
                      com = sprintf('%sbadchannels = catchbadchannels(%s, ''LineNoise'', %s, ''Smoothed'', %s, ''PointByPoint'', %s, ''Trim'', %s, ''Skip'', %s);\n', com, inputname(1), structout.LineNoise, structout.Smoothed, structout.PointByPoint, structout.Trim, skipchanlistcom);
                      com = sprintf('%s\tif ~isempty(badchannels); %s = pop_select( %s, ''nochannel'', badchannels); %s = letterkilla(%s); end\n', com, inputname(1), inputname(1), inputname(1), inputname(1));
                      disp(com)
                  else
                      OUTEEG = EEG;
                      com = '';
                  end
            end
        end
    end
end