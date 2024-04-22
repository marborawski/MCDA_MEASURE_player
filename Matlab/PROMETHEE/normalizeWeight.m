function W=normalizeWeight(NoOfCriteria,W)
	%normalization of weights to 1 
	tmp=sum(W);
	for i=1:NoOfCriteria
		W(i)=W(i)/tmp;
	end
end