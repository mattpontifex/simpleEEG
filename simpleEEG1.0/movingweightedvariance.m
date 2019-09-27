function [matrixout] = movingweightedvariance(matrixin)
%   Computes the variance of the input matrix from a matrix smoothed using
%   a sliding gaussian function.
%
%   tempmatrix_variance = movingweightedvariance(tempmatrix);
%
%   Author: Matthew B. Pontifex, Health Behaviors and Cognition Laboratory, Michigan State University, July 18, 2014
    
    tempmat = matrixin;
    for rN=1:size(matrixin, 1)
        %tempmat(rN,:) = fastsmooth(tempmat(rN,:),100,3,1);
        tempmat(rN,:) = gaussmooth(tempmat(rN,:), 'Window', 100, 'Sigma', 2.0);
    end
    tempdif = matrixin - tempmat;
    tempdif = power(tempdif,2);
    matrixout = zeros(r,1);
    for rN=1:size(matrixin, 1)
        matrixout(rN,1) = mean(tempdif(rN,:));
    end
    
end 
     
                