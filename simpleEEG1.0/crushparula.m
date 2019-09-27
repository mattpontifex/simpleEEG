function cmap = crushparula(m)
% Attemps to expand the ending portions of the Parula color map and squish
% the middle portions.

    if nargin < 1
        m = size(get(gcf,'colormap'),1);
    end
    
    values = [0,0,135;1,57,184;1,104,225;8,139,205;15,174,185;137,185,119;255,195,55;252,225,33;249,251,14];
    values = [values(:,1)/255,values(:,2)/255,values(:,3)/255]; % convert from 0 to 255 into 0 to 1
    P = size(values,1);
    cmap = interp1(1:size(values,1), values, linspace(1,P,m), 'linear');
    
