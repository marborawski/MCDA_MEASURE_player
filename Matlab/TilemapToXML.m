function txt = TilemapToXML(tilemap)
%Map conversion from an array of numbers to xml format
%
% tilemap - map in the form of an array of numbers
% returns a map saved in xml format

  txt = sprintf('\t<Table>');
  for ii = 1:size(tilemap,1)
    txt = [txt sprintf('\t\t<Row>')];
    for jj = 1:size(tilemap,2)
      txt = [txt sprintf('\t\t\t<Cell>')];
      txt = [txt sprintf('<Data')];       
      if isfield(tilemap{ii,jj},'type')
       txt = [txt sprintf(' type="%s"',tilemap{ii,jj}.type)];     
      end
      txt = [txt sprintf('>')];       
      txt = [txt sprintf('%s',tilemap{ii,jj}.name)];      
      txt = [txt sprintf('</Data>')];
      txt = [txt sprintf('</Cell>')];
    end
    txt = [txt sprintf('\t\t</Row>')];
  end
  txt = [txt sprintf('\t</Table>')];

end