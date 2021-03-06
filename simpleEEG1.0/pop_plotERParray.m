function [com] = pop_plotERPArray(ERP)

    % Prepare List of Current Channels in ERP.data
%     listch = cell(1,size(INERP.chanlocs,2)+1);
%     listch{1} = '';
%     for ch =1:size(INERP.chanlocs,2)
%             listch{ch+1} = [num2str(ch) ' = ' INERP.chanlocs(ch).labels ];
%     end
    cb_chansel1 = '[tmp tmpval] = pop_chansel({ERP(1).chanlocs.labels}, ''withindex'', ''on'', ''selectionmode'', ''single''); set(findobj(gcbf, ''tag'', ''ChannelScale''   ), ''string'',tmpval); clear tmp tmpval';

    g1 = [0.5 0.5 ];
    g2 = [0.3 0.2 0.1];
    s1 = [1];
    geometry = { g1 s1 g1 s1 g2 s1 g1 s1 g1 s1 s1 s1 s1 s1 };
    uilist = { ...
          { 'Style', 'text', 'string', 'ERP Bin'} ...
          { 'Style', 'edit', 'string', '1' 'tag' 'Bin' } ...
          ...
          { } ...
          ...
          { 'Style', 'text', 'string', 'Plot Polarity'  } ...
          { 'Style', 'popupmenu', 'string', 'Positive Down | Positive Up' 'tag' 'Polarity' } ...
          ...
          { } ...
          ...
          { 'Style', 'text', 'string', 'Display Axis on Channel'  } ...          
          { 'Style', 'edit', 'string', 'M1' 'tag' 'ChannelScale' } ...
          { 'Style' 'pushbutton' 'string' '...' 'callback' cb_chansel1 'tag' 'refbr' } ...
          ...
          { } ...
          ...
          { 'Style', 'text', 'string', 'Smooth Data'  } ...
          { 'Style', 'popupmenu', 'string', 'False | True' 'tag' 'Smooth' } ...
          ...
          { } ...
          ...
          { 'Style', 'text', 'string', 'Font Size' } ...
          { 'Style', 'edit', 'string', '8' 'tag' 'guiFontSize' } ...
          ...
          { } ...
          ...
          { 'Style', 'text', 'string', 'Arrow Up and Down scale the amplitude.' } ...
          ...
          { 'Style', 'text', 'string', 'Holding shift while using the up and down arrow will linearly shift' } ...
          ...
          { 'Style', 'text', 'string', 'the axis up or down.' } ...
          ...
          { } ...
          ...
      };
 
      [ tmp1 tmp2 strhalt structout ] = inputgui( geometry, uilist, 'pophelp(''pop_plotERParray'');', 'Plot ERP Activity -- pop_plotERParray');
      if ~isempty(structout)
          structout.Bin = str2num(structout.Bin);
          structout.guiFontSize = str2num(structout.guiFontSize);
          if (structout.Polarity == 1)
              structout.Polarity = 'Positive Down';
          else
              structout.Polarity = 'Positive Up';
          end
          if (structout.Smooth == 1)
              structout.Smooth = 'False';
          else
              structout.Smooth = 'True';
          end
          com = sprintf('\n%%Equivalent command:\n plotERParray(ERP, ''Bin'', %d, ''ChannelScale'', ''%s'', ''Polarity'', ''%s'', ''Smooth'', ''%s'', ''guiFontSize'', %d);\n',structout.Bin, structout.ChannelScale, structout.Polarity, structout.Smooth, structout.guiFontSize);
          disp(com)
          plotERParray(ERP, 'Bin', structout.Bin, 'ChannelScale', structout.ChannelScale, 'Polarity', structout.Polarity, 'Smooth', structout.Smooth, 'guiFontSize', structout.guiFontSize);
      else
          com = '';
      end

end