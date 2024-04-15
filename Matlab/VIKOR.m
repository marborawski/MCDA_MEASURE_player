function [Q,S,R]=VIKOR(E,W,PrefDirection,q)
%VIKOR function
% E             - data table, the columns are the criteria and the rows are the alternatives
% W             - criteria weights
% PrefDirection - criteria Preference direction (1-max;2-min)
% q             - coefficient
% returns an array of measure values for decision variants

%Normalization
  start = 1;
	for ii=1:size(E,1)
    if start == 1
      xL = E(ii,:);
      xP = E(ii,:);
      start = 0;
    else
      for jj=1:size(E,2)
        if PrefDirection(jj) == 1
          if E(ii,jj) > xP(jj)
            xP(jj) = E(ii,jj);
          end
          if E(ii,jj) < xL(jj)
            xL(jj) = E(ii,jj);
          end
        else
          if E(ii,jj) < xP(jj)
            xP(jj) = E(ii,jj);
          end
          if E(ii,jj) > xL(jj)
            xL(jj) = E(ii,jj);
          end          
        end
      end
    end
	end
	for ii=1:size(E,1)
		for jj=1:size(E,2)
      E(ii,jj) = (E(ii,jj) - xL(jj))/(xP(jj) - xL(jj));
		end
	end

%Weight calculation
	for ii=1:size(E,1)
		for jj=1:size(E,2)
      E_(ii,jj) = E(ii,jj)*W(jj);
		end
	end

%Calculating the measure value
  S = sum(E_');
  R = max(E_');
  Q = q*((S - min(S))/(max(S) - min(S))) + (1 - q)*((R - min(R))/(max(R) - min(R)))
    
end
