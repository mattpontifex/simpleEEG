function [outstruct, com] = pop_simplecountavailabletrials(EEG, varargin)

    if ~isempty(varargin)
    	r=struct(varargin{:});
    end
    try, Pop = r(1).Pop; catch, Pop = 'False'; end
    
    if isobject(EEG) % eegobj
        disp('Error in pop_simplecountavailabletrials(): This function is not designed to work with the EEG object.')
        beep
    else
        if isempty(EEG)
            disp('Error in pop_simplecountavailabletrials(): This function cannot run on an empty dataset.')
            beep
        else
            if isempty(EEG.data)
                disp('Error in pop_simplecountavailabletrials(): This function cannot run on an empty dataset.')
                beep
            else

                % Identify eligible events - slow but reliable
                [epochevents, epocheventlist, epochmatrix] = simplecheckavailabletrials(EEG); 
                outstruct = struct('TrialType', [], 'Accepted',[], 'Rejected', []);
                                
                % obtain available epochs
                if (size(EEG.data,3) > 1)
                    INEEG2 = EEG;
                    [T, INEEG2] = evalc('pop_syncroartifacts(INEEG2, ''Direction'', ''bidirectional'');'); %synchronize artifact databases
                    if (isempty(INEEG2.reject.rejmanual))
                        EEG.reject.rejmanual = zeros(1,EEG.trials);
                    else
                        EEG.reject.rejmanual = INEEG2.reject.rejmanual;
                    end
                    acceptindex = find([EEG.reject.rejmanual] == 0); % find accepted trials
                else
                    acceptindex = 1:size(epochmatrix,1);
                end
                
                
                % go to work
                spaccheck = 7; % check spacing
                for cE = 1:numel(epochevents)
                    if ~isnan(epochevents(cE))
                        outstruct(cE).TrialType = epochevents(cE);
                        trialindices = find([epochmatrix(:,2)] == epochevents(cE));
                        outstruct(cE).Accepted = numel(intersect(acceptindex,trialindices));
                        outstruct(cE).Rejected = numel(trialindices) - outstruct(cE).Accepted;
                        spaccheck = max([spaccheck, strlength(num2str(outstruct(cE).TrialType)), strlength(num2str(outstruct(cE).Accepted)), strlength(num2str(outstruct(cE).Rejected))]);
                    end
                end
                
                
                spacertext = '';
                faketab = '   '; % 3 spaces is a tab
                spaccheck = spaccheck + 3;
                for cE = 1:spaccheck
                    spacertext = sprintf('%s-', spacertext);
                end
                
                % output
                com = sprintf('\npop_simplecountavailabletrials() -- Output:\n\n');
                com = sprintf('%s%s%s%s%s%s%s\n',com,faketab,spacertext,faketab,spacertext,faketab,spacertext);
                
                texttooutput = {'Trial Type', 'Accepted', 'Rejected'};
                com = sprintf('%s%s', com, faketab);
                for cE = 1:numel(texttooutput)
                    com = sprintf('%s%s', com, texttooutput{cE});
                    if (cE ~= numel(texttooutput))
                        com = sprintf('%s%s', com,faketab);
                        if (strlength(texttooutput{cE}) < spaccheck)
                            for cS = 1:(spaccheck - strlength(texttooutput{cE}))
                                com = sprintf('%s ', com);
                            end
                        end
                    end
                end
                com = sprintf('%s\n', com);
                com = sprintf('%s%s%s%s%s%s%s\n',com,faketab,spacertext,faketab,spacertext,faketab,spacertext);
                
                for cN = 1:numel(epochevents)
                    if ~isnan(epochevents(cN))
                        texttooutput = {num2str(outstruct(cN).TrialType), num2str(outstruct(cN).Accepted), num2str(outstruct(cN).Rejected)};
                        com = sprintf('%s%s', com, faketab);
                        for cE = 1:numel(texttooutput)
                            com = sprintf('%s%s', com, texttooutput{cE});
                            if (cE ~= numel(texttooutput))
                                com = sprintf('%s%s', com,faketab);
                                if (strlength(texttooutput{cE}) < spaccheck)
                                    for cS = 1:(spaccheck - strlength(texttooutput{cE}))
                                        com = sprintf('%s ', com);
                                    end
                                end
                            end
                        end
                        com = sprintf('%s\n', com);
                    end
                end
                com = sprintf('%s%s%s%s%s%s%s\n',com,faketab,spacertext,faketab,spacertext,faketab,spacertext);
                
                texttooutput = {'All Trials', num2str(sum([outstruct.Accepted])), num2str(sum([outstruct.Rejected]))};
                com = sprintf('%s%s', com, faketab);
                for cE = 1:numel(texttooutput)
                    com = sprintf('%s%s', com, texttooutput{cE});
                    if (cE ~= numel(texttooutput))
                        com = sprintf('%s%s', com,faketab);
                        if (strlength(texttooutput{cE}) < spaccheck)
                            for cS = 1:(spaccheck - strlength(texttooutput{cE}))
                                com = sprintf('%s ', com);
                            end
                        end
                    end
                end
                com = sprintf('%s\n', com);
                com = sprintf('%s%s%s%s%s%s%s\n',com,faketab,spacertext,faketab,spacertext,faketab,spacertext);
                disp(com)
                if (strcmpi(Pop, 'True'))
                    com = sprintf('\npop_simplecountavailabletrials() Equivalent Code:\n\ttrialcountinformation = pop_simplecountavailabletrials(EEG);');
                    disp(com)
                end
            end
        end
    end
end