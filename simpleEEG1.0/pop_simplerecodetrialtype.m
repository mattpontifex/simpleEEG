function [OUTEEG, com] = pop_simplerecodetrialtype(EEG, varargin)

    if ~isempty(varargin)
    	r=struct(varargin{:});
    end
    try, Pop = r(1).Pop; catch, Pop = 'False'; end
    
    if isobject(EEG) % eegobj
        disp('Error in pop_simplerecodetrialtype(): This function is not designed to work with the EEG object.')
        beep
    else
        if isempty(EEG)
            disp('Error in pop_simplerecodetrialtype(): This function cannot run on an empty dataset.')
            beep
        else
            if isempty(EEG.data)
                disp('Error in pop_simplerecodetrialtype(): This function cannot run on an empty dataset.')
                beep
            else

                 cb_chansel1 = '[epochevents, epocheventlist] = simplecheckavailabletrials(EEG); temp2 = {epochevents}; temp2 = temp2{1,1}; [tmp tmpval] = pop_chansel(temp2, ''withindex'', ''on''); [epocheventlist] = simplecollapsesequentialnumbers(str2num(tmpval)); set(findobj(gcbf, ''tag'', ''Eventtypes''   ), ''string'',epocheventlist); clear epochevents epocheventlist temp2 tmp tmpval';
                
                % Identify eligible events - slow but reliable
                [epochevents, epocheventlist, eventmatrix] = simplecheckavailabletrials(EEG); 
                 
                % Check to see if event information is loaded
                if (isfield(EEG.event,'respcode'))
                    prompttext = sprintf('To recode response events associated with this event type based on behavior, input new response codes:');
                    enabresponse = 'on';
                else
                    prompttext = sprintf('Behavior must be merged to recode response events.');
                    enabresponse = 'off';
                end
                
                % Extract available times
                g1 = [0.5 0.5 ];
                g2 = [0.5 1 0.2];
                s1 = [1];
                geometry = { g2 s1 g1 s1 s1 g1 g1 g1};
                uilist = { ...
                      { 'Style', 'text', 'string', 'Choose events to recode:'} ...
                      { 'Style', 'edit', 'string', epocheventlist, 'tag' 'Eventtypes'} ...   
                      { 'Style' 'pushbutton' 'string' '...' 'callback' cb_chansel1 'tag' 'refbr' } ...
                      ...
                      { } ...
                      ...
                      { 'Style', 'text', 'string', 'New event code:'} ...
                      { 'Style', 'edit', 'string', '', 'tag' 'NewCode'} ...  
                      ...
                      { } ...
                      ...
                      { 'Style', 'text', 'string', prompttext} ...
                      ...
                      { 'Style', 'text', 'string', 'Event code for correct responses:', 'enable' enabresponse} ...
                      { 'Style', 'edit', 'string', '', 'tag' 'Correct', 'enable' enabresponse} ...  
                      ...
                      { 'Style', 'text', 'string', 'Event code for match-correct responses:', 'enable' enabresponse} ...
                      { 'Style', 'edit', 'string', '', 'tag' 'MatchCorrect', 'enable' enabresponse} ...  
                      ...
                      { 'Style', 'text', 'string', 'Event code for commission error responses:', 'enable' enabresponse} ...
                      { 'Style', 'edit', 'string', '', 'tag' 'CommissionError', 'enable' enabresponse} ...  
                  };
                [ tmp1 tmp2 strhalt structout ] = inputgui( geometry, uilist, 'pophelp(''responselockedrecodebasedonbehavior'');', 'Recode -- pop_simplerecodetrialtype');
                
                com = '';
                if ~isempty(structout)
                    if (~isempty(structout.Eventtypes)) % event codes were specified
                        if ~isempty(intersect(str2num(structout.Eventtypes), eventmatrix(:,2))) % event codes exist
                            com = sprintf('%s\npop_simplerecodetrialtype() Equivalent Code:\n', com);
                            histcom = '';
                            if ((~isempty(structout.Correct)) | (~isempty(structout.MatchCorrect)) | (~isempty(structout.CommissionError))) % if any of the three were specified
                            
                                tcom = sprintf('%s = responselockedrecodebasedonbehavior(%s, ''Type'', %s', inputname(1), inputname(1), structout.Eventtypes);
                                if (~isempty(structout.Correct))
                                    tcom = sprintf('%s, ''Correct'', %s', tcom, structout.Correct);
                                end
                                if (~isempty(structout.MatchCorrect))
                                    tcom = sprintf('%s, ''MatchCorrect'', %s', tcom, structout.MatchCorrect);
                                end
                                if (~isempty(structout.CommissionError))
                                    tcom = sprintf('%s, ''CommissionError'', %s', tcom, structout.CommissionError);
                                end
                                tcom = sprintf('%s);', tcom);
                                eval(tcom);
                                com = sprintf('%s\t%s\n', com, tcom); % format for screen
                            end
                            if (~isempty(structout.NewCode)) % user would like each event to have a new code
                                
                                tcom = sprintf('[epochevents, epocheventlist, eventmatrix] = simplecheckavailabletrials(EEG);');
                                eval(tcom)
                                com = sprintf('%s\t%s\n', com, tcom); % format for screen
                                histcom = sprintf('%s%s\n', histcom, tcom); % format for history
                                
                                tcom = sprintf('tempelements = eventmatrix(ismember(eventmatrix(:,2), %s),1);', simplecollapsesequentialnumbers(str2num(structout.Eventtypes)));
                                eval(tcom)
                                com = sprintf('%s\t%s\n', com, tcom); % format for screen
                                histcom = sprintf('%s%s\n', histcom, tcom); % format for history
                                
                                tcom = sprintf('for iEvent = 1:numel(tempelements); %s.event(tempelements(iEvent)).type = %s; end', inputname(1), structout.NewCode);
                                eval(tcom)
                                com = sprintf('%s\t%s\n', com, tcom); % format for screen
                                histcom = sprintf('%s%s', histcom, tcom); % format for history
                                
                                tcom = sprintf('clear eventmatrix tempelements iEvent;');
                                eval(tcom)
                                com = sprintf('%s\t%s\n', com, tcom); % format for screen
                                
                                EEG.history = sprintf('%s\n%s', EEG.history, histcom);
                            end

                            OUTEEG = EEG;
                          disp(com)
                        else
                            OUTEEG = EEG;
                        end
                    else
                      OUTEEG = EEG;
                    end
                    
                else
                  OUTEEG = EEG;
                end
            end
        end
    end
end