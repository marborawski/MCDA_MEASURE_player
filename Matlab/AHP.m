function [m]=AHP(E,W,PrefDirection,max_)
%AHP function
%
% E             - data table, the columns are the criteria and the rows are the alternatives
% W             - criteria weights
% PrefDirection - criteria Preference direction (1-max;2-min)
% max_          - the maximum value by which one decision variant can be better than the fringe one
% returns an array of measure values for decision variants

%Determining how much some decision variants are better than others
  for ii = 1:size(E,2)
    C{ii} = zeros(size(E,1),size(E,1));
    for jj = 1:size(C{ii},1)
      for k = 1:size(C{ii},1)
        if E(jj,ii) == E(k,ii)
          C{ii}(jj,k) = 1;
        else
          if PrefDirection(ii) == 1
            C{ii}(jj,k) = E(jj,ii)/E(k,ii);
          else
            C{ii}(jj,k) = E(k,ii)/E(jj,ii);
          end
          if C{ii}(jj,k) > max_
            C{ii}(jj,k) = max_;
          end
          if C{ii}(jj,k) < 1/max_
            C{ii}(jj,k) = 1/max_;
          end
        end
      end    
    end
  end

% Calculating eigenvalues and vectors
  for ii = 1:length(C)
    [a,b] = eig(C{ii});
    b = diag(b);
    p = find(imag(b) >= 0.00000001);
    b(p) = -inf;
    [~,ind] = max(b);
    W = a(:,ind);
    W = W/sum(W);
    C{ii} = W;
  end
  
 % Calculating the measure value
  m = zeros(1,size(E,1));
  for ii = 1:length(m)
    for jj = 1:length(C)
      m(ii) = m(ii) + C{jj}(ii)*W(jj);
    end
  end

end
