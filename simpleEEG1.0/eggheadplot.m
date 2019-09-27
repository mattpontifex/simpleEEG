function eggheadplot(varargin)
%   Stylized topographic plot using 10-10 label matching for location positioning.
%
%    Input parameters are as follows:
%       1    'Channels' - Channel labels.
%       2    'Amplitude' - Data values for each channel.
%       3    'Method' - Interpolation method ['nearest' | 'linear' | 'cubic' | 'v4' | 'natural' (default)].
%       4    'Scale' - 1x2 matrix [min max]
%       5    'Contours' - Number of contour lines (default is 0).
%       6    'ElectrodeColor' - Color of electrode markers (default is black).
%       7    'FillColor' - Color of background of the head (default is grey - [0.4117, 0.4117, 0.4117]).
%       8    'FontSize' - GUI font size. Default is 8
%       9    'MapStyle' - Color bar style [ 'haxby' | 'fireice' | 'bipolar' | 'hot' | 'cool' | 'autumn' | 'winter' | 'summer' | 'spring' | 'gray' | 'hotiso' | 'coldiso' | 'kuler' | 'greenstain' | 'jet' | 'crushparula'  (default)]. 
%       10  'Knockout' - Range of values to not plot [min max] ex. [-1.9 1.9].
%       11  'Style' - Plot style [ 'None' | 'Outline' | 'Full' (default) ].
%       12  'ElectrodeSize' - Electrode marker size (default 5).
%       13  'Label' - Text label for the figure plot window. Default is empty.
%       14  'Steps' - Controls how many steps are included in the colormap.  Default is 2048.
%       15  'Smooth' - Controls how many points are included for spatial smoothing. Default is 30.
%       16  'ShowElectrodes' - [ 'No' | 'Yes' (default) ].
%       17  'ShowBrain' - [ 'Yes' | 'No' (default)].
%       18  'BrainOpacity' - Controls how visible the brain appears with 0 being transparent and 1 being solid. Default is 0.2.
%      
%      
%   Example Code:
%       
%       % Plot amplitude at particular latency
%       
%           channelvector = {ERP.chanlocs(:).labels};
%           amplitudevector = ERP.bindata(:,find(ERP.times == 350),1);
%           eggheadplot('Channels', channelvector, 'Amplitude', amplitudevector, 'Method', 'natural', 'Scale', [2 8], 'Contours', 0, 'MapStyle', 'jet', 'Style', 'Full', 'ElectrodeSize', 10, 'FontSize', 10, 'Label', ERP.erpname);
%      
%       % Plot mean amplitude within a specified time window 
%       
%           channelvector = {ERP.chanlocs(:).labels};
%           amplitudevector = mean(ERP.bindata(:,find(ERP.times == 300):find(ERP.times == 400), 1)');
%           eggheadplot('Channels', channelvector, 'Amplitude', amplitudevector, 'Method', 'natural', 'Scale', [2 8], 'Contours', 0, 'MapStyle', 'jet', 'Style', 'Full', 'ElectrodeSize', 10, 'FontSize', 10, 'Label', ERP.erpname);
%
%       % Plot an array of amplitudes
%
%           channelvector = {'FP1';'FPZ';'FP2';'AF7';'AF3';'AFZ';'AF4';'AF8';'F7';'F5';'F3';'F1';'FZ';'F2';'F4';'F6';'F8';'FT7';'FC5';'FC3';'FC1';'FCZ';'FC2';'FC4';'FC6';'FT8';'T7';'C5';'C3';'C1';'CZ';'C2';'C4';'C6';'T8';'CCPZ';'TP7';'CP5';'CP3';'CP1';'CPZ';'CP2';'CP4';'CP6';'TP8';'P7';'P5';'P3';'P1';'PZ';'P2';'P4';'P6';'P8';'PO7';'PO5';'PO3';'POZ';'PO4';'PO6';'PO8';'O1';'OZ';'O2'};
%           amplitudevector = [1;2;1;1;1;2;1;1;1;1;1;2;3;2;1;1;1;1;1;2;3;4;3;2;1;1;1;1;2;3;4;3;2;1;1;5;1;1;2;4;6;4;2;1;1;1;1;3;5;8;5;3;1;1;1;1;2;3;2;1;1;1;1;1];
%           eggheadplot('Channels', channelvector, 'Amplitude', amplitudevector, 'Method', 'natural', 'Scale', [0 5], 'Contours', 0, 'Steps', 1024, 'MapStyle', 'jet', 'Style', 'Full', 'ElectrodeSize', 10, 'FontSize', 10, 'Smooth', 50, 'ShowBrain', 'Yes', 'BrainOpacity', 0.2);
%
%       % Plot an array of t-scores
%
%           channelvector = {'FP1';'FPZ';'FP2';'AF7';'AF3';'AFZ';'AF4';'AF8';'F7';'F5';'F3';'F1';'FZ';'F2';'F4';'F6';'F8';'FT7';'FC5';'FC3';'FC1';'FCZ';'FC2';'FC4';'FC6';'FT8';'T7';'C5';'C3';'C1';'CZ';'C2';'C4';'C6';'T8';'CCPZ';'TP7';'CP5';'CP3';'CP1';'CPZ';'CP2';'CP4';'CP6';'TP8';'P7';'P5';'P3';'P1';'PZ';'P2';'P4';'P6';'P8';'PO7';'PO5';'PO3';'POZ';'PO4';'PO6';'PO8';'O1';'OZ';'O2'};
%           amplitudevector = [-0.775000000000000;-0.992000000000000;-0.500000000000000;-0.351000000000000;-0.445000000000000;-0.806000000000000;-0.445000000000000;-0.271000000000000;0.0770000000000000;-0.351000000000000;-0.445000000000000;-0.806000000000000;-0.992000000000000;-0.775000000000000;-0.500000000000000;-0.271000000000000;0.102000000000000;0.667000000000000;1.16000000000000;1.33000000000000;1.42900000000000;1.45300000000000;1.39600000000000;1.31600000000000;1.09300000000000;0.566000000000000;0.796000000000000;0.847000000000000;2.08300000000000;2.14500000000000;2.15700000000000;2.10100000000000;2.05100000000000;0.849000000000000;0.743000000000000;2.90000000000000;0.503000000000000;2.39000000000000;2.94900000000000;3.40300000000000;3.64400000000000;3.34800000000000;2.95500000000000;2.27300000000000;0.438000000000000;0.405000000000000;2.63400000000000;2.87000000000000;3.51800000000000;4.34300000000000;3.11500000000000;2.84600000000000;2.43100000000000;0.863000000000000;0.903000000000000;2.79600000000000;3.10000000000000;3.81200000000000;2.99200000000000;2.74100000000000;0.231000000000000;2.03700000000000;2.19300000000000;1.76100000000000];
%           eggheadplot('Channels', channelvector, 'Amplitude', amplitudevector, 'Method', 'natural', 'Scale', [1.5 3.5], 'Contours', 0, 'Steps', 1024, 'MapStyle', 'hotiso', 'Style', 'Full', 'ElectrodeSize', 10, 'FontSize', 10, 'Smooth', 50, 'ShowBrain', 'Yes', 'BrainOpacity', 0.2, 'Knockout', [-1.9 1.9]);
%            
%   Author: Matthew B. Pontifex, Health Behaviors and Cognition Laboratory, Michigan State University, August 27, 2014

    bolerror = 0;
    handles=struct;    %'Structure which stores all object handles
    if ~isempty(varargin)
          r=struct(varargin{:});
    end
    try, r.Channels; inchans = upper({r.Channels}); catch, bolerror = 1; end
    try, r.Amplitude; indat = r.Amplitude; catch, bolerror = 1; end
    try, r.Method; handles.interpmethod = r(1).Method; catch, handles.interpmethod = 'natural'; end
    try, r.Scale; [handles.yscale] = r(1).Scale; catch, handles.yscale = [-10 10]; end
    try, r.Contours; handles.ncontours = r(1).Contours; catch, handles.ncontours = 0; end
    try, r.ElectrodeColor; handles.markcolor = r(1).ElectrodeColor; catch, handles.markcolor = 'k'; end
    try, r.ElectrodeSize; handles.marksize = r(1).ElectrodeSize; catch, handles.marksize = 10; end
    try, r.FillColor; handles.topbackground = r(1).FillColor; catch, handles.topbackground = [0.4117, 0.4117, 0.4117]; end
    try, r.FontSize; handles.fontsize = r(1).FontSize; catch, handles.fontsize = 10; end
    try, r.MapStyle; handles.colormapstyle = r(1).MapStyle; catch, handles.colormapstyle = 'crushparula'; end
    try, r.Knockout; [handles.knockout] = r(1).Knockout; catch, handles.knockout = []; end
    try, r.Style; handles.style = r(1).Style; catch, handles.style = 'Full'; end
    try, r.Label; handles.label = r(1).Label; catch, handles.label = ''; end
    try, r.Steps; handles.steps = r(1).Steps; catch, handles.steps = 2048; end
    try, r.Smooth; handles.smooth = r(1).Smooth; catch, handles.smooth = 30; end
    try, r.ShowElectrodes; handles.ShowElectrodes = r(1).ShowElectrodes; catch, handles.ShowElectrodes = 'Yes'; end
    try, r.ShowBrain; handles.ShowBrain = r(1).ShowBrain; catch, handles.ShowBrain = 'No'; end
    try, r.BrainOpacity; handles.BrainOpacity = r(1).BrainOpacity; catch, handles.BrainOpacity = 0.2; end
    try, r.Plump; handles.Plump = r(1).Plump; catch, handles.Plump = 0; end
   
    warning('off','all');
    if (bolerror == 1)
        pop_eggheadplot
    else
        
    if ismac
        handles.fontsize = handles.fontsize*1.5;
    end
        
    %     handles.d = dbstack('-completenames');
    %     handles.d
    %     pwd
    %     handles.d = strsplit(handles.d.file, 'eggheadplot.m');
    %     handles.d = handles.d(1);
    
        handles.chanlabs = {'FP1';'FPZ';'FP2';'AFP5';'AFP3';'AFP1';'AFP2';'AFP4';'AFP6';'AF7';'AF7h';'AF5';'AF5h';'AF3';'AF1';'AF1h';'AFZ';'AF2h';'AF2';'AF4';'AF6h';'AF6';'AF8h';'AF8';'AFF7';'AFF7h';'AFF5';'AFF5h';'AFF3';'AFF3h';'AFF1h';'AFF2h';'AFF4h';'AFF4';'AFF6h';'AFF6';'AFF8h';'AFF8';'F7';'F7h';'F5';'F5h';'F3';'F3h';'F1';'F1h';'FZ';'F2h';'F2';'F4h';'F4';'F6h';'F6';'F8h';'F8';'FFT7';'FFT7h';'FFC5';'FFC5h';'FFC3';'FFC3h';'FFC1';'FFC1h';'FFCZ';'FFC2h';'FFC2';'FFC4h';'FFC4';'FFC6h';'FFC6';'FFT8h';'FFT8';'FT7';'FT7h';'FC5';'FC5h';'FC3';'FC3h';'FC1';'FC1h';'FCZ';'FC2h';'FC2';'FC4h';'FC4';'FC6h';'FC6';'FT8h';'FT8';'FTT7';'FTT7h';'FCC5';'FCC5h';'FCC3';'FCC3h';'FCC1';'FCC1h';'FCCZ';'FCC2h';'FCC2';'FCC4h';'FCC4';'FCC6h';'FCC6';'FTT8h';'FTT8';'T7';'T7h';'C5';'C5h';'C3';'C3h';'C1';'C1h';'CZ';'C2h';'C2';'C4h';'C4';'C6h';'C6';'T8h';'T8';'TTP7';'TTP7h';'CCP5';'CCP5h';'CCP3';'CCP3h';'CCP1';'CCP1h';'CCPZ';'CCP2h';'CCP2';'CCP4h';'CCP4';'CCP6h';'CCP6';'TTP8h';'TTP8';'TP7';'TP7h';'CP5';'CP5h';'CP3';'CP3h';'CP1';'CP1h';'CPZ';'CP2h';'CP2';'CP4h';'CP4';'CP6h';'CP6';'TP8h';'TP8';'TPP7';'TPP7h';'CPP5';'CPP5h';'CPP3';'CPP3h';'CPP1';'CPP1h';'CPPZ';'CPP2h';'CPP2';'CPP4h';'CPP4';'CPP6h';'CPP6';'TPP8h';'TPP8';'P7';'P7h';'P5';'P5h';'P3';'P3h';'P1';'P1h';'PZ';'P2h';'P2';'P4h';'P4';'P6h';'P6';'P8h';'P8';'PPO7';'PPO7h';'PPO5';'PPO5h';'PPO3';'PPO3h';'PPO1';'PPO1h';'PPOZ';'PPO2h';'PPO2';'PPO4h';'PPO4';'PPO6h';'PPO6';'PPO8h';'PPO8';'PO7';'PO7h';'PO5';'PO5h';'PO3';'PO3h';'PO1';'POZ';'PO2';'PO4h';'PO4';'PO6h';'PO6';'PO8h';'PO8';'POO5';'POO3';'POO1';'POOZ';'POO2';'POO4';'POO6';'O1';'O1h';'OZ';'O2h';'O2';'MiPf';'MiCe';'MiPa';'MiOc';'LLPf';'LLFr';'LLTe';'LLOc';'RLPf';'RLFr';'RLTe';'RLOc';'LMPf';'LDFr';'LDCe';'LDPa';'LMOc';'RMPf';'RDFr';'RDCe';'RDPa';'RMOc';'LMFr';'LMCe';'RMFr';'RMCe'};
        handles.tempxvect = [-79;-3;73;-148;-97;-42;36;91;142;-216;-182;-148;-113;-79;-57;-34;-3;28;51;73;107;142;176;210;-235;-209;-184;-150;-113;-79;-36;30;73;107;144;178;203;229;-254;-235;-216;-187;-155;-116;-79;-37;-3;31;73;110;149;182;210;230;248;-282;-256;-229;-198;-164;-126;-85;-44;-3;38;79;120;158;193;223;250;276;-309;-278;-245;-211;-178;-134;-91;-47;-3;41;86;128;172;205;238;272;303;-331;-295;-260;-224;-185;-142;-96;-49;-3;44;90;136;179;218;255;289;325;-349;-315;-278;-238;-198;-147;-100;-51;-3;45;94;141;192;233;272;309;343;-352;-315;-280;-243;-199;-149;-100;-52;-3;46;94;143;193;236;274;309;347;-341;-311;-280;-238;-198;-148;-100;-50;-3;44;94;142;192;232;275;305;335;-309;-277;-248;-214;-175;-134;-90;-47;-3;41;84;128;170;208;242;271;303;-258;-238;-219;-189;-157;-125;-80;-42;-3;36;74;119;151;183;213;233;252;-215;-197;-176;-148;-115;-79;-54;-28;-3;22;48;73;110;142;170;191;209;-172;-156;-141;-109;-77;-41;-22;-3;16;35;71;103;135;150;166;-125;-93;-41;-3;35;87;119;-79;-41;-3;35;73;-3;-3;-3;-3;-196;-300;-341;-215;190;294;335;209;-79;-198;-238;-214;-91;73;193;233;208;86;-91;-149;86;143];
        handles.tempyvect = [398;402;398;387;372;370;370;372;387;359;346;343;341;337;337;337;337;337;337;337;341;343;346;359;332;324;317;313;311;308;308;308;308;311;313;317;324;332;305;296;291;286;282;279;276;274;273;274;276;279;282;286;291;296;305;252;239;228;219;213;209;205;200;199;200;205;209;213;219;228;239;252;199;176;162;150;143;137;134;129;126;129;134;137;143;150;162;176;199;114;99;86;77;70;64;60;56;52;56;60;64;70;77;86;99;114;28;13;6;1;-5;-10;-16;-18;-21;-18;-16;-10;-5;1;6;13;28;-62;-65;-67;-69;-71;-72;-74;-75;-75;-75;-74;-72;-71;-69;-67;-65;-62;-151;-147;-141;-137;-136;-133;-132;-130;-129;-130;-132;-133;-136;-137;-141;-147;-151;-220;-210;-204;-200;-195;-191;-188;-185;-183;-185;-188;-191;-195;-200;-204;-210;-220;-289;-274;-266;-260;-255;-248;-243;-239;-237;-239;-243;-248;-255;-260;-266;-274;-289;-328;-318;-309;-304;-299;-295;-293;-291;-289;-291;-293;-295;-299;-304;-309;-318;-328;-367;-356;-350;-345;-344;-342;-342;-341;-342;-342;-344;-345;-350;-356;-367;-384;-371;-369;-369;-369;-371;-384;-393;-395;-397;-395;-393;402;-21;-183;-397;345;176;-151;-328;345;176;-151;-328;308;219;1;-200;-293;308;219;1;-200;-293;134;-72;134;-72];
        
        % Populate z values based on those channels which were inputted
        %Check to see if the input channel exists in the handles.chanlabs
        handles.chanvect = {};
        handles.zvect = [];
        handles.xvect = [];
        handles.yvect = [];
        for cR = 1:size(inchans,2)
            index = find(strcmp(handles.chanlabs, inchans(cR)));
            if (~isempty(index))
                handles.chanvect(end+1) = inchans(cR);
                handles.zvect(end+1) = indat(cR);
                handles.xvect(end+1) = handles.tempxvect(index);
                handles.yvect(end+1) = handles.tempyvect(index);
            end
        end
        handles.origchanxvect = handles.xvect; handles.origchanyvect = handles.yvect; % Store original positions

        handles.expand = 0.05;
        % Adjust rostral sensors vertically
        temparray = {'AFP5','FP1','FP1h','FPZ','FP2h','FP2','AFP6','AF7','AFF7','F7','FFT7','AF8','AFF8','F8','FFT8','AF7','AFF7','F7','FFT7','AF8','AFF8','F8','FFT8','MiPf','LLPf','RLPf'};
        for chann = temparray
            index = find(strcmpi(handles.chanvect, chann));
            if ~(isempty(index))
                handles.yvect(index) = handles.yvect(index)+(handles.yvect(index)*handles.expand);
            end
        end
        handles.expand = 0.004;
        % Adjust caudal sensors vertically
        temparray = {'POO5','O1','O1h','OZ','O2h','O2','POO6','TPP7','P7','PPO7','PO7','TPP8','P8','PPO8','PO8','MiOc'};
        for chann = temparray
            index = find(strcmpi(handles.chanvect, chann));
            if ~(isempty(index))
                handles.yvect(index) = handles.yvect(index)+(handles.yvect(index)*handles.expand);
            end
        end
        handles.expand = 0.065;
        % Adjust caudal sensors vertically
        temparray = {'LLOc','RLOc'};
        for chann = temparray
            index = find(strcmpi(handles.chanvect, chann));
            if ~(isempty(index))
                handles.yvect(index) = handles.yvect(index)+(handles.yvect(index)*handles.expand);
            end
        end
        handles.expand = 0.05;
        % Adjust lateral sensors horizontally
        temparray = {'AFP5','AFP6','AF7','AFF7','F7','FFT7','AF8','AFF8','F8','FFT8','POO5','POO6','TPP7','P7','PPO7','PO7','TPP8','P8','PPO8','PO8','FT7','FTT7','T7','TTP7','TP7','FT8','FTT8','T8','TTP8','TP8','LLPf','RLPf','LLFr','RLFr','LLTe','RLTe','LLOc','RLOc'};
        for chann = temparray
            index = find(strcmpi(handles.chanvect, chann));
            if ~(isempty(index))
                handles.xvect(index) = handles.xvect(index)+(handles.xvect(index)*handles.expand);
            end
        end
        
        if strcmpi(handles.Plump, 'True')
            handles.expand = 0.065;
            % Adjust vertically
            temparray = {'PO5', 'PO6'};
            for chann = temparray
                index = find(strcmpi(handles.chanvect, chann));
                if ~(isempty(index))
                    handles.yvect(index) = handles.yvect(index)+(handles.yvect(index)*handles.expand);
                end
            end
            
            handles.expand = 0.065;
            % Adjust vertically
            temparray = {'F7', 'F5', 'F3', 'FZ', 'F4', 'F6', 'F8'};
            for chann = temparray
                index = find(strcmpi(handles.chanvect, chann));
                if ~(isempty(index))
                    handles.yvect(index) = handles.yvect(index)+(handles.yvect(index)*handles.expand);
                end
            end
        end

        handles.xi = min(handles.xvect):1:max(handles.xvect); % xaxis: -352:1:357
        handles.yi = min(handles.yvect):1:max(handles.yvect); % yaxis: -397:1:402
        [handles.Xi,handles.Yi,handles.Zi] = griddata(handles.xvect,handles.yvect,handles.zvect,handles.xi,handles.yi',handles.interpmethod); % interpolate data
        if (handles.smooth > 0)
            handles.Zi = smooth2a(handles.Zi,handles.smooth,handles.smooth*1.2);
        end
        %[handles.Xi, handles.Yi] = meshgrid(handles.xi, handles.yi);
        %handles.Zi = interp2(handles.xvect,handles.yvect,handles.zvect,handles.Xi,handles.Yi', 'spline');

        if (strcmpi(handles.style, 'None'))
                    handles.imgover = imread('eggheadplot3.png');
        else
            if (strcmpi(handles.style, 'Outline'))
                    handles.imgover = imread('eggheadplot2.png');
            else
                if (strcmpi(handles.style, 'Full'))
                    handles.imgover = imread('eggheadplot1.png');
                end
            end
        end

        handles.imgover = flipdim(handles.imgover, 1);
        handles.imgover2 = handles.imgover(:,:,1) ~= handles.imgover(:,:,2);
        
        if (strcmpi(handles.ShowBrain, 'Yes'))
            handles.imgbrain = imread('eggheadplot4.png');
            handles.imgbrain = flipdim(handles.imgbrain, 1);
            handles.imgbrain2 = repmat(handles.BrainOpacity, size(handles.imgbrain(:,:,2)));
            handles.imgbrain2a = handles.imgbrain(:,:,1) == handles.imgbrain(:,:,2);
            handles.imgbrain2(handles.imgbrain2a == 0) = 0;      % 100% transparent
        end

        %Threshold surface plot
        if ~isempty(handles.knockout)
           handles.thresmin = handles.knockout(1);
           handles.thresmax = handles.knockout(2);
           % handles.img2 = (handles.Zi(:,:) >= handles.thresmin) & (handles.Zi(:,:) <= handles.thresmax);
            %handles.Zi(handles.img2) = NaN;
        end

        % Create GUI window
        handles.fig1 = figure('Name',sprintf('Topographic Plot of %s', handles.label),'NumberTitle','off','Position',[80,80,600,600],'Color', 'w');
        handles.axes = axes('Position',[.01,.14,.99,.88],'FontSize', handles.fontsize);
        hold on

        handles.fill = fill([-350 -350 350 350], [-395 400 400 -395], handles.topbackground); % background grey fill
        handles.surf = surface(handles.Xi,handles.Yi,zeros(size(handles.Zi)),handles.Zi,'EdgeColor','none','FaceColor','interp','FaceLighting','phong'); %Map

        axis off;
        if (handles.ncontours > 0)
            handles.cont = contour(handles.Xi,handles.Yi,handles.Zi,handles.ncontours,'LineColor',handles.markcolor); % Show Contours
        end
        if (strcmpi(handles.ShowElectrodes, 'Yes'))
            handles.electrodefill = plot3(handles.origchanxvect*0.91,handles.origchanyvect*0.95,ones(size(handles.origchanxvect))*10,'.','Color',handles.markcolor,'markersize',handles.marksize,'linewidth',1); % Show electrodes
        end
        if (strcmpi(handles.ShowBrain, 'Yes'))
            handles.imgBrain3 = imagesc(-410,-397,handles.imgbrain, 'AlphaData', handles.imgbrain2); % mask out everything except the plot
        end
        handles.imgoverlay = imagesc(-410,-397,handles.imgover, 'AlphaData', ~handles.imgover2); % mask out everything except the plot

        % Set colormap and threshold if necessary
        %handles.colormap = colormap(handles.colormapstyle);
       handles.colormap = colormap(sprintf('%s(%d)',handles.colormapstyle,handles.steps));
       if ~isempty(handles.knockout)
            tempinc = (handles.yscale(2)-handles.yscale(1))/(size(handles.colormap,1)-1);
            tempincC = 0;
            tempmarks = zeros(size(handles.colormap,1),1);
            for cR = 1:size(handles.colormap,1)
                tempval = (handles.yscale(1) + ((cR-1)*tempinc));
                if (tempval >= handles.thresmin) && (tempval <= handles.thresmax)
                    handles.colormap(cR,:) = handles.topbackground;
                    tempincC = tempincC + 1;
                    tempmarks(cR,1) = 1;
                end
            end
            if (tempincC > 4)
                tempincC = round((tempincC/3)/1);
                tempmax = [.8,.8,.8];
                tempinc = (tempmax-handles.topbackground)/tempincC;
                if (tempmarks(1,1) ~= 1)
                    for xR = 1:tempincC
                        tempInd = find(tempmarks, 1, 'first');
                        handles.colormap(tempInd,:) = tempmax;
                        tempmarks(tempInd,1) = 0;
                        tempmax = tempmax - tempinc;
                    end
                end
                tempmax = [.8,.8,.8];
                if (tempmarks(end,1) ~= 1)
                    for xR = 1:tempincC
                        tempInd = find(tempmarks, 1, 'last');
                        handles.colormap(tempInd,:) = tempmax;
                        tempmarks(tempInd,1) = 0;
                        tempmax = tempmax - tempinc;
                    end
                end
            end
            handles.colormap = colormap(handles.colormap);
        end
        handles.bar = colorbar('location', 'SouthOutside', 'Position', [.305,.07,.4,.03], 'FontSize', handles.fontsize);

        caxis(handles.yscale); % set coloraxis scale
        try
            h = findobj('type','Patch'); set(h,'visible','Off');
        catch
            h = 0;
        end
        handles.MinText = uicontrol('Style', 'text', 'String', 'Min', 'Units','normalized', 'Position', [0.01,0.02,.1,0.03], 'FontSize', (handles.fontsize), 'BackgroundColor', 'w');
        handles.edMin = uicontrol('Style','edit','String',num2str(handles.yscale(1)),'Units','normalized','Position',[0.01,0.06,.1,(.01+(handles.fontsize*.002))],'FontSize', (handles.fontsize), 'BackgroundColor', 'w','Callback',{@scalechange});
        handles.MaxText = uicontrol('Style', 'text', 'String', 'Max', 'Units','normalized', 'Position', [0.11,0.02,.1,0.03], 'FontSize', (handles.fontsize), 'BackgroundColor', 'w');
        handles.edMax = uicontrol('Style','edit','String',num2str(handles.yscale(2)),'Units','normalized','Position',[0.11,0.06,.1,(.01+(handles.fontsize*.002))],'FontSize', (handles.fontsize), 'BackgroundColor', 'w','Callback',{@scalechange});
        changeplot
                
    end
    function changeplot
        min = str2num(get(handles.edMin,'String'));
        max = str2num(get(handles.edMax,'String'));
        if (min < max)
            handles.yscale(1) = min;
            handles.yscale(2) = max;
            caxis(handles.yscale);
            handles.colormap = colormap(handles.colormapstyle);
            if ~isempty(handles.knockout)
                tempinc = (handles.yscale(2)-handles.yscale(1))/(size(handles.colormap,1)-1);
                tempincC = 0;
                tempmarks = zeros(size(handles.colormap,1),1);
                for cR = 1:size(handles.colormap,1)
                    tempval = (handles.yscale(1) + ((cR-1)*tempinc));
                    if (tempval >= handles.thresmin) && (tempval <= handles.thresmax)
                        handles.colormap(cR,:) = handles.topbackground;
                        tempincC = tempincC + 1;
                        tempmarks(cR,1) = 1;
                    end
                end
                if (tempincC > 4)
                tempincC = round((tempincC/3)/1);
                tempmax = [.8,.8,.8];
                tempinc = (tempmax-handles.topbackground)/tempincC;
                if (tempmarks(1,1) ~= 1)
                    for xR = 1:tempincC
                        tempInd = find(tempmarks, 1, 'first');
                        handles.colormap(tempInd,:) = tempmax;
                        tempmarks(tempInd,1) = 0;
                        tempmax = tempmax - tempinc;
                    end
                end
                tempmax = [.8,.8,.8];
                if (tempmarks(end,1) ~= 1)
                    for xR = 1:tempincC
                        tempInd = find(tempmarks, 1, 'last');
                        handles.colormap(tempInd,:) = tempmax;
                        tempmarks(tempInd,1) = 0;
                        tempmax = tempmax - tempinc;
                    end
                end
            end
                handles.colormap = colormap(handles.colormap);
            end
        end
        set(handles.edMin, 'String', num2str(handles.yscale(1)));
        set(handles.edMax, 'String', num2str(handles.yscale(2)));
    end
    
    function scalechange(hObject, eventdata, handles)
        changeplot
    end
end
  










