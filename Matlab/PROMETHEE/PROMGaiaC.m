function out=PROMGaiaC(NoOfCriteria,NoOfVariants,E,W,D,PrefFun,q,p,s)
% NoOfCriteria - number of criteria
% NoOfVariants - number of variants
% E - decision matrix
% W - weights vector
% Sc - sustainability/compensation coefficients vector
% D - preference direction vector
% PrefFun - preferences function vector
% q - indifference thresholds vector
% p - preference thresholds vector
% s - std deviations thresholds vector

%W=W./sum(W);
Cdiag=diag(ones(NoOfCriteria,1));
[Phi,PhiC]=PROMGaiaProm(NoOfCriteria,NoOfVariants,E,W,D,PrefFun,q,p,s);

%variance-covariance matrix
nC=PhiC'*PhiC;
%cov(PhiC)
%n=nC./cov(PhiC)

[eigvectors,~]=eig(nC);
eigvalues=eig(nC);
[lambda1,idxu]=max(eigvalues);
[lambda2,idxv]=max(eigvalues(eigvalues<lambda1));
sigma=(lambda1+lambda2)/sum(sum(eigvalues))
u=eigvectors(:,idxu);
v=eigvectors(:,idxv);
for i=1:NoOfVariants
    uA(i)=PhiC(i,:)*u;
    vA(i)=PhiC(i,:)*v;
end;

for i=1:NoOfCriteria
    uC(i)=Cdiag(i,:)*u;
    vC(i)=Cdiag(i,:)*v;
end;

%plotting
figure();%('Resize','off','Units','inches','Position', [5, 5, 6, 2]);
grid on;
grid minor;
hold on;
axis([min([uA uC W*u])-0.2 max([uA uC W*u])+0.4 min([vA vC W*v])-0.2 max([vA vC W*v])+0.2]);
colors=distinguishable_colors(NoOfVariants+NoOfCriteria);
%colors=distinguishable_colors(NoOfVariants+NoOfCriteria);
%colors=colormap(hsv(NoOfVariants+NoOfCriteria));
for i=1:NoOfVariants
    legV(i)=scatter(uA(i),vA(i),60,colors(i,:),'filled','s');
    text(uA(i),vA(i),[' \leftarrowA',num2str(i)]);
end;
for i=1:NoOfCriteria
    legC(i)=plot([0 uC(i)],[0 vC(i)],'Color',colors(NoOfVariants+i,:),'LineWidth',1);
    %legend(legC(i),['C',num2str(i)]);
end;
legC(i+1)=plot([0 W*u],[0 W*v],'Color','r','LineWidth',2);%compromise solution
for i=1:NoOfCriteria
    color=get(legC(i),'Color');
    scatter(uC(i),vC(i),20,'o','filled','MarkerEdgeColor',color,'MarkerFaceColor',color);
end;
scatter(W*u,W*v,30,'p','filled','MarkerEdgeColor','r','MarkerFaceColor','r');%compromise solution
posx=['left  ';'center';'right '];
posy=['top   ';'middle';'bottom'];
for i=1:NoOfCriteria
    color=get(legC(i),'Color');
    if uC(i)>0 && vC(i)>0 && sum(abs(uC(i)-uC(1:i-1))<0.002) && sum(abs(vC(i)-vC(1:i-1))<0.002)
        text(uC(i),vC(i),[' C',num2str(i)],'horizontalAlignment','left','verticalAlignment',posy(randi([1 2]),:),'Color',color);
    elseif uC(i)>0 && vC(i)>0
        text(uC(i),vC(i),[' C',num2str(i)],'horizontalAlignment','left','verticalAlignment','bottom','Color',color);
    elseif uC(i)>0 && vC(i)<0 && sum(abs(uC(i)-uC(1:i-1))<0.002) && sum(abs(vC(i)-vC(1:i-1))<0.002)
        text(uC(i),vC(i),[' C',num2str(i)],'horizontalAlignment','left','verticalAlignment',posy(randi([2 3]),:),'Color',color);
    elseif uC(i)>0 && vC(i)<0
        text(uC(i),vC(i),[' C',num2str(i)],'horizontalAlignment','left','verticalAlignment','top','Color',color);
    elseif uC(i)<0 && vC(i)<0 && sum(abs(uC(i)-uC(1:i-1))<0.002) && sum(abs(vC(i)-vC(1:i-1))<0.002)
        text(uC(i),vC(i),[' C',num2str(i)],'horizontalAlignment','right','verticalAlignment',posy(randi([2 3]),:),'Color',color);
    elseif uC(i)<0 && vC(i)<0
        text(uC(i),vC(i),[' C',num2str(i)],'horizontalAlignment','right','verticalAlignment','top','Color',color);
    elseif uC(i)<0 && vC(i)>0 && sum(abs(uC(i)-uC(1:i-1))<0.002) && sum(abs(vC(i)-vC(1:i-1))<0.002)
        text(uC(i),vC(i),[' C',num2str(i)],'horizontalAlignment','right','verticalAlignment',posy(randi([1 2]),:),'Color',color);
    elseif uC(i)<0 && vC(i)>0
        text(uC(i),vC(i),[' C',num2str(i)],'horizontalAlignment','right','verticalAlignment','bottom','Color',color);
    end;
end;
if W*u>0 && W*v>0%compromise solution
    text(W*u,W*v,' \Pi ','horizontalAlignment','left','verticalAlignment','bottom','Color','k');
elseif W*u>0 && W*v<0
    text(W*u,W*v,' \Pi ','horizontalAlignment','left','verticalAlignment','top','Color','k');
elseif W*u<0 && W*v<0
    text(W*u,W*v,' \Pi ','horizontalAlignment','right','verticalAlignment','top','Color','k');
elseif W*u<0 && W*v>0
    text(W*u,W*v,' \Pi ','horizontalAlignment','right','verticalAlignment','bottom','Color','k');
end;
%legend('A1','A2','A3','A4','C1','C2','C3','C4','Location','eastoutside','Orientation','vertical');