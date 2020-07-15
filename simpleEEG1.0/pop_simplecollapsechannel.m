function [ERP, com] = pop_simplecollapsechannel(ERP)

    if isobject(ERP) % eegobj
        disp('Error in pop_simplecollapsechannel(): This function is not designed to work with the EEG object.')
        beep
    else
        if isempty(ERP)
            disp('Error in pop_simplecollapsechannel(): This function cannot run on an empty dataset.')
            beep
        else
            if isempty(ERP.bindata)
                disp('Error in pop_simplecollapsechannel(): This function cannot run on an empty dataset.')
                beep
            else
                cb_chansel1 = 'tmpchanlocs = ERP(1).chanlocs; [tmp tmpval] = pop_chansel({tmpchanlocs.labels}, ''withindex'', ''on''); set(findobj(gcbf, ''tag'', ''Skip''   ), ''string'',tmpval); clear tmpchanlocs tmp tmpval';
               
                g1 = [0.5 0.5 ];
                g2 = [0.5 0.5 0.2];
                s1 = [1];
                geometry = { g1 s1 g2 s1 g1 s1 };
                uilist = { ...
                      { 'Style', 'text', 'string', 'Choose central tendency approach:'} ...
                      { 'Style', 'popupmenu', 'string', 'Mean | Median' 'tag' 'Method' } ...  
                      ...
                      { } ...
                      ...
                      { 'Style', 'text', 'string', 'Select channels to collapse:'} ...
                      { 'Style', 'edit', 'string', '' 'tag' 'Skip' } ...
                      { 'Style' 'pushbutton' 'string' '...' 'callback' cb_chansel1 'tag' 'refbr' } ...
                      ...
                      { } ...
                      ...
                      { 'Style', 'text', 'string', 'New channel name'} ...
                      { 'Style', 'edit', 'string', '' 'tag' 'NewName' } ...
                      ...
                      { } ...
                      ...
                  };

                  [ tmp1 tmp2 strhalt structout ] = inputgui( geometry, uilist, 'pophelp(''simplecollapsechannel'');', 'Collapse Channels -- pop_simplecollapsechannel');
                  if ~isempty(structout)
                      
                      switch structout.Method
                          case 1
                              structout.Method = 'Mean';
                          case 2
                              structout.Method = 'Median';
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
                      if (strcmpi(skipchanlistcom, ""))
                          skipchanlistcom = '[]';
                      end
                      
                      com = sprintf('ERP = simplecollapsechannel(%s, ''Method'', ''%s'', ''Channels'', %s, ''NewChannelName'', ''%s'');', inputname(1), structout.Method, skipchanlistcom, structout.NewName);
                      eval(com)
                      
                      com = sprintf('\npop_simplecollapsechannel() Equivalent Code:\n\t%s\n', com);
                      disp(com)
                  else
                      ERP = [];
                      com = '';
                  end
            end
        end
    end
end