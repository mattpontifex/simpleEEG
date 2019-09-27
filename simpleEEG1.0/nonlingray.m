function cmap = nonlingray(m)

% Nonlinear Gray Colormap

    if nargin < 1
        m = size(get(gcf,'colormap'),1);
    end
    
    origseg = fix((1/8)*m);

    % Establish matrix
    r = ones(1,m)*255; % default to white
    
    % transition black (1: 0, 0,0) to navyblue(2: 0,30,58)
    seg = origseg;
    seg = seg*1;
    spanstart = 1;
    spanend = floor(spanstart + seg - 1);
    seg = spanend-spanstart+1;
    val = [0 80];
    r(spanstart:spanend) = val(1):((val(2)-val(1))/(seg-1)):val(2);
        
    % transition
    seg = origseg;
    seg = seg*3;
    spanstart = floor(spanend+1);
    spanend = floor(spanstart + seg - 1);
    seg = spanend-spanstart+1;
    val = [80 200];
    r(spanstart:spanend) = val(1):((val(2)-val(1))/(seg-1)):val(2);
    
    % transition 
    seg = origseg;
    seg = seg*4;
    spanstart = floor(spanend+1);
    spanend = floor(spanstart + seg - 1);
    seg = spanend-spanstart+1;
    val = [200 255];
    r(spanstart:spanend) = val(1):((val(2)-val(1))/(seg-1)):val(2);
    
    totseg = spanend/origseg;
    
    r = r/255;
    cmap = [r' r' r'];