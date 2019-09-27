function [EEG, com] = pop_simpleremovechannel(EEG, varargin)
% Function to remove a channel. 
%
% Example:
%   EEG = pop_simpleremovechannel(EEG, 'Channels', { 'CB1', 'CB2' });

    if ~isempty(varargin)
    	r=struct(varargin{:});
    end
    try, Pop = r(1).Pop; catch, Pop = 'False'; end
    try, r(1).Channels = {r.Channels}; catch, r(1).Channels = ''; end
    
    com = "";
    
    if isobject(EEG) % eegobj
        disp('Error in pop_simpleremovechannel(): This function is not designed to work with the EEG object.')
        beep
    else
        if isempty(EEG)
            disp('Error in pop_simpleremovechannel(): This function cannot run on an empty dataset.')
            beep
        else
                
           structout = [];
           if strcmpi(Pop, 'True') % only show if pop is true
               cb_chansel1 = 'tmpchanlocs = EEG(1).chanlocs; [tmp tmpval] = pop_chansel({tmpchanlocs.labels}, ''withindex'', ''on''); set(findobj(gcbf, ''tag'', ''Channel''   ), ''string'',tmpval); clear tmpchanlocs tmp tmpval';

                g1 = [0.3 0.3 ];
                g2 = [0.3 0.2 0.1];
                s1 = [1];
                geometry = { g2 s1 };
                uilist = { ...
                      { 'Style', 'text', 'string', 'Select channel(s) to remove:'} ...
                      { 'Style', 'edit', 'string', '' 'tag' 'Channel' } ...
                      { 'Style' 'pushbutton' 'string' '...' 'callback' cb_chansel1 'tag' 'refbr' } ...
                      ...
                      { } ...
                      ...
                  };

                  [ tmp1 tmp2 strhalt structout ] = inputgui( geometry, uilist, 'pophelp(''pop_simpleremovechannel'');', 'Remove Channels -- pop_simpleremovechannel');
           end
           if ~isempty(structout)
               if (~strcmpi(structout.Channel, ""))
                    skipchanlist = textscan(structout.Channel,'%s','Delimiter',' ');
                    skipchanlist = skipchanlist{1}';
                    r(1).Channels = skipchanlist;
               end
           end

           if ~(isempty(r(1).Channels))
               
               com = sprintf('%s = pop_select(%s, ''nochannel'', %s);', inputname(1), inputname(1), makecellarraystr(r(1).Channels));
               t = evalc(com);
               EEG.history = sprintf('%s\n%s', EEG.history, com);
               com = sprintf('%s EEG = letterkilla(EEG);', com);
               t = evalc('EEG = letterkilla(EEG);');
               EEG = eeg_checkset(EEG);
               
               if strcmpi(Pop, 'True')
                    com = sprintf('\npop_simpleremovechannel() Equivalent Code:\n\t%s', com);
                    disp(com)
               end
               
           end
        end
    end
end