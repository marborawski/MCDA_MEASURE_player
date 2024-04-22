function plotPartialOrder(NoOfAlternatives,names,rankPhiPlus,rankPhiMinus)
    %relation matrices initiation
    PreferenceRel=zeros(NoOfAlternatives);
    IndifferenceRel=zeros(NoOfAlternatives);
    UncomparabilityRel=zeros(NoOfAlternatives);
    %relation computations
    for i=1:NoOfAlternatives
        for j=1:NoOfAlternatives
            if i~=j
                if rankPhiPlus(i)<rankPhiPlus(j) && rankPhiMinus(i)<rankPhiMinus(j) || ...
                   rankPhiPlus(i)==rankPhiPlus(j) && rankPhiMinus(i)<rankPhiMinus(j) || ...
                   rankPhiPlus(i)<rankPhiPlus(j) && rankPhiMinus(i)==rankPhiMinus(j)
                    PreferenceRel(i,j)=1;                
                elseif rankPhiPlus(i)==rankPhiPlus(j) && rankPhiMinus(i)==rankPhiMinus(j)
                    IndifferenceRel(i,j)=1;
                elseif rankPhiPlus(i)<rankPhiPlus(j) && rankPhiMinus(i)>rankPhiMinus(j) || ...
                       rankPhiPlus(i)>rankPhiPlus(j) && rankPhiMinus(i)<rankPhiMinus(j)
                    UncomparabilityRel(i,j)=1;
                end
            end
        end
    end
    Rank=sum(PreferenceRel)+1;
    %computate coordinates of alternatives on plot area
    coordinates=zeros(3,NoOfAlternatives);
    i=1;
    j=1;
    while min(Rank)<NoOfAlternatives+1
        alternative=find(Rank==min(Rank));
        for k=1:length(alternative)
            coordinates(:,i+j-1)=[NoOfAlternatives-j-k+1;i;alternative(k)];
            Rank(alternative(k))=NoOfAlternatives+1;
            if length(alternative)>1 && k<length(alternative)
                j=j+1;
            end
        end
        i=i+1;
    end
    coordinates2=coordinates;
    %Plot Partial Order (PROMETHEE I)
    %%generate figure
    figure;
    title('PROMETHEE I partial order');
	grid on;
	grid minor;
	hold on;
    axis([min(coordinates(2,:))-1 max(coordinates(2,:))+1 min(coordinates(1,:))-1 max(coordinates(1,:))+1]);
    xticklabels({''});
    yticklabels({''});
    %%show preference and indifference relations
    i=1;
    while min(coordinates(2,:))<NoOfAlternatives+1
        alternative=find(coordinates(2,:)==min(coordinates(2,:)));
        for j=1:length(alternative)
            l=0;
            for k=coordinates(2,alternative(j)):NoOfAlternatives
                alternative2=find(coordinates(2,:)==min(setdiff(coordinates(2,:),min(coordinates(2,:)))));
                if PreferenceRel(coordinates(3,alternative(j)),coordinates(3,k)) && l<length(alternative2)
                    hP=plot([coordinates(2,alternative(j))+0.2 coordinates(2,k)-0.2],[coordinates(1,alternative(j)) coordinates(1,k)],'-','Color','r','LineWidth',1);
                    line2arrow(hP);
                    l=l+1;
                end
                if IndifferenceRel(coordinates(3,alternative(j)),coordinates(3,k))==1 && coordinates(2,alternative(j))<=NoOfAlternatives && coordinates(2,k)<=NoOfAlternatives 
                    hI=plot([coordinates(2,alternative(j)) coordinates(2,k)],[coordinates(1,alternative(j))-0.2 coordinates(1,k)+0.2],'-.','Color','b','LineWidth',1);
                end
            end
            coordinates(2,alternative(j))=NoOfAlternatives+1;
        end
        i=i+1;
    end
    %%show alternative names and legend
    for i=1:NoOfAlternatives
        text(coordinates2(2,i),coordinates2(1,i),names(coordinates2(3,i),:),'Color','b','BackgroundColor','white','FontWeight','bold','HorizontalAlignment','center','VerticalAlignment','middle');
    end
	if sum(sum(PreferenceRel)) && sum(sum(IndifferenceRel))
		legend([hP hI],{'Preference','Indifference'},'Location','southwest','Orientation','vertical');
	elseif sum(sum(PreferenceRel))
		legend(hP,'Preference','Location','southwest','Orientation','vertical');
	elseif sum(sum(IndifferenceRel))
		legend(hI,'Indifference','Location','southwest','Orientation','vertical');
	end
end
