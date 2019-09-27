function plotparticipantsaschannels(varargin)
%   Display participants data side by side for a given channel.
%
%   Arrow Up and Down scale the amplitude, holding shift while using the up and 
%   down arrow will linearly shift the axis up or down.
%
%    Input parameters are as follows:
%       1    'Averages' - ALLERP set or structure containing multiple ALLERP sets.
%       2    'Channels' - Channel(s) to evaluate the activity in. Cell array of channels will be averaged across each channel within each trial.
%       3    'Bin' - Bin to display. Default is 1.
%       4    'ParticipantIDSize' - Number of characters that makes up the Participant ID in ERP.fieldname
%       5    'ParticipantIDPrefixSize' - Number of characters in the Participant ID in ERP.fieldname to ignore as a prefix.
%       6    'ParticipantIDSuffixSize' - Number of characters in the Participant ID in ERP.fieldname to ignore as a suffix.
%       7    'Polarity' - ['Positive Up' | 'Positive Down' (default)]
%       8    'Smooth' - Smothing Enabled [ 'True' | 'False' (default)]
%       9    'guiSize' - Size of the GUI (i.e., [200,200,1600,800] - 200 pixels right on screen, 200 pixels up on screen, 1600 pixels wide, 800 pixels tall)
%       10    'guiFontSize' - GUI font size. Default is 8
%       11    'TrialWidth' - Line width of the individul trial waveforms
%       12    'guiBackgroundColor' - GUI background color. Default is [0.941,0.941,0.941]
%       13    'Columns' - Number of columns of trials to plot.
%       14    'XScale' - X axis limits (i.e., [-100 1000]).
%      
%   Example Code:
%
%       % Example of ALLERP set
%       [ERP ALLERP] = pop_loaderp( 'filename', 'File1.erp', 'filepath', '/Studies/');
%       [ERP ALLERP] = pop_loaderp( 'filename', 'File2.erp', 'filepath', '/Studies/');
%       [ERP ALLERP] = pop_loaderp( 'filename', 'File3.erp', 'filepath', '/Studies/');
%       [ERP ALLERP] = pop_loaderp( 'filename', 'File4.erp', 'filepath', '/Studies/');
%       plotparticipantsaschannels('Averages', ALLERP, 'Channels', {'CZ'}, 'Columns', 2)
%
%       or
%
%       % Example of multiple ALLERP sets in a a structure
%       disp('loading files... (this will take a while)'); ERP = []; ALLERP = []; groupings=struct;    %'Structure which stores all object handles
%       for condition = {'A','B'}
%            for participant = {'101','101','102'}
%                [ERP ALLERP] = pop_loaderp('filename',strcat(participant,cell2mat(condition),'.erp'),'filepath','/Studies/');
%            end
%            groupings.(sprintf('%s', cell2mat(condition))) = ALLERP; % the label in condition is carried foward as the legend label in the plot
%            ERP = []; ALLERP = [];
%        end
%       ALLERP = groupings;
%       disp('plotting files...')
%       plotparticipantsaschannels('Averages', ALLERP, 'Channels', {'CZ', 'CPZ', 'PZ'}, 'ParticipantIDSize', 3)
%
%    
%   Author: Matthew B. Pontifex, Health Behaviors and Cognition Laboratory, Michigan State University, May 4, 2015


    handles=struct;    %'Structure which stores all object handles
    if ~isempty(varargin)
          r=struct(varargin{:});
    end
    try, r.Averages; datain = r.Averages; catch, help plotparticipantsaschannels; error('Error at plotparticipantsaschannels(). Missing information! Please provide an ALLERP structure or structure containing multiple ALLERP sets.'); end
    try, r.Channels; temprefch = {r.Channels}; catch, help plotparticipantsaschannels; error('Error at plotparticipantsaschannels(). Missing information! Please input Channel Information.'); end
    try, r.Polarity; Polarity = r.Polarity; catch, Polarity = 'Positive Down';  end
    try, r.Smooth; bolSmooth = r.Smooth; catch, bolSmooth = 'False'; end
    try, r.Columns; cColumns = r.Columns; catch, cColumns = 5; end
    try, r.TrialWidth; TrialWidth = r.TrialWidth; catch, TrialWidth = 1.5; end
    try, r.guiSize; guiSize = r.guiSize; catch, guiSize = []; end
    try, r.guiBackgroundColor; guiBackgroundColor = r.guiBackgroundColor; catch, guiBackgroundColor = [0.941,0.941,0.941]; end
    try, r.guiFontSize; guiFontSize = r.guiFontSize; catch, guiFontSize = 8; end
    try, r.Bin; handles.bin = r(1).Bin; catch, handles.bin = 1; end
    try, r.ParticipantIDSize; handles.ParticipantIDSize = r(1).ParticipantIDSize; catch, handles.ParticipantIDSize = []; end
    try, r.ParticipantIDPrefixSize; handles.ParticipantIDPrefixSize = r(1).ParticipantIDPrefixSize; catch, handles.ParticipantIDPrefixSize = 0; end
    try, r.ParticipantIDSuffixSize; handles.ParticipantIDSuffixSize = r(1).ParticipantIDSuffixSize; catch, handles.ParticipantIDSuffixSize = 0; end
    try, r.XScale; XScale = r.XScale; catch, XScale = []; end
    
    if isempty(guiSize)
        try
            set(0,'units','pixels')
            guiSize = get(0,'screensize');
            origguiSize = guiSize;
            viewW = guiSize(3)*0.95;
            viewH = guiSize(4)*0.9;
            guiSize(1)=(origguiSize(3)-viewW)/2;
            guiSize(2)=((origguiSize(4)-viewH)/2)+((origguiSize(4)-viewH)/8);
            guiSize(3)=viewW;
            guiSize(4)=viewH;
        catch
            guiSize = [200,200,1000,800];
        end
    end
    
    if ismac
        guiFontSize = guiFontSize*1.5;
    end
    
    % Check to see what was inputted
    if isempty(find(strcmpi(fieldnames(datain),'filename'),1))
        handles.numberofcomparisons = size(fieldnames(datain),1);
        handles.listofcomparisons = fieldnames(datain);
    else
        handles.numberofcomparisons = 1;
        handles.listofcomparisons = [];
    end
    
    % Populate list of participants
    handles.listofparticipants = [];
    if isempty(handles.listofcomparisons)
        handles.listofparticipants = {datain.filename};
    else
        for cP = 1:numel(handles.listofcomparisons)
            handles.listofparticipants = horzcat(handles.listofparticipants,{datain.(sprintf('%s',cell2mat(handles.listofcomparisons(cP)))).filename});
        end
    end
   handles.listofparticipants = strtrim(handles.listofparticipants);
   if ~isempty(handles.ParticipantIDSize)
       tempvect = handles.listofparticipants;
       for cP = 1:numel(handles.listofparticipants)
           temp = char(handles.listofparticipants{cP});
           tempvect(cP) = {temp((1+handles.ParticipantIDPrefixSize):(handles.ParticipantIDSize-handles.ParticipantIDSuffixSize))};
       end
       handles.listofparticipants = unique(tempvect);
   end
    handles.listofparticipants = sort(handles.listofparticipants);
    
   % Determine comparison matrix
   handles.nparticipants = numel(handles.listofparticipants);
   if (cColumns > handles.nparticipants)
       cColumns = handles.nparticipants;
   end
   cRows = ceil(handles.nparticipants/cColumns); % determine number of Rows needed for display
   
   % Collapse into single ALLERP structure
   if isempty(handles.listofcomparisons)
       mastertemp = datain;
   else
       mastertemp = datain.(sprintf('%s',cell2mat(handles.listofcomparisons(1))));
       for cP = 2:numel(handles.listofcomparisons)
            mastertemp = [mastertemp, datain.(sprintf('%s',cell2mat(handles.listofcomparisons(cP))))];
       end
   end
   
   % Check Sample Rates
   if (size(unique([mastertemp.srate]),2) > 1) 
        error('Error at plotparticipantsaschannels(). Sample Rates do not match.')
   else
       handles.srate = unique([mastertemp.srate]);
   end
   timetemp = [mastertemp.times];
   handles.times = (min(timetemp)):(1000/handles.srate):(max(timetemp)); 
   handles.pnts = size(handles.times,2);
   
   handles.comparisonmatrix = NaN(handles.nparticipants,handles.numberofcomparisons);
   handles.comparisonstructure = struct('participant', []);
   handles.comparisonlabels = {};
        
    for cP = 1:handles.nparticipants
        handles.comparisonstructure(cP).participant = handles.listofparticipants{cP};
    end
    for cC = 1:handles.numberofcomparisons
        if isempty(handles.listofcomparisons)
            tempvect = strtrim({datain.filename});
            tempdatain = datain;
        else
            tempvect = strtrim({datain.(sprintf('%s',cell2mat(handles.listofcomparisons(cC)))).filename});
            tempdatain = datain.(sprintf('%s',cell2mat(handles.listofcomparisons(cC))));
            handles.comparisonlabels{end+1} = sprintf('%s',cell2mat(handles.listofcomparisons(cC)));
        end
        if ~isempty(handles.ParticipantIDSize)
            for cN = 1:numel(tempvect)
                temp = char(tempvect{cN});
                tempvect(cN) = {temp((1+handles.ParticipantIDPrefixSize):(handles.ParticipantIDSize-handles.ParticipantIDSuffixSize))};
            end
        end
        for cP = 1:handles.nparticipants
            inMat = NaN(numel(temprefch),handles.pnts); % channels x points
            % Determine location in structure
            tempsearch = find(strcmpi(tempvect,handles.listofparticipants(cP)));
            if ~isempty(tempsearch)
                handles.comparisonmatrix(cP,cC) = tempsearch(1);
                tempchan = {tempdatain(handles.comparisonmatrix(cP,cC)).chanlocs.labels};
                tempd = tempdatain(handles.comparisonmatrix(cP,cC)).bindata;
                tempt = tempdatain(handles.comparisonmatrix(cP,cC)).times;
                % Setup null matrix
                for cT = 1:numel(temprefch)
                    inMat(cT,find(handles.times == tempt(1)):find(handles.times == tempt(end))) = tempd(find(strcmpi(tempchan,temprefch(cT))),:,handles.bin);
                end
                if (numel(temprefch) > 1)
                    inMat = nanmean(inMat);
                end
                if (strcmpi(bolSmooth, 'True'))
                    inMat = fastsmooth(inMat,9,3,1);
                elseif (strcmpi(bolSmooth, 'Max'))
                    inMat = fastsmooth(inMat,25,3,1);
                end
            end
            handles.comparisonstructure(cP).(sprintf('comp%d', cC)) = inMat;
       end
    end
    
    handles.lin.width1 = TrialWidth;
    handles.pl.color = guiBackgroundColor;
    handles.pl.size = guiSize;
    handles.size.xpadding = 75;
    handles.size.xceilpadding = 5;
    handles.size.ypadding = 55;
    handles.size.yceilpadding = 5;
    handles.size.xshift = 50;
    handles.size.yshift = 45;
    handles.size.label = 'Position'; %'OuterPosition'
    handles.size.xchannel = 100;
    handles.size.ychannel = 15;
    handles.size.fSz = guiFontSize;
    
    % Create GUI window
    handles.fig1 = figure('Name','ERP Comparison By Participant','NumberTitle','off', 'Position',handles.pl.size, 'Color', handles.pl.color, 'MenuBar', 'none', 'KeyPressFcn', @keyPress);

    % Calculate Plot Characteristics
    handles.size.xsize = floor((handles.pl.size(3)-(handles.size.xpadding*(cColumns-1))-handles.size.xshift)/cColumns)-handles.size.xceilpadding;
    handles.size.ysize = floor((handles.pl.size(4)-(handles.size.ypadding*(cRows-1))-handles.size.yshift)/cRows)-handles.size.yceilpadding;
    handles.size.xsizeScaled = handles.size.xsize / handles.pl.size(3);
    handles.size.ysizeScaled = handles.size.ysize / handles.pl.size(4);
    handles.size.xpaddingScaled = handles.size.xpadding / handles.pl.size(3);
    handles.size.ypaddingScaled = handles.size.ypadding / handles.pl.size(4);
    handles.size.xshiftScaled = handles.size.xshift/handles.pl.size(3);
    handles.size.yshiftScaled = handles.size.yshift/handles.pl.size(4);
    handles.size.xchannelScaled = handles.size.xchannel/handles.pl.size(3);
    handles.size.ychannelScaled = handles.size.ychannel/handles.pl.size(4);
    
    if (numel(handles.listofcomparisons) > 7)
        try
        colormap default
        catch
            boleroc = 0;
        end
        handles.colormap = colormap;
        handles.colormapstep = size(handles.colormap,1)/handles.numberofcomparisons;
    else
        handles.colormap = [0,    0.4470,    0.7410; 0.4660,    0.6740,    0.1880; 0.8500,    0.3250,    0.0980;0.4940,   0.1840,    0.5560;0.3010,    0.7450,    0.9330;0.6350,    0.0780,    0.1840;0.9290,    0.6940,    0.1250];
        handles.colormapstep = 1;
    end
     
    % Populate Grid
    celCount = 1;
    axeslist = [];
    rspace = handles.size.yshiftScaled + (handles.size.ysizeScaled*(cRows-1)) + (handles.size.ypaddingScaled*(cRows-1));
    for cR = 1:cRows
        cspace = handles.size.xshiftScaled;
        for cC = 1:cColumns
            if (celCount <= handles.nparticipants)
                handles.(sprintf('r%dc%d',cR,cC)).axes = axes(handles.size.label,[cspace,rspace,handles.size.xsizeScaled,handles.size.ysizeScaled],'FontSize', handles.size.fSz);
                for cL = 1:handles.numberofcomparisons
                    handles.(sprintf('r%dc%dl%d',cR,cC,cL)).line = line(handles.times,handles.comparisonstructure(celCount).(sprintf('comp%d', cL)),'LineWidth',TrialWidth, 'Color',handles.colormap(handles.colormapstep*cL,:));
                    %uistack(handles.(sprintf('r%dc%dl%d',cR,cC,cL)).line, 'down', 1);
                end
                box('off'); axis tight;
                set(handles.(sprintf('r%dc%d',cR,cC)).axes,'Color','None'); 
                axeslist(end+1) = handles.(sprintf('r%dc%d',cR,cC)).axes;
                if (strcmpi(Polarity, 'Positive Down') == 1)
                    set(handles.(sprintf('r%dc%d',cR,cC)).axes,'YDir','reverse');    
                end
                ylabel(handles.(sprintf('r%dc%d',cR,cC)).axes,'Microvolts'); 
                xlabel(handles.(sprintf('r%dc%d',cR,cC)).axes,'Time (ms)'); 
            end
            celCount = celCount + 1;
            cspace = cspace + handles.size.xsizeScaled + handles.size.xpaddingScaled;
        end
        rspace = rspace - (handles.size.ysizeScaled + handles.size.ypaddingScaled);
    end
    linkaxes(axeslist, 'xy');
    ylim([-50 70]);
    if ~isempty(XScale)
        xlim([XScale(1) XScale(2)]);
    end
    cspacemax = cspace - handles.size.xsizeScaled - handles.size.xpaddingScaled;
    rspacemax = rspace - (handles.size.ysizeScaled + handles.size.ypaddingScaled);
   
    % Populate Labels
    celCount = 1;
    %rspace = handles.size.yshiftScaled + (handles.size.ysizeScaled*(cRows-1)) + (handles.size.ypaddingScaled*(cRows-1))+(0.81*(handles.size.ysizeScaled + handles.size.ypaddingScaled));
    rspace = handles.size.yshiftScaled + (handles.size.ysizeScaled*(cRows-1)) + (handles.size.ypaddingScaled*(cRows-1));
    for cR = 1:cRows
        cspace = handles.size.xshiftScaled + (1/handles.pl.size(3));
        for cC = 1:cColumns
            if (celCount <= handles.nparticipants)
                handles.(sprintf('r%dc%d',cR,cC)).tN = uicontrol('Style', 'text', 'String', handles.comparisonstructure(celCount).participant, 'Units','normalized', 'Position', [cspace,rspace,handles.size.xchannelScaled,handles.size.ychannelScaled], 'HorizontalAlignment', 'left','FontSize', handles.size.fSz);
            end
            celCount = celCount + 1;
            cspace = cspace + handles.size.xsizeScaled + handles.size.xpaddingScaled;
        end
        rspace = rspace - (handles.size.ysizeScaled + handles.size.ypaddingScaled);
    end
    if ~isempty(handles.listofcomparisons)
        legmsg = {};
        for cC = 1:handles.numberofcomparisons
            legmsg(end+1) = handles.listofcomparisons(cC);
        end
        handles.legend = legend(legmsg);
        temppos = get(handles.legend, 'Position');
        set(handles.legend, 'Position', [.94,.025,temppos(3),temppos(4)]);
    end
    
     % Set axis as button
