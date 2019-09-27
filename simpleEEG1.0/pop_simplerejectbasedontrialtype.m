function [EEG, com] = pop_simplerejectbasedontrialtype(EEG)

    if isobject(EEG) % eegobj
        disp('Error in pop_simplerejectbasedontrialtype(): This function is not designed to work with the EEG object.')
        beep
    else
        if isempty(EEG)
            disp('Error in pop_simplerejectbasedontrialtype(): This function cannot run on an empty dataset.')
            beep
        else
            if isempty(EEG.data)
                disp('Error in pop_simplerejectbasedontrialtype(): This function cannot run on an empty dataset.')
                beep
            else

                 cb_chansel1 = '[epochevents, epocheventlist] = simplecheckavailabletrials(EEG); temp2 = {epochevents}; temp2 = temp2{1,1}; [tmp tmpval] = pop_chansel(temp2, ''withindex'', ''on''); [epocheventlist] = simplecollapsesequentialnumbers(str2num(tmpval)); set(findobj(gcbf, ''tag'', ''Eventtypes''   ), ''string'',epocheventlist); clear epochevents epocheventlist temp2 tmp tmpval';
                
                % Identify eligible events - slow but reliable
                [epochevents, epocheventlist] = simplecheckavailabletrials(EEG); 
                
                % Extract available times
                prompttext2 = sprintf('Choose events to reject:');
                
                g1 = [0.5 0.5 ];
                g2 = [0.5 1 0.2];
                s1 = [1];
                geometry = { g2 s1};
                uilist = { ...
                      { 'Style', 'text', 'string', prompttext2} ...
                      { 'Style', 'edit', 'string', epocheventlist, 'tag' 'Eventtypes'} ...   
                      { 'Style' 'pushbutton' 'string' '...' 'callback' cb_chansel1 'tag' 'refbr' } ...
                      ...
                      { } ...
                      ...
                  };

                  [ tmp1 tmp2 strhalt structout ] = inputgui( geometry, uilist, 'pophelp(''simplerejectbasedontrialtype'');', 'Reject by trial type -- pop_simplerejectbasedontrialtype');
                  if ~isempty(structout)
                      
                      com = sprintf('%s = simplerejectbasedontrialtype(%s, ''Types'', %s);', inputname(1), inputname(1), structout.Eventtypes);
                      eval(com)
                      com = sprintf('\npop_simplerejectbasedontrialtype() Equivalent Code:\n\t%s', com);
                      disp(com)
                  else
                      com = '';
                  end
            end
        end
    end
end