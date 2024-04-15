function [E,W,PrefDirection] = RemoveCriteria(E,W,PrefDirection)
%Removal of criteria whose values for all decision variants do not differ from each other
%
% E             - data table, the columns are the criteria and the rows are the alternatives
% W             - criteria weights
% PrefDirection - criteria Preference direction (1-max;2-min):
% returns a table of data, columns are criteria and rows are alternatives

  tmp = std(E);
  p = find(abs(tmp) >= 0.000000000000001);
  E = E(:,p);
  W = W(p);
  PrefDirection = PrefDirection(p);
end