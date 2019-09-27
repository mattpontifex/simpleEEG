function [EEG] = responselockedrecodebasedonbehavior(EEG, varargin)
%   Modifies trial type in EEG.event based on the correctness of behavioral
%   respones. There is no limit
%   on the number of digits that can be used in the event code.
%
%   1   Input EEG File From EEGLAB
%   2   The available parameters are as follows:
%       a    'Type' - Event code number(s)
%       b    'Correct' - New Event code number for correct trials
%       c    'MatchCorrect' - New Event code number for correct trials matched by latency to errors of commission
%       d    'CommissionError' - New Event code number for errors of commission
%
%   EEG = responselockedrecodebasedonbehavior( EEG, 'Type', [21, 22, 23, 24, 25, 26, 41, 42, 43, 44, 45, 46], 'Correct', 555, 'MatchCorrect', 556, 'CommissionError', 566 );
%
%   NOTE: You must first have merged the behavior
%
%   Author: Matthew B. Pontifex, Health Behaviors and Cognition Laboratory, Michigan State University, March 30, 2014

    if ~isempty(varargin)
             r=struct(varargin{:});
    end
    try, r.Type;   catch, r.Type=0;  error('Error at responselockedrecodebasedonbehavior(). Missing trial information.');   end
    try, r.Correct;       catch, r.Correct=0; end
    try, r.MatchCorrect;       catch, r.MatchCorrect=0; end
    try, r.CommissionError;       catch, r.CommissionError=0; end
    try, r.Threshold;   hitthres= r.Threshold; catch, hitthres=33; end % 2 frames (16.7) difference between response and response trigger 
   

    Type =  [r.Type];
    Correct =  r.Correct;
    MatchCorrect =  r.MatchCorrect;
    CommissionError =  r.CommissionError;
    
    
    if (isfield(EEG.event, 'respcode') ~= 1)
        error('responselockedrecodebasedonbehavior(): Warning - You must first merge the behavioral data.')
    end

    samprate = (1/EEG.srate)*1000;
        
    r = size(EEG.event,2);
    for index1 = 1:r
        if (strcmp(EEG.event(index1).type,'boundary') == 1)
            EEG.event(index1).urevent = index1;
            EEG.event(index1).respcode = 0;
            EEG.event(index1).respcorr = 0;
            EEG.event(index1).resplatency = 0;
            EEG.event(index1).stimresp = EEG.event(index1).type;
        end
    end
    
    % loads each stimulus event into a matrix if it matches the requested
    % trial types and has an associated response event
    c = 8;
    tempdattable = [];
    for rC = 1:size(EEG.event,2)
        tindex = 1;
        if (strcmpi(EEG.event(rC).stimresp, 'stim') == 1) || (strcmpi(EEG.event(rC).stimresp, 'Stimulus') == 1)% is the event a stimulus
            boltype = 0;
            for tempindex = Type % For each of the specified trial types
                if (tempindex == EEG.event(rC).type) % if the current stimulus type matches the specified trial type
                    boltype = 1;
                    break
                end
            end
            if (boltype == 1) % If stimulus event matches the requested type
                if (EEG.event(rC).respcode > 0) % Was a response made
                    if (EEG.event(rC).respcorr ~= -1) % If response was not impulsive
                        if ((rC+1) <= size(EEG.event,2))
                            if (strcmpi(EEG.event(rC+1).stimresp, 'resp') == 1) || (strcmpi(EEG.event(rC+1).stimresp, 'Response') == 1)% If next event is a response
                                bol = 0; bolhit = 0;
                                while (strcmpi(EEG.event(rC+tindex).stimresp, 'resp') == 1) || (strcmpi(EEG.event(rC+tindex).stimresp, 'Response') == 1)% While the events are responses
                                    if (EEG.event(rC+tindex).type == EEG.event(rC).respcode) % If the stimulus response matches the next event code
                                        bol = 1;
                                        bolhit = rC+tindex;
                                        break
                                    end
                                    tindex = tindex + 1;
                                    if ((rC + tindex)>size(EEG.event,2))
                                        break
                                    end
                                end
                                if (bol == 1) % If a matching response event was found
                                    tempa = (EEG.event(bolhit).latency - EEG.event(rC).latency)*samprate;
                                    tempdif = abs(tempa-EEG.event(rC).resplatency);
                                    if (tempdif <  hitthres) % Is the difference between the stimulus recorded response latency and the response event latency less than threshold
                                        temparray = zeros(1,8);
                                        temparray(1) = EEG.event(rC).type;
                                        temparray(2) = EEG.event(rC).latency;
                                        temparray(3) = EEG.event(rC).respcode;
                                        temparray(4) = EEG.event(rC).respcorr;
                                        temparray(5) = EEG.event(rC).resplatency;
                                        temparray(6) = rC;
                                        temparray(7) = uint64((EEG.event(rC).resplatency/samprate) + EEG.event(rC).latency);
                                        temparray(8) = bolhit;
                                        tempdattable(end+1,:) = temparray;
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    
    %CodeCorrect Responses
    if (Correct ~= 0)
        for index2 = 1:size(tempdattable,1)
            if (tempdattable(index2, 4) == 1)
                if (tempdattable(index2, 3) > 0)
                    tempindex = tempdattable(index2, 8);
                    EEG.event(tempindex).type = Correct;
                    EEG.event(tempindex).respcode = tempdattable(index2, 3);
                    EEG.event(tempindex).respcorr = tempdattable(index2, 4);
                end
            end
        end
    end
    
    %CodeError Responses
    if (CommissionError ~= 0)
        for index2 = 1:size(tempdattable,1)
            if (tempdattable(index2, 4) == 0)
                if (tempdattable(index2, 3) > 0)
                    tempindex = tempdattable(index2, 8);
                    EEG.event(tempindex).type = CommissionError;
                    EEG.event(tempindex).respcode = tempdattable(index2, 3);
                    EEG.event(tempindex).respcorr = tempdattable(index2, 4);
                end
            end
        end
    end
    
    
    %CodeMatchCorrect Responses
    if (MatchCorrect ~= 0)
        
        %Populate Error table
        temperrortable = [];
        for index2 = 1:size(tempdattable,1)
            if (tempdattable(index2, 4) == 0)
                if (tempdattable(index2, 3) > 0)
                    temparray = zeros(1,2);
                    temparray(1) = uint64(tempdattable(index2, 5));
                    temparray(2) = tempdattable(index2, 8);
                    temperrortable(end+1,:) = temparray;
                end
            end
        end
        temperrortable = sortrows(temperrortable);
        if (size(temperrortable,1) ~= 0)
            %Populate Correct table
            tempcorrecttable = [];
            for index2 = 1:size(tempdattable,1)
                if (tempdattable(index2, 4) == 1)
                    if (tempdattable(index2, 3) > 0)
                        temparray = zeros(1,2);
                        temparray(1) = uint64(tempdattable(index2, 5));
                        temparray(2) = tempdattable(index2, 8);
                        tempcorrecttable(end+1,:) = temparray;
                    end
                end
            end
            tempcorrecttable = sortrows(tempcorrecttable);

            %Find perfect RT match latency for error trials among the correct trials without replacement
            tempmatchtable = [];
            for index1 = 1:size(temperrortable,1)
                templatency1 = temperrortable(index1, 1);
                for index2 = 1:size(tempcorrecttable,1)
                    templatency2 = tempcorrecttable(index2, 1);
                    if (templatency1 == templatency2)
                        temparray = zeros(1,2);
                        temparray(1) = tempcorrecttable(index2, 1);
                        temparray(2) = tempcorrecttable(index2, 2);
                        tempmatchtable(end+1,:) = temparray;
                        temperrortable(index1,:) = 0;
                        tempcorrecttable(index2,:) = 0;
                        break
                    end
                end
            end

            %Find the closest possible RT match latency for the remaining error trials among the correct
            %trials without replacement with a preference for faster trials
            for shift = 1:500
                if (size(temperrortable,1) > 0)
                    if (size(tempcorrecttable,1) > 0)
                        for index1 = 1:size(temperrortable,1)
                            templatency1 = temperrortable(index1, 1);
                            if (templatency1 > 0)
                                for index2 = 1:size(tempcorrecttable,1)
                                    if (tempcorrecttable(index2, 1) > 0)
                                        templatency2 = tempcorrecttable(index2, 1)-shift;
                                        if (templatency1 == templatency2)
                                            temparray = zeros(1,2);
                                            temparray(1) = tempcorrecttable(index2, 1);
                                            temparray(2) = tempcorrecttable(index2, 2);
                                            tempmatchtable(end+1,:) = temparray;
                                            temperrortable(index1,:) = 0;
                                            tempcorrecttable(index2,:) = 0;
                                            break
                                        end
                                        templatency2 = tempcorrecttable(index2, 1)+shift;
                                        if (templatency1 == templatency2)
                                            temparray = zeros(1,2);
                                            temparray(1) = tempcorrecttable(index2, 1);
                                            temparray(2) = tempcorrecttable(index2, 2);
                                            tempmatchtable(end+1,:) = temparray;
                                            temperrortable(index1,:) = 0;
                                            tempcorrecttable(index2,:) = 0;
                                            break
                                        end
                                    end
                                end
                            end
                        end
                    else
                        break
                    end
                else
                    break
                end
            end

            for index1 = 1:size(tempmatchtable,1)
                tempindex = tempmatchtable(index1, 2);
                for index2 = 1:size(tempdattable,1)
                    if (tempdattable(index2,8) == tempindex)
                        EEG.event(tempindex).type = MatchCorrect;
                        EEG.event(tempindex).respcode = tempdattable(index2, 3);
                        EEG.event(tempindex).respcorr = tempdattable(index2, 4);
                        break
                    end
                end
            end
        end
    end
        
    com = sprintf('%s = responselockedrecodebasedonbehavior(%s, ''Type'', %s', inputname(1), inputname(1), simplecollapsesequentialnumbers(Type));
    if (Correct > 0)
       com = sprintf('%s, ''Correct'', %s', com, num2str(Correct));
    end
    if (MatchCorrect > 0)
       com = sprintf('%s, ''MatchCorrect'', %s', com, num2str(MatchCorrect));
    end
    if (CommissionError > 0)
       com = sprintf('%s, ''CommissionError'', %s', com, num2str(CommissionError));
    end
    com = sprintf('%s);', com);
    EEG.history = sprintf('%s\n%s', EEG.history, com);
    
end

