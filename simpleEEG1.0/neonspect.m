function cmap = neonspect(m)

    if nargin < 1
        m = size(get(gcf,'colormap'),1);
    end
    
    r = zeros(m,1);
    g = zeros(m,1);  
    b = zeros(m,1); 
    
    n = fix((66/100)*m);
    beg = 232; fin = 255; 
    r(n:end) = beg:((fin-beg)/(m-n)):fin; 
    beg = 192; fin = 48; 
    b(n:end) = beg:((fin-beg)/(m-n)):fin; 
    beg = 87; fin = 194; 
    g(n:end) = beg:((fin-beg)/(m-n)):fin; 

    n1 = fix((26/100)*m);
    beg = 22; fin = 232;
    r(n1:n) = beg:((fin-beg)/(n-n1)):fin; 
    beg = 192; fin = 250;
    b(n1:n) = beg:((fin-beg)/(n-n1)):fin; 
    beg = 113; fin = 87;
    g(n1:n) = beg:((fin-beg)/(n-n1)):fin; 
    
    beg = 169; fin = 22;
    r(1:n1) = beg:((fin-beg)/(n1-1)):fin; 
    beg = 250; fin = 252;
    b(1:n1) = beg:((fin-beg)/(n1-1)):fin; 
    
    n2 = fix((13/100)*m);
    beg = 180; fin = 113;
    g(n2:n1) = beg:((fin-beg)/(n1-n2)):fin; 
    beg = 247; fin = 180;
    g(1:n2) = beg:((fin-beg)/(n2-1)):fin; 
    
    b = b/255;
    g = g/255;
    r = r/255;
    
    cmap = [r g b];