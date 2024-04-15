function result = ChangeBeginEnd(array)
%Marking the beginnings and ends of paths
%
% array - a table containing information about the map
% returns a table containing information about the map

  result = array;
  for ii = 1:size(array,1)
    for jj = 1:size(array,2)
      if strcmp(array{ii,jj}.name,'Begin') == 1
        result{ii,jj}.name = 'Water';
        result{ii,jj}.type = array{ii,jj}.name;
      end
      if strcmp(array{ii,jj}.name,'End') == 1
        result{ii,jj}.name = 'Water';
        result{ii,jj}.type = array{ii,jj}.name;
      end
    end
  end
end