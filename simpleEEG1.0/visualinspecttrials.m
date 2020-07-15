function [EEG] = visualinspecttrials(EEG, varargin)
%   Graphical user interface to allow for visual inspection of the inputted
%   data. Trial data will show up as the Green lines, the average of all
%   accepted trials shows up as the Grey line. To reject a trial click on the
%   axis of the trial. Rejected trials will have a  red background. To accept 
%   a trial click the axis of the trial again.  Arrow Left and Right can be used 
%   to scroll through  the data. Arrow Up and Down scale the amplitude, 
%   holding shift while using the up and down arrow will linearly shift the 
%   axis up or down.
%
%    Input parameters are as follows:
%       1    'Channels' - Channel(s) to evaluate the activity in. Cell array of channels will be averaged across each channel within each trial.
%       2    'Rows' - Number of rows of trials to plot.
%       3    'Columns' - Number of columns of trials to plot.
%       4    'Polarity' - ['Positive Up' | 'Positive Down' (default)]
%       5    'Smooth' - Smothing Enabled [ 'True' | 'False' (default)]
%       6    'Average' - Display average of all accepted trials [ 'True' | 'False' (default)]
%       7    'TrialColor' - Color of the individul trial waveforms
%       8    'TrialWidth' - Line width of the individul trial waveforms
%       9    'AverageColor' - Color of the average waveform
%       10    'AverageWidth' - Line width of the average waveform
%       11    'guiSize' - Size of the GUI (i.e., [200,200,1600,800] - 200 pixels right on screen, 200 pixels up on screen, 1600 pixels wide, 800 pixels tall)
%       12  'guiBackgroundColor' - GUI background color. Default is [0.941,0.941,0.941]
%       13  'guiFontSize' - GUI font size. Default is 8
%       14  'RejectColor' - Color to display for rejected trials. Default is [0.937,0.867,0.867]
%       15  'Scale' - Scaling of plot. Default is [-50 70]
%       16    'XScale' - X axis limits (i.e., [-100 1000]).
%       17    'LearnPos' - Minimum correlation value for use with the learning functions to add trials. Trials with correlations to the mean at or exceeding this value are included. Default is 0.25
%       18    'LearnNeg' - Minimum correlation value for use with the learning functions to reject trials. Trials with correlations to the mean at or below this value are rejected. Default is 0.4
%       19    'Original' - Display average of all previously accepted trials [ 'True' | 'False' (default)]
%
%   Example Code:
%
%       EEG = visualinspecttrials(EEG, 'Channels', {'CZ', 'CPZ', 'PZ'}, 'Rows', 3, 'Columns', 4, 'Average', 'True', 'Smooth', 'True', 'guiSize', [200,200,1600,800], 'guiFontSize', 8);
%    
%   Author: Matthew B. Pontifex, Health Behaviors and Cognition Laboratory, Michigan State University, August 5, 2014

    if ~isempty(varargin)
          r=struct(varargin{:});
    end
    try, r.Channels; temprefch = {r.Channels}; catch, error('Error at visualinspecttrials(). Missing information! Please input Channel Information.'); end
    try, r.Rows; cRows = r.Rows; catch, cRows = 3; end
    try, r.Columns; cColumns = r.Columns; catch, cColumns = 4; end
    try, r.Polarity; Polarity = r.Polarity; catch, Polarity = 'Positive Down';  end
    try, r.Average; Average = r.Average; catch, Average = 'False';  end
    try, r.Smooth; bolSmooth = r.Smooth; catch, bolSmooth = 'False'; end
    try, r.TrialColor; TrialColor = r.TrialColor; catch, TrialColor = [0 0.6 0]; end
    try, r.TrialWidth; TrialWidth = r.TrialWidth; catch, TrialWidth = 1.5; end
    try, r.AverageColor; AverageColor = r.AverageColor; catch, AverageColor = [.8 .8 .8]; end
    try, r.AverageWidth; AverageWidth = r.AverageWidth; catch, AverageWidth = 2; end
    try, r.guiSize; guiSize = r.guiSize; catch, guiSize = []; end
    try, r.guiBackgroundColor; guiBackgroundColor = r.guiBackgroundColor; catch, guiBackgroundColor = [0.941,0.941,0.941]; end
    try, r.RejectColor; RejectColor = r.RejectColor; catch, RejectColor = [0.937,0.867,0.867]; end
    try, r.guiFontSize; guiFontSize = r.guiFontSize; catch, guiFontSize = 8; end
    try, r.Scale; scalsize = r.Scale; catch, scalsize = [-50, 70]; end
    try, r.XScale; XScale = r.XScale; catch, XScale = []; end
    try, r.LearnPos; CorrLearnPos = r.LearnPos; catch, CorrLearnPos = 0.25; end
    try, r.LearnNeg; CorrLearnNeg = r.LearnNeg; catch, CorrLearnNeg = 0.4; end
    try, r.Original; pOriginal = r.Original; catch, pOriginal = 'False'; end
    
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
    
     % Identify what channel indices actually exist within the EEG set
    tempchinc = [];
    for cC = 1:numel(temprefch)
        for m=1:size(EEG.chanlocs, 2)
            tempval = EEG.chanlocs(m).('labels');
            if (strcmp(tempval,temprefch(cC)) > 0)
                tempchinc(end+1) = m;
                break;
            end
        end
    end
    if (numel(tempchinc) == 0)
        error('Error at visualinspecttrials(). Channels do not exist in this EEG set.');
    end
    
    % Collapse channels to create 2d matrix with each trial as a row and
    % data point as a column.
    inMat = zeros(size(EEG.data,3),size(EEG.data,2));
    for cT = 1:size(EEG.data,3)
        tempmat = zeros(numel(tempchinc),size(EEG.data,2));
        for cC = 1:numel(tempchinc)
            tempmat(cC,:) = EEG.data(tempchinc(cC),:,cT);
        end
        if (numel(tempchinc) > 1)
            inMat(cT,:) = nanmean(tempmat);
        else
            inMat(cT,:) = tempmat;
        end
    end
    
    if (strcmpi(bolSmooth, 'True'))
        for cC = 1:size(inMat,1)
            inMat(cC,:) = fastsmooth(inMat(cC,:),9,3,1);
        end
    elseif (strcmpi(bolSmooth, 'Max'))
        for cC = 1:size(inMat,1)
            inMat(cC,:) = fastsmooth(inMat(cC,:),25,3,1);
        end
    elseif (isnumeric(bolSmooth))
        for cC = 1:size(inMat,1)
            inMat(cC,:) = fastsmooth(inMat(cC,:),bolSmooth,3,1);
        end
    end
    
    if ~isempty(XScale)
        [Ytemp, Imin] = min(abs(EEG.times-XScale(1)));
        [Ytemp, Imax] = min(abs(EEG.times-XScale(2)));
        inMat = inMat(:,Imin:Imax);
        x = x(Imin:Imax);
    end
    
    inMat_Mean = subsetmean(inMat, EEG.reject.rejmanual);
    pOriginal_Mean = inMat_Mean;
    
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
    handles.size.xceilpadding = 5;
    handles.size.ypadding = 30;
    handles.size.yceilpadding = 5;
    handles.size.xshift = 50;
    handles.size.yshift = 90;
    handles.size.label = 'Position'; %'OuterPosition'
    handles.size.xchannel = 30;
    handles.size.ychannel = 15;
    handles.size.fSz = guiFontSize;
    currenttrial = 1;
    
    % Create GUI window
    handles.fig1 = figure('Name','Visual Inspection','NumberTitle','off', 'Position',handles.pl.size, 'Color', handles.pl.color, 'MenuBar', 'none', 'KeyPressFcn', @keyPress);

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
    
    % Populate Grid
    celCount = 0;
    axeslist = [];
    rspace = handles.size.yshiftScaled + (handles.size.ysizeScaled*(cRows-1)) + (handles.size.ypaddingScaled*(cRows-1));
    for cR = 1:cRows
        cspace = handles.size.xshiftScaled;
        for cC = 1:cColumns
            if ((currenttrial+celCount) <= size(inMat,1))
                handles.(sprintf('r%dc%d',cR,cC)).axes = axes(handles.size.label,[cspace,rspace,handles.size.xsizeScaled,handles.size.ysizeScaled],'FontSize', handles.size.fSz);
                handles.(sprintf('r%dc%d',cR,cC)).plot = plot(x,inMat((currenttrial+celCount),:),'LineWidth',handles.lin.width1,'Color',handles.lin.color1);  
                if (strcmpi(Average, 'True') == 1)
                   handles.(sprintf('r%dc%d',cR,cC)).line = line(x,inMat_Mean,'LineWidth',handles.lin.width2, 'Color',handles.lin.color2);
                   uistack(handles.(sprintf('r%dc%d',cR,cC)).line, 'down', 1);
                end
                if (strcmpi(pOriginal, 'True') == 1)
                   handles.(sprintf('Porigr%dc%d',cR,cC)).line = line(x,pOriginal_Mean,'LineWidth',5, 'Color',[.7 .7 .7 .3]);
                   uistack(handles.(sprintf('Porigr%dc%d',cR,cC)).line, 'down', 1);
                end
                box('off'); axis tight;
                set(handles.(sprintf('r%dc%d',cR,cC)).axes,'Color','None'); 
                axeslist(end+1) = handles.(sprintf('r%dc%d',cR,cC)).axes;
                if (strcmpi(Polarity, 'Positive Down') == 1)
                    set(handles.(sprintf('r%dc%d',cR,cC)).axes,'YDir','reverse');    
                end
                if (cC ~= 1)
                    set(handles.(sprintf('r%dc%d',cR,cC)).axes,'YTickLabel',''); 
                else
                    ylabel(handles.(sprintf('r%dc%d',cR,cC)).axes,'Microvolts'); 
                end
                if (cR ~= cRows)
                    set(handles.(sprintf('r%dc%d',cR,cC)).axes,'XTickLabel',''); 
                else
                    xlabel(handles.(sprintf('r%dc%d',cR,cC)).axes,'Time (ms)'); 
                end
            end
            celCount = celCount + 1;
            cspace = cspace + handles.size.xsizeScaled + handles.size.xpaddingScaled;
        end
        rspace = rspace - (handles.size.ysizeScaled + handles.size.ypaddingScaled);
    end
    linkaxes(axeslist, 'y');
    ylim(scalsize);
    
    % Populate Labels
    celCount = 0;
    rspace = handles.size.yshiftScaled + (handles.size.ysizeScaled*(cRows-1)) + (handles.size.ypaddingScaled*(cRows-1))+(0.81*(handles.size.ysizeScaled + handles.size.ypaddingScaled));
    for cR = 1:cRows
        cspace = handles.size.xshiftScaled + (1/handles.pl.size(3));
        for cC = 1:cColumns
            if ((currenttrial+celCount) <= size(inMat,1))
                handles.(sprintf('r%dc%d',cR,cC)).tN = uicontrol('Style', 'text', 'String', num2str(currenttrial+celCount), 'Units','normalized', 'Position', [cspace,rspace,handles.size.xchannelScaled,handles.size.ychannelScaled], 'FontSize', handles.size.fSz);
            end
            celCount = celCount + 1;
            cspace = cspace + handles.size.xsizeScaled + handles.size.xpaddingScaled;
        end
        rspace = rspace - (handles.size.ysizeScaled + handles.size.ypaddingScaled);
    end
                
    handles.trialtext = uicontrol('Style', 'text', 'String', 'Trial X of X', 'Units','normalized', 'Position', [0.3,0.01,(handles.size.xchannelScaled*7),(handles.size.ychannelScaled*1.5)], 'FontSize', (handles.size.fSz*1.2));
    handles.trialnumtext = uicontrol('Style', 'text', 'String', 'X Trials Accepted', 'Units','normalized', 'Position', [0.6,0.01,(handles.size.xchannelScaled*7),(handles.size.ychannelScaled*1.5)], 'FontSize', (handles.size.fSz*1.2));
    handles.pbNext = uicontrol('Style','pushbutton','String','Next Trial','Units','normalized','Position',[0.8,0.01,(handles.size.xchannelScaled*5),(handles.size.ychannelScaled*2)],'Callback',{@nextbuttonCallback});
    handles.pbPrevious = uicontrol('Style','pushbutton','String','Previous Trial','Units','normalized','Position',[0.1,0.01,(handles.size.xchannelScaled*5),(handles.size.ychannelScaled*2)],'Callback',{@prevbuttonCallback});
   
    handles.pbRejectall = uicontrol('Style','pushbutton','String','Reject All','Units','normalized','Position',[0.73,0.01,(handles.size.xchannelScaled*3),(handles.size.ychannelScaled*2)],'Callback',{@rejectallbuttonCallback});
    handles.pbAcceptall = uicontrol('Style','pushbutton','String','Accept All','Units','normalized','Position',[0.2,0.01,(handles.size.xchannelScaled*3),(handles.size.ychannelScaled*2)],'Callback',{@acceptallbuttonCallback});
    handles.pbLearnpos = uicontrol('Style','pushbutton','String','Learn+','Units','normalized','Position',[0.43,0.01,(handles.size.xchannelScaled*2.5),(handles.size.ychannelScaled*2)],'Callback',{@learnposbuttonCallback});
    handles.pbLearnallpos = uicontrol('Style','pushbutton','String','Learn+ All','Units','normalized','Position',[0.48,0.01,(handles.size.xchannelScaled*3),(handles.size.ychannelScaled*2)],'Callback',{@learnposallbuttonCallback});
    handles.pbLearnneg = uicontrol('Style','pushbutton','String','Learn-','Units','normalized','Position',[0.55,0.01,(handles.size.xchannelScaled*2.5),(handles.size.ychannelScaled*2)],'Callback',{@learnnegbuttonCallback});
    
    
    changeplot;
    uiwait(handles.fig1);
    [T, EEG] = evalc('pop_syncroartifacts(EEG, ''Direction'', ''eeglab2erplab'')'); %synchronize artifact databases
    
    function changeplot
        % Update text
            fintrial = currenttrial+(cRows*cColumns)-1;
            if (fintrial > size(inMat,1))
                fintrial = size(inMat,1);
            end
            message = sprintf('Trials %d to %d of %d', currenttrial, fintrial, size(inMat,1));
            set(handles.trialtext, 'String', message);
            message = sprintf('%d Trials Accepted', nnz(~(EEG.reject.rejmanual)));
            set(handles.trialnumtext, 'String', message);
        % Enable/Disable Buttons
            if (currenttrial <= 1)
                set(handles.pbPrevious, 'enable', 'off');
            else
                set(handles.pbPrevious, 'enable', 'on');
            end
            if (currenttrial+(cRows*cColumns)-1 >= size(inMat,1))
                set(handles.pbNext, 'enable', 'off');
            else
                set(handles.pbNext, 'enable', 'on');
            end
            if (strcmpi(Average, 'True') == 1)
                inMat_Mean = subsetmean(inMat, EEG.reject.rejmanual);
            end
         % Determine plot color
           celCount = 0;
            for cR = 1:cRows
                for cC = 1:cColumns
                    if ((currenttrial+celCount) <= size(inMat,1))
                        if (EEG.reject.rejmanual(currenttrial+celCount) == 0)
                            set(handles.(sprintf('r%dc%d',cR,cC)).axes, 'Color',handles.hot.accept);
                            set(handles.(sprintf('r%dc%d',cR,cC)).tN, 'BackgroundColor',handles.hot.accept);
                        else
                            set(handles.(sprintf('r%dc%d',cR,cC)).axes, 'Color',handles.hot.reject);
                            set(handles.(sprintf('r%dc%d',cR,cC)).tN, 'BackgroundColor',handles.hot.reject);
                        end
                        set(handles.(sprintf('r%dc%d',cR,cC)).tN, 'String', num2str(currenttrial+celCount));
                        set(handles.(sprintf('r%dc%d',cR,cC)).plot, 'YData', inMat((currenttrial+celCount),:));
                        set(handles.(sprintf('r%dc%d',cR,cC)).axes, 'ButtonDownFcn', {@axisPress, (currenttrial+celCount)});
                        if (strcmpi(Average, 'True') == 1)
                             set(handles.(sprintf('r%dc%d',cR,cC)).line, 'YData', inMat_Mean);
                        end
                    end
                    celCount = celCount + 1;
                end
            end
    end
    function nextbuttonCallback(hObject,eventdata,handles)
        currenttrial = currenttrial + 1;
        changeplot
    end
    function prevbuttonCallback(hObject,eventdata,handles)
        currenttrial = currenttrial - 1;
        changeplot
    end
    function rejectallbuttonCallback(hObject,eventdata,handles)
        EEG.reject.rejmanual = ones(size(EEG.reject.rejmanual));
        changeplot
    end
    function acceptallbuttonCallback(hObject,eventdata,handles)
        EEG.reject.rejmanual = zeros(size(EEG.reject.rejmanual));
        changeplot
    end


    function learnposbuttonCallback(hObject,eventdata,handles)
        
        % obtain average of currently accepted trials
        inMat_Mean = subsetmean(inMat, EEG.reject.rejmanual);
        
        % obtain correlation between average and each trial currently being
        % displayed
        fintrial = currenttrial+(cRows*cColumns)-1;
        if (fintrial > size(inMat,1))
            fintrial = size(inMat,1);
        end
        cormatrix = NaN(size(EEG.reject.rejmanual));
        corPmatrix = NaN(size(EEG.reject.rejmanual));
        for cR = currenttrial:fintrial
            try
                [Rval, Pval] = corrcoef([inMat_Mean; inMat(cR,:)]'); % Compute correlation
                cormatrix(1,cR) = Rval(2,1); % Extract correlation
                corPmatrix(1,cR) = Pval(2,1); % Extract p value
            catch
               boolerr = 1; 
            end
        end
        if ~isempty(find(cormatrix >= CorrLearnPos))
            EEG.reject.rejmanual(find(cormatrix >= CorrLearnPos)) = 0;
        end
        changeplot
        
    end
    function learnposallbuttonCallback(hObject,eventdata,handles)
        
        % obtain average of currently accepted trials
        inMat_Mean = subsetmean(inMat, EEG.reject.rejmanual);
        
        % obtain correlation between average and each trial
        cormatrix = NaN(size(EEG.reject.rejmanual));
        corPmatrix = NaN(size(EEG.reject.rejmanual));
        for cR = 1:size(inMat,1)
            try
                [Rval, Pval] = corrcoef([inMat_Mean; inMat(cR,:)]'); % Compute correlation
                cormatrix(1,cR) = Rval(2,1); % Extract correlation
                corPmatrix(1,cR) = Pval(2,1); % Extract p value
            catch
                boolerr = 1;
            end
        end
        if ~isempty(find(cormatrix >= CorrLearnPos))
            EEG.reject.rejmanual(find(cormatrix >= CorrLearnPos)) = 0;
        end
        changeplot
        
    end
    function learnnegbuttonCallback(hObject,eventdata,handles)
        
        % obtain average of currently accepted trials
        inMat_Mean = subsetmean(inMat, EEG.reject.rejmanual);
        
        % obtain correlation between average and each trial currently being
        % displayed
        fintrial = currenttrial+(cRows*cColumns)-1;
        if (fintrial > size(inMat,1))
            fintrial = size(inMat,1);
        end
        cormatrix = NaN(size(EEG.reject.rejmanual));
        corPmatrix = NaN(size(EEG.reject.rejmanual));
        for cR = currenttrial:fintrial
            try
                [Rval, Pval] = corrcoef([inMat_Mean; inMat(cR,:)]'); % Compute correlation
                cormatrix(1,cR) = Rval(2,1); % Extract correlation
                corPmatrix(1,cR) = Pval(2,1); % Extract p value
            catch
                boolerr = 1;
            end
        end
        if ~isempty(find(cormatrix <= CorrLearnNeg))
            EEG.reject.rejmanual(find(cormatrix <= CorrLearnNeg)) = 1;
        end
        changeplot
        
    end

    function axisPress(hObject,eventdata,handles)
        if (EEG.reject.rejmanual(handles) == 0)
            EEG.reject.rejmanual(handles) = 1;
        else
            EEG.reject.rejmanual(handles) = 0;
        end
        changeplot;
    end
    function keyPress(src, e)
        scale = ylim;
        numlocs = (cRows * cColumns);
        switch e.Key
             case 'leftarrow'
                if strcmp(e.Modifier, 'shift')
                    if (currenttrial > 1)
                        currenttrial = currenttrial - 1;
                    end
                else
                    if (currenttrial-numlocs > 1)
                        currenttrial = currenttrial - numlocs;
                    else
                        currenttrial = 1;
                    end
                end
                changeplot;
             case 'rightarrow'
                if strcmp(e.Modifier, 'shift')
                    if (currenttrial+numlocs-1 < (size(inMat,1)))
                        currenttrial = currenttrial + 1;
                    end
                else
                    if (currenttrial+numlocs-1+numlocs < (size(inMat,1)))
                        currenttrial = currenttrial + numlocs;
                    else
                        currenttrial = size(inMat,1)-numlocs+1;
                    end
                end
                changeplot;
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
    function [outmatrix] = subsetmean(inMat, acceptvector)
        outmatrix = nanmean(inMat(~logical(acceptvector),:),1);
        outmatrix(isnan(outmatrix)) = 0;
    end
    function closefcn(hObject,eventdata,handles)
        delete(hObject);
    end
end



