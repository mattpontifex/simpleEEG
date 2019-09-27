function cmap = coldiso(m)

    if nargin < 1
        m = size(get(gcf,'colormap'),1);
    end
    
    n = fix((1/3)*m);
    
    r = zeros(m,1); r = flipud(r/255);
    g = zeros(m,1);  g(n+1:end) = 0:(255/(m-n-1)):255; g = flipud(g/255);
    b = ones(m,1)*255; b(1:n) = 117:((255-117)/(n-1)):255; b = flipud(b/255);
    
    cmap = [r g b];