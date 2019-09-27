function cmap = greenstain(m)

% Black to Navy Blue to Light Blue to Green to Yellow

% transition black (1: 0, 0,0) to navyblue(2: 0,0,0)
% transition navyblue(2: 0,0,0) to lightblue (3: 0, 0,0)
% transition lightblue (3: 0, 0,0) to green(4: 0,0,0)
% transition green(4: 0,0,0) to brightgreen(5: 0,0,0)
% transition brightgreen(5: 0,0,0) to white(6: 0,0,0)


    if nargin < 1
        m = size(get(gcf,'colormap'),1);
    end
    
    origseg = fix((1/14)*m);

    % Establish matrix
    r = zeros(1,m); % default to black
    g = zeros(1,m); % default to black
    b = zeros(1,m); % default to black
    
    % transition black (1: 0, 0,0) to navyblue(2: 0,30,58)
    seg = origseg;
    seg = seg*3;
    spanstart = 1;
    spanend = floor(spanstart + seg - 1);
    seg = spanend-spanstart+1;
    gval = [0 30];
    bval = [0 58];
    r(spanstart:spanend) = zeros(1,seg);
    g(spanstart:spanend) = gval(1):((gval(2)-gval(1))/(seg-1)):gval(2);
    b(spanstart:spanend) = bval(1):((bval(2)-bval(1))/(seg-1)):bval(2);
    
    % transition navyblue(2: 0,30,58) to lightblue(3: 0,74,149)
    seg = origseg;
    seg = seg*4;
    spanstart = floor(spanend+1);
    spanend = floor(spanstart + seg - 1);
    seg = spanend-spanstart+1;
    gval = [30 74];
    bval = [58 149];
    r(spanstart:spanend) = zeros(1,seg);
    g(spanstart:spanend) = gval(1):((gval(2)-gval(1))/(seg-1)):gval(2);
    b(spanstart:spanend) = bval(1):((bval(2)-bval(1))/(seg-1)):bval(2);
    
    % transition lightblue(3: 0,74,149) to brightblue(2: 0,191,255)
    seg = origseg;
    seg = seg*2.5;
    spanstart = floor(spanend+1);
    spanend = floor(spanstart + seg - 1);
    seg = spanend-spanstart+1;
    gval = [74 191];
    bval = [149 255];
    r(spanstart:spanend) = zeros(1,seg);
    g(spanstart:spanend) = gval(1):((gval(2)-gval(1))/(seg-1)):gval(2);
    b(spanstart:spanend) = bval(1):((bval(2)-bval(1))/(seg-1)):bval(2);
    
    
    % transition brightblue(2: 0,191,255)to green(4: 0,216,41)
    seg = origseg;
    seg = seg*2.5;
    spanstart = floor(spanend+1);
    spanend = floor(spanstart + seg - 1);
    seg = spanend-spanstart+1;
    gval = [191 216];
    bval = [41 255];
    r(spanstart:spanend) = zeros(1,seg);
    g(spanstart:spanend) = gval(1):((gval(2)-gval(1))/(seg-1)):gval(2);
    b(spanstart:spanend) = fliplr(bval(1):((bval(2)-bval(1))/(seg-1)):bval(2));
    
    % transition green(4: 0,216,41) to brightgreen(5: 151,254,0)
    seg = origseg;
    seg = seg*3;
    spanstart = floor(spanend+1);
    spanend = floor(spanstart + seg - 1);
    seg = spanend-spanstart+1;
    rval = [0 151];
    gval = [216 254];
    bval = [0 41];
    r(spanstart:spanend) = rval(1):((rval(2)-rval(1))/(seg-1)):rval(2);
    g(spanstart:spanend) = gval(1):((gval(2)-gval(1))/(seg-1)):gval(2);
    b(spanstart:spanend) = fliplr(bval(1):((bval(2)-bval(1))/(seg-1)):bval(2));

    totseg = spanend/origseg;
    
    r = r/255;
    g = g/255;
    b = b/255;
    cmap = [r' g' b'];