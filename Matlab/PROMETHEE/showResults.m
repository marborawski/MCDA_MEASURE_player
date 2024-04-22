function showResults(NoOfAlternatives,names,rankPhi,rankPhiPlus,rankPhiMinus,Phi,PhiPlus,PhiMinus)
	%results initiation
	resultsPhiNet=cell(NoOfAlternatives,3);
	resultsPhiPlus=cell(NoOfAlternatives,3);
	resultsPhiMinus=cell(NoOfAlternatives,3);
	%group all Phi Net results
	for i=1:NoOfAlternatives
		resultsPhiNet(i,:)=[names(i,:) Phi(i,:) rankPhi(i)];
	end
	%group all Phi Plus results
	for i=1:NoOfAlternatives
		resultsPhiPlus(i,:)=[names(i,:) PhiPlus(i,:) rankPhiPlus(i)];
	end
	%group all Phi Minus results
	for i=1:NoOfAlternatives
		resultsPhiMinus(i,:)=[names(i,:) PhiMinus(i,:) rankPhiMinus(i)];
	end
	%print results
	resultsPhiNet
	resultsPhiPlus
	resultsPhiMinus
end

