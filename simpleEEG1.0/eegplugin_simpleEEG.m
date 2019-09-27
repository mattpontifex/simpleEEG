function eegplugin_simpleEEG(fig,try_strings,catch_strings)

%  def.path = mfilename('fullpath');
%  idcs = strfind(def.path,filesep); def.path = strcat(def.path(1:idcs(end)-1),filesep);
%  eval(sprintf('fileID = fopen(''%s'',''r'');', strcat(def.path, 'simpleEEG.appcache')))
%  dataArray = textscan(fileID, '%s%s%[^\n\r]', 'Delimiter', ' ', 'MultipleDelimsAsOne', true, 'TextType', 'string',  'ReturnOnError', false);
%  fclose(fileID);
%  tcheck = dataArray{1};
% 
% if (datetime(tcheck) >= datetime)

    W_MAIN = findobj(fig,'tag','EEGLAB');   % At EEGLAB Main Menu
    submenu = uimenu( W_MAIN,'Label','Simple EEG','separator','on','tag','SimpleEEG','userdata','startup:on;continuous:on;epoch:on;study:on;erpset:on');
    set(submenu,'position', 9);

    % peak detection 

    % create menu
    %toolsmenu1 = findobj(fig, 'tag', 'tools');
    %submenu = uimenu( toolsmenu1,'Label','Simple EEG Tools','separator','on','tag','simpleEEGtools','userdata','startup:on;continuous:on;epoch:on;study:on;erpset:on');

    mFIOTools = uimenu( submenu,'Label','File IO Tools','tag','FIOTools','separator','off','userdata','startup:on;continuous:on;epoch:on;study:on;erpset:on');
    %uimenu( submenu, 'label', '*** File IO Tools ***', 'separator','off','userdata','startup:off;continuous:off;epoch:off;study:off;erpset:off');
    uimenu( mFIOTools, 'label', 'Load .SET File', 'separator','off','callback', '[EEG LASTCOM]=pop_simpleloadset(EEG); [ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET); eeglab redraw;');
    uimenu( mFIOTools, 'label', 'Save .SET File', 'separator','off','callback', '[LASTCOM]=pop_simplesaveset(EEG);');
    uimenu( mFIOTools, 'label', 'Merge .SET Files', 'separator','off','callback', '[EEG, ALLEEG, LASTCOM]=pop_simplemerge(EEG, ALLEEG); [ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET); eeglab redraw;');
    uimenu( mFIOTools, 'label', 'Load .ERP File', 'separator','of','callback', '[ERP, ALLERP, LASTCOM] = pop_simpleloaderp(ERP, 1); eeglab redraw;');
    uimenu( mFIOTools, 'label', 'Load .ERP File into ALLERP', 'separator','of','callback', '[ERP, ALLERP, LASTCOM] = pop_simpleloaderp(ERP, ALLERP); eeglab redraw;');
    uimenu( mFIOTools, 'label', 'Save .ERP File', 'separator','of','callback', '[LASTCOM]=pop_simplesaveavg(ERP);');

    mWorkTools = uimenu( submenu,'Label','Workspace Tools','tag','WorkTools','separator','off','userdata','startup:on;continuous:on;epoch:on;study:on;erpset:on');
    %uimenu( submenu, 'label', '*** Workspace Tools ***', 'separator','on','userdata','startup:off;continuous:off;epoch:off;study:off;erpset:off');
    uimenu( mWorkTools, 'label', 'Clear EEG and ERP Variables', 'separator','of','callback', 'EEG = []; ALLEEG = []; ERP = []; ALLERP = []; CURRENTERP = 1; fprintf(''\nEquivalent Code:\n\tEEG = []; ALLEEG = []; ERP = []; ALLERP = []; CURRENTERP = 1;\n'')');
    uimenu( mWorkTools, 'label', 'Cleanup Command Window', 'separator','of','callback', 'clc; fprintf(''\nEquivalent Code:\n\tclc\n'')');
    uimenu( mWorkTools, 'label', 'Clear Workspace and Restart EEGLAB', 'separator','of','callback', 'clc; clear; eeglab; fprintf(''\nEquivalent Code:\n\tclc; clear; eeglab;\n'')');
    uimenu( mWorkTools, 'label', 'Refresh EEGLAB', 'separator','of','callback', 'eeglab redraw; fprintf(''\nEquivalent Code:\n\teeglab redraw\n'')');
    uimenu( mWorkTools, 'label', 'View EEG history', 'separator','of','callback', 'EEG.history');
    uimenu( mWorkTools, 'label', 'View ERP history', 'separator','of','callback', 'ERP.history');
    uimenu( mWorkTools, 'label', 'View Example EEG Workflow', 'separator','of','callback', 'clc; simpleshowworkflow;');

    uimenu( submenu, 'label', '*** Tools for General Use ***', 'separator','on','userdata','startup:off;continuous:off;epoch:off;study:off;erpset:off');
    uimenu( submenu, 'label', 'Change Channel Label', 'separator','off','callback', '[EEG LASTCOM]=pop_simplechangechannellabel(EEG, ''Pop'', ''True''); [ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);');
    uimenu( submenu, 'label', 'Compute EEG Spectral Power', 'separator','off','callback', '[EEG LASTCOM]=pop_simplespectral(EEG); [ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET); eeglab redraw;');
    uimenu( submenu, 'label', 'Compute ICA', 'separator','off','callback', '[EEG LASTCOM]=pop_simplerunica(EEG); [ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);');
    uimenu( submenu, 'label', 'Count Available Trials', 'separator','off','callback', 'trialcountinformation=pop_simplecountavailabletrials(EEG, ''Pop'', ''True'');');
    uimenu( submenu, 'label', 'Filter Data', 'separator','off','callback', '[EEG ALLEEG LASTCOM]=pop_simpleEEGfilter(EEG, ALLEEG); [ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);');
    uimenu( submenu, 'label', 'Interpolate Array', 'separator','off','callback', '[EEG LASTCOM]=interpolate1010electrodearray(EEG, ''Pop'', ''True''); [ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET); eeglab redraw;');
    uimenu( submenu, 'label', 'Interpolate Data', 'separator','off','callback', '[EEG LASTCOM]=pop_simpleinterpolatedata(EEG, ''Pop'', ''True''); [ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);');
    uimenu( submenu, 'label', 'Reference Data', 'separator','off','callback', '[EEG LASTCOM]=pop_simplerereference(EEG); [ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET); eeglab redraw;');
    uimenu( submenu, 'label', 'Remove Channel', 'separator','off','callback', '[EEG LASTCOM]=pop_simpleremovechannel(EEG, ''Pop'', ''True''); [ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET); eeglab redraw;');
    uimenu( submenu, 'label', 'Smooth EEG Data', 'separator','off','callback', '[EEG ALLEEG LASTCOM]=pop_simplesmooth(EEG, ALLEEG); [ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);');
    uimenu( submenu, 'label', 'Trim Data', 'separator','off','callback', '[EEG LASTCOM]=pop_simpletrim(EEG); [ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);');

    uimenu( submenu, 'label', '*** Tools for Continuous Data ***', 'separator','on','userdata','startup:off;continuous:off;epoch:off;study:off;erpset:off');
    uimenu( submenu, 'label', 'Detect Bad Channels', 'separator','off','callback', '[EEG LASTCOM]=pop_catchbadchannels(EEG); [ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET); eeglab redraw;');
    uimenu( submenu, 'label', 'Place Events in Channel', 'separator','off','callback', '[EEG LASTCOM]=simpleevent2channel(EEG); [ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET); eeglab redraw;');
    uimenu( submenu, 'label', 'Recode Events', 'separator','off','callback', '[EEG LASTCOM]=pop_simplerecodetrialtype(EEG); [ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);');
    uimenu( submenu, 'label', 'Relocate Referential/Bipolar Channels', 'separator','off','callback', '[EEG LASTCOM]=pop_movechannels(EEG);  [ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);'); % requires icablinkmetrics
    uimenu( submenu, 'label', 'Compute icablinkmetrics', 'separator','off','callback', '[EEG LASTCOM]=pop_icablinkmetrics(EEG); [ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);'); % requires icablinkmetrics
    
    uimenu( submenu, 'label', '*** Tools for Epoched Data ***', 'separator','on','userdata','startup:off;continuous:off;epoch:off;study:off;erpset:off');
    uimenu( submenu, 'label', 'Epoch Continuous EEG', 'separator','off','callback', '[EEG LASTCOM]=pop_simpleepoch(EEG); [ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET); eeglab redraw;');
    uimenu( submenu, 'label', 'Baseline Correct EEG', 'separator','off','callback', '[EEG ALLEEG LASTCOM]=pop_simplebaselinecorrect(EEG, ALLEEG); [ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);');
    uimenu( submenu, 'label', 'Artifact Reject', 'separator','off','callback', '[EEG LASTCOM]=pop_simpleartifactrejection(EEG); [ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);');
    uimenu( submenu, 'label', 'Reject by Trial Type', 'separator','off','callback', '[EEG LASTCOM]=pop_simplerejectbasedontrialtype(EEG); [ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);');
    uimenu( submenu, 'label', 'Visual Inspect Array', 'separator','off','callback', '[EEG LASTCOM]=pop_visualinspectarray(EEG); [ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);');
    uimenu( submenu, 'label', 'Visual Inspect Trials', 'separator','off','callback', '[EEG LASTCOM]=pop_visualinspecttrials(EEG); [ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);');

    uimenu( submenu, 'label', '*** Tools for Average Data ***', 'separator','on','userdata','startup:off;continuous:off;epoch:off;study:off;erpset:off');
    uimenu( submenu, 'label', 'Average Epoched EEG', 'separator','off','callback', '[ERP LASTCOM]=pop_simpleaverage(EEG);');
    uimenu( submenu, 'label', 'Baseline Correct ERP', 'separator','off','callback', '[ERP ALLERP LASTCOM]=pop_simplebaselinecorrect(ERP, ALLERP);');
    uimenu( submenu, 'label', 'Filter Data', 'separator','off','callback', '[ERP ALLERP LASTCOM]=pop_simpleEEGfilter(ERP, ALLERP);');
    uimenu( submenu, 'label', 'Smooth ERP', 'separator','off','callback', '[ERP ALLERP LASTCOM]=pop_simplesmooth(ERP, ALLERP);');
    uimenu( submenu, 'label', 'Subtract ERP', 'separator','off','callback', '[ERP LASTCOM]=pop_simplesubtractERP(ERP);');
    uimenu( submenu, 'label', 'Compute ERP Spectral Power', 'separator','off','callback', '[ERP LASTCOM]=pop_simplespectral(ERP);');
    
    uimenu( submenu, 'label', '*** Plotting Tools ***', 'separator','on','userdata','startup:off;continuous:off;epoch:off;study:off;erpset:off');
    uimenu( submenu, 'label', 'Plot ERP Array', 'separator','off','callback', 'pop_plotERParray(ERP);');
    uimenu( submenu, 'label', 'Egg Head Plot', 'separator','off', 'callback', 'pop_eggheadplot;');
    uimenu( submenu, 'label', 'Grand Average ALLERP', 'separator','off','callback', '[ERP LASTCOM]=pop_xgrandaverage(ALLERP);');
    uimenu( submenu, 'label', 'Plot ALLERP Array', 'separator','off', 'callback', '[LASTCOM]=pop_compareERParray(ALLERP);');
    uimenu( submenu, 'label', 'Plot ALLERP Side by Side', 'separator','off', 'callback', '[LASTCOM]=pop_plotparticipantsaschannels(ALLERP);');

% end

