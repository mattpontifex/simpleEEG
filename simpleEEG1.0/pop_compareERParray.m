function [com] = pop_compareERPArray(ALLERP)

    cb_chansel1 = 'tmpchanlocs = ALLERP(1).chanlocs; [tmp tmpval] = pop_chansel({tmpchanlocs.labels}, ''withindex'', ''on'', ''selectionmode'', ''single''); set(findobj(gcbf, ''tag'', ''ChannelScale''   ), ''string'',tmpval); clear tmpchanlocs tmp tmpval';

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
 
      [ tmp1 tmp2 strhalt structout ] = inputgui( geometry, uilist, 'pophelp(''pop_compareERParray'');', 'Comparison of ERP Activity -- pop_compareERParray');
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
          com = sprintf('\n%%Equivalent command:\n compareERParray(ALLERP, ''Bin'', %d, ''ChannelScale'', ''%s'', ''Polarity'', ''%s'', ''Smooth'', ''%s'', ''guiFontSize'', %d);\n', structout.Bin, structout.ChannelScale, structout.Polarity, structout.Smooth, structout.guiFontSize);
          disp(com)
          compareERParray(ALLERP, 'Bin', structout.Bin, 'ChannelScale', structout.ChannelScale, 'Polarity', structout.Polarity, 'Smooth', structout.Smooth, 'guiFontSize', structout.guiFontSize);
      else
          com = '';
      end

end