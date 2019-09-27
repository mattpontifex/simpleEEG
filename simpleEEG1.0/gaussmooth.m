function [outY] = gaussmooth(Y, varargin)
%   Smooths vector/matrix Y using gaussian weights. 
%
%   1   Input vector
%   2   The available parameters are as follows:
%       a    'Window' - Window of gaussian weights to use.
%       b    'Sigma' - PDF sigma for calculation of gaussian weights (default is 1, larger values will give muted peak).
%       
%   Example Code:
%
%   OutVector = gaussmooth( Y, 'Window', 100, 'Sigma', 1.5);
%
%   NOTE: You must have the Matlab Statistics Toolbox installed.
%
%   Author: Matthew B. Pontifex, Health Behaviors and Cognition Laboratory, Michigan State University, July 25, 2014

    if ~isempty(varargin)
             r=struct(varargin{:});
    end
    try, r.Window; winsize = r.Window; catch, r.Window=0;  error('Error at gaussmooth(). Missing information! Please input Window size.');   end
    try, r.Sigma; sig = r.Sigma; catch, sig = 1; end
    
    if (winsize < 3)
        winsize = 3;
    end
    if ~mod(winsize,2)
        winsize = winsize + 1;
    end 
    % Populate weights
    x = [-3:(6/(winsize-1)):3];
    norm = normpdf(x,0,sig); % Create normal distribution
    temp = 1/sum(norm); % Calculate correction weight
    norm = temp.*norm; % Adjust normal distribution to have sum of 1
    shift = floor(winsize/2); % Calculate how much of a shift is necessary to accomodate the full window
    
    booltranspose = 0;
    if (size(Y,1) > size(Y,2)) % rows are bigger than columns
       Y = Y'; % transpose
       booltranspose = 1;
    end
    outY = NaN(size(Y,1),size(Y,2));
    
    for rC = 1:size(Y,1)
        tY = zeros(1,(size(Y,2)+shift+shift)); % Populate empty dataset
        oldstart = shift+1; oldend = size(Y,2)+shift;
        tY(1:shift) = fliplr(Y(rC,2:shift+1));
        tY(oldstart:oldend) = Y(rC,1:end);
        tY((oldend+1):(oldend+shift)) = fliplr(Y(rC,end-shift:end-1));

        nY = zeros(1,size(tY,2)); % Populate empty dataset
        for cC = (1+shift):(size(tY,2)-shift)
            min = cC - shift; max = cC + shift; % Determine points of data to grab
            nY(cC) = sum(tY(min:max).* norm); % Multiply data segment by PDF weights, then sum for new smoothed value
        end

        outY(rC,:) = nY(oldstart:oldend);
    end
    
    if (booltranspose == 1)
        outY = outY'; % transpose back to original
    end
end
    
    
