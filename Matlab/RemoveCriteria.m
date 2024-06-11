function [E,W,PrefDirection, ind] = RemoveCriteria(E,W,PrefDirection)
%Removal of criteria whose values for all decision variants do not differ from each other
%
% E             - data table, the columns are the criteria and the rows are the alternatives
% W             - criteria weights
% PrefDirection - criteria Preference direction (1-max;2-min):
% ind           - criteria indexes that have not been deleted
% returns a table of data, columns are criteria and rows are alternatives

  tmp = std(E);
  ind = find(abs(tmp) >= 0.000000000000001);
  E = E(:,ind);
  W = W(ind);
  PrefDirection = PrefDirection(ind);
end