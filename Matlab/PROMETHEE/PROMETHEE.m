function [Phi,PhiPlus,PhiMinus,Pi,W,P,d]=PROMETHEE(E,W,PrefDirection)
%PROMETHEE function
	NoOfAlternatives=size(E,1);
	NoOfCriteria=size(E,2);
	PrefFun=ones(NoOfCriteria,1)*3;
    for j=1:NoOfCriteria
        stdDev(j)=std(E(:,j));
    end
    q=ones(NoOfCriteria,1)'*0;
    p=2*stdDev;
    s=stdDev;
	%if preference direction is min then multiply N by -1
	for i=1:NoOfAlternatives
		for j=1:NoOfCriteria
			if PrefDirection(j)==2
				E(i,j)=E(i,j)*-1;
			end
		end
	end
	%computation of fuzzy devation and mapping to unicriterion preference degrees
	[P,d]=mapDeviation(NoOfAlternatives,NoOfCriteria,E,PrefFun,q,p,s);
	%defuzzification of weights and normalization to 1 
	W=normalizeWeight(NoOfCriteria,W);
	%preference aggregation
	[Phi,PhiPlus,PhiMinus,Pi]=aggrPreference(NoOfAlternatives,NoOfCriteria,P,W);
	Phi=Phi';
end
