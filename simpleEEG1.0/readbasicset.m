function [EEG, command] = readbasicset(fullfilename, varargin)
    command = '';
    EEG = [];
    EEG = eeg_emptyset;
    [pathstr,name,ext] = fileparts(fullfilename);
    filename = [name,ext];
    filepath = [pathstr, filesep];
    file = [pathstr, filesep, name];
    EEG.filename = [name, ext];
    EEG.filepath = filepath;
    EEG.ref = 'Common';
    
    EEG.chaninfo.plotrad = [];
    EEG.chaninfo.shrink = [];
    EEG.chaninfo.nosedir = '+X';
    EEG.chaninfo.nodatchans = [];
    EEG.chaninfo.icachansind = [];

    fid=fopen(fullfilename);
    boolcont = true;
    % Check the file format
    line_ex = fgetl(fid);
    tempvect = split(line_ex,"=");
    if ~strcmpi(strtrim(tempvect{2}), 'eegpipe_1.0.0')
        boolcont = false;
    end
    cline = 2;
    while (boolcont == true)
       try
        line_ex = fgetl(fid);
       catch
        boolcont = false;
       end

       if (cline < 8)
           tempvect = split(line_ex,"=");
           if strcmpi(strtrim(tempvect{1}), 'srate')
                EEG.srate = str2double(strtrim(tempvect{2}));
           end
           if strcmpi(strtrim(tempvect{1}), 'nbchan')
                EEG.nbchan = str2double(strtrim(tempvect{2}));
           end
           if strcmpi(strtrim(tempvect{1}), 'channels')
               chanlist = split(tempvect{2},',');
                 % Populate channel labels
                EEG.chanlocs = struct('labels', [], 'ref', [], 'theta', [], 'radius', [], 'X', [], 'Y', [], 'Z', [],'sph_theta', [], 'sph_phi', [], 'sph_radius', [], 'type', [], 'urchan', []);
                for cC = 1:EEG.nbchan
                    EEG.chanlocs(cC).labels = char(strtrim(chanlist{cC})); % store as character array string
                    EEG.chanlocs(cC).urchan = cC;
                end
                EEG.chanlocs(EEG.nbchan+1).labels = char('Markers'); % store as character array string
                EEG.chanlocs(EEG.nbchan+1).urchan = EEG.nbchan+1;
                EEG.nbchan = EEG.nbchan + 1;
           end
           if strcmpi(strtrim(tempvect{1}), 'points')
                EEG.pnts = str2double(strtrim(tempvect{2}));
           end
           if strcmpi(strtrim(tempvect{1}), 'times')
               timelist = split(tempvect{2},',');
               for cC = 1:EEG.pnts
                   EEG.times(end+1) = str2double(strtrim(timelist{cC}));
               end
           end
           if strcmpi(strtrim(tempvect{1}), 'trials')
                EEG.trials = str2double(strtrim(tempvect{2}));
                EEG.reject.rejmanual = zeros(1,EEG.trials);
           end
       elseif (cline > 9)
           if (line_ex == -1)
               boolcont = false;
           else
               tempvect = split(line_ex,",");
               if isnumeric(str2double(strtrim(tempvect{1})))
                    % dealing with data
                    %'Event, Time, Markers, Reject, Lpsize, Rpsize'
                   currenttrial = str2double(strtrim(tempvect{1}));
                   currenttime = str2double(strtrim(tempvect{2}));
                   currentmarker = str2double(strtrim(tempvect{3}));

                   % place event reject status
                   EEG.reject.rejmanual(currenttrial) = str2double(strtrim(tempvect{4}));
                   [val,ind] = min(abs(EEG.times-currenttime));

                   % cycle through channels
                   for cC = 5:length(tempvect)
                       EEG.data(cC-4, ind, currenttrial) = str2double(strtrim(tempvect{cC}));
                   end
                   EEG.data(EEG.nbchan, ind, currenttrial) = currentmarker;
               end
           end
       end

       cline = cline + 1;
    end
    EEG = eeg_checkset(EEG);

end

