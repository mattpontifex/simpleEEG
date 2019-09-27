function cmap = kuler(m)

% Named for Aobe Kuler color wheel
% Green to Light Blue to Blue to Purple to Pink to Red to Orange to Yellow

% split green segment in 3rds
% transition darkgreen (1: 0, 64,20) to green(2: 0,255,81) - over 1/3rd step
% transition green(2: 0,255,81)  to light blue(3: 12,208,232) - over 2/3rd step
% transition light blue(3: 12,208,232) to blue(4: 13,47,255)
% transition blue(4: 13,47,255) to darkpurple(5: 95, 2, 255)
% split purple segment in 3rds
% transition darkpurple(5: 95, 2, 255) to purple(6: 136, 0, 255) - over  1/3rd step
% transition purple(6: 136, 0, 255) to pink(7: 255,0,255) - over 2/3rd step
% transition pink(7: 255,0,255) to red(8: 232,0,0)
% split red segment in 3rds
% transition red(8: 232,0,0) to darkorange(9:255,100,13) - over  1/3rd step
% transition darkorange(9:255,100,13) to orange(10:255,178,0)
% transition orange(10:255,178,0) to yellow(11:255,255,0)

% increase size of orange


    if nargin < 1
        m = size(get(gcf,'colormap'),1);
    end
    
    origseg = fix((1/20)*m);

    % Establish matrix
    r = ones(1,m)*255; % default to white
    g = ones(1,m)*255; % default to white
    b = ones(1,m)*255; % default to white

    % transition darkgreen (1: 0, 64,20) to green(2: 0,255,81)
    seg = origseg;
    seg = seg*1.5;
    spanstart = 1;
    spanend = floor(spanstart + seg - 1);
    seg = spanend-spanstart+1;
    gval = [64 255];
    bval = [20 81];
    r(spanstart:spanend) = zeros(1,seg);
    g(spanstart:spanend) = gval(1):((gval(2)-gval(1))/(seg-1)):gval(2);
    b(spanstart:spanend) = bval(1):((bval(2)-bval(1))/(seg-1)):bval(2);
    
    % transition green(2: 0,255,81)  to light blue(3: 12,208,232) - over 2 step
    seg = origseg;
    seg = seg*2.25;
    spanstart = floor(spanend+1);
    spanend = floor(spanstart + seg - 1);
    seg = spanend-spanstart+1;
    rval = [0 12];
    gval = [208 255];
    bval = [81 232];
    r(spanstart:spanend) = rval(1):((rval(2)-rval(1))/(seg-1)):rval(2);
    g(spanstart:spanend) = fliplr(gval(1):((gval(2)-gval(1))/(seg-1)):gval(2));
    b(spanstart:spanend) = bval(1):((bval(2)-bval(1))/(seg-1)):bval(2);
    
    % transition light blue(3: 12,208,232) to blue(4: 13,47,255)
    seg = origseg;
    seg = seg*2.75;
    spanstart = floor(spanend+1);
    spanend = floor(spanstart + seg - 1);
    seg = spanend-spanstart+1;
    rval = [12 13];
    gval = [47 208];
    bval = [232 255];
    r(spanstart:spanend) = rval(1):((rval(2)-rval(1))/(seg-1)):rval(2);
    g(spanstart:spanend) = fliplr(gval(1):((gval(2)-gval(1))/(seg-1)):gval(2));
    b(spanstart:spanend) = bval(1):((bval(2)-bval(1))/(seg-1)):bval(2);
    
    % transition blue(4: 13,47,255) to darkpurple(5: 95, 2, 255)
    seg = origseg;
    seg = seg*2;
    spanstart = floor(spanend+1);
    spanend = floor(spanstart + seg - 1);
    seg = spanend-spanstart+1;
    rval = [13 95];
    gval = [2 47];
    bval = [255 255];
    r(spanstart:spanend) = rval(1):((rval(2)-rval(1))/(seg-1)):rval(2);
    g(spanstart:spanend) = fliplr(gval(1):((gval(2)-gval(1))/(seg-1)):gval(2));
    b(spanstart:spanend) = ones(1,seg)*255;
    
    % transition darkpurple(5: 95, 2, 255) to purple(6: 136, 0, 255) - over  1 step
    seg = origseg;
    seg = seg*2.25;
    spanstart = floor(spanend+1);
    spanend = floor(spanstart + seg - 1);
    seg = spanend-spanstart+1;
    rval = [95 136];
    gval = [0 2];
    bval = [255 255];
    r(spanstart:spanend) = rval(1):((rval(2)-rval(1))/(seg-1)):rval(2);
    g(spanstart:spanend) = fliplr(gval(1):((gval(2)-gval(1))/(seg-1)):gval(2));
    b(spanstart:spanend) = ones(1,seg)*255;
    
    % transition purple(6: 136, 0, 255) to pink(7: 255,0,255) - over 2 step
    seg = origseg;
    seg = seg*2.75;
    spanstart = floor(spanend+1);
    spanend = floor(spanstart + seg - 1);
    seg = spanend-spanstart+1;
    rval = [136 255];
    gval = [0 0];
    bval = [255 255];
    r(spanstart:spanend) = rval(1):((rval(2)-rval(1))/(seg-1)):rval(2);
    g(spanstart:spanend) = zeros(1,seg);
    b(spanstart:spanend) = ones(1,seg)*255;
    
    % transition pink(7: 255,0,255) to red(8: 232,0,0)
    seg = origseg;
    seg = seg*3.5;
    spanstart = floor(spanend+1);
    spanend = floor(spanstart + seg - 1);
    seg = spanend-spanstart+1;
    rval = [232 255];
    gval = [0 0];
    bval = [0 255];
    r(spanstart:spanend) = fliplr(rval(1):((rval(2)-rval(1))/(seg-1)):rval(2));
    g(spanstart:spanend) = zeros(1,seg);
    b(spanstart:spanend) = fliplr(bval(1):((bval(2)-bval(1))/(seg-1)):bval(2));
    

    % transition red(8: 232,0,0) to darkorange(9:255,100,13) - over  1 step
    seg = origseg;
    seg = seg*1.5;
    spanstart = floor(spanend+1);
    spanend = floor(spanstart + seg - 1);
    seg = spanend-spanstart+1;
    rval = [232 255];
    gval = [0 100];
    bval = [0 13];
    r(spanstart:spanend) = rval(1):((rval(2)-rval(1))/(seg-1)):rval(2);
    g(spanstart:spanend) = gval(1):((gval(2)-gval(1))/(seg-1)):gval(2);
    b(spanstart:spanend) = bval(1):((bval(2)-bval(1))/(seg-1)):bval(2);
    
    % transition darkorange(9:255,100,13) to orange(10:255,178,0) - over 2 step
    seg = origseg;
    seg = seg*2;
    spanstart = floor(spanend+1);
    spanend = floor(spanstart + seg - 1);
    seg = spanend-spanstart+1;
    rval = [255 255];
    gval = [100 178];
    bval = [0 13];
    r(spanstart:spanend) = ones(1,seg)*255;
    g(spanstart:spanend) = gval(1):((gval(2)-gval(1))/(seg-1)):gval(2);
    b(spanstart:spanend) = fliplr(bval(1):((bval(2)-bval(1))/(seg-1)):bval(2));
    
    % transition orange(10:255,178,0) to yellow(11:255,255,0)
    seg = origseg;
    seg = seg*1;
    spanstart = floor(spanend+1);
    spanend = floor(spanstart + seg - 1);
    seg = spanend-spanstart+1;
    rval = [255 255];
    gval = [178 255];
    bval = [0 0];
    r(spanstart:spanend) = ones(1,seg)*255;
    g(spanstart:spanend) = gval(1):((gval(2)-gval(1))/(seg-1)):gval(2);
    b(spanstart:spanend) = zeros(1,seg);

    if (r(spanend) ~= 255) | (g(spanend) ~= 255) | (b(spanend) ~= 0)
        r(spanend) = 255;
        g(spanend) = 255;
        b(spanend) = 0;
    end
    
    % slice just in case
    r = r(1:spanend);
    g = g(1:spanend);
    b = b(1:spanend);
    
    r = r/255;
    g = g/255;
    b = b/255;
    cmap = [r' g' b'];
