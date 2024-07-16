function [S]=TOPSIS(E,W,PrefDirection,p)
%TOPIS function
%
% E             - data table, the columns are the criteria and the rows are the alternatives
% W             - criteria weights
% PrefDirection - criteria Preference direction (1-max;2-min)
% p             - coefficient
% returns an array of measure values for decision variants

%Normalization
  n = sqrt(sum(E.*E));
	for ii=1:size(E,1)
		for jj=1:size(E,2)
      E(ii,jj) = E(ii,jj)/n(jj);
		end
	end

%Weight calculation
	for ii=1:size(E,1)
		for jj=1:size(E,2)
      E(ii,jj) = E(ii,jj)*W(jj);
		end
	end

  %Pattern and anti-pattern calculation
  start = 1;
  for ii = 1:size(E,1)
    if start == 1
      vPlus = E(ii,:);
      vMinus = E(ii,:);
      start = 0;
    else
      for jj = 1:size(E,2)
        if PrefDirection(jj) == 1
          if E(ii,jj) > vPlus(jj)
            vPlus(jj) = E(ii,jj);
          end
          if E(ii,jj) < vMinus(jj)
            vMinus(jj) = E(ii,jj);
          end
        else
          if E(ii,jj) < vPlus(jj)
            vPlus(jj) = E(ii,jj);
          end
          if E(ii,jj) > vMinus(jj)
            vMinus(jj) = E(ii,jj);
          end
        end
      end
    end
  end

  %Calculating the measure value
  dPlus = zeros(1,size(E,1));
  dMinus = zeros(1,size(E,1));
  for ii = 1:size(E,1)
    dPlus(ii) = sum(abs(E(ii,:)-vPlus).^p)^(1/p);
    dMinus(ii) = sum(abs(E(ii,:)-vMinus).^p)^(1/p);
  end
  S = dMinus./(dPlus + dMinus);

end