%     celCount = 1;
%     for cR = 1:cRows
%         for cC = 1:cColumns
%             if (celCount <= handles.nparticipants)
%                 set(handles.(sprintf('r%dc%d',cR,cC)).axes, 'ButtonDownFcn', {@axisPress, (celCount)});
%             end
%             celCount = celCount + 1;
%         end
%     end
    
%     function axisPress(hObject,eventdata,handles)
%         celCount = 1;
%         for cR = 1:cRows
%             for cC = 1:cColumns
%                 if (celCount == handles)
%                     tempcolor = get(handles.(sprintf('r%dc%d',cR,cC)).axes, 'Color');
%                     set(handles.(sprintf('r%dc%d',cR,cC)).axes, 'Color', fliplf(tempcolor))
%                     set(handles.(sprintf('r%dc%d',cR,cC)).axes, 'Color', fliplf(tempcolor))
%                 end
%                 celCount = celCount + 1;
%             end
%         end
%         %http://www.mathworks.com/help/matlab/ref/axes-properties.html
%     end
%     


    
    function keyPress(src, e)
        scale = ylim;
        numlocs = (cRows * cColumns);
        switch e.Key
             case 'downarrow'
                if strcmp(e.Modifier, 'shift')
                    scale = scale + 0.5;
                else
                    scale = scale * 1.25;
                end
             case 'uparrow'
                if strcmp(e.Modifier, 'shift')
                    scale = scale - 0.5;
                else
                    scale = scale * 0.75;
                end
        end
        ylim(scale);
    end

    function closefcn(hObject,eventdata,handles)
        delete(hObject);
    end
    

end