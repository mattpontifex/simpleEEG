function [EEG, com] = pop_simpleinterpolatedata(EEG, varargin)
% Function to interpolate any NaN datapoints.
%
% Example:
%   EEG = pop_simpleinterpolatedata(EEG, 'Channels', { 'PupilLeft', 'PupilRight', 'PupilAvg' });

    if ~isempty(varargin)
             r=struct(varargin{:});
    end
    try, r.Pop; catch, r(1).Pop = 'False'; end
    try, r(1).Channels = {r.Channels}; catch, r(1).Channels = ''; end

    if isobject(EEG) % eegobj
        disp('Error in pop_simpleinterpolatedata(): This function is not designed to work with the EEG object.')
        beep
    else
        if isempty(EEG)
            disp('Error in pop_simpleinterpolatedata(): This function cannot run on an empty dataset.')
            beep
        else
            if isempty(EEG.data)
                disp('Error in pop_simpleinterpolatedata(): This function cannot run on an empty dataset.')
                beep
            else
                com = '';
                if (strcmpi(r(1).Pop, 'True'))
                    cb_chansel1 = 'tmpchanlocs = EEG(1).chanlocs; [tmp tmpval] = pop_chansel({tmpchanlocs.labels}, ''withindex'', ''on''); set(findobj(gcbf, ''tag'', ''Skip''   ), ''string'',tmpval); clear tmpchanlocs tmp tmpval';

                    g1 = [0.5 0.5 ];
                    g2 = [0.5 0.5 0.2];
                    s1 = [1];
                    geometry = { g2 s1 };
                    uilist = { ...
                          { 'Style', 'text', 'string', 'Select channels to interpolate:'} ...
                          { 'Style', 'edit', 'string', '' 'tag' 'Skip' } ...
                          { 'Style' 'pushbutton' 'string' '...' 'callback' cb_chansel1 'tag' 'refbr' } ...
                          ...
                          { } ...
                          ...
                      };

                  [ tmp1 tmp2 strhalt structout ] = inputgui( geometry, uilist, 'pophelp(''pop_simpleinterpolatedata'');', 'Epoch -- pop_simpleinterpolatedata');
                  if ~isempty(structout)
                    if ~isempty(structout.Skip)
                        skipchanlist = textscan(structout.Skip,'%s','Delimiter',' ');
                        skipchanlist = skipchanlist{1}';
                        r(1).Channels = skipchanlist;
                    end
                  end
                end
                
                if ~(isempty(r(1).Channels))
                
                    searchans = r(1).Channels;
                    for cChan = 1:numel(searchans)
                        chanind = find(strcmpi({EEG.chanlocs.labels}, searchans{cChan}),1);
                        if ~isempty(chanind)
                            tempi = find(isnan(EEG.data(chanind,:))); % find discontinuities in the data
                            temps = gaussmooth(EEG.data(chanind,:), 'Window', 10, 'Sigma', 2); % Smooth data 
                            temps = inpaint_nans(temps,4); % Interpolate Missing Data
                            EEG.data(chanind,tempi) = temps(1,tempi); % Replace with Interpolated data points
                        end
                    end
                    
                    com = sprintf('EEG = pop_simpleinterpolatedata(EEG, ''Channels'', %s);', makecellarraystr(r(1).Channels));
                    EEG.history = sprintf('%s\n%s', EEG.history, com);
                      
                    if (strcmpi(r(1).Pop, 'True'))
                          com = sprintf('\npop_simpleinterpolatedata() Equivalent Code:\n\t%s', com);
                          disp(com)
                    end
                      
                end
                
            end
        end
    end
end