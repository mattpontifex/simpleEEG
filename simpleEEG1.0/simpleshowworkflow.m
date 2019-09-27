function simpleshowworkflow(varargin)
% Shows the standard workflow steps for EEG data processing

    if ~isempty(varargin)
    	r=struct(varargin{:});
    end
    try, r(1).Full = r(1).Full; catch, r(1).Full = 'False'; end

    % Standard Header present in all files
    com = sprintf('simpleshowworkflow():\n\nclear; clc; %%Clear memory and the command window');
    com = sprintf('%s\n\n%% Establish some default variables for file types and file operations', com);
    com = sprintf('%s\n%% ------------------------ DO NOT EDIT ------------------------------', com);
    com = sprintf('%s\ndef.CNT = ''.cnt''; def.PSYDAT = ''.psydat''; def.DAT = ''.dat''; def.TXT = ''.txt''; def.SET = ''.set''; def.PNG = ''.png''; def.ERP = ''.erp''; def.TSV = ''.tsv'';', com);
    com = sprintf('%s\ndef.unde = ''_''; def.dash = ''-''; def.path = cd; idcs = strfind(def.path,filesep); def.path = strcat(def.path(1:idcs(end)-1),filesep);', com);
    com = sprintf('%s\ndef.folder1 = strcat(''Raw'',filesep); def.folder2 = strcat(''Reduction'',filesep); def.folder2b = strcat(''Errors'',filesep); def.folder3 = strcat(''ICA'',filesep); def.folder4 = strcat(''Preaverages'',filesep); def.folder5 = strcat(''Averages'',filesep); def.folder6 = strcat(''GrandAverages'',filesep); def.folder7 = strcat(''Batch'',filesep);', com);
    com = sprintf('%s\n%% ------------------------ DO NOT EDIT ------------------------------', com);
    com = sprintf('%s\n\n%% Start eeglab', com);
    com = sprintf('%s\neeglab;  %% Requires Matlab Signal Processing Toolbox & Statistics Toolbox', com);
    com = sprintf('%s\n\n%% Save study wise random state prior to beginning any data processing', com);
    com = sprintf('%s\nif ~(exist(''studywiserandomstate.mat'', ''file'') > 0)\n\tstudywiserandomstate = rng; save(''studywiserandomstate.mat'',''studywiserandomstate'')\nend', com);
    
    % Standard Steps for data prep
    com = sprintf('%s\n\n\n%%%% Standard Steps for Preparing Data', com);
    com = sprintf('%s\n%% Load Data', com);
    if (strcmpi(r(1).Full, 'True'))
        com = sprintf('%s\nEEG = loadcurry(filein);', com);
    end
    com = sprintf('%s\n\n%% Recode Events', com);
    if (strcmpi(r(1).Full, 'True'))
        com = sprintf('%s\nEEG = responselockedrecodebasedonbehavior( EEG, ''Type'', [10110, 10210], ''Correct'', 195, ''MatchCorrect'', 196, ''CommissionError'', 197);', com);
        com = sprintf('%s\n[epochevents, epocheventlist, eventmatrix] = simplecheckavailabletrials(EEG);', com);
        com = sprintf('%s\ntempelements = eventmatrix(ismember(eventmatrix(:,2), [ 20110 ]),1);', com);
        com = sprintf('%s\nfor iEvent = 1:numel(tempelements); EEG.event(tempelements(iEvent)).type = 4444; end; clear eventmatrix tempelements iEvent;', com);
    end
    com = sprintf('%s\n\n%% Change Channel Labels', com);
    if (strcmpi(r(1).Full, 'True'))
        com = sprintf('%s\nEEG = pop_simplechangechannellabel(EEG, ''CurrentChannel'', ''VEO'', ''NewChannel'', ''VEOG'');', com);
        com = sprintf('%s\nEEG = pop_simplechangechannellabel(EEG, ''CurrentChannel'', ''HEO'', ''NewChannel'', ''HEOG'');', com);
    end
    com = sprintf('%s\n\n%% Trim Pretask and Posttask EEG activity', com);
    if (strcmpi(r(1).Full, 'True'))
        com = sprintf('%s\nEEG = simpletrim(EEG, ''Pre'', 3, ''Post'', 10);', com);
    end
    com = sprintf('%s\n\n%% Remove Bad Electrodes', com);
    if (strcmpi(r(1).Full, 'True'))
        com = sprintf('%s\nEEG = pop_select(EEG, ''nochannel'', { ''CB1'', ''CB2'' }); EEG = letterkilla(EEG);', com);
    end
    com = sprintf('%s\n\n%% Rereference to Average Mastoids', com);
    if (strcmpi(r(1).Full, 'True'))
        com = sprintf('%s\nEEG = pop_reref(EEG, { ''M1'', ''M2'' }, ''exclude'', eegchannelarrayindex( EEG, { ''HEOG'', ''VEOG'' }), ''keepref'', ''on'');', com);
    end
    com = sprintf('%s\n\n%% Filter Data (0.5 Hz Highpass)', com);
    if (strcmpi(r(1).Full, 'True'))
        %[EEG, com, b] = pop_firws(EEG, 'ftype', 'lowpass', 'fcutoff', [30], 'wtype', 'hamming', 'forder', 3*fix(EEG.srate/0.5));
        com = sprintf('%s\nEEG = simpleEEGfilter(EEG,''Filter'',''Highpass'',''Design'',''Windowed Symmetric FIR'',''Cutoff'',[ 0.5 ],''Order'',3*fix(EEG.srate/0.5));', com);
    end
    com = sprintf('%s\n\n%% Catch Remaining Bad Electrodes', com);
    if (strcmpi(r(1).Full, 'True'))
        com = sprintf('%s\nbadchannels = catchbadchannels(EEG, ''LineNoise'', 20, ''Smoothed'', 20, ''PointByPoint'', 20, ''Trim'', 2, ''Skip'', { ''HEOG'', ''VEOG'' });', com);
        com = sprintf('%s\nif ~isempty(badchannels); EEG = pop_select( EEG, ''nochannel'', badchannels); EEG = letterkilla(EEG); end', com);
    end
    com = sprintf('%s\n\n%% Relocate Referential/Bipolar Channels', com);
    if (strcmpi(r(1).Full, 'True'))
        com = sprintf('%s\nEEG = movechannels(EEG, ''Direction'', ''Remove'', ''Channels'', { ''HEOG'', ''M1'', ''M2'' });', com);
    end
    com = sprintf('%s\n\n%% Save to Reduction Folder', com);
    if (strcmpi(r(1).Full, 'True'))
        com = sprintf('%s\nsimplesaveset(EEG, strcat(def.path, def.folder2, ''PreICAFile.set''));', com);
    end
    
    
    % Standard Steps for ICA
    com = sprintf('%s\n\n\n%%%% Standard Steps for Eyeblink Artifact Reduction - Can be run using parallel processing with parfor loop', com);
    com = sprintf('%s\n%% Load Data from Reduction Folder', com);
    if (strcmpi(r(1).Full, 'True'))
        com = sprintf('%s\nEEG = pop_loadset(strcat(def.path, def.folder2, ''PreICAFile.set''));', com);
    end
    com = sprintf('%s\n\n%% Compute ICA Weights', com);
    if (strcmpi(r(1).Full, 'True'))
        com = sprintf('%s\ntemp = load(''studywiserandomstate.mat''); studywiserandomstate = temp.studywiserandomstate; rng(studywiserandomstate);', com);
        com = sprintf('%s\nEEG = pop_runica(EEG,''icatype'',''runica'',''options'',{''extended'',1,''block'',floor(sqrt(EEG.pnts/3)),''anneal'',0.98,''rndreset'',''no''});', com);
    end
    com = sprintf('%s\n\n%% Save to Reduction Folder', com);
    if (strcmpi(r(1).Full, 'True'))
        com = sprintf('%s\nsimplesaveset(EEG, strcat(def.path, def.folder2, ''PostICAFile.set''));', com);
    end
    
    
    % Standard Steps for preprocessing
    com = sprintf('%s\n\n\n%%%% Standard Steps for Preprocessing', com);
    com = sprintf('%s\n%% Load Data from Reduction Folder', com);
    if (strcmpi(r(1).Full, 'True'))
        com = sprintf('%s\nEEG = pop_loadset(strcat(def.path, def.folder2, ''PostICAFile.set''));', com);
    end
    com = sprintf('%s\n\n%% Identify Eyeblink-related ICA Component', com);
    if (strcmpi(r(1).Full, 'True'))        
        com = sprintf('%s\ncontaminated_channel = []; for iChannel = {''VEOG'', ''FPZ'', ''FP1'', ''AF3'', ''F3'', ''F4'', ''FC3'', ''FC4'', ''C3'', ''C4'' }; contaminated_channel = find(strcmp({EEG.chanlocs.labels},iChannel)); if ~isempty(contaminated_channel); break; end; end', com);
        com = sprintf('%s\ntry; EEG.icaquant = icablinkmetrics(EEG,''ArtifactChannel'',EEG.data(contaminated_channel,:),''VisualizeData'',''False''); catch; EEG.icaquant.identifiedcomponents = []; end', com);
    end
    com = sprintf('%s\n\n%% Remove Eyeblink-related ICA Component', com);
    if (strcmpi(r(1).Full, 'True'))
        com = sprintf('%s\nEEG = pop_subcomp(EEG,EEG.icaquant.identifiedcomponents,0);', com);
    end
    com = sprintf('%s\n\n%% Relocate Referential/Bipolar Channels', com);
    if (strcmpi(r(1).Full, 'True'))
        com = sprintf('%s\nEEG = movechannels(EEG, ''Direction'', ''Restore'', ''Channels'', { ''HEOG'', ''M1'', ''M2'' });', com);
    end
    com = sprintf('%s\n\n%% Interpolate Bad or Missing Electrodes', com);
    if (strcmpi(r(1).Full, 'True'))
        com = sprintf('%s\nEEG = interpolate1010electrodearray(EEG);', com);
    end
    com = sprintf('%s\n\n%% Save to Reduction Folder', com);
    if (strcmpi(r(1).Full, 'True'))
        com = sprintf('%s\nsimplesaveset(EEG, strcat(def.path, def.folder2, ''FileWithoutEyeblinks.set''));', com);
    end
    
    
    % Merge Fileblocks if necessary
    com = sprintf('%s\n\n\n%%%% Collapse data into a single file', com);
    com = sprintf('%s\n%% Load Data from Reduction Folder', com);
    if (strcmpi(r(1).Full, 'True'))
        com = sprintf('%s\nEEG = pop_loadset(strcat(def.path, def.folder2, ''FileWithoutEyeblinks.set''));', com);
    end
    com = sprintf('%s\n\n%% Merge EEG Blocks', com);
    if (strcmpi(r(1).Full, 'True'))
         com = sprintf('%s\nALLEEG = []; EEG.data = double(EEG.data); EEG.times = double(EEG.times);', com);
         com = sprintf('%s\nALLEEG = eeg_store(ALLEEG, EEG); EEG = [];', com);
         com = sprintf('%s\nEEG = pop_loadset(''filename'', ''File2.set'', ''filepath'', strcat(def.path, def.folder2));', com);
         com = sprintf('%s\nEEG.data = double(EEG.data); EEG.times = double(EEG.times);', com);
         com = sprintf('%s\nALLEEG = eeg_store(ALLEEG, EEG); EEG = [];', com);
         com = sprintf('%s\nEEG = xmerge(ALLEEG); EEG = eeg_checkset(EEG); EEG = pullchannellocations(EEG);', com);
    end
    com = sprintf('%s\n\n%% Save to ICA folder', com);
    if (strcmpi(r(1).Full, 'True'))
        com = sprintf('%s\nsimplesaveset(EEG, strcat(def.path, def.folder3, ''MergedFile.set''));', com);
    end
    com = sprintf('%s\n\n%% Remove Reduction Files', com);
    if (strcmpi(r(1).Full, 'True'))
        com = sprintf('%s\ndelete(strcat(def.path, def.folder2, ''PreICAFile.set''));', com);
        com = sprintf('%s\ndelete(strcat(def.path, def.folder2, ''PostICAFile.set''));', com);
        com = sprintf('%s\ndelete(strcat(def.path, def.folder2, ''FileWithoutEyeblinks.set''));', com);
    end
    
    % Standard Steps for Epoching
    com = sprintf('%s\n\n\n%%%% Standard Steps for Epoching', com);
    com = sprintf('%s\n%% Load Data from ICA Folder', com);
    if (strcmpi(r(1).Full, 'True'))
        com = sprintf('%s\nEEG = pop_loadset(strcat(def.path, def.folder3, ''MergedFile.set''));', com);
    end
    com = sprintf('%s\n\n%% Filter (30 Hz Lowpass for Stimulus Locked; 1 to 12 Hz Bandpass for Response Locked)', com);
    if (strcmpi(r(1).Full, 'True'))
        com = sprintf('%s\nEEG = simpleEEGfilter(EEG,''Filter'',''Lowpass'',''Design'',''Windowed Symmetric FIR'',''Cutoff'',[ 30 ],''Order'',3*fix(EEG.srate/0.5));', com);
    end
    com = sprintf('%s\n\n%% Epoch', com);
    if (strcmpi(r(1).Full, 'True'))
        com = sprintf('%s\nEEG = simpleepoch(EEG, ''Window'', [-100 1000], ''Types'', [ 10000:11000 ]);', com);
        com = sprintf('%s\nEEG = simplesyncartifacts(EEG, ''Direction'', ''bidirectional'');', com);
    end
    com = sprintf('%s\n\n%% Baseline Correct', com);
    if (strcmpi(r(1).Full, 'True'))
        com = sprintf('%s\nEEG = simplebaselinecorrect(EEG, ''Approach'', ''Mean'', ''Window'', [-100 0]);', com);
    end
    com = sprintf('%s\n\n%% Artifact Reject', com);
    if (strcmpi(r(1).Full, 'True'))
        com = sprintf('%s\nEEG = simpleartifactrejection(EEG, ''VoltageThreshold'', [ -100, 100 ], ''PointThreshold'', 100, ''Window'', [ -100, 1000 ], ''Channels'', { ''FZ'', ''FCZ'', ''CZ'', ''CPZ'', ''PZ'', ''POZ'', ''OZ'' });', com);
        com = sprintf('%s\nEEG = simplesyncartifacts(EEG, ''Direction'', ''bidirectional'');', com);
    end
    com = sprintf('%s\n\n%% Visually Inspect', com);
    if (strcmpi(r(1).Full, 'True'))
        com = sprintf('%s\nEEG = visualinspecttrials(EEG, ''Channels'', {''CZ'', ''CPZ'', ''PZ''}, ''Rows'', 5, ''Columns'', 5, ''Average'', ''True'', ''Smooth'', ''True'', ''guiSize'', [200,200,1600,800], ''guiFontSize'', 8);', com);
    end
    com = sprintf('%s\n\n%% Save to Preaverage Folder', com);
    if (strcmpi(r(1).Full, 'True'))
        com = sprintf('%s\nsimplesaveset(EEG, strcat(def.path, def.folder4, ''PreaverageFile.set''));', com);
    end
    
    % Standard Steps for Averaging
    com = sprintf('%s\n\n\n%%%% Standard Steps for Averaging', com);
    com = sprintf('%s\n%% Load Data from Preaverage Folder', com);
    if (strcmpi(r(1).Full, 'True'))
        com = sprintf('%s\nEEG = pop_loadset(strcat(def.path, def.folder4, ''PreaverageFile.set''));', com);
    end
    com = sprintf('%s\n\n%% Reject Trials Not to Be Included', com);
    if (strcmpi(r(1).Full, 'True'))
        com = sprintf('%s\nEEG = simplerejectbasedontrialtype(EEG, ''Types'', [ 10008, 10009 ]);', com);
        com = sprintf('%s\nEEG = simplesyncartifacts(EEG, ''Direction'', ''bidirectional'');', com);
    end
    com = sprintf('%s\n\n%% Check Available Trials', com);
    if (strcmpi(r(1).Full, 'True'))
        com = sprintf('%s\ntrialcountinformation = pop_simplecountavailabletrials(EEG);', com);
    end
    com = sprintf('%s\n\n%% Average', com);
    if (strcmpi(r(1).Full, 'True'))
        com = sprintf('%s\nERP = simpleaverage(EEG);', com);
    end
    com = sprintf('%s\n\n%% Baseline Correct', com);
    if (strcmpi(r(1).Full, 'True'))
        com = sprintf('%s\nERP = simplebaselinecorrect(ERP, ''Approach'', ''Mean'', ''Window'', [-100, 0]);', com);
    end
    com = sprintf('%s\n\n%% Save to Average Folder', com);
    if (strcmpi(r(1).Full, 'True'))
        com = sprintf('%s\nsaveERP(ERP, strcat(def.path, def.folder5, ''Test.erp''));', com);
    end
    
    
    com = sprintf('%s\n\n', com);
    disp(com)

end

