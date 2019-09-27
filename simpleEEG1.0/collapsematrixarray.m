function outstring = collapsematrixarray(epochevents)
% Function to take a matrix array [ 1, 4 ] and return that same matrix
% array formatted as a string '[ 1, 4 ]' with consecutive number runs collapsed.
%
% example: outstring = collapsematrixarray([ 1, 2, 3, 4 ])
      
     % identify consecutive runs of numbers
    epocheventlist = sprintf('['); 
    k = [true;diff(epochevents(:))~=1 ];
    s = cumsum(k);
    x =  histc(s,1:s(end));
    numrunsstart = find(k);
    numrunsstop = numrunsstart - 1;
    numrunsstop = vertcat(numrunsstop, numel(epochevents));
    for cE = 1:numel(numrunsstart)
        if (numrunsstart(cE) == numrunsstop(cE+1)) % start and stop are the same numbers which means they are not runs
            if (strcmpi(epocheventlist, '[')) %first event added
                epocheventlist = sprintf('%s %s', epocheventlist, num2str(epochevents(numrunsstart(cE))));
            else
                epocheventlist = sprintf('%s, %s', epocheventlist, num2str(epochevents(numrunsstart(cE))));
            end
        else
            if (strcmpi(epocheventlist, '[')) %first event added
                epocheventlist = sprintf('%s %s:%s', epocheventlist, num2str(epochevents(numrunsstart(cE))), num2str(epochevents(numrunsstop(cE+1))));
            else
                epocheventlist = sprintf('%s, %s:%s', epocheventlist, num2str(epochevents(numrunsstart(cE))), num2str(epochevents(numrunsstop(cE+1))));
            end
        end
    end
    outstring = sprintf('%s ]', epocheventlist);
      
end