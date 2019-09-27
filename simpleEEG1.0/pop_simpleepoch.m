function [OUTEEG, com] = pop_simpleepoch(EEG)

    if isobject(EEG) % eegobj
        disp('Error in pop_simpleepoch(): This function is not designed to work with the EEG object.')
        beep
    else
        if isempty(EEG)
            disp('Error in pop_simpleepoch(): This function cannot run on an empty dataset.')
            beep
        else
            if isempty(EEG.data)
                disp('Error in pop_simpleepoch(): This function cannot run on an empty dataset.')
                beep
            else

                 cb_chansel1 = '[epochevents, epocheventlist] = simplecheckavailabletrials(EEG); temp2 = {epochevents}; temp2 = temp2{1,1}; [tmp tmpval] = pop_chansel(temp2, ''withindex'', ''on''); [epocheventlist] = simplecollapsesequentialnumbers(str2num(tmpval)); set(findobj(gcbf, ''tag'', ''Eventtypes''   ), ''string'',epocheventlist); clear epochevents epocheventlist temp2 tmp tmpval';
                
                % Identify eligible events - slow but reliable
                [epochevents, epocheventlist] = simplecheckavailabletrials(EEG); 
                
                % Extract available times
                availabletimes = sprintf('[ -100, 1000 ]');
                prompttext = sprintf('Choose window period in ms:');
                prompttext2 = sprintf('Choose events to epoch:');
                
                g1 = [0.5 0.5 ];
                g2 = [0.5 1 0.2];
                s1 = [1];
                geometry = { g1 s1 g2 s1};
                uilist = { ...
                      { 'Style', 'text', 'string', prompttext} ...
                      { 'Style', 'edit', 'string', availabletimes, 'tag' 'Window'} ...   
                      ...
                      { } ...
                      ...
                      { 'Style', 'text', 'string', prompttext2} ...
                      { 'Style', 'edit', 'string', epocheventlist, 'tag' 'Eventtypes'} ...   
                      { 'Style' 'pushbutton' 'string' '...' 'callback' cb_chansel1 'tag' 'refbr' } ...
                      ...
                      { } ...
                      ...
                  };

                  [ tmp1 tmp2 strhalt structout ] = inputgui( geometry, uilist, 'pophelp(''simpleepoch'');', 'Epoch -- pop_simpleepoch');
                  if ~isempty(structout)
                      OUTEEG = simpleepoch( EEG, 'Window', str2num(structout.Window), 'Types', str2num(structout.Eventtypes));
                      com = sprintf('\npop_simpleepoch() Equivalent Code:\n\t%s = simpleepoch(%s, ''Window'', %s, ''Types'', %s);\n', inputname(1), inputname(1), structout.Window, structout.Eventtypes);
                      disp(com)
                  else
                      OUTEEG = EEG;
                      com = '';
                  end
            end
        end
    end
end