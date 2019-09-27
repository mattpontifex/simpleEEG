function [EEG] = rereferenceplus(EEG, temprefch, tempexclch, retorigref)
%   Rereferences the data based on the channels provided
%   while excluding those specified channels.
%   
%   Optional parameter to retain old reference.
%
%   Average M1 and M2 for reference, Exclude VEO and HEO
%   Retain reference and save as CCPZ
%   EEG = rereferenceplus( EEG, {'M1', 'M2'}, {'VEO', 'HEO'}, 'CCPZ');
%
%   or
%
%   Average M1 and M2 for reference, Exclude VEO and HEO
%   Does not retain original reference
%   EEG = rereferenceplus( EEG, {'M1', 'M2'}, {'VEO', 'HEO'}, '');
%
%   or
%
%   Average M1 and M2 for reference, Does not exclude any electrodes
%   Retain reference and save as CCPZ
%   EEG = rereferenceplus( EEG, {'M1', 'M2'}, '', 'CCPZ');
%
%   or
%
%   Average M1 and M2 for reference, Does not exclude any electrodes
%   Does not retain original reference
%   EEG = rereferenceplus( EEG, {'M1', 'M2'}, '', '');

    boolerr = 0;
    try
        temp2 = [EEG.chanlocs.impedance];
        temp3 = [EEG.chanlocs.median_impedance];
        EEG.chanlocs = rmfield(EEG.chanlocs, 'impedance');
        EEG.chanlocs = rmfield(EEG.chanlocs, 'median_impedance');
    catch
        boolerr = 1;
    end

    tempchinc = [];
    for m = 1:numel(temprefch)
        if ~isempty(find(strcmp({EEG.chanlocs.labels},temprefch(m))))
            tempchinc(end+1) = find(strcmp({EEG.chanlocs.labels},temprefch(m)));
        end
    end
    
    if (not(isempty(tempexclch)))
        %Run if there are channels excluded
        tempchexc = [];
        for m = 1:numel(tempexclch)
            if ~isempty(find(strcmp({EEG.chanlocs.labels},tempexclch(m))))
                tempchexc(end+1) = find(strcmp({EEG.chanlocs.labels},tempexclch(m)));
            end
        end
        
        if (not(isempty(retorigref)))
            %Run if keeping the reference
            %   EEG = rereferenceplus( EEG, {'M1', 'M2'}, {'VEO', 'HEO'}, 'CCPZ');
            n = size(EEG.chanlocs, 2);
            n1 = n + 1;
            EEG = pop_chanedit(EEG, 'append',n,'changefield',{n1 'labels' retorigref});
            EEG = pop_reref( EEG, [tempchinc] ,'refloc',struct('labels',{retorigref},'type',{''},'theta',{[]},'radius',{[]},'X',{[]},'Y',{[]},'Z',{[]},'sph_theta',{[]},'sph_phi',{[]},'sph_radius',{[]},'urchan',{[]},'ref',{''},'datachan',{0}),'exclude',[tempchexc] ,'keepref','on');
        else
            %Run if not keeping the reference
            %   EEG = rereferenceplus( EEG, {'M1', 'M2'}, {'VEO', 'HEO'}, '');
            EEG = pop_reref( EEG, [tempchinc], 'exclude', [tempchexc],'keepref','on');
        end
    else
        %Run if there are no channels excluded
        if (not(isempty(retorigref)))
            %Run if keeping the reference
            n = size(EEG.chanlocs, 2);
            n1 = n + 1;
            EEG = pop_chanedit(EEG, 'append',n,'changefield',{n1 'labels' retorigref});
            EEG = pop_reref( EEG, [tempchinc] ,'refloc',struct('labels',{retorigref},'type',{''},'theta',{[]},'radius',{[]},'X',{[]},'Y',{[]},'Z',{[]},'sph_theta',{[]},'sph_phi',{[]},'sph_radius',{[]},'urchan',{[]},'ref',{''},'datachan',{0}),'keepref','on');
        else
            %Run if not keeping the reference
            EEG = pop_reref(EEG, [tempchinc],'keepref','on');
        end        
    end
    
    if (boolerr == 0)
        for cR = 1:size(EEG.chanlocs,2)-1
            EEG.chanlocs(cR).impedance = temp2(cR);
            EEG.chanlocs(cR).median_impedance = temp3(cR);
        end
        EEG.chanlocs(size(EEG.chanlocs,2)).impedance = NaN;
        EEG.chanlocs(size(EEG.chanlocs,2)).median_impedance = NaN; 
    end
end

