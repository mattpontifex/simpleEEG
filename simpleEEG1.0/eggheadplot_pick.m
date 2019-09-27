function eggheadplot_pick(ERP, varargin)
%   Plots activity of the specified electrode allowing the user to choose
%   the specified latency to use to create a stylized topographic plot.
%
%    Input parameters are as follows:
%       1    'Channel' - Channel label.
%       2    'Window' - Milliseconds radius from the peak to include in the average [default is 0].
%       3    'Bin' - Bin Number from ERP set [default is 1].
%       4    'Polarity' - ['Positive Up' | 'Positive Down' (default)]
%       5    'Style' - Plot style [ 'None' | 'Outline' | 'Full' (default) ].
%       6    'MapStyle' - Color bar style [ 'hot' | 'cool' | 'autumn' | 'winter' | 'summer' | 'spring' | 'gray' | 'jet' | 'crushparula' (default)]. It will also accept a 3xn matrix of RGB values for custom plots.
%       7    'Method' - Interpolation method ['nearest' | 'linear' | 'cubic' | 'v4' | 'natural' (default)].
%       8    'Scale' - 1x2 matrix [min max]
%       9    'Contours' - Number of contour lines (default is 0).
%       10  'ElectrodeSize' - Electrode marker size (default 5).
%       11  'ElectrodeColor' - Color of electrode markers (default is black).
%       12  'FillColor' - Color of background of the head (default is grey).
%       13  'Knockout' - Range of values to not plot [min max] ex. [-1.9 1.9].
%       14  'TrialColor' - Color of the individul trial waveforms
%       15  'TrialWidth' - Line width of the individul trial waveforms
%       16  'guiSize' - Size of the GUI. Default is [200,200,1600,800] (200 pixels right on screen, 200 pixels up on screen, 1600 pixels wide, 800 pixels tall)
%       17  'guiBackgroundColor' - GUI background color. Default is [0.941,0.941,0.941]
%       18  'guiFontSize' - GUI font size. Default is 8
%       19  'Steps' - Controls how many steps are included in the colormap.  Default is 2048.
%
%   Example Code:
%       
%       eggheadplot_pick(ERP, 'Channel', 'FCZ', 'Window', 0, 'Bin', 1, 'Style', 'Full', 'MapStyle', 'jet', 'Scale', [-10 10], 'Contours', 0, 'ElectrodeSize', 10, 'guiSize', [200,200,1200,800], 'guiFontSize', 8);
%      
%   Author: Matthew B. Pontifex, Health Behaviors and Cognition Laboratory, Michigan State University, August 28, 2014

    handles=struct;    %'Structure which stores all object handles
    if ~isempty(varargin)
          r=struct(varargin{:});
    end
    try, r.Channel; Channel = r(1).Channel; catch, Channel = 'CPZ';  end
    try, r.Bin; Bin = r(1).Bin; catch Bin = 1; end
    try, r.Polarity; Polarity = r(1).Polarity; catch, Polarity = 'Positive Down';  end
    try, r.Window; Window = r(1).Window; catch, Window = 0; end
    try, r.TrialColor; TrialColor = r.TrialColor; catch, TrialColor = [0 0.6 0]; end
    try, r.TrialWidth; TrialWidth = r.TrialWidth; catch, TrialWidth = 0.5; end
    try, r.guiSize; guiSize = r.guiSize; catch, guiSize = [200,200,1600,800]; end
    try, r.guiBackgroundColor; guiBackgroundColor = r.guiBackgroundColor; catch, guiBackgroundColor = [0.941,0.941,0.941]; end
    try, r.guiFontSize; guiFontSize = r(1).guiFontSize; catch, guiFontSize = 8; end
    try, r.Method; handles.interpmethod = r(1).Method; catch, handles.interpmethod = 'natural'; end
    try, r.Scale; [handles.yscale] = r(1).Scale; catch, handles.yscale = [3 8]; end
    try, r.Contours; handles.ncontours = r(1).Contours; catch, handles.ncontours = 0; end
    try, r.ElectrodeColor; handles.markcolor = r(1).ElectrodeColor; catch, handles.markcolor = 'k'; end
    try, r.ElectrodeSize; handles.marksize = r(1).ElectrodeSize; catch, handles.marksize = 8; end
    try, r.FillColor; handles.topbackground = r(1).FillColor; catch, handles.topbackground = [0.686, 0.686, 0.686]; end
    try, r.MapStyle; handles.colormapstyle = r(1).MapStyle; catch, handles.colormapstyle = 'crushparula'; end
    try, r.Knockout; [handles.knockout] = r(1).Knockout; catch, handles.knockout = []; end
    try, r.Style; handles.style = r(1).Style; catch, handles.style = 'Full'; end    
    try, r.Steps; handles.steps = r(1).Steps; catch, handles.steps = 2048; end
    try, r.ShowBrain; handles.ShowBrain = r(1).ShowBrain; catch, handles.ShowBrain = 'No'; end
    try, r.BrainOpacity; handles.BrainOpacity = r(1).BrainOpacity; catch, handles.BrainOpacity = 0.2; end
    try, r.Smooth; handles.smooth = r(1).Smooth; catch, handles.smooth = 0; end
    
    warning('off','all');
    x = ERP.times;
        
    if ismac
        guiFontSize = guiFontSize*1.5;
    end

    handles.lin.width1 = TrialWidth;
    handles.lin.color1 = TrialColor; % Trial
    handles.pl.color = guiBackgroundColor;
    handles.hot.accept = handles.pl.color;
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
    
    % Check to see if the channel exists
    index = erpchannelindex(ERP, Channel);
    if (index == 0)
        error('Error at eggheadplot_pick(). Specified channel does not exist in this set.')
    end
    
    % Create GUI window
    
    handles.fig1 = figure('Name',sprintf('Select Latency Using Channel: %s', Channel),'NumberTitle','off', 'Position',handles.pl.size, 'Color', handles.pl.color, 'MenuBar', 'none', 'KeyPressFcn', @keyPress, 'windowbuttonmotionfcn',{@fh_wbmfcn});
            
    handles.axes = axes(handles.size.label,[0.1,0.1,0.85,0.85],'FontSize', handles.size.fSz);
    handles.plot = plot(x,ERP.bindata(index,:,Bin),'LineWidth',handles.lin.width1,'Color',handles.lin.color1); 
    if (strcmpi(Polarity, 'Positive Down') == 1)
        set(handles.axes,'YDir','reverse','Color','None');    
    end
    box('off'); axis tight;
    xlabel(handles.axes,'Time (ms)');
    ylabel(handles.axes,'Amplitude (microvolts)');
    handles.cursorposAmp = uicontrol('Style', 'text', 'String', 'Amplitude: ', 'Units','normalized', 'Position', [0.55,0,0.2,0.03], 'FontSize', (handles.size.fSz*0.9));
    handles.cursorposLat = uicontrol('Style', 'text', 'String', 'Latency: ', 'Units','normalized', 'Position', [0.75,0,0.2,0.03], 'FontSize', (handles.size.fSz*0.9));
    ylim([-20 30]);
    scale = ylim;
    handles.currentline = line([0 0], [(scale(1)*.8) (scale(2)*.8)], 'LineStyle', '--', 'Color', 'k');
    set(handles.currentline, 'ButtonDownFcn', {@axisHit});
    
    function axisHit(varargin)
        channelvector = {ERP.chanlocs(:).labels};
        channelvector = upper(channelvector);
        temp = get(handles.currentline,'XData');
        temp = temp(1);
        if (Window == 0)
            templabelout = sprintf('%s at %d ms', ERP.erpname, temp);
            amplitudevector = ERP.bindata(:,find(ERP.times == temp),Bin);
        else
            templabname = ERP.erpname;
            if iscell(templabname)
                templabname = cell2mat(templabname);
            end
            templabelout = sprintf('%s from %d to %d ms', templabname,(temp - Window),(temp + Window));
            amplitudevector = mean(ERP.bindata(:,find(ERP.times == (temp-Window)):find(ERP.times == (temp+Window)), Bin)');
        end
        eggheadplot('Channels', channelvector, 'Amplitude', amplitudevector, 'Method', handles.interpmethod, 'Scale', handles.yscale, 'Contours', handles.ncontours, 'MapStyle', handles.colormapstyle, 'Style', handles.style, 'ElectrodeSize', handles.marksize, 'FontSize', handles.size.fSz,'ElectrodeColor', handles.markcolor, 'Steps', handles.steps, 'FillColor', handles.topbackground, 'Knockout', handles.knockout, 'Label', templabelout, 'Smooth', handles.smooth, 'ShowBrain', handles.ShowBrain, 'BrainOpacity', handles.BrainOpacity);
        
        fprintf('\n%%Equivalent command:\nchannelvector = {')
        for cChan = 1:numel(channelvector)
            fprintf('''%s''', channelvector{cChan})
            if (cChan ~= numel(channelvector))
                fprintf('; ')
            end
        end
        fprintf('};\namplitudevector = %s;\n', mat2str(amplitudevector))
        com = sprintf('eggheadplot(''Channels'', channelvector, ''Amplitude'', amplitudevector, ''Method'', ''%s'', ''Scale'', %s, ''Contours'', %d, ''Steps'', %d, ''MapStyle'', ''%s'', ''Style'', ''%s'', ''ElectrodeSize'', %d, ''FontSize'', %d, ''Smooth'', %d, ''ShowBrain'', ''%s'', ''BrainOpacity'', %0.3f, ''Label'', ''%s'');\n', handles.interpmethod, mat2str(handles.yscale), handles.ncontours, handles.steps, handles.colormapstyle, handles.style, handles.marksize, handles.size.fSz, handles.smooth, handles.ShowBrain, handles.BrainOpacity, templabelout);
        disp(com)

        
    end
    
    function fh_wbmfcn(varargin)
        % WindowButtonMotionFcn for the figure.
        S.AXP = get(handles.axes,'Position');
        S.XLM = get(handles.axes,'xlim');
        F = get(handles.fig1,'currentpoint');  % The current point w.r.t the figure.
        handles.pl.size = getpixelposition(handles.fig1);
        % Figure out of the current point is over the axes or not -> logicals.
        S.AXP(1) = (S.AXP(1)*handles.pl.size(3)); S.AXP(2) = (S.AXP(2)*handles.pl.size(4));
        S.AXP(3) = (S.AXP(3)*handles.pl.size(3))+S.AXP(1); S.AXP(4) = (S.AXP(4)*handles.pl.size(4))+S.AXP(2);
        tf1 = S.AXP(1) < F(1) && F(1) < S.AXP(3);
        tf2 = S.AXP(2) < F(2) && F(2) < S.AXP(4);

        if tf1 && tf2
            posaxdiff = ceil(((F(1)-S.AXP(1))/(S.AXP(3)-S.AXP(1)))*(size(ERP.bindata,2))); % Find what point the cursor corresponds to
            if (posaxdiff>0)
                message = sprintf('Latency: %d ms', x(posaxdiff));
                set(handles.cursorposLat, 'String', message);
                message = sprintf('Amplitude: %.2f', ERP.bindata(index,posaxdiff,Bin));
                set(handles.cursorposAmp, 'String', message);
                set(handles.currentline, 'XData', [x(posaxdiff) x(posaxdiff)]);
            end
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
        set(handles.currentline, 'YData', [(scale(1)*.8) (scale(2)*.8)]);
    end
    
end
    