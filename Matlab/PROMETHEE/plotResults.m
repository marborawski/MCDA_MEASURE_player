function plotResults(NoOfAlternatives,names,rankPhi,rankPhiPlus,rankPhiMinus,Phi,PhiPlus,PhiMinus)
	%generate perceptually-distinct colors
	colors=distinguishable_colors(NoOfAlternatives);
    %generate labels
    ylabels=cell(1,NoOfAlternatives);
	ticks=0:0.1:(NoOfAlternatives)/10;
    labels=NoOfAlternatives:-1:1;
    for i=1:NoOfAlternatives
        ylabels(i)=cellstr([num2str(labels(i),'%d')]);
    end
    ylabels=[{' '} ylabels {' '}];
    %Plot PhiNet (PROMETHEE II)
	%%generate figure with subplots
	figure('Position',[50 300 1000 500]);
	subplot(2,2,[3,4]);
	title('Phi_n_e_t outranking flow');
	grid on;
	grid minor;
	hold on;
    yticks(ticks);
    yticklabels(ylabels);
    ylim([0 (NoOfAlternatives+0.5)*0.1]);
    xlim([-0.3 0.4]);
    leg=zeros(NoOfAlternatives,1);
    %%show numbers
	for i=1:NoOfAlternatives
		leg(i)=plot([Phi(i) Phi(i)],[0 (NoOfAlternatives+1-rankPhi(i))*0.1],'Color',colors(i,:),'LineWidth',2);
		plot([Phi(i) Phi(i)],[0 (NoOfAlternatives+1-rankPhi(i))*0.1],'--','Color',colors(i,:),'LineWidth',2);
	end
	%%show alternative names
	for i=1:NoOfAlternatives
		text(Phi(i),(NoOfAlternatives+1-rankPhi(i))*0.1,names(i,:),'Color',colors(i,:),'BackgroundColor','none','FontWeight','bold','HorizontalAlignment','center','VerticalAlignment','bottom');
	end
	%%show legend and labels
	legend([leg(1:i)],names(1:i,:),'Location','eastoutside','Orientation','vertical');
	xlabel('\Phi_n_e_t');
	ylabel('Rank');
	%Plot PhiPlus
	subplot(2,2,1);
	title('Phi^+ outranking flow');
	grid on;
	grid minor;
	hold on;
	yticks(ticks);
    yticklabels(ylabels);
    ylim([0 (NoOfAlternatives+0.5)*0.1]);
	for i=1:NoOfAlternatives
		leg(i)=plot([PhiPlus(i) PhiPlus(i)],[0 (NoOfAlternatives+1-rankPhiPlus(i))*0.1],'Color',colors(i,:),'LineWidth',2);
		plot([PhiPlus(i) PhiPlus(i)],[0 (NoOfAlternatives+1-rankPhiPlus(i))*0.1],'--','Color',colors(i,:),'LineWidth',2);
	end
	for i=1:NoOfAlternatives
		text(PhiPlus(i),(NoOfAlternatives+1-rankPhiPlus(i))*0.1,names(i,:),'Color',colors(i,:),'BackgroundColor','none','FontWeight','bold','HorizontalAlignment','center','VerticalAlignment','bottom');  
	end
	xlabel('\Phi^+');
	ylabel('Rank');
	%Plot PhiMinus
	subplot(2,2,2);
	title('Phi^- outranking flow');
	grid on;
	grid minor;
	hold on;
	yticks(ticks);
    yticklabels(ylabels);
    ylim([0 (NoOfAlternatives+0.5)*0.1]);
	for i=1:NoOfAlternatives
		leg(i)=plot([PhiMinus(i) PhiMinus(i)],[0 (NoOfAlternatives+1-rankPhiMinus(i))*0.1],'Color',colors(i,:),'LineWidth',2);
		plot([PhiMinus(i) PhiMinus(i)],[0 (NoOfAlternatives+1-rankPhiMinus(i))*0.1],'--','Color',colors(i,:),'LineWidth',2);
	end
	for i=1:NoOfAlternatives
		text(PhiMinus(i),(NoOfAlternatives+1-rankPhiMinus(i))*0.1,names(i,:),'Color',colors(i,:),'BackgroundColor','none','FontWeight','bold','HorizontalAlignment','center','VerticalAlignment','bottom');  
	end
	xlabel('\Phi^-');
	ylabel('Rank');
end

