function res = GetVectorFromCell(data, field)
%Reading a data vector from a selected field of the structure array
%
% data - structure array
% data - read structure fields
% returns a data vector

  res = [];
  for ii = 1:length(data)
    res = [res getfield(data{ii},field)];
  end
end