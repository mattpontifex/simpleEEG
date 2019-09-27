function [INPUTSTRUCT] = reorderchannelarray(INPUTSTRUCT, desiredarray)
%   This function reorders the available channels to match the order in the
%   inputted array. If the number of channels in the file does not match
%   the requested ordering array, the program will error out.
%
%   1   Input EEG File From EEGLAB
%   2   Order of electrode array desired
%
%   standardchannelarray = {'AF7', 'AF3', 'AF4', 'AF8', 'F7', 'F5', 'F3', 'F1', 'FZ', 'F2', 'F4', 'F6', 'F8', 'FT7', 'FC5', 'FC3', 'FC1', 'FCZ', 'FC2', 'FC4', 'FC6', 'FT8', 'T7', 'C5', 'C3', 'C1', 'CZ', 'C2', 'C4', 'C6', 'T8', 'TP7', 'CP5', 'CP3', 'CP1', 'CPZ', 'CP2', 'CP4', 'CP6', 'TP8', 'P7', 'P5', 'P3', 'P1', 'PZ', 'P2', 'P4', 'P6', 'P8', 'PO7', 'PO5', 'PO3', 'POZ', 'PO4', 'PO6', 'PO8', 'O1', 'OZ', 'O2'};
%   EEG = reorderchannelarray( EEG, standardchannelarray);
%
%   Author: Matthew B. Pontifex, Health Behaviors and Cognition Laboratory, Michigan State University, April 1, 2014

    nchannelsIdeal = size(desiredarray, 2);
    nchannelsCurrent = size(INPUTSTRUCT.chanlocs, 2);
    
    if (nchannelsIdeal ~= nchannelsCurrent)
        tempA = {INPUTSTRUCT.chanlocs.labels};
        missingchannels = setdiff(desiredarray,tempA);
        if ~isempty(missingchannels)
            for index1=1:size(missingchannels, 2)
                INPUTSTRUCT.chanlocs(nchannelsCurrent+index1).('labels') = missingchannels(index1);
                if (isfield(INPUTSTRUCT,'erpname')) % ERP structure
                    INPUTSTRUCT.bindata(nchannelsCurrent+index1,:) = NaN;
                    INPUTSTRUCT.binerror(nchannelsCurrent+index1,:) = NaN;
                else
                    INPUTSTRUCT.data(nchannelsCurrent+index1,:) = NaN;
                end
            end
        end
        missingchannels = setdiff(tempA,desiredarray);
        if ~isempty(missingchannels)
            for index1=1:size(missingchannels, 2)
                desiredarray(nchannelsIdeal+index1) = missingchannels(index1);
            end
        end
        INPUTSTRUCT.nchan = size(INPUTSTRUCT.chanlocs, 2);
        nchannelsCurrent = size(INPUTSTRUCT.chanlocs, 2);
        nchannelsIdeal = size(desiredarray, 2);
    end
    TEMPTSTRUCT = INPUTSTRUCT;

    %create key matrix
    tempkey = [];
    %For each channel in the desired array
    for index1=1:nchannelsCurrent
        tempval = INPUTSTRUCT.chanlocs(index1).('labels');
        %For each channel in the actual array
        for index2=1:nchannelsIdeal
            %Compare channel labels
            if (strcmpi(desiredarray(index2), tempval) == 1)
                tempkey(end+1) = index2;
            end
        end
    end   
    %Clear data
    for index1=1:nchannelsCurrent
        INPUTSTRUCT.chanlocs(index1).('labels') = '';
        if (isfield(INPUTSTRUCT,'erpname')) % ERP structure
            INPUTSTRUCT.bindata(index1,:) = 0;
            INPUTSTRUCT.binerror(index1,:) = 0;
        else
            INPUTSTRUCT.data(index1,:) = 0;
        end
    end
    if (isfield(INPUTSTRUCT,'erpname')) % ERP structure
        [rEnd, cEnd] = size(TEMPTSTRUCT.bindata);
    else
        [rEnd, cEnd] = size(TEMPTSTRUCT.data);
    end

    for index1=1:nchannelsCurrent
        index2 = tempkey(index1);
        INPUTSTRUCT.chanlocs(index2).('labels') = TEMPTSTRUCT.chanlocs(index1).('labels');
        INPUTSTRUCT.chanlocs(index2).('ref') = TEMPTSTRUCT.chanlocs(index1).('ref');  

        if (isfield(INPUTSTRUCT,'erpname')) % ERP structure
            for c = 1:cEnd
                INPUTSTRUCT.bindata(index2,c) = TEMPTSTRUCT.bindata(index1,c);
                INPUTSTRUCT.binerror(index2,c) = TEMPTSTRUCT.binerror(index1,c);
            end
        else
            for c = 1:cEnd
                INPUTSTRUCT.data(index2,c) = TEMPTSTRUCT.data(index1,c);
            end
        end
    end  

%     else
%         fprintf('\nThe number of channels included in the requested array is different from the channels in the EEG file.\n')
%         error('Unable to reorder the array. Please check that the requested ordering includes all channels in the EEG file.')
%     end
end