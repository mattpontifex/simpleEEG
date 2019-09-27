function plotERParray(ERP, varargin)
%   Plot of ERP data corresponding to the 10-10 array in a manner 
%   similar to how data is presented in Neuroscan 4 Edit. Clicking 
%   on ERP activity in any channel will open up a new figure of activity
%   at that channel (depending on computer specs this can sometimes
%   take a second or two). Arrow Up and Down scale the amplitude, 
%   holding shift while using the up and down arrow will linearly shift
%   the axis up or down.
%
%    Input parameters are as follows:
%       1    'Bin' - Bin to display. Default is 1.
%       2    'ChannelScale' - Channel to display axis on. Default is 'M1'.
%       3    'Polarity' - ['Positive Up' | 'Positive Down' (default)]
%       4    'Smooth' - Smothing Enabled [ 'True' | 'False' (default)]
%       5    'TrialColor' - Color of the individul trial waveforms
%       6    'TrialWidth' - Line width of the individul trial waveforms
%       7    'guiSize' - Size of the GUI (i.e., [200,200,1600,800] - 200 pixels right on screen, 200 pixels up on screen, 1600 pixels wide, 800 pixels tall)
%       8    'guiBackgroundColor' - GUI background color. Default is [0.941,0.941,0.941]
%       9    'guiFontSize' - GUI font size. Default is 8
%       10  'ChannelMatrix' - Cell array of 81 channel labels. Plots are
%               labeled in a 9 x 9 grid from the top left to the lower right.
%               Default are labels from the 10-10 system. If the channel is not
%               listed in EEG.chanlocs.labels then that channel will not be
%               displayed. If EEG.chanlocs.labels has a channel that is not in the
%               'ChannelMatrix' then that channel will also not be displayed.
%      
%   Example Code:
%
%       plotERParray(ERP, 'Bin', 1, 'ChannelScale', 'M1', 'guiSize', [200,200,1600,800], 'guiFontSize', 8);
%    
%   Author: Matthew B. Pontifex, Health Behaviors and Cognition Laboratory, Michigan State University, September 7, 2014

    handles=struct;    %'Structure which stores all object handles
    if ~isempty(varargin)
          r=struct(varargin{:});
    end
    try, r.Bin; handles.bin = r(1).Bin; catch, handles.bin = 1; end
    try, r.ChannelScale; ChannelScale = r.ChannelScale; catch, ChannelScale = 'M1';  end
    try, r.Polarity; Polarity = r.Polarity; catch, Polarity = 'Positive Down';  end
    try, r.Smooth; bolSmooth = r.Smooth; catch, bolSmooth = 'False'; end
    try, r.TrialColor; TrialColor = r.TrialColor; catch, TrialColor = [0 0.6 0]; end
    try, r.TrialWidth; TrialWidth = r.TrialWidth; catch, TrialWidth = 0.5; end
    try, r.guiSize; guiSize = r.guiSize; catch, guiSize = []; end
    try, r.guiBackgroundColor; guiBackgroundColor = r.guiBackgroundColor; catch, guiBackgroundColor = [0.941,0.941,0.941]; end
    try, r.guiFontSize; guiFontSize = r.guiFontSize; catch, guiFontSize = 8; end
    try, r.ChannelMatrix; fullmatrix = {r.ChannelMatrix}; catch, fullmatrix = {}; end
    
    if isempty(guiSize)
        try
              set(0,'units','pixels')
              guiSize = get(0,'screensize');
              guiSize(2) = guiSize(4)*0.2;
              guiSize(4) = guiSize(4)*0.9;
        catch
            guiSize = [200,200,1000,800];
        end
    end
    
    warning('off','all');
    x = ERP.times;
        
    if ismac
        guiFontSize = guiFontSize*1.5;
    end
    
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
        disp('in')
    else
        disp('out')
        fullmatrix = {'M1','CB1','O3','O1','OZ','O2','O4','CB2','M2','PO9','PO7','PO5','PO3','POZ','PO4','PO6','PO8','PO10','P7','P5','P3','P1','PZ','P2','P4','P6','P8','TP7','CP5','CP3','CP1','CPZ','CP2','CP4','CP6','TP8','T7','C5','C3','C1','CZ','C2','C4','C6','T8','FT7','FC5','FC3','FC1','FCZ','FC2','FC4','FC6','FT8','F7','F5','F3','F1','FZ','F2','F4','F6','F8','AF9','AF7','AF5','AF3','AFZ','AF4','AF6','AF8','AF10','VEOG','HEOG','FP3','FP1','FPZ','FP2','FP4','FP6','FP8'};
    end
    fullmatrixcheck = zeros(1,size(fullmatrix,2));
    fullmatrixindex = zeros(1,size(fullmatrix,2));
    tempmatrix = {ERP.chanlocs(:).labels};
    for cC = 1:size(fullmatrix,2)
        index = find(strcmp(tempmatrix, fullmatrix(cC)));
        if (~isempty(index))
            fullmatrixcheck(cC) = 1;
            fullmatrixindex(cC) = index;
        end
    end
    % Determine where to put the axis info
    ChannelScale = find(strcmp(ChannelScale, fullmatrix(cC)));
    if isempty(ChannelScale)
        ChannelScale = 1;
    end
    
    inMat = ERP.bindata;
    
    if (strcmpi(bolSmooth, 'True'))
        for cC = 1:size(inMat,1)
            for cT = 1:size(inMat,3)
                inMat(cC,:,cT) = fastsmooth(inMat(cC,:,cT),9,3,1);
            end
        end
    end
    if (strcmpi(bolSmooth, 'Max'))
        for cC = 1:size(inMat,1)
            for cT = 1:size(inMat,3)
                inMat(cC,:,cT) = fastsmooth(inMat(cC,:,cT),25,3,1);
            end
        end
    end
   
    handles.lin.width1 = TrialWidth;
    handles.lin.color1 = TrialColor; % Trial
    handles.pl.color = guiBackgroundColor;
    handles.hot.accept = handles.pl.color;
    handles.pl.size = guiSize;
    handles.pl.size2 = [200,200,800,500];
    handles.size.xpadding = 30;
    handles.size.ypadding = 30;
    handles.size.xshift = 30;
    handles.size.yshift = 30;
    handles.size.label = 'Position'; %'OuterPosition'
    handles.size.xchannel = 30;
    handles.size.ychannel = 15;
    handles.size.fSz = guiFontSize;
    currenttrial = handles.bin;

    % Create GUI window
    if iscell(ERP.erpname)
       ERP.erpname = cell2mat(ERP.erpname); 
    end
    handles.fig1 = figure('Name', sprintf('Plot of %s', ERP.erpname),'NumberTitle','off', 'Position',handles.pl.size, 'Color', handles.pl.color, 'MenuBar', 'none', 'KeyPressFcn', @keyPress);

    % Calculate Plot Characteristics
    handles.size.xsize = floor((handles.pl.size(3)-(handles.size.xpadding*8)-handles.size.xshift)/9);
    handles.size.ysize = floor((handles.pl.size(4)-(handles.size.ypadding*8)-handles.size.yshift)/9);
    handles.size.xsizeScaled = handles.size.xsize / handles.pl.size(3);
    handles.size.ysizeScaled = handles.size.ysize / handles.pl.size(4);
    handles.size.xpaddingScaled = handles.size.xpadding / handles.pl.size(3);
    handles.size.ypaddingScaled = handles.size.ypadding / handles.pl.size(4);
    handles.size.xshiftScaled = handles.size.xshift/handles.pl.size(3);
    handles.size.yshiftScaled = handles.size.yshift/handles.pl.size(4);
    handles.size.xchannelScaled = handles.size.xchannel/handles.pl.size(3);
    handles.size.ychannelScaled = handles.size.ychannel/handles.pl.size(4);

    % Populate Grid
    celCount = 1;
    axeslist = [];
    rspace = handles.size.yshiftScaled;
    for cR = 1:9
        cspace = handles.size.xshiftScaled;
        for cC = 1:9
            if (fullmatrixcheck(celCount) == 1)
                handles.(sprintf('r%dc%d',cR,cC)).axes = axes(handles.size.label,[cspace,rspace,handles.size.xsizeScaled,handles.size.ysizeScaled],'FontSize', handles.size.fSz);
                handles.(sprintf('r%dc%d',cR,cC)).plot = plot(x,inMat(fullmatrixindex(celCount),:,currenttrial),'LineWidth',handles.lin.width1,'Color',handles.lin.color1); 
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

    % Populate Labels
    celCount = 1;
    rspace = handles.size.yshiftScaled+(0.55*(handles.size.ysizeScaled + handles.size.ypaddingScaled));
    for cR = 1:9
        cspace = handles.size.xshiftScaled + (1/handles.pl.size(3));
        for cC = 1:9
            if (fullmatrixcheck(celCount) == 1)
                handles.(sprintf('r%dc%d',cR,cC)).tN = uicontrol('Style', 'text', 'String', fullmatrix(celCount), 'Units','normalized', 'Position', [cspace,rspace,handles.size.xchannelScaled,handles.size.ychannelScaled], 'FontSize', handles.size.fSz);
            end
            celCount = celCount + 1;
            cspace = cspace + handles.size.xsizeScaled + handles.size.xpaddingScaled;
        end
        rspace = rspace + handles.size.ysizeScaled + handles.size.ypaddingScaled;
    end
    
    handles.trialnumtext = uicontrol('Style', 'text', 'String', 'X Trials Accepted', 'Units','normalized', 'Position', [0.6,0,(handles.size.xchannelScaled*7),(handles.size.ychannelScaled*1.5)], 'FontSize', (handles.size.fSz*1.2));
    message = sprintf('%d Trials Accepted', ERP.ntrials.accepted);
    set(handles.trialnumtext, 'String', message);
    
    % Populate axis buttons
    celCount = 1;
    for cR = 1:9
        for cC = 1:9
            if (fullmatrixcheck(celCount) == 1)
                set(handles.(sprintf('r%dc%d',cR,cC)).plot, 'ButtonDownFcn', {@axisHit, celCount});
            end
            celCount = celCount + 1;
        end
    end
            
    function axisHit(hObject,eventdata,celCount)
        handles.fig2 = figure('Name',char(fullmatrix(celCount)),'NumberTitle','off', 'Position',handles.pl.size2, 'Color', handles.pl.color, 'MenuBar', 'none','KeyPressFcn', @keyPress, 'windowbuttonmotionfcn',{@fh_wbmfcn,celCount});
        handles.subplot.axes = axes(handles.size.label,[0.1,0.1,0.85,0.85],'FontSize', handles.size.fSz);
        handles.subplot.plot = plot(x,inMat(fullmatrixindex(celCount),:),'LineWidth',handles.lin.width1,'Color',handles.lin.color1); 
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
        handles.currentline = line([0 0], [(scale(1)*.998) (scale(2)*.998)], 'LineStyle', '--', 'Color', 'k');
    end

    function fh_wbmfcn(varargin)
        celCount = cell2mat(varargin(3));
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
            posaxdiff = ceil(((F(1)-S.AXP(1))/(S.AXP(3)-S.AXP(1)))*(size(inMat,2))); % Find what point the cursor corresponds to
            message = sprintf('Latency: %d ms', x(posaxdiff));
            set(handles.cursorposLat, 'String', message);
            message = sprintf('Amplitude: %.2f', inMat(fullmatrixindex(celCount),posaxdiff));
            set(handles.cursorposAmp, 'String', message);
            set(handles.currentline, 'XData', [x(posaxdiff) x(posaxdiff)]);
        end
    end
    
    
    function keyPress(src, e)
        scale = ylim;
        switch e.Key
             case 'downarrow'
                if strcmp(e.Modifier, 'shift')
                    scale = scale - 0.5;
                else
                    scale = scale * 1.25;
                end
             case 'uparrow'
                if strcmp(e.Modifier, 'shift')
                    scale = scale + 0.5;
                else
                    scale = scale * 0.75;
                end
        end
        ylim(scale);
    end

end








