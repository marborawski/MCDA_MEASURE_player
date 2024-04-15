function [m]=VMCM(E,W,PrefDirection)
%VMCM function
% E             - data table, the columns are the criteria and the rows are the alternatives
% W             - criteria weights
% PrefDirection - criteria Preference direction (1-max;2-min)
% returns an array of measure values for decision variants

%Normalization
  n = std(E.*E);
  min_ = min(E);
	for ii=1:size(E,1)
		for jj=1:size(E,2)
      E(ii,jj) = (E(ii,jj) - min_(jj))/n(jj);
		end
	end

%Pattern and anti-pattern calculation
  pattern = quantile(E,0.75);
  antiPattern = quantile(E,0.25);
	for ii=1:length(pattern)
    if PrefDirection(ii) ~= 1
      tmp = pattern(ii);
      pattern(ii) = antiPattern(ii);
      antiPattern(ii) = tmp;
    end
  end

%Calculating the measure value
  t = pattern - antiPattern;
  d = sum(t.*t);
  m = zeros(1,size(E,1));
  for ii=1:size(E,1)
    m(ii) = sum(W.*(E(ii,:) - antiPattern).*t)/d;
	end
end
