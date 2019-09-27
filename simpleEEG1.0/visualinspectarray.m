function [EEG] = visualinspectarray(EEG, varargin)
%   Graphical user interface to allow for visual inspection of the inputted
%   data. Trial data will show up as the Green lines, the average of all
%   accepted trials shows up as the Grey line. To reject a trial click 'd'. 
%   Rejected trials will have a red background. To accept a trial click 'c'. 
%   Arrow Left and Right can be used to scroll through the data. Arrow Up 
%   and Down scale the amplitude, holding shift while using the up and 
%   down arrow will linearly shift the axis up or down.
%
%    Input parameters are as follows:
%       1    'ChannelScale' - Channel to display axis on. Default is 'M1'.
%       2    'Polarity' - ['Positive Up' | 'Positive Down' (default)]
%       3    'Smooth' - Smothing Enabled [ 'True' | 'False' (default)]
%       4    'Average' - Display average of all accepted trials [ 'True' | 'False' (default)]
%       5    'TrialColor' - Color of the individul trial waveforms
%       6    'TrialWidth' - Line width of the individul trial waveforms
%       7    'AverageColor' - Color of the average waveform
%       8    'AverageWidth' - Line width of the average waveform
%       9    'guiSize' - Size of the GUI (i.e., [200,200,1600,800] - 200 pixels right on screen, 200 pixels up on screen, 1600 pixels wide, 800 pixels tall)
%       10  'guiBackgroundColor' - GUI background color. Default is [0.941,0.941,0.941]
%       11  'guiFontSize' - GUI font size. Default is 8
%       12  'RejectColor' - Color to display for rejected trials. Default is [0.937,0.867,0.867]
%       13  'ChannelMatrix' - Cell array of 81 channel labels. Plots are
%               labeled in a 9 x 9 grid from the top left to the lower right.
%               Default are labels from the 10-10 system. If the channel is not
%               listed in EEG.chanlocs.labels then that channel will not be
%               displayed. If EEG.chanlocs.labels has a channel that is not in the
%               'ChannelMatrix' then that channel will also not be displayed.
%       14    'XScale' - X axis limits (i.e., [-100 1000]).
%      
%   Example Code:
%
%       EEG = visualinspectarray(EEG, 'ChannelScale', 'M1', 'Average', 'True', 'guiSize', [200,200,1600,800], 'guiFontSize', 8);
%    
%   Author: Matthew B. Pontifex, Health Behaviors and Cognition Laboratory, Michigan State University, August 7, 2014

    if ~isempty(varargin)
          r=struct(varargin{:});
    end
    try, r.ChannelScale; ChannelScale = r.ChannelScale; catch, ChannelScale = 'M1';  end
    try, r.Polarity; Polarity = r.Polarity; catch, Polarity = 'Positive Down';  end
    try, r.Average; Average = r.Average; catch, Average = 'False';  end
    try, r.Smooth; bolSmooth = r.Smooth; catch, bolSmooth = 'False'; end
    try, r.TrialColor; TrialColor = r.TrialColor; catch, TrialColor = [0 0.6 0]; end
    try, r.TrialWidth; TrialWidth = r.TrialWidth; catch, TrialWidth = 0.5; end
    try, r.AverageColor; AverageColor = r.AverageColor; catch, AverageColor = [.8 .8 .8]; end
    try, r.AverageWidth; AverageWidth = r.AverageWidth; catch, AverageWidth = 0.5; end
    try, r.guiSize; guiSize = r.guiSize; catch, guiSize = []; end
    try, r.guiBackgroundColor; guiBackgroundColor = r.guiBackgroundColor; catch, guiBackgroundColor = [0.941,0.941,0.941]; end
    try, r.RejectColor; RejectColor = r.RejectColor; catch, RejectColor = [0.937,0.867,0.867]; end
    try, r.guiFontSize; guiFontSize = r.guiFontSize; catch, guiFontSize = 8; end
    try, r.ChannelMatrix; fullmatrix = r.ChannelMatrix; catch, fullmatrix = {}; end
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
    
    x = EEG.times;
    if (isempty(EEG.reject.rejmanual))
        EEG.reject.rejmanual = zeros(1,size(EEG.data,3));
    end
     [T, EEG] = evalc('pop_syncroartifacts(EEG, ''Direction'', ''bidirectional'')'); %synchronize artifact databases
    % Determine which channels are present in the EEG set
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
    else
        fullmatrix = {'M1','CB1','O3','O1','OZ','O2','O4','CB2','M2','PO9','PO7','PO5','PO3','POZ','PO4','PO6','PO8','PO10','P7','P5','P3','P1','PZ','P2','P4','P6','P8','TP7','CP5','CP3','CP1','CPZ','CP2','CP4','CP6','TP8','T7','C5','C3','C1','CZ','C2','C4','C6','T8','FT7','FC5','FC3','FC1','FCZ','FC2','FC4','FC6','FT8','F7','F5','F3','F1','FZ','F2','F4','F6','F8','AF9','AF7','AF5','AF3','AFZ','AF4','AF6','AF8','AF10','VEOG','HEOG','FP3','FP1','FPZ','FP2','FP4','FP6','FP8'};
    end
    fullmatrixcheck = zeros(1,size(fullmatrix,2));
    fullmatrixindex = zeros(1,size(fullmatrix,2));
    tempmatrix = {EEG.chanlocs(:).labels};
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
    
    inMat = EEG.data;
    
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
   
    if ~isempty(XScale)
        [Ytemp, Imin] = min(abs(EEG.times-XScale(1)));
        [Ytemp, Imax] = min(abs(EEG.times-XScale(2)));
        inMat = inMat(:,Imin:Imax,:);
        x = x(Imin:Imax);
    end
    
    inMat_Mean = subsetmean(inMat, EEG.reject.rejmanual); % Average Accepted Trials

    handles=struct;    %'Structure which stores all object handles
    handles.lin.width1 = TrialWidth;
    handles.lin.width2 = AverageWidth;
    handles.lin.color1 = TrialColor; % Trial
    handles.lin.color2 = AverageColor; % Average
    handles.pl.color = guiBackgroundColor;
    handles.hot.accept = handles.pl.color;
    handles.hot.reject = RejectColor;
    handles.pl.size = guiSize;
    handles.size.xpadding = 30;
    handles.size.ypadding = 30;
    handles.size.xshift = 30;
    handles.size.yshift = 30;
    handles.size.label = 'Position'; %'OuterPosition'
    handles.size.xchannel = 30;
    handles.size.ychannel = 15;
    handles.size.fSz = guiFontSize;
    currenttrial = 1;

    % Create GUI window
    handles.fig1 = figure('Name','Visual Inspection','NumberTitle','off', 'Position',handles.pl.size, 'Color', handles.pl.color, 'MenuBar', 'none', 'KeyPressFcn', @keyPress);

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
                if (strcmpi(Average, 'True') == 1)
                    handles.(sprintf('r%dc%d',cR,cC)).line = line(x,inMat_Mean(fullmatrixindex(celCount),:),'LineWidth',handles.lin.width2, 'Color',handles.lin.color2);
                    uistack(handles.(sprintf('r%dc%d',cR,cC)).line, 'down', 1);
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
    ylim([-50 70]);

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
    
    handles.trialtext = uicontrol('Style', 'text', 'String', 'Trial X of X', 'Units','normalized', 'Position', [0.3,0,(handles.size.xchannelScaled*7),(handles.size.ychannelScaled*1.5)], 'FontSize', (handles.size.fSz*1.2));
    handles.trialnumtext = uicontrol('Style', 'text', 'String', 'X Trials Accepted', 'Units','normalized', 'Position', [0.6,0,(handles.size.xchannelScaled*7),(handles.size.ychannelScaled*1.5)], 'FontSize', (handles.size.fSz*1.2));
    
    %maximize;
    changeplot;
    uiwait(handles.fig1);
    
    function changeplot
        message = sprintf('Trial %d of %d', currenttrial, size(inMat,3));
        set(handles.trialtext, 'String', message);
        message = sprintf('%d Trials Accepted', nnz(~(EEG.reject.rejmanual)));
        set(handles.trialnumtext, 'String', message);
        if (EEG.reject.rejmanual(currenttrial) == 0) % If accept
            set(handles.fig1, 'Color', handles.hot.accept);
            set(handles.trialtext, 'BackgroundColor', handles.hot.accept);
            set(handles.trialnumtext, 'BackgroundColor', handles.hot.accept);
            celCount = 1;
            for cR = 1:9
                for cC = 1:9
                    if (fullmatrixcheck(celCount) == 1)
                        set(handles.(sprintf('r%dc%d',cR,cC)).tN,'BackgroundColor',handles.hot.accept);
                    end
                    celCount = celCount + 1;
                end
            end
        else
            set(handles.fig1, 'Color', handles.hot.reject);
            set(handles.trialtext, 'BackgroundColor', handles.hot.reject);
            set(handles.trialnumtext, 'BackgroundColor', handles.hot.reject);
            celCount = 1;
            for cR = 1:9
                for cC = 1:9
                    if (fullmatrixcheck(celCount) == 1)
                        set(handles.(sprintf('r%dc%d',cR,cC)).tN,'BackgroundColor',handles.hot.reject);
                    end
                    celCount = celCount + 1;
                end
            end
        end
        if (strcmpi(Average, 'True') == 1)
            inMat_Mean = subsetmean(inMat, EEG.reject.rejmanual); % Average Accepted Trials
        end
        celCount = 1;
        for cR = 1:9
            for cC = 1:9
                if (fullmatrixcheck(celCount) == 1)
                    set(handles.(sprintf('r%dc%d',cR,cC)).plot, 'YData', inMat(fullmatrixindex(celCount),:,currenttrial));
                    if (strcmpi(Average, 'True') == 1)
                        set(handles.(sprintf('r%dc%d',cR,cC)).line, 'YData', inMat_Mean(fullmatrixindex(celCount),:));
                    end
                end
                celCount = celCount + 1;
            end
        end
    end
    
    function keyPress(src, e)
        scale = ylim;
        switch e.Key
             case 'c'
                EEG.reject.rejmanual(currenttrial) = 0;
                changeplot;
             case 'd'
                EEG.reject.rejmanual(currenttrial) = 1;
                changeplot;
            case 'leftarrow'
                if (currenttrial > 1)
                     currenttrial = currenttrial - 1;
                     changeplot;
                end
             case 'rightarrow'
                if (currenttrial < (size(inMat,3)))
                     currenttrial = currenttrial + 1;
                     changeplot;
                end
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

    function [outmatrix] = subsetmean(matrixin, rejectvector)
        outmatrix = zeros(size(matrixin,1),size(matrixin,2));
        for cR = 1:size(matrixin,1) % for each channel
            tempmat = [];
            for cT = 1:size(matrixin,3) % for each trial
                if (rejectvector(cT) == 0) % If trial is not rejected
                    tempmat(end+1,:) = matrixin(cR,:,cT);
                else
                    tempmat(end+1,:) = NaN(1,size(matrixin,2),1);
                end
            end
            outmatrix(cR,:) = nanmean(tempmat);
            outmatrix(cR,isnan(outmatrix(cR,:))) = 0;
        end
    end

    function closefcn(hObject,eventdata,handles)
        [T, EEG] = evalc('pop_syncroartifacts(EEG, ''Direction'', ''eeglab2erplab'')'); %synchronize artifact databases
        delete(hObject);
    end
end








