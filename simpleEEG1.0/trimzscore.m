function [matrixout] = trimzscore(matrixin, varargin)
%   Computes Z scores after trimming out the specified minimum and maximum
%   values.
%
%   1   Input Matrix
%   2   The available parameters are as follows:
%       a    'trimMin' - Number of small values to trim.
%       b   'trimMax' - Number of large values to trim.
%       c   'method' - ['mean' (default) | 'median'] Select what measure of central tendency to use.
%
%   tempmatrix= trimzscore(tempmatrix, 'trimMin', 2, 'trimMax', 2, 'method', 'mean');
%
%   Author: Matthew B. Pontifex, Health Behaviors and Cognition Laboratory, Michigan State University, July 18, 2014

    if ~isempty(varargin)
             r=struct(varargin{:});
    end
    try, r.trimMin;   catch, r.trimMin=0;  end
    try, r.trimMax;  catch, r.trimMax=0; end
    try, r.method;  catch, r.method='mean'; end

    tmin =  r.trimMin;
    tmax = r.trimMax;
    if (strcmpi(r.method,'mean') == 1)
        cented = 1;
    end
    if (strcmpi(r.method,'median') == 1)
        cented = 2;
    end
    
    r = size(matrixin, 1);
    c = size(matrixin, 2);

    if (c == 1)
        if (r > 1)
            matrixin = matrixin';
            r = size(matrixin, 1);
            c = size(matrixin, 2);
        else
            error('Error at functionname(). This function requires more than 1 value.');
        end
    end

    %Zscore columns
    tempmatrix = matrixin;
    for rN = 1:r
        temparray = matrixin(rN,:);
        temparray = sort(temparray, 'ascend');
        temparray = temparray(1:(end-tmax));
        temparray = sort(temparray, 'descend');
        temparray = temparray(1:(end-tmin));
        if (cented == 1)
            tempmean = nanmean(temparray);
        else
            tempmean = nanmedian(temparray);
        end
        tempstd = nanstd(temparray);
        for cN = 1:c
            if ~isnan(matrixin(rN,cN))
                tempval = ((matrixin(rN,cN)-tempmean)/tempstd);
                tempmatrix(rN,cN) = tempval;
            else
                tempmatrix(rN,cN) = NaN;
            end
        end
    end
    matrixout = tempmatrix;
end