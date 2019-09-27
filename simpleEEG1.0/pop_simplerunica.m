function [EEG, com] = pop_simplerunica(EEG, varargin)
%   simple runica call for ICA with extended infomax, using the
%   block size heuristic from MNE python, and the randomseed disabled.

    if ~isempty(varargin)
             r=struct(varargin{:});
    end
    try, r.Pop; catch, r(1).Pop = 'False'; end

    if isobject(EEG) % eegobj
        disp('Error in pop_simplerunica(): This function is not designed to work with the EEG object.')
        beep
    else
        if isempty(EEG)
            disp('Error in pop_simplerunica(): This function cannot run on an empty dataset.')
            beep
        else
            if isempty(EEG.data)
                disp('Error in pop_simplerunica(): This function cannot run on an empty dataset.')
                beep
            else
                
                cb_chansel1 = '[filename, filepath] = uigetfile({''*.mat'' ''Matlab .mat File''}, ''Select a study-wise random seed -- pop_simplerunica()''); if (isequal(filename,0) || isequal(filepath,0)); filepath = ''; filename = ''; end; set(findobj(gcbf, ''tag'', ''swrs''   ), ''string'',strcat(filepath, filename));';
                
                g1 = [0.5 0.5 ];
                g2 = [0.5 0.5 0.2];
                s1 = [1];
                geometry = { g2 s1 s1};
                uilist = { ...
                      { 'Style', 'text', 'string', 'Select file for study-wise random state:'} ...
                      { 'Style', 'edit', 'string', '', 'tag' 'swrs'} ...   
                      { 'Style' 'pushbutton' 'string' '...' 'callback' cb_chansel1 'tag' 'refbr' } ...
                      ...
                      { 'Style', 'text', 'string', '(''on'' will enable a random seed)'} ...
                      ...
                      { } ...
                      ...
                };

                [ tmp1 tmp2 strhalt structout ] = inputgui( geometry, uilist, 'pophelp(''runica'');', 'ICA Decomposition -- pop_simplerunica');
                if ~isempty(structout)
                    com = sprintf('\npop_simplerunica() Equivalent Code:\n');
                    tcom = '';
                    % determine if the random seed should be reset
                    rsrandom = 'no';
                    if (~isempty(structout.swrs)) 
                        if (strcmpi(structout.swrs, 'on')) 
                            % user has asked that a random state be used
                            rsrandom = 'yes';
                        end
                    end
                    if strcmpi(rsrandom, 'off') % if the random seed should not be reset
                        boolload = 0;
                        if (~isempty(structout.swrs)) % was a file path specified for the random seed
                            if ~(exist(sprintf('%s',structout.swrs), 'file') > 0) % if the file exists
                                try
                                    temp = load(structout.swrs); 
                                    studywiserandomstate = temp.studywiserandomstate;
                                    rng(studywiserandomstate);
                                    tcom = sprintf('%stemp = load(''%s''); studywiserandomstate = temp.studywiserandomstate; rng(studywiserandomstate);', com, structout.swrs);
                                    eval(tcom);
                                    com = sprintf('%s\t%s\n', com, tcom);
                                    boolload = 1;
                                catch
                                    boolload = 0;
                                end
                            end
                        end
                        if (boolload == 0) % either no file was specified or it could not be run
                            tcom = sprintf('\tif ~(exist(''studywiserandomstate.mat'', ''file'') > 0)\n\t\tstudywiserandomstate = rng;  save(''studywiserandomstate.mat'',''studywiserandomstate'');\n\tend\n');
                            tcom = sprintf('%s\ttemp = load(''studywiserandomstate.mat''); studywiserandomstate = temp.studywiserandomstate; rng(studywiserandomstate);\n', tcom);
                            eval(tcom);
                            com = sprintf('%s%s', com, tcom);
                        end
                    end
                                        
                    % check EEGLAB version
                    [vers vnum] = eeg_getversion;
                    rancal = 'rndreset';
                    if (vnum < 2019)
                        rancal = 'reset_randomseed';
                        if (strcmpi(rsrandom, 'no'))
                            rsrandom = 'off';
                        else
                            rsrandom = 'on';
                        end
                    end
                    
                    tcom = sprintf('%s = pop_runica(%s,''icatype'',''runica'',''options'',{''extended'',1,''block'',floor(sqrt(%s.pnts/3)),''anneal'',0.98,''%s'',''%s''});', inputname(1), inputname(1), inputname(1), rancal, rsrandom);
                    eval(tcom)
                    
                    com = sprintf('%s%s\n', com, tcom);
                    EEG.history = sprintf('%s\n%s', EEG.history, tcom);
                    disp(com)
                    EEG = eeg_checkset(EEG);
                else
                      com = '';
                end                
            end
        end
    end
        
end

