function result = NumberToName(array, names)
%Replacing numbers representing field types with their names
%
% array - a table containing information about the map
% names - map field names
% returns a table containing information about the map

  result = cell(size(array));
  for ii = 1:size(array,1)
    for jj = 1:size(array,2)
      result{ii,jj}.name = names{array(ii,jj)};
    end
  end
end