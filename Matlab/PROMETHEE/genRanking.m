function ranking=genRanking(v)
	%if vector of alternative performances is not empty
	if ~isnan(v)
		%check vector length
		n=length(v);
		%ranking initiation
		ranking=zeros(n,1);
		%index initiation
		i=1;
		%while alternatives are not ranked
		while any(v~=-Inf)
			%find alternative with max performance
			tmp=find(v==max(v));
			%if one alternative was found, give it rank i and mark it in v
			if length(tmp)==1
				ranking(tmp)=i;
				v(tmp)=-Inf;
			%if multiple alternatives were found, give them rank of i and mark them in v
			else
				for j=1:length(tmp)
					ranking(tmp(j))=i;
					v(tmp(j))=-Inf;
				end
			end
			%increase index
			i=i+length(tmp);
		end
	else
		error('Vector v is empty');
	end
end
