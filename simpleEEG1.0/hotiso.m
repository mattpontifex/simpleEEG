function cmap = hotiso(m)

    if nargin < 1
        m = size(get(gcf,'colormap'),1);
    end
    
    n = fix((1/3)*m);
    
    r = ones(m,1)*255; r(1:n) = 117:((255-117)/(n-1)):255; r = r/255;
    g = zeros(m,1);  g(n+1:end) = 0:(255/(m-n-1)):255; g = g/255;
    b = zeros(m,1); b = b/255;
    
    cmap = [r g b];