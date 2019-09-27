function compareERParray(INALLERP, varargin)
%   Plot ERP sets within the ALLERP structure for comparison purposes. 
%   Clicking on a channel will bring up another figure window ploting
%   activity within that channel (the more sets, the longer the delay
%   before the window shows up). At present plotting more than 6 ERP sets
%   is computationally very slow.
%   Arrow Left and Right can be used to scroll through the data. Arrow Up 
%   and Down scale the amplitude, holding shift while using the up and 
%   down arrow will linearly shift the axis up or down.
%
%    Input parameters are as follows:
%       1    'Bin' - Bin to display. Default is 1.
%       2    'ChannelScale' - Channel to display axis on. Default is 'M1'.
%       3    'Polarity' - ['Positive Up' | 'Positive Down' (default)]
%       4    'Smooth' - Smothing Enabled [ 'True' | 'False' (default)]
%       5    'TrialColor' - Color of the individul trial waveforms in 3x6 matrix
%       6    'TrialWidth' - Line width of the individul trial waveforms
%       7    'guiSize' - Size of the GUI. Default is [200,200,1600,800] (200 pixels right on screen, 200 pixels up on screen, 1600 pixels wide, 800 pixels tall)
%       8    'guiBackgroundColor' - GUI background color. Default is [0.941,0.941,0.941]
%       9    'guiFontSize' - GUI font size. Default is 8
%       10   'ChannelMatrix' - Cell array of 81 channel labels. Plots are
%               labeled in a 9 x 9 grid from the top left to the lower right.
%               Default are labels from the 10-10 system. If the channel is not
%               listed in EEG.chanlocs.labels then that channel will not be
%               displayed. If EEG.chanlocs.labels has a channel that is not in the
%               'ChannelMatrix' then that channel will also not be displayed.
%       11    'XScale' - X axis limits (i.e., [-100 1000]).
%       12    'Legend' - Legend labels (i.e., { 'CondA', 'CondB' }).
%      
%   Example Code:
%
%       compareERParray(ALLERP, 'Bin', 1, 'ChannelScale', 'M1', 'guiSize', [200,200,1600,800], 'guiFontSize', 8);
%    
%   Author: Matthew B. Pontifex, Health Behaviors and Cognition Laboratory, Michigan State University, September 9, 2014
%   revised to be insensitive to channel order and times: August 23, 2015 - MBP

    handles=struct;    %'Structure which stores all object handles
    if ~isempty(varargin)
          r=struct(varargin{:});
    end
    try, r.Bin; handles.bin = r(1).Bin; catch, handles.bin = 1; end
    try, r.ChannelScale; ChannelScale = r.ChannelScale; catch, ChannelScale = 'M1';  end
    try, r.Polarity; Polarity = r.Polarity; catch, Polarity = 'Positive Down';  end
    try, r.Smooth; bolSmooth = r.Smooth; catch, bolSmooth = 'False'; end
    try, r.TrialColor; TrialColor = r.TrialColor; catch, TrialColor = [0 0 0.6; 0 0.6 0; 0 0 0; 0.6 0 0; 0.6 0.3 0.6; 0.45 0.45 0.45]; end
    try, r.TrialWidth; TrialWidth = r.TrialWidth; catch, TrialWidth = 0.5; end
    try, r.guiSize; guiSize = r.guiSize; catch, guiSize = []; end
    try, r.guiBackgroundColor; guiBackgroundColor = r.guiBackgroundColor; catch, guiBackgroundColor = [0.941,0.941,0.941]; end
    try, r.guiFontSize; guiFontSize = r.guiFontSize; catch, guiFontSize = 8; end
    try, r.ChannelMatrix; fullmatrix = {r.ChannelMatrix}; catch, fullmatrix = {}; end
    try, r.XScale; XScale = r.XScale; catch, XScale = []; end
    try, r.Legend; legmsg = {r(1).Legend}; catch, legmsg = []; end

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

    % Check Sample Rates
    if (size(unique([INALLERP.srate]),2) > 1) 
       error('Error at compareERParray(). Sample Rates do not match.')
    else
       handles.srate = unique([INALLERP.srate]);
    end

    timetemp = [INALLERP.times];
    handles.times = (min(timetemp)):(1000/handles.srate):(max(timetemp)); 
    handles.pnts = size(handles.times,2);

    % Determine which channels are present in the ERP set
    if (~isempty(fullmatrix)) && (numel(fullmatrix) == 81)
        fullmatrix = fliplr(fullmatrix);
        tempmatrix = {};
        tempcount = 0;
        for cR = 1:9
            temp = fliplr(fullmatrix(tempcount+1:tempcount+9));
            tempcount = tempcount + 9;
            for cC = 1:9
                tempmatrix(end+1) = temp(cC);
            end
        end
        fullmatrix = upper(tempmatrix);
    elseif (~isempty(fullmatrix))
        fullmatrix = upper(fullmatrix);
    else
        fullmatrix = {'M1','CB1','O3','O1','OZ','O2','O4','CB2','M2','PO9','PO7','PO5','PO3','POZ','PO4','PO6','PO8','PO10','P7','P5','P3','P1','PZ','P2','P4','P6','P8','TP7','CP5','CP3','CP1','CPZ','CP2','CP4','CP6','TP8','T7','C5','C3','C1','CZ','C2','C4','C6','T8','FT7','FC5','FC3','FC1','FCZ','FC2','FC4','FC6','FT8','F7','F5','F3','F1','FZ','F2','F4','F6','F8','AF9','AF7','AF5','AF3','AFZ','AF4','AF6','AF8','AF10','VEOG','HEOG','FP3','FP1','FPZ','FP2','FP4','FP6','FP8'};
        tempcount = 0;
        for cP = 1:size(INALLERP,2)
            tempcount = tempcount + numel(intersect(fullmatrix,upper({INALLERP(cP).chanlocs.labels})));
        end
        if ((tempcount/size(INALLERP,2)) < 5)
            % Set for Non 10-10 array #####################################
            fullmatrix = {'M1','CB1','O3','O1','OZ','O2','O4','CB2','M2','PO9','PO7','PO5','PO3','POZ','PO4','PO6','PO8','PO10','P7','P5','P3','P1','PZ','P2','P4','P6','P8','TP7','CP5','CP3','CP1','CPZ','CP2','CP4','CP6','TP8','T7','C5','C3','C1','CZ','C2','C4','C6','T8','FT7','FC5','FC3','FC1','FCZ','FC2','FC4','FC6','FT8','F7','F5','F3','F1','FZ','F2','F4','F6','F8','AF9','AF7','AF5','AF3','AFZ','AF4','AF6','AF8','AF10','VEOG','HEOG','FP3','FP1','FPZ','FP2','FP4','FP6','FP8'};
            fullmatrix = upper(fullmatrix);
        end
    end

    handles.comparisonstructure = struct('participant', []);
    handles.comparisonlabels = NaN(1,numel(fullmatrix));

    for cP = 1:size(INALLERP,2)
        handles.comparisonstructure(cP).participant = {INALLERP(cP).erpname};
        inMat = NaN(numel(fullmatrix),handles.pnts); % channels x points
        for cC = 1:numel(fullmatrix)
            tempsearch = find(strcmpi(upper({INALLERP(cP).chanlocs.labels}),upper(fullmatrix(cC))));
            if ~isempty(tempsearch)
                % Populate matrix for the data that does exist only for the time span available
                inMat(cC,find(handles.times == INALLERP(cP).times(1)):find(handles.times == INALLERP(cP).times(end))) = INALLERP(cP).bindata(tempsearch,:,handles.bin);
                handles.comparisonlabels(cC) = 1;
            end
        end
        % Smooth if specified
        if (strcmpi(bolSmooth, 'True'))
            inMat = gaussmooth(inMat, 'Window', floor(INALLERP(1).srate/10), 'Sigma', 1.5);
        elseif (strcmpi(bolSmooth, 'Max'))
            inMat = gaussmooth(inMat, 'Window', floor(INALLERP(1).srate/5), 'Sigma', 1.5);
        end
        if ~isempty(XScale)
            [Ytemp, Imin] = min(abs(handles.times-XScale(1)));
            [Ytemp, Imax] = min(abs(handles.times-XScale(2)));
            inMat = inMat(:,Imin:Imax);
        end
        handles.comparisonstructure(cP).data = inMat;
    end
    
    if ~isempty(XScale)
        handles.times = handles.times(Imin:Imax);
    end

    % Determine where to put the axis info
    ChannelScale = find(strcmpi(ChannelScale, fullmatrix));
    if ~isempty(ChannelScale) || ~isnan(handles.comparisonlabels(ChannelScale))
        if (~isnan(handles.comparisonlabels(1)))
            ChannelScale = 1;
        elseif (~isnan(handles.comparisonlabels(10)))
            ChannelScale = 10;
        elseif (~isnan(handles.comparisonlabels(19)))
            ChannelScale = 19;
        elseif (~isnan(handles.comparisonlabels(28)))
            ChannelScale = 28;
        elseif (~isnan(handles.comparisonlabels(37)))
            ChannelScale = 37;
        elseif (~isnan(handles.comparisonlabels(46)))
            ChannelScale = 46;
        elseif (~isnan(handles.comparisonlabels(55)))
            ChannelScale = 55;
        elseif (~isnan(handles.comparisonlabels(64)))
            ChannelScale = 64;
        elseif (~isnan(handles.comparisonlabels(64)))
            ChannelScale = 73;
        else
            temp = find(handles.comparisonlabels == 1);
            if ~isempty(temp)
                ChannelScale = temp(1);
            end
        end
    end
    
    handles.lin.width1 = TrialWidth;
    handles.lin.color1 = TrialColor; % Trial
    handles.pl.color = guiBackgroundColor;
    handles.hot.accept = handles.pl.color;
    handles.pl.size = guiSize;
    handles.pl.size2 = [200,200,800,500];
    handles.size.label = 'Position'; %'OuterPosition'
    handles.size.fSz = guiFontSize;    
    handles.size.xpadding = 30;
    handles.size.xshift = 30;
    handles.size.xchannel = 100;
    
    handles.size.ypadding = 35;
    handles.size.yshift = 30;
    handles.size.ychannel = 15;

    % Create GUI window
    handles.fig1 = figure('Name','ERP Comparison Plot','NumberTitle','off', 'Position',handles.pl.size, 'Color', handles.pl.color, 'MenuBar', 'none', 'KeyPressFcn', @keyPress);

    % Calculate Plot Characteristics
    handles.size.xsize = floor((handles.pl.size(3)-(handles.size.xpadding*8)-handles.size.xshift)/9);
    handles.size.ysize = floor((handles.pl.size(4)-(handles.size.ypadding*8.5)-handles.size.yshift)/9);
    handles.size.xsizeScaled = handles.size.xsize / handles.pl.size(3);
    handles.size.ysizeScaled = handles.size.ysize / handles.pl.size(4);
    handles.size.xpaddingScaled = handles.size.xpadding / handles.pl.size(3);
    handles.size.ypaddingScaled = handles.size.ypadding / handles.pl.size(4);
    handles.size.xshiftScaled = handles.size.xshift/handles.pl.size(3);
    handles.size.yshiftScaled = handles.size.yshift/handles.pl.size(4);
    handles.size.xchannelScaled = handles.size.xchannel/handles.pl.size(3);
    handles.size.ychannelScaled = handles.size.ychannel/handles.pl.size(4);
    
    if (size(INALLERP,2) > 7)
        try
        colormap default
        catch
            boleroc = 0;
        end
        handles.colormap = colormap;
        handles.colormapstep = size(handles.colormap,1)/size(INALLERP,2);
    else
        handles.colormap = [0,    0.4470,    0.7410; 0.4660,    0.6740,    0.1880; 0.8500,    0.3250,    0.0980;0.4940,   0.1840,    0.5560;0.3010,    0.7450,    0.9330;0.6350,    0.0780,    0.1840;0.9290,    0.6940,    0.1250];
        handles.colormapstep = 1;
    end
    
    % Populate Grid
    celCount = 1;
    axeslist = [];
    rspace = handles.size.yshiftScaled;
    for cR = 1:9
        cspace = handles.size.xshiftScaled;
        for cC = 1:9
            if ~isnan(handles.comparisonlabels(celCount))
                handles.(sprintf('r%dc%d',cR,cC)).axes = axes(handles.size.label,[cspace,rspace,handles.size.xsizeScaled,handles.size.ysizeScaled],'FontSize', handles.size.fSz);
                
                for cL = 1:size(INALLERP,2)
                    handles.(sprintf('r%dc%dcomp%d',cR,cC,cL)).line = line(handles.times,handles.comparisonstructure(cL).data(celCount,:),'LineWidth',handles.lin.width1, 'Color',handles.colormap(handles.colormapstep*cL,:));
                end
                
                if (strcmpi(Polarity, 'Positive Down') == 1)
                    set(handles.(sprintf('r%dc%d',cR,cC)).axes,'YDir','reverse');    
                end
                if (ChannelScale ~= celCount)
                    set(handles.(sprintf('r%dc%d',cR,cC)).axes,'XTickLabel','','YTickLabel','','visible','off'); 
                end
                set(handles.(sprintf('r%dc%d',cR,cC)).axes,'Color','None'); 
                box('off'); axis tight;
                axeslist(end+1) = handles.(sprintf('r%dc%d',cR,cC)).axes;
            end
            celCount = celCount + 1;
            cspace = cspace + handles.size.xsizeScaled + handles.size.xpaddingScaled;
        end
        rspace = rspace + handles.size.ysizeScaled + handles.size.ypaddingScaled;
    end
    linkaxes(axeslist, 'y');
    ylim([-20 30]);
    xlim([handles.times(1), handles.times(end)]);

    % Populate Labels
    celCount = 1;
    rspace = handles.size.yshiftScaled+(0.55*(handles.size.ysizeScaled + handles.size.ypaddingScaled));
    for cR = 1:9
        cspace = handles.size.xshiftScaled + (1/handles.pl.size(3));
        for cC = 1:9
            if ~isnan(handles.comparisonlabels(celCount))
                handles.(sprintf('r%dc%d',cR,cC)).tN = uicontrol('Style', 'text', 'String', fullmatrix(celCount), 'Units','normalized', 'Position', [cspace,rspace,handles.size.xchannelScaled,handles.size.ychannelScaled], 'FontSize', handles.size.fSz);
            end
            celCount = celCount + 1;
            cspace = cspace + handles.size.xsizeScaled + handles.size.xpaddingScaled;
        end
        rspace = rspace + handles.size.ysizeScaled + handles.size.ypaddingScaled;
    end
    if (isempty(legmsg)) | (max(size(legmsg)) ~= size(INALLERP,2)) 
        legmsg = {};
        for cC = 1:size(INALLERP,2)
            if iscell(INALLERP(cC).erpname)
                legmsg(end+1) = INALLERP(cC).erpname;
            else
                legmsg(end+1) = {INALLERP(cC).erpname};
            end
        end
    end
    handles.mainlegend = legend(legmsg);
    temppos = get(handles.mainlegend, 'Position');
    set(handles.mainlegend, 'Position', [(1-temppos(3))*.998,(1-temppos(4))*.998,temppos(3),temppos(4)]);

    % Populate axis buttons
    celCount = 1;
    for cR = 1:9
        for cC = 1:9
            if ~isnan(handles.comparisonlabels(celCount))
                for cL = 1:size(INALLERP,2)
                    set(handles.(sprintf('r%dc%dcomp%d',cR,cC,cL)).line, 'ButtonDownFcn', {@axisHit, celCount});
                end
            end
            celCount = celCount + 1;
        end
    end

    function axisHit(hObject,eventdata,celCount)
        handles.fig2 = figure('Name',char(fullmatrix(celCount)),'NumberTitle','off', 'Position',handles.pl.size2, 'Color', handles.pl.color, 'MenuBar', 'none','KeyPressFcn', @keyPress, 'windowbuttonmotionfcn',{@fh_wbmfcn,celCount});
        handles.subplot.axes = axes(handles.size.label,[0.1,0.1,0.85,0.85],'FontSize', handles.size.fSz);
        
        for cL = 1:size(INALLERP,2)
            handles.subplot.(sprintf('comp%d',cL)).line = line(handles.times,handles.comparisonstructure(cL).data(celCount,:),'LineWidth',handles.lin.width1*2, 'Color',handles.colormap(handles.colormapstep*cL,:));
        end
        
        if (strcmpi(Polarity, 'Positive Down') == 1)
            set(handles.subplot.axes,'YDir','reverse','Color','None');    
        end
        box('off'); axis tight;
        xlabel(handles.subplot.axes,'Time (ms)');
        ylabel(handles.subplot.axes,'Amplitude (microvolts)');
        axeslist(end+1) = handles.subplot.axes;
        linkaxes(axeslist, 'y');
        handles.cursorposAmp = uicontrol('Style', 'text', 'String', 'Amplitude: ', 'Units','normalized', 'Position', [0.55,0,0.2,0.03], 'FontSize', (handles.size.fSz*0.9));
        handles.cursorposLat = uicontrol('Style', 'text', 'String', 'Latency: ', 'Units','normalized', 'Position', [0.75,0,0.2,0.03], 'FontSize', (handles.size.fSz*0.9));
        scale = ylim;
        xlim([handles.times(1), handles.times(end)]);
        handles.currentline = line([0 0], [(scale(1)*.998) (scale(2)*.998)], 'LineStyle', '--', 'Color', 'k');
        
        handles.legend = legend(legmsg);
        temppos = get(handles.legend, 'Position');
        set(handles.legend, 'Position', [(1-temppos(3))*.998,(1-temppos(4))*.998,temppos(3),temppos(4)]);
    end

    function fh_wbmfcn(varargin)
        celCount = cell2mat(varargin(3));
        xlim([handles.times(1), handles.times(end)]);
        % WindowButtonMotionFcn for the figure.
        S.AXP = get(handles.subplot.axes,'Position');
        S.XLM = get(handles.subplot.axes,'xlim');
        F = get(handles.fig2,'currentpoint');  % The current point w.r.t the figure.
        handles.pl.size2 = getpixelposition(handles.fig2);
        % Figure out if the current point is over the axes or not -> logicals.
        S.AXP(1) = (S.AXP(1)*handles.pl.size2(3)); S.AXP(2) = (S.AXP(2)*handles.pl.size2(4));
        S.AXP(3) = (S.AXP(3)*handles.pl.size2(3))+S.AXP(1); S.AXP(4) = (S.AXP(4)*handles.pl.size2(4))+S.AXP(2);
        tf1 = S.AXP(1) <= F(1) && F(1) <= S.AXP(3);
        tf2 = S.AXP(2) <= F(2) && F(2) <= S.AXP(4);

        if tf1 && tf2
            posaxdiff = ceil(((F(1)-S.AXP(1))/(S.AXP(3)-S.AXP(1)))*(size(handles.times,2))); % Find what point the cursor corresponds to
            if (posaxdiff > 0)
                try
                    message = sprintf('Latency: %d ms', handles.times(posaxdiff));
                    set(handles.cursorposLat, 'String', message);
                    message = sprintf('Amplitude: %.2f', handles.comparisonstructure(1).data(celCount,posaxdiff));
                    set(handles.cursorposAmp, 'String', message);
                    set(handles.currentline, 'XData', [handles.times(posaxdiff) handles.times(posaxdiff)]);
                catch
                    boolerr = 0;
                end
            end
        end
    end

    function keyPress(src, e)
        scale = ylim;
        ymin = scale(1);
        ymax = scale(2);
        switch e.Key
             case 'downarrow'
                if strcmp(e.Modifier, 'shift')
                    ymin = ymin + ((ymax-ymin)*.1);
                    ymax = ymax + ((ymax-ymin)*.1);
                else
                    ymin = ymin - ((ymax-ymin)*.1);
                    ymax = ymax + ((ymax-ymin)*.1);
                end
             case 'uparrow'
                if strcmp(e.Modifier, 'shift')
                    ymin = ymin - ((ymax-ymin)*.1);
                    ymax = ymax - ((ymax-ymin)*.1);
                else
                    ymin = ymin + ((ymax-ymin)*.1);
                    ymax = ymax - ((ymax-ymin)*.1);
                end
        end
        ylim([ymin, ymax]);
    end

end




