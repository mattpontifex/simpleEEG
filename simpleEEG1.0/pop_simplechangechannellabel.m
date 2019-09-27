function [EEG, com] = pop_simplechangechannellabel(EEG, varargin)
% Function to change the label of a channel. 
%
% example:
% EEG = pop_simplechangechannellabel(EEG, 'CurrentChannel', 'HEO', 'NewChannel', 'HEOG');

    if ~isempty(varargin)
    	r=struct(varargin{:});
    end
    try, Pop = r(1).Pop; catch, Pop = 'False'; end
    try, CurrentChannel = r(1).CurrentChannel; catch, CurrentChannel = ''; end
    try, NewChannel = r(1).NewChannel; catch, NewChannel = ''; end
    
    com = "";
    
    if isobject(EEG) % eegobj
        disp('Error in pop_simplechangechannellabel(): This function is not designed to work with the EEG object.')
        beep
    else
        if isempty(EEG)
            disp('Error in pop_simplechangechannellabel(): This function cannot run on an empty dataset.')
            beep
        else
            if isempty(EEG.data)
                disp('Error in pop_simplechangechannellabel(): This function cannot run on an empty dataset.')
                beep
            else
                
               structout = [];
               if strcmpi(Pop, 'True') % only show if pop is true
                   cb_chansel1 = 'tmpchanlocs = EEG(1).chanlocs; [tmp tmpval] = pop_chansel({tmpchanlocs.labels}, ''withindex'', ''on'', ''selectionmode'', ''single''); set(findobj(gcbf, ''tag'', ''Channel''   ), ''string'',tmpval); clear tmpchanlocs tmp tmpval';

                    g1 = [0.3 0.3 ];
                    g2 = [0.3 0.2 0.1];
                    s1 = [1];
                    geometry = { g2 s1 g1 s1 };
                    uilist = { ...
                          { 'Style', 'text', 'string', 'Select channel to rename:'} ...
                          { 'Style', 'edit', 'string', '' 'tag' 'Channel' } ...
                          { 'Style' 'pushbutton' 'string' '...' 'callback' cb_chansel1 'tag' 'refbr' } ...
                          ...
                          { } ...
                          ...
                          { 'Style', 'text', 'string', 'Enter a new name for the channel:'} ...
                          { 'Style', 'edit', 'string', '' 'tag' 'Newname' } ... 
                          ...
                          { } ...
                          ...
                      };

                      [ tmp1 tmp2 strhalt structout ] = inputgui( geometry, uilist, 'pophelp(''pop_simplechangechannellabel'');', 'Change Channel Label -- pop_simplechangechannellabel');
               end
               if ~isempty(structout)
                   if (~strcmpi(structout.Channel, "")) & (~strcmpi(structout.Newname, ""))
                       CurrentChannel = structout.Channel;
                       NewChannel = structout.Newname;
                   end
               end
               
               if (~isempty(CurrentChannel)) & (~isempty(NewChannel))
                   tmpchanlocs = EEG(1).chanlocs;
                   if (find(strcmpi({tmpchanlocs.labels},CurrentChannel),1)) & (isempty(find(strcmpi({tmpchanlocs.labels},NewChannel),1))) % current exists new does not
                       
                       EEG.chanlocs(find(strcmpi({EEG.chanlocs.labels}, CurrentChannel),1)).('labels') = char(NewChannel);
                       com = sprintf('%s.chanlocs(find(strcmpi({%s.chanlocs.labels}, ''%s''),1)).(''labels'') = char(''%s'');', inputname(1), inputname(1), CurrentChannel, NewChannel);
                       EEG.history = sprintf('%s\n%s', EEG.history, com);
                       EEG = eeg_checkset(EEG);
                       
                       if strcmpi(Pop, 'True')
                           
                           com = sprintf('%s\n\t\t%s\n', com, 'Or');
                           com = sprintf('%s\t%s = pop_simplechangechannellabel(%s, ''CurrentChannel'', ''%s'', ''NewChannel'', ''%s'');\n', com, inputname(1),inputname(1),CurrentChannel, NewChannel);
                           com = sprintf('\npop_simplechangechannellabel() Equivalent Code:\n\t%s', com);
                           disp(com)
                       end
                       
                   else
                       disp(sprintf('Error in pop_simplechangechannellabel(): Either the selected channel (%s) does not exist or a channel already exists with the requested name (%s).', CurrentChannel, NewChannel))
                   end
                   
               end
            end
        end
    end
end