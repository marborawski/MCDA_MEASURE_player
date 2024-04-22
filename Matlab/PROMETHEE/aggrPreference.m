function [Phi,PhiPlus,PhiMinus,Pi]=aggrPreference(NoOfAlternatives,NoOfCriteria,P,W)
	%variable initiation
	Pi=zeros(NoOfAlternatives,NoOfAlternatives);
	PhiPlus=zeros(NoOfAlternatives,1);
	PhiMinus=zeros(NoOfAlternatives,1);
	Phi=zeros(NoOfAlternatives,1);
	%global preference degrees
	for i=1:NoOfAlternatives
		for j=1:NoOfAlternatives
			if i~=j
				for k=1:NoOfCriteria
					Pi(i,j)=Pi(i,j)+P(i,j,k)*W(k);
				end
			end
		end
	end
	%positive and negative outranking flows
	for i=1:NoOfAlternatives
		for j=1:NoOfAlternatives
			PhiPlus(i)=PhiPlus(i)+Pi(i,j)/(NoOfAlternatives-1);
			PhiMinus(i)=PhiMinus(i)+Pi(j,i)/(NoOfAlternatives-1);
		end
	end
	%net outranking flow
	for i=1:NoOfAlternatives
		Phi(i)=PhiPlus(i)-PhiMinus(i);
	end
end