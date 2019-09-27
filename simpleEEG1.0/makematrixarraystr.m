function outstring = makematrixarraystr(inmat)
% Function to take a matrix array [ 1, 4 ] and return that same matrix
% array formatted as a string '[ 1, 4 ]'.
%
% example: outstring = makematrixarraystr([ 1, 4 ])

      outstring = sprintf('[');
      for cE = 1:size(inmat,2)
          outstring = sprintf('%s %s', outstring, num2str(inmat(cE)));
          if (cE ~= size(inmat,2))
              outstring = sprintf('%s,', outstring);
          end
      end
      outstring = sprintf('%s ]', outstring);
end