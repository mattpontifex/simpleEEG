function [EEG, com] = pop_simplerereference(EEG)

    if isobject(EEG) % eegobj
        disp('Error in pop_simplerereference(): This function is not designed to work with the EEG object.')
        beep
    else
        if isempty(EEG)
            disp('Error in pop_simplerereference(): This function cannot run on an empty dataset.')
            beep
        else
            if isempty(EEG.data)
                disp('Error in pop_simplerereference(): This function cannot run on an empty dataset.')
                beep
            else
                
               cb_chansel1 = 'tmpchanlocs = EEG(1).chanlocs; [tmp tmpval] = pop_chansel({tmpchanlocs.labels}, ''withindex'', ''on''); set(findobj(gcbf, ''tag'', ''Reref''   ), ''string'',tmpval); clear tmpchanlocs tmp tmpval';
               cb_chansel2 = 'tmpchanlocs = EEG(1).chanlocs; [tmp tmpval] = pop_chansel({tmpchanlocs.labels}, ''withindex'', ''on''); set(findobj(gcbf, ''tag'', ''Skip''   ), ''string'',tmpval); clear tmpchanlocs tmp tmpval';
               
                g1 = [0.3 0.3 ];
                g2 = [0.3 0.2 0.1];
                s1 = [1];
                geometry = { g2 s1 g1 s1 g2 s1 };
                uilist = { ...
                      { 'Style', 'text', 'string', 'Rereference data to channel(s):'} ...
                      { 'Style', 'edit', 'string', '' 'tag' 'Reref' } ...
                      { 'Style' 'pushbutton' 'string' '...' 'callback' cb_chansel1 'tag' 'refbr' } ...
                      ...
                      { } ...
                      ...
                      { 'Style', 'text', 'string', 'Retain original reference:'} ...
                      { 'Style', 'popupmenu', 'string', 'Yes | No' 'tag' 'OrigRef' } ... 
                      ...
                      { } ...
                      ...
                      { 'Style', 'text', 'string', 'Select any channels to skip when rereferencing data:'} ...
                      { 'Style', 'edit', 'string', '' 'tag' 'Skip' } ...
                      { 'Style' 'pushbutton' 'string' '...' 'callback' cb_chansel2 'tag' 'refbr' } ...
                      ...
                      { } ...
                      ...
                  };

                  [ tmp1 tmp2 strhalt structout ] = inputgui( geometry, uilist, 'pophelp(''rereferenceplus'');', 'Rereference data -- pop_simplerereference');
                  if ~isempty(structout)
                      if ~strcmpi(structout.Reref, "") % something was chosen to reference to
                      
                          refchanlist = textscan(structout.Reref,'%s','Delimiter',' ');
                          refchanlist = refchanlist{1}';
                          refchanlistcom = sprintf('{');
                          for cE = 1:size(refchanlist,2)
                              refchanlistcom = sprintf('%s ''%s''', refchanlistcom, refchanlist{cE});
                              if (cE ~= size(refchanlist,2))
                                  refchanlistcom = sprintf('%s,', refchanlistcom);
                              end
                          end
                          refchanlistcom = sprintf('%s }', refchanlistcom);
                          structout.Reref = refchanlistcom;
                          
                          switch structout.OrigRef
                              case 1
                                  structout.OrigRef = 'on';
                              case 2
                                  structout.OrigRef = 'off';
                          end
                          
                          if strcmpi(structout.Skip, "")
                              structout.Skip = [];
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
                              structout.Skip = sprintf('eegchannelarrayindex( %s, %s)', inputname(1), structout.Skip);
                          end

                          %   EEG = rereferenceplus( EEG, {'M1', 'M2'}, {'VEO', 'HEO'}, 'CCPZ');
                          % EEG = pop_reref( EEG, {'M1', 'M2'}, 'exclude', [43, 69], 'keepref', 'on');
                          
                          com = sprintf('%s = pop_reref(%s, %s, ''exclude'', %s, ''keepref'', ''%s'');', inputname(1), inputname(1), structout.Reref, structout.Skip, structout.OrigRef);
                          eval(com);
                          EEG.history = sprintf('%s\n%s', EEG.history, com);
                          com = sprintf('\npop_simplerereference() Equivalent Code:\n\t%s', com);
                          disp(com)
                      else
                          com = '';
                     end
                  else
                      com = '';
                  end
            end
        end
    end
end